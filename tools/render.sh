#!/usr/bin/env bash
# tools/render.sh <file.scad> [-D ...]
# Renders multi-angle PNG views of OpenSCAD designs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <file.scad> [-D ...]" >&2
    exit 1
fi

INPUT_SCAD="$1"
shift
EXTRA_ARGS=("$@")

if [ ! -f "$INPUT_SCAD" ]; then
    echo "Error: file '$INPUT_SCAD' not found" >&2
    exit 1
fi

SCAD_DIR="$(cd "$(dirname "$INPUT_SCAD")" && pwd)"
SCAD_BASE="$(basename "$INPUT_SCAD" .scad)"
OUT_DIR="${SCAD_DIR}/out"
mkdir -p "$OUT_DIR"

RENDER_LOG="${OUT_DIR}/render.log"
: > "$RENDER_LOG"

render_view() {
    local view_name="$1"
    local cam_rot="$2"
    local proj="$3"
    local out_png="${OUT_DIR}/${SCAD_BASE}_${view_name}.png"
    local is_section="${4:-false}"

    local cmd=(
        "$OPENSCAD"
        --render
        --backend=manifold
        --imgsize=1200,900
        --colorscheme=Cornfield
        --camera="0,0,0,${cam_rot},0"
        --projection="$proj"
        --viewall
        --autocenter
    )

    if [ "$is_section" = "true" ]; then
        cmd+=(-D "section=true")
    fi

    if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
        cmd+=("${EXTRA_ARGS[@]}")
    fi

    cmd+=(-o "$out_png" "$INPUT_SCAD")

    # Run OpenSCAD; on display/GL failure retry under xvfb-run
    if ! "${cmd[@]}" >> "$RENDER_LOG" 2>&1; then
        echo "Direct render failed for view ${view_name}, retrying with xvfb-run..." >> "$RENDER_LOG"
        xvfb-run -a "${cmd[@]}" >> "$RENDER_LOG" 2>&1
    fi
}

# Verified camera rotation angles (rx,ry,rz):
# iso: 55,0,25 (perspective)
# back-iso: 55,0,205 (perspective)
# front: 90,0,0 (orthographic)
# right: 90,0,90 (orthographic)
# top: 0,0,0 (orthographic)
# bottom: 180,0,0 (orthographic)

render_view "iso" "55,0,25" "p"
render_view "back-iso" "55,0,205" "p"
render_view "front" "90,0,0" "o"
render_view "right" "90,0,90" "o"
render_view "top" "0,0,0" "o"
render_view "bottom" "180,0,0" "o"

# Section views if file declares 'section' parameter
if grep -E '^\s*section\s*=' "$INPUT_SCAD" >/dev/null 2>&1; then
    render_view "section_iso" "55,0,25" "p" "true"
    render_view "section_front" "90,0,0" "o" "true"
fi

echo "Render complete for ${SCAD_BASE}: views saved to ${OUT_DIR}/"
