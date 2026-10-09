#!/usr/bin/env bash
# tools/env.sh: exports OPENSCADPATH and OpenSCAD binary path

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export OPENSCADPATH="${REPO_ROOT}/lib"

# Ensure user local bin and git-core are in PATH
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "/usr/lib/git-core" ] && [[ ":$PATH:" != *":/usr/lib/git-core:"* ]]; then
    export PATH="/usr/lib/git-core:$PATH"
fi

if command -v openscad >/dev/null 2>&1; then
    export OPENSCAD="$(command -v openscad)"
elif [ -x "$HOME/.local/bin/openscad" ]; then
    export OPENSCAD="$HOME/.local/bin/openscad"
elif [ -x "$HOME/opt/openscad/squashfs-root/AppRun" ]; then
    export OPENSCAD="$HOME/opt/openscad/squashfs-root/AppRun"
else
    echo "ERROR: OpenSCAD binary not found" >&2
    exit 1
fi
