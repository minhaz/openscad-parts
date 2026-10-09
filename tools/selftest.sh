#!/usr/bin/env bash
# tools/selftest.sh
# Verifies toolchain against tests/golden.scad and compares bounding box to expected dimensions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [ -f "${SCRIPT_DIR}/versions.env" ]; then
    source "${SCRIPT_DIR}/versions.env"
fi

TEST_SCAD="${REPO_ROOT}/tests/golden.scad"
SUMMARY_JSON="${REPO_ROOT}/tests/out/summary.json"

echo "=== Running check.sh on tests/golden.scad ==="
"${SCRIPT_DIR}/check.sh" "$TEST_SCAD"

echo "=== Verifying bounding box dimensions ==="
# Read expected values from golden.scad and actual size from summary.json
python3 - << EOF
import json, re, sys

# Parse expected values from tests/golden.scad
expected = {}
with open("${TEST_SCAD}", "r") as f:
    for line in f:
        m = re.match(r'^\s*expected_([xyz])\s*=\s*([0-9\.]+);', line)
        if m:
            expected[m.group(1)] = float(m.group(2))

exp_size = [expected.get('x', 30.0), expected.get('y', 20.0), expected.get('z', 10.0)]

with open("${SUMMARY_JSON}", "r") as f:
    data = json.load(f)

actual_size = data.get("geometry", {}).get("bounding_box", {}).get("size", [])

print(f"Expected size: {exp_size}")
print(f"Actual size:   {actual_size}")

if len(actual_size) != 3:
    print(f"Error: Invalid actual bounding box size: {actual_size}", file=sys.stderr)
    sys.exit(1)

for axis, (exp, act) in zip(["X", "Y", "Z"], zip(exp_size, actual_size)):
    diff = abs(exp - act)
    if diff > 0.1:
        print(f"Error: {axis} dimension mismatch! Expected {exp}, got {act} (diff {diff})", file=sys.stderr)
        sys.exit(1)

print("Bounding box matches expected values within 0.1mm tolerance.")
EOF

echo "=== Toolchain Details ==="
scad_version=$("$OPENSCAD" --version 2>&1)
echo "OpenSCAD:         ${scad_version}"
if [ -d "${REPO_ROOT}/lib/BOSL2/.git" ]; then
    echo "BOSL2 Commit:     $(git -C "${REPO_ROOT}/lib/BOSL2" rev-parse HEAD)"
elif [ -n "${BOSL2_COMMIT:-}" ]; then
    echo "BOSL2 Commit:     ${BOSL2_COMMIT}"
fi

echo "=== selftest.sh PASSED ==="
