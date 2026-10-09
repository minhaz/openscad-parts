#!/usr/bin/env bash
# tools/export.sh <file.scad> [-D ...]
# Exports binary STL and 3MF files, plus summary JSON with bounding box.
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

EXPORT_LOG="${OUT_DIR}/export.log"
: > "$EXPORT_LOG"

export_target() {
    local target_name="$1"     # e.g., "" (single file) or "partname" or "print"
    local part_arg="$2"        # e.g., "" or "part=\"partname\""
    local stl_file
    local m3mf_file
    local summary_file

    if [ -z "$target_name" ]; then
        stl_file="${OUT_DIR}/${SCAD_BASE}.stl"
        m3mf_file="${OUT_DIR}/${SCAD_BASE}.3mf"
        summary_file="${OUT_DIR}/summary.json"
    else
        stl_file="${OUT_DIR}/${SCAD_BASE}-${target_name}.stl"
        m3mf_file="${OUT_DIR}/${SCAD_BASE}-${target_name}.3mf"
        summary_file="${OUT_DIR}/summary_${target_name}.json"
    fi

    local stl_cmd=(
        "$OPENSCAD"
        --export-format binstl
        --backend=manifold
        --summary all
        --summary-file "$summary_file"
    )

    if [ -n "$part_arg" ]; then
        stl_cmd+=(-D "$part_arg")
    fi

    if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
        stl_cmd+=("${EXTRA_ARGS[@]}")
    fi

    stl_cmd+=(-o "$stl_file" "$INPUT_SCAD")

    echo "Exporting STL: $(basename "$stl_file")" >> "$EXPORT_LOG"
    "${stl_cmd[@]}" >> "$EXPORT_LOG" 2>&1

    local m3mf_cmd=(
        "$OPENSCAD"
        --backend=manifold
    )

    if [ -n "$part_arg" ]; then
        m3mf_cmd+=(-D "$part_arg")
    fi

    if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
        m3mf_cmd+=("${EXTRA_ARGS[@]}")
    fi

    m3mf_cmd+=(-o "$m3mf_file" "$INPUT_SCAD")

    echo "Exporting 3MF: $(basename "$m3mf_file")" >> "$EXPORT_LOG"
    "${m3mf_cmd[@]}" >> "$EXPORT_LOG" 2>&1

    # Keep a main summary.json pointer
    if [ "$target_name" = "print" ] || [ ! -f "${OUT_DIR}/summary.json" ]; then
        cp "$summary_file" "${OUT_DIR}/summary.json"
    fi
}

# Check if model has a 'part' parameter
# Pattern e.g.: part = "assembly"; // [assembly, print, body, lid]
part_line=$(grep -E '^\s*part\s*=' "$INPUT_SCAD" || true)

if [ -n "$part_line" ] && [[ "$part_line" =~ \[([a-zA-Z0-9_, -]+)\] ]]; then
    raw_parts="${BASH_REMATCH[1]}"
    IFS=',' read -ra PARTS_ARRAY <<< "$raw_parts"
    has_print=false
    printable_parts=()

    for p in "${PARTS_ARRAY[@]}"; do
        trimmed=$(echo "$p" | tr -d '[:space:]')
        if [ "$trimmed" = "assembly" ]; then
            continue
        elif [ "$trimmed" = "print" ]; then
            has_print=true
        elif [ -n "$trimmed" ]; then
            printable_parts+=("$trimmed")
        fi
    done

    # Export each individual printable part
    for p in "${printable_parts[@]}"; do
        export_target "$p" "part=\"$p\""
    done

    # Export print layout
    if [ "$has_print" = true ]; then
        export_target "print" "part=\"print\""
    fi
else
    # Single part export
    export_target "" ""
fi

echo "Export complete for ${SCAD_BASE}: artifacts saved to ${OUT_DIR}/"
