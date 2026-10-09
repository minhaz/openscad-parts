#!/usr/bin/env bash
# tools/new-design.sh <name>
# Scaffolds a new design folder designs/<name>/ with spec.md, log.md, ref/, ref/private/, and out/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <design-name>" >&2
    exit 1
fi

DESIGN_NAME="$1"
DESIGN_DIR="${REPO_ROOT}/designs/${DESIGN_NAME}"

if [ -d "$DESIGN_DIR" ]; then
    echo "Error: design directory '${DESIGN_DIR}' already exists" >&2
    exit 1
fi

mkdir -p "${DESIGN_DIR}/ref/private"
mkdir -p "${DESIGN_DIR}/out"

cat << EOF > "${DESIGN_DIR}/spec.md"
# ${DESIGN_NAME} spec
Status: DRAFT

## Purpose

## Real objects and interfaces
| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
|---|---|---|---|---|

## Overall geometry

## Parameters (exposed)
| Name | Default | Range | Unit | Note |
|---|---|---|---|---|

## Mounting

## Material and environment

## Print orientation and supports

## Assumptions (things not stated by user)

## Out of scope
EOF

cat << EOF > "${DESIGN_DIR}/log.md"
# ${DESIGN_NAME} log

## Iteration Log
EOF

echo "Scaffolded new design at: designs/${DESIGN_NAME}/"
echo "Next step: interview user, populate spec.md, and get approval before creating ${DESIGN_NAME}.scad."
