# OpenSCAD + AI Agent Workflow Guide

Location in repo: `docs/GUIDE.md`. Agent instructions: `AGENTS.md` (repo root).

---

## 1. Overview & Architecture

This repository is a reusable library of parametric OpenSCAD designs for functional FDM 3D printing. It is designed to work interactively with AI coding assistants (such as Antigravity or Claude Code).

### The Pipeline
1. **You**: Define requirements, measure real-world objects with calipers, provide sketches/photos.
2. **Agent**: Interviews you, drafts `spec.md`, and requests approval.
3. **Agent**: Writes parametric OpenSCAD (`.scad`), renders multi-angle PNG views + section cuts, and checks dimensions/warnings.
4. **You**: Inspect model live in the Windows OpenSCAD GUI (which auto-reloads on every save). Give feedback.
5. **Agent**: Exports final binary STL + 3MF, and drafts `print-notes.md`.
6. **You**: Slice in Bambu Studio, print, test physical fit, and report back.
7. **Agent**: Adjusts clearances, logs results, and updates shared libraries in `lib/common/`.

### Architecture: Dual Windows + WSL Setup

| Component | Environment | Role |
|---|---|---|
| **WSL2 (`Ubuntu`)** | Windows 11 | Hosts repository, runs AI agents, bash toolchain, headless OpenSCAD rendering |
| **OpenSCAD dev snapshot** | WSL | Headless multi-angle PNG rendering and STL/3MF export using Manifold backend |
| **OpenSCAD dev snapshot** | Windows | Visual GUI viewer with Automatic Reload and Customizer panel |
| **BOSL2** | `lib/BOSL2` submodule | Library for rounded primitives, attachments, chamfers, and threads |
| **AI Agents** | WSL / IDE | Pair programming (Claude Code / Antigravity) reading `AGENTS.md` |
| **Bambu Studio** | Windows | Slicing and sending prints to printer |

> **Why development snapshots?** OpenSCAD development snapshots include the **Manifold** geometry engine (orders of magnitude faster renders), headless PNG rendering, and full BOSL2 compatibility.

---

## 2. Setup & Installation (One-Time)

Follow these steps when cloning or setting up this repository on a new machine.

### Step 1: Clone the Repository with Submodules
Clone the repo and its submodules (including `lib/BOSL2`):
```bash
git clone --recurse-submodules <repo-url>
cd openscad-parts
```
*If you already cloned without `--recurse-submodules`, initialize them with:*
```bash
git submodule update --init --recursive
```

### Step 2: Configure WSL & Install Packages
1. **WSL Mount Permissions**: To ensure bash scripts in the repository have execution permissions and git filemodes remain stable across the Windows drive, ensure `/etc/wsl.conf` has the metadata option:
   ```bash
   cat /etc/wsl.conf
   ```
   If there is no `[automount]` section, append:
   ```ini
   [automount]
   options = "metadata,umask=22,fmask=11"
   ```
   If you modified `/etc/wsl.conf`, restart WSL from PowerShell with `wsl --shutdown`, then reopen WSL.

2. **Install Required Packages**:
   In WSL:
   ```bash
   sudo apt update
   sudo apt install -y git python3 xvfb curl
   ```

### Step 3: Install OpenSCAD Dev Snapshot in WSL (Headless Toolchain)
Download and extract the matching development snapshot AppImage in WSL (matches snapshot date in `tools/versions.env`, e.g., `2026.10.05`):
```bash
mkdir -p ~/opt/openscad ~/.local/bin
cd ~/opt/openscad

# Download matching snapshot from https://files.openscad.org/snapshots/
# (Replace <SNAPSHOT-DATE> with date from tools/versions.env, e.g. 2026.10.05)
curl -fLO https://files.openscad.org/snapshots/OpenSCAD-<SNAPSHOT-DATE>-x86_64.AppImage
chmod +x OpenSCAD-*.AppImage
./OpenSCAD-*.AppImage --appimage-extract
ln -sf ~/opt/openscad/squashfs-root/AppRun ~/.local/bin/openscad
```
Verify the installation:
```bash
openscad --version
```

### Step 4: Install OpenSCAD on Windows (Visual Viewer)
1. **Install GUI**: Download the Windows 64-bit development snapshot installer from [openscad.org/downloads.html](https://openscad.org/downloads.html) (choose the date closest to the WSL snapshot).
2. **Set Windows Library Path**: In Windows PowerShell, configure `OPENSCADPATH` so Windows OpenSCAD resolves BOSL2 and `lib/common/`:
   ```powershell
   [Environment]::SetEnvironmentVariable("OPENSCADPATH", "<windows-repo-path>\lib", "User")
   ```
   *(Replace `<windows-repo-path>` with the absolute Windows path to the repo, e.g., `C:\path\to\openscad-parts`).*
   Restart OpenSCAD and your terminals to pick up the new variable.
3. **Configure Windows OpenSCAD GUI**:
   - Check **Design > Automatic Reload and Preview** (OpenSCAD will automatically re-render the view whenever the AI agent edits and saves a file).
   - Open **Preferences > Advanced > 3D View**, set backend to **Manifold**.
   - Open **Window > Customizer** to view and test exposed model parameters.

### Step 5: Verify the Toolchain
1. **WSL Self-Test**: Run the test script in WSL:
   ```bash
   bash tools/selftest.sh
   ```
   This tests headless rendering, BOSL2 imports, and bounding box validation against `tests/golden.scad`. It should report `selftest.sh PASSED`.
2. **Windows GUI Test**: Open `<windows-repo-path>\tests\golden.scad` in Windows OpenSCAD. It should render a 30 x 20 x 10 mm rounded box without errors.

### Step 6: Configure Your AI Coding Agent
Run your agent in WSL within the repository root:
- **Claude Code**: Run `claude` from the repository root in WSL. It automatically reads `CLAUDE.md` and imports `AGENTS.md`.
- **Antigravity**: Open the repository folder in WSL mode. Antigravity automatically reads `AGENTS.md`.

---

## 3. Tolerance Calibration (`designs/tolerance-coupon`)

Before modeling tight-tolerance parts with a new filament brand, material (PLA / PETG), or nozzle size, measure your printer's real clearances using `designs/tolerance-coupon`:

1. Export or open `designs/tolerance-coupon/out/tolerance-coupon-print.3mf` (or ask the agent: `Read AGENTS.md. Calibrate tolerances using designs/tolerance-coupon (section 12).`).
2. Print all 4 parts (`key`, `slot-block`, `pin`, `hole-plate`) in Bambu Studio using standard settings (0.20 mm layer height, 3 wall loops).
3. Measure with digital calipers:
   - Printed `key` thickness at 3 points (record max).
   - Printed `pin` diameter at 3 points (record max).
4. Test fits into each numbered slot ("0" to "6") and hole ("0" to "6"), and rate each: `press`, `snug`, `slide`, `free`, or `does-not-fit`.
5. Report the results to the agent. The agent logs the results in `designs/tolerance-coupon/log.md` and updates `lib/common/tolerances.scad` with measured clearance values.

> **Note on fit geometry**: `tolerances.scad` measures short, rigid vertical holes and slots. For designs with long sliding slots, tall walls where part tilt can bind, or entry over fillets/ramps, use a design-specific `gauge` or `test-slice` (see Section 4.4) to dial in clearance before printing the full part.

---

## 4. Running a Design Session

### 4.1 Scaffold & Prepare References
1. Scaffold the design directory (`new-design.sh` is idempotent and safe to run before or after adding reference files):
   ```bash
   ./tools/new-design.sh <name>
   ```
2. Sketch the part or write notes and measure physical mating objects with digital calipers (measure at 3 points, take max).
3. Put sketches, notes, or photos in `designs/<name>/ref/` (or `designs/<name>/ref/private/` for files you want kept gitignored).

### 4.2 Start the Interview
Start your agent session:
```text
Read AGENTS.md. New design: <name>. Refs in designs/<name>/ref/. Interview me.
```

### 4.3 Interview & Spec
- Answer the agent's questions (wall thickness, clearances, mounting methods, print constraints).
- For large prints (>100 g / >2 hours) or custom sliding/tilting fits, ask for or approve `test-slice` and/or stepped `gauge` modes under the `part` parameter.
- Review `designs/<name>/spec.md`. Ensure dimensions, fit classes, and assumptions match your intent.
- Approve the spec explicitly ("Spec approved").

### 4.4 Build & Iterate
- Keep `<windows-repo-path>\designs\<name>\<name>.scad` open in Windows OpenSCAD.
- Every time the agent updates the code, OpenSCAD automatically reloads and renders, while the agent runs `tools/check.sh` (rendering PNG views and checking geometry/assertions without waiting on full multi-part STL/3MF exports).
- Give concise feedback referring to views by name (`iso`, `back-iso`, `front`, `right`, `top`, `bottom`, `section_iso`, `section_front`) and specify dimension adjustments.
- **Customizer tip**: OpenSCAD's Customizer panel cannot edit vector parameters with more than 4 elements (`[a, b, c, d]`). Edit longer lists directly in the `.scad` file.
- Approve iterations explicitly once satisfied.

### 4.5 Export, Test Prints & Full Slicing
- Prompt: `Export.`
- The agent runs `tools/export.sh`, exporting binary `.stl`, `.3mf`, and `summary_<part>.json` files for all printable `part` modes to `designs/<name>/out/` and generating `print-notes.md`.
- Open `<windows-repo-path>\designs\<name>\out\` in Explorer and drag the `.3mf` or `.stl` files into Bambu Studio.
- If the design includes a `gauge` or `test-slice`, print and test those first, report fit results to the agent to refine clearances, and then print the full part.

---

## 5. Bambu Studio Slicing Guidelines

### Import & Layout
- Drag `.3mf` or `.stl` onto the plate. If prompted, load geometry only.
- Parts are modeled in their intended print orientation (bed face at $Z=0$).
- If multiple parts or gauge bars are in a single file (`print` or `gauge` layout), right-click $\rightarrow$ **Split to objects** for independent positioning.

### Process Settings for Functional Parts (0.4 mm Nozzle)
Start with the standard **0.20 mm Standard** profile:

| Setting | Location (Process tab) | Recommended Value |
|---|---|---|
| Wall generator | Quality > Walls | **Arachne** (handles thin/tapered walls cleanly) |
| Wall loops | Strength > Walls | **3** (use **4** for structural brackets, or **5–6** so 4–4.5 mm divider walls print solid) |
| Top / bottom shell layers | Strength > Top/bottom shells | **5 top / 4 bottom** |
| Sparse infill density | Strength > Infill | **15–25%** |
| Sparse infill pattern | Strength > Infill | **Gyroid** |
| Ironing | Quality > Ironing | **Off** (or **Top surfaces** for smooth sliding ramps/slot floors) |
| Supports | Support | **Off** (parts are designed to print support-free) |
| Brim | Others > Bed adhesion | **Off** (turn on 5 mm only for tall/narrow parts) |
| Elephant foot compensation | Quality > Precision | Default (~0.15 mm) |
| X-Y hole compensation | Quality > Precision | **0** (tolerances are built into CAD models) |

---

## 6. Maintenance & Updates

- **Upgrading OpenSCAD snapshot or BOSL2**: Upgrade deliberately between projects.
  Prompt: `Upgrade OpenSCAD snapshot and BOSL2 to latest. Run selftest and re-check all designs. Report diffs.`
  Then install the matching snapshot on Windows.
- **Filament calibration**: Re-run the tolerance coupon whenever switching filament brands, nozzle sizes, or slicer flow profiles.

---

## 7. Troubleshooting

| Symptom | Likely Cause | Solution |
|---|---|---|
| `Can't open include file BOSL2/std.scad` in Windows GUI | `OPENSCADPATH` not set or OpenSCAD not restarted | Check path in Windows environment variables (Step 4), restart OpenSCAD |
| Same error in WSL bash | `tools/env.sh` not sourced | Run scripts via `tools/*.sh` rather than raw `openscad` |
| Windows GUI does not auto-reload | Auto-reload option disabled | Enable **Design > Automatic Reload and Preview**; press `F5` |
| Vector parameter missing or greyed out in Customizer | OpenSCAD Customizer limit on vectors with $>4$ items | Edit vectors with more than 4 elements directly in the `.scad` file |
| `Permission denied` running `tools/*.sh` in WSL | Windows mount lacking `metadata` option | Check `/etc/wsl.conf` (Step 2), restart with `wsl --shutdown`; or run `bash tools/<script>.sh` |
| `git status` shows file permission changes | File mode noise on `/mnt/c` | Confirm `metadata` in `/etc/wsl.conf`; run `git config core.fileMode false` if needed |
| Agent runs PowerShell or cannot find `openscad` | IDE opened repository in Windows mode, or sandbox blocks `~/opt` | Reopen repository in WSL mode; allow unsandboxed execution if `~/opt/openscad` is outside workspace |
| PNG export fails in WSL with GL/display error | Missing headless X11 display | `render.sh` automatically retries with `xvfb-run -a`; ensure `xvfb` is installed (`sudo apt install xvfb`) |
| Render is very slow | OpenSCAD not using Manifold backend | Ensure `--backend=manifold` is active; check for heavy `minkowski()` or excessive `$fn` |
| Submodule folder `lib/BOSL2` is empty | Cloned without submodules | Run `git submodule update --init --recursive` |
| Part fits too tight or too loose | Printer/filament or long-wall geometry differs from coupon | Run `tolerance-coupon` for filament baseline, or print a design-specific `gauge` / `test-slice` |

---

## 8. Publishing Models

- **MakerWorld (Parametric Model Maker)**: Requires a single self-contained `.scad` file; local includes cannot be resolved, but MakerWorld supports BOSL2. Future bundling scripts can inline `lib/common/` while preserving BOSL2 includes.
- **Printables**: Upload STL/3MF files alongside `.scad`; multi-file projects can be zipped.
- **Licensing**: Models and original code in this repository are licensed under [CC BY-NC 4.0](../LICENSE). BOSL2 maintains its own BSD-2-Clause license.