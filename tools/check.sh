#!/usr/bin/env bash
# tools/check.sh <file.scad> [-D ...]
# Runs render + export, checks for warnings/errors, and prints key dimensions and bounding box.
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
OUT_DIR="${SCAD_DIR}/out"

echo "=== Running render.sh ==="
"${SCRIPT_DIR}/render.sh" "$INPUT_SCAD" "${EXTRA_ARGS[@]}"

echo "=== Running export.sh ==="
"${SCRIPT_DIR}/export.sh" "$INPUT_SCAD" "${EXTRA_ARGS[@]}"

echo "=== Scan logs for warnings and errors ==="
RENDER_LOG="${OUT_DIR}/render.log"
EXPORT_LOG="${OUT_DIR}/export.log"

FOUND_ISSUES=false
issue_lines=""

# Match diagnostic warnings, errors, deprecations, manifold errors, assertion failures
# Exclude informational command-line echoes and clean manifold status lines
for logfile in "$RENDER_LOG" "$EXPORT_LOG"; do
    if [ -f "$logfile" ]; then
        matches=$(grep -iE 'warning|error|deprecated|manifold|assert' "$logfile" | \
            grep -v -- '--backend=manifold' | \
            grep -v -E 'Status:\s+NoError' | \
            grep -v -E 'Top level object is a 3D object \(manifold\)' || true)
        if [ -n "$matches" ]; then
            FOUND_ISSUES=true
            issue_lines+="$(printf "\nIn %s:\n%s\n" "$logfile" "$matches")"
        fi
    fi
done

if [ "$FOUND_ISSUES" = true ]; then
    echo "FAILED: Warnings or errors found in output logs:"
    echo "$issue_lines"
else
    echo "Log scan clean: 0 warnings, 0 errors"
fi

echo "=== REPORT echo values ==="
for logfile in "$RENDER_LOG" "$EXPORT_LOG"; do
    if [ -f "$logfile" ]; then
        grep -E 'REPORT ' "$logfile" | sed -E 's/.*"REPORT (.*)".*/REPORT \1/' | sort -u || true
    fi
done

echo "=== Geometry Summary ==="
SUMMARY_JSON="${OUT_DIR}/summary.json"
if [ -f "$SUMMARY_JSON" ]; then
    python3 - << EOF
import json, sys

try:
    with open("${SUMMARY_JSON}", "r") as f:
        data = json.load(f)
    geo = data.get("geometry", {})
    bbox = geo.get("bounding_box", {})
    size = bbox.get("size", "N/A")
    min_pt = bbox.get("min", "N/A")
    max_pt = bbox.get("max", "N/A")
    t = data.get("time", {}).get("time", "N/A")
    print(f"Bounding box size (x, y, z): {size}")
    print(f"Bounding box min: {min_pt}  max: {max_pt}")
    print(f"Render time: {t}")
except Exception as e:
    print(f"Error reading summary JSON: {e}", file=sys.stderr)
EOF
else
    echo "Warning: ${SUMMARY_JSON} not found"
fi

if [ "$FOUND_ISSUES" = true ]; then
    exit 1
fi

echo "=== check.sh PASSED ==="
