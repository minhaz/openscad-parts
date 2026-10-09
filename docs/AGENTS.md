# AGENTS.md

Instructions for AI coding agents (Claude Code, Antigravity) working in this repo.
Read fully at session start. Follow exactly. When a rule conflicts with a user instruction in the current session, follow the user and note the conflict.

## 1. Purpose

Repo is a reusable library of parametric OpenSCAD designs for FDM printing.
- Printer: Bambu Lab P1S, 0.4 mm nozzle, build volume 256 x 256 x 256 mm. Usable: 250 x 250 x 250 mm.
- Materials: PLA, PETG. Single color.
- Part types: boxes, brackets, holders, mounts. No organic/sculpted shapes.
- Precision: functional. Snug fits matter; sub-0.1 mm precision does not.
- License: CC BY-NC 4.0 (models). Repo is public.

Your job per design: interview user, write spec, get approval, write OpenSCAD, render, self-check, iterate, export, write print notes. User slices and prints manually in Bambu Studio.

## 2. Environment

- Runs in WSL2 (distro `Ubuntu`) on Windows 11. Always run commands in the WSL bash shell. If `uname -s` is not `Linux`, stop and tell the user.
- Repo path:
  - WSL: `<wsl-repo-path>`
  - Windows: `<windows-repo-path>`
  - Repo is on the Windows filesystem on purpose: Windows OpenSCAD GUI and Bambu Studio open files natively. Consequences: file I/O and git are slower than on the Linux filesystem (acceptable for this repo size); executable bits depend on the `metadata` mount option (setup step 1 checks it). If a script lacks the exec bit, run it as `bash tools/<script>.sh`.
- Tool binaries (OpenSCAD AppImage) live on the Linux filesystem under `~/opt/`, not in the repo.
- OpenSCAD: development snapshot (AppImage, extracted), on PATH as `openscad`. Never use apt `openscad` (2021.01: no Manifold, no headless PNG).
- Geometry backend: Manifold. Pass `--backend=manifold` unless `openscad --help` shows it is default.
- Library path: `OPENSCADPATH=<repo>/lib`. Set in `tools/env.sh`; all scripts source it.
- BOSL2: git submodule at `lib/BOSL2`, pinned commit. Include as `include <BOSL2/std.scad>`.
- User views models in Windows OpenSCAD GUI (same snapshot version) with Automatic Reload and Preview on, opening files from `<windows-repo-path>\designs\...`. Windows `OPENSCADPATH` = `<windows-repo-path>\lib`. Every save you make re-renders on their screen. When referring user to a file, give the Windows path.
- PNG rendering: WSLg provides a display. If PNG export fails with GL/display errors, retry under `xvfb-run -a`. `tools/render.sh` handles this.
- Versions pinned in `tools/versions.env`. Do not upgrade OpenSCAD or BOSL2 unless user asks.

## 3. Repo layout

```
AGENTS.md                 this file
CLAUDE.md                 contains only: @AGENTS.md
README.md                 repo overview, design index, license
LICENSE                   CC BY-NC 4.0 legal code
.gitignore  .gitattributes
docs/GUIDE.md             user's guide (do not edit unless asked)
lib/BOSL2/                submodule, never edit
lib/common/               shared modules (this repo's own library)
  tolerances.scad         measured clearances per material (from tolerance coupon)
  printing.scad           printer constants, min wall, layer height, helpers
  fasteners.scad          screw holes, heat-set insert holes, countersinks
  ...                     add modules only when used by 2+ designs
tools/
  env.sh                  exports OPENSCADPATH, OPENSCAD binary path
  versions.env            OPENSCAD_SNAPSHOT=..., BOSL2_COMMIT=...
  render.sh               PNG views
  export.sh               STL + 3MF + summary
  check.sh                render + export + warning scan + dimension report
  selftest.sh             verifies toolchain against tests/golden.scad
  new-design.sh           scaffolds designs/<name>/
tests/
  golden.scad             uses BOSL2 + lib/common; fixed expected bounding box
designs/<name>/
  spec.md                 approved spec (source of truth for intent)
  <name>.scad             the model
  print-notes.md          orientation + slicer settings + fit test
  log.md                  iteration log, print results, decisions
  ref/                    sketches, photos (committed, public)
  ref/private/            gitignored; anything user does not want public
  out/                    gitignored; renders, STL, 3MF, summary.json
```

Naming: `designs/` folders and files in kebab-case. One primary `.scad` per design.

## 4. First-run setup (do once, when user asks)

Preconditions the user handles (verify, do not perform): WSL, apt packages, `gh auth`, git identity, Windows OpenSCAD install.

Steps:
1. Verify: `git --version`, `gh auth status`, `python3 --version`, `xvfb-run` present; `pwd` is the repo path in section 2; `mount | grep ' /mnt/c '` shows `metadata`; `git config core.autocrlf` is `input`. Report missing items; stop.
2. Install OpenSCAD snapshot in WSL if `openscad --version` fails or reports 2021.01:
   - List `https://files.openscad.org/snapshots/`, pick latest `OpenSCAD-YYYY.MM.DD-x86_64.AppImage`.
   - Download to `~/opt/openscad/`, `chmod +x`, run `--appimage-extract` (avoids FUSE dependency), symlink `squashfs-root/AppRun` to `~/.local/bin/openscad`.
   - Record date in `tools/versions.env`. Tell user the date so they install the matching Windows snapshot.
3. Run `openscad --help`. Confirm flags used below exist: `--backend`, `--render`, `--camera`, `--viewall`, `--autocenter`, `--projection`, `--imgsize`, `--colorscheme`, `--export-format`, `--summary`, `--summary-file`. Adapt scripts to what exists. Note differences in `tools/README` comments.
4. Scaffold layout from section 3. Create `CLAUDE.md` with single line `@AGENTS.md`. Do not create `GEMINI.md`.
5. `git submodule add https://github.com/BelfrySCAD/BOSL2.git lib/BOSL2`; pin to current HEAD commit; record in `tools/versions.env`.
6. Write `.gitignore`: `designs/*/out/`, `designs/*/ref/private/`, `*.tmp`, `__pycache__/`.
7. Write `.gitattributes`: `* text=auto eol=lf`, `*.png *.jpg *.jpeg *.stl *.3mf binary`.
8. Write `LICENSE`: CC BY-NC 4.0 legal code from `https://creativecommons.org/licenses/by-nc/4.0/legalcode.txt`. Note in README that `lib/BOSL2` keeps its own license (BSD-2-Clause).
9. Write tools (section 8). Write `tests/golden.scad`. Run `tools/selftest.sh`; must pass.
10. Write `lib/common/printing.scad` and `lib/common/tolerances.scad` with provisional defaults (section 9), marked `// PROVISIONAL`.
11. Commit: `chore: initial scaffold`. Do not push unless asked.
12. Tell user: setup done, snapshot date for Windows, next step is tolerance coupon (section 12).

## 5. Workflow per design

States: INTERVIEW -> SPEC -> (approval) -> BUILD -> ITERATE -> (approval) -> EXPORT -> PRINT NOTES -> (print) -> FEEDBACK.

### 5.1 Interview
- Start with `tools/new-design.sh <name>`.
- Read everything in `ref/` (sketch photos, measurements). Describe back what you see in the sketch in one short list; ask user to correct.
- Ask questions in batches of at most 5. Prefer specific questions with a proposed default: "Wall thickness 2.4 mm OK?".
- Cover:
  - Function: what it holds/mounts, what it attaches to, loads, how often inserted/removed.
  - Every interface with a real object: object dimension (caliper-measured), fit class (press / snug / slide / free, see section 9), axis of insertion.
  - Mounting: screws (size, head type), heat-set inserts, adhesive tape, magnets, freestanding.
  - Material (PLA/PETG) and environment (heat, sun, moisture, outdoor).
  - Envelope limits: max footprint, height, clearance around neighbors.
  - Cosmetics: edge rounding radius, chamfers, text/labels.
  - Print constraints: preferred bed face, supports allowed (default: no).
  - Which values must be user-adjustable parameters.
- Measurements: if user gives one value for an object dimension, ask whether it was measured at multiple points. Use max measured value.
- Never invent a dimension of a real object. Ask.

### 5.2 Spec
Write `designs/<name>/spec.md` using this template:

```
# <name> spec
Status: DRAFT | APPROVED (date)
## Purpose
## Real objects and interfaces
| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
## Overall geometry
## Parameters (exposed)
| Name | Default | Range | Unit | Note |
## Mounting
## Material and environment
## Print orientation and supports
## Assumptions (things not stated by user)
## Out of scope
```

- Every number in the spec has a source: user-measured, user-stated, tolerances.scad, or assumption. Assumptions go in the Assumptions section.
- Ask user to approve. Do not write `.scad` before Status is APPROVED. Commit spec on approval: `design(<name>): spec approved`.

### 5.3 Build
- Write `<name>.scad` per section 6.
- Run `tools/check.sh designs/<name>/<name>.scad`.
- Self-review (section 7) before showing user. Fix what you can; max 3 self-fix attempts per problem, then report it.

### 5.4 Iterate
- Present to user: what changed, check results (dimensions, warnings), paths of PNGs, things you could not verify. User inspects in GUI.
- One coherent change set per iteration. Re-run check after every edit.
- Append to `log.md` each iteration: date, change, reason, check result.
- Feedback mapping: user refers to views by name (iso, front, right, top, bottom, back-iso, section). Ask for a dimension when feedback is qualitative and the fix is ambiguous ("thicker" -> "by how much? propose 1.2 mm").
- If a change contradicts the approved spec, update spec.md first and note it in log.md.
- Commit after each user-approved iteration: `design(<name>): <what changed>`.

### 5.5 Export
- On user approval: `tools/export.sh` for each printable part. Produces `out/<name>[-<part>].stl` (binary) and `.3mf`, plus `out/summary.json`.
- Confirm zero warnings in export log. Confirm bounding box fits 250 x 250 x 250.

### 5.6 Print notes
Write `designs/<name>/print-notes.md`:

```
# <name> print notes
Parts: <list, count of each>
Material: PLA | PETG (reason)
Orientation: <which face on bed, as modeled: Z=0 face>
Supports: none | <where, type>
Layer height: 0.20 mm (default) | <other + reason>
Walls: <n> loops   Top/bottom: <n> layers   Infill: <n>% <pattern>
Brim: none | <width + reason>
Special: <pauses for magnets/nuts, heat-set inserts after print, etc.>
Fit test: <how to check fit, what to measure, what to report back>
```

Default settings for functional parts: 0.20 mm layers, 3 walls (4 for brackets under load), 5 top / 4 bottom layers, 15-25% gyroid infill. Deviate only with a stated reason.

### 5.7 Feedback after print
- User reports fit results ("snug slot too tight, needed force") and/or measurements.
- Adjust the clearance parameter for this design; record in log.md with the printed value and the new value.
- If the same correction applies across designs (same material, same fit class), propose an update to `lib/common/tolerances.scad`. Do not change shared values without approval.

## 6. OpenSCAD code conventions

### 6.1 File structure (in order)
```
// <name>.scad: one-line description
// Spec: spec.md   License: CC BY-NC 4.0
include <BOSL2/std.scad>
use <common/tolerances.scad>     // or include if constants are needed
include <common/printing.scad>

/* [Part] */
part = "assembly"; // [assembly, print, body, lid]

/* [Main dimensions] */
// Tablet thickness, measured (mm)
tablet_t = 7.6; // [3:0.1:15]
...

/* [Fit] */
material = "PLA"; // [PLA, PETG]
fit = "snug"; // [press, snug, slide, free]

/* [Debug] */
section = false;   // cut-away view for checking internals
section_axis = "x"; // [x, y]

/* [Hidden] */
$fa = 1; $fs = $preview ? 0.8 : 0.4;
eps = 0.01;
// derived values
clr = clearance(material, fit, "slot");
slot_w = tablet_t + clr;

// assertions
assert(slot_w > tablet_t, "slot must exceed tablet thickness");
...
echo(str("REPORT slot_w=", slot_w));

// dispatch
...
// modules
...
```

### 6.2 Rules
- Units: mm. Coordinates: Z up. Each printable part modeled in print orientation, bed face at Z=0, centered on XY origin, unless the part's natural datum is a corner (state which in a comment).
- Parameters: Customizer syntax with `/* [Section] */` groups, a comment line above each, range annotation `// [min:step:max]` or option list. Derived values in `[Hidden]`.
- No magic numbers in geometry. Every dimension traces to a parameter, a derived value, or a named constant.
- `part` parameter for multi-part designs: `assembly` shows parts in fitted position (for review), `print` lays all parts flat on the bed with 5 mm gaps, individual part names export one part each.
- `section` debug parameter: when true, intersect the model with a half-space to show a cut-away along the given axis. Required for any design with slots, internal cavities, or mating features.
- Assertions: assert every relationship that, if violated, makes the part useless (clearances positive, walls >= min wall, fits within build volume, mating parts agree).
- Report lines: `echo(str("REPORT <key>=", value))` for each key dimension in the spec. `tools/check.sh` collects them.
- Booleans: avoid coincident faces. Extend cutters by `eps` past surfaces.
- Prefer BOSL2 for rounded/chamfered primitives (`cuboid`, `cyl`), attachments, `diff()`/`tag()`. Plain OpenSCAD is fine for simple geometry.
- BOSL2 overrides `cube`, `cylinder`, `sphere` with attachable versions. Do not mix assumptions about anchors; when in doubt, use explicit `anchor=`.
- Before using any BOSL2 module/function you have not used in this session, grep `lib/BOSL2/` for its definition and read its argument list. Never guess BOSL2 signatures.
- Keep render time low: avoid `minkowski()` on complex shapes, avoid huge `$fn`. Target full render under 10 s.
- Shared code: put a module in `lib/common/` only when a second design needs it. Changes to `lib/common/` require user approval and a re-check of every design that uses the file (`grep -rl` to find them).

## 7. Self-review checklist (run before every presentation to user)

1. `tools/check.sh` exit code 0.
2. No `WARNING`, `ERROR`, `DEPRECATED`, or manifold messages in output.
3. All assertions pass.
4. REPORT values match spec values (state each: spec vs model).
5. Bounding box matches expected overall size within 0.1 mm.
6. View every PNG with your image-reading tool. Check:
   - Shape matches spec and sketch.
   - No missing/floating parts, no unintended solids filling cavities.
   - Cutouts go fully through where intended (look for skins).
   - Orientation: bed face at Z=0 is flat and is the largest practical face.
7. Section view (if applicable): wall thickness, slot depth, internal clearances visible and correct.
8. Printability (section 10) passes.
9. List what you could not verify from images or numbers. Say so explicitly.

## 8. Tools spec

All scripts: bash, `set -euo pipefail`, source `tools/env.sh`, accept extra `-D name=value` args passed through to OpenSCAD, write outputs to `designs/<name>/out/` (derived from input path), exit non-zero on any failure.

### render.sh `<file.scad> [-D ...]`
- Renders with `--render` (final geometry, not preview) and Manifold backend, `--imgsize=1200,900`, a light colorscheme.
- Views (camera gimbal form `tx,ty,tz,rx,ry,rz,dist` with `--viewall --autocenter`):
  - `iso`: rotation 55,0,25, perspective
  - `back-iso`: rotation 55,0,205, perspective
  - `front`: 90,0,0, orthographic
  - `right`: 90,0,90, orthographic
  - `top`: 0,0,0, orthographic
  - `bottom`: 180,0,0, orthographic
  - `section`: only if file declares `section`; renders iso and front with `-D section=true`
- Output: `out/<name>_<view>.png`.
- On GL/display failure, retry the same command under `xvfb-run -a`.
- Verify starting camera values on first run; adjust if views are wrong; record final values in script comments.

### export.sh `<file.scad> [-D ...]`
- Exports binary STL (`--export-format binstl`) and 3MF.
- If file has `part` parameter: export each printable part separately (`-D part="<name>"`), plus `print` layout.
- Writes `--summary all --summary-file out/summary.json` if supported. If not supported: compute bounding box from STL with Python (`numpy-stl` or `trimesh`, install with `pip install --user --break-system-packages`).
- Captures stderr to `out/export.log`.

### check.sh `<file.scad> [-D ...]`
- Runs render.sh + export.sh.
- Scans all logs: grep -iE `warning|error|deprecated|manifold|assert` and prints matches.
- Prints: all `REPORT` echo lines, bounding box (x, y, z), render time.
- Exits non-zero on any warning, error, or failed assertion.

### selftest.sh
- Runs check.sh on `tests/golden.scad`; compares bounding box to expected values stored in the test file; prints OpenSCAD version and BOSL2 commit.

### new-design.sh `<name>`
- Creates `designs/<name>/{spec.md,log.md,ref/,ref/private/,out/}` from templates. Does not create `.scad` (written after spec approval).

## 9. Fits and tolerances

Fit classes:
- `press`: needs force to assemble, stays put.
- `snug`: holds by friction, removable by hand.
- `slide`: moves freely, minimal play.
- `free`: loose, obvious play.

Clearance = added to the real object's measured dimension (total, not per side) for slots/pockets; subtracted for pegs into holes.

`lib/common/tolerances.scad` exposes:
```
function clearance(material, fit, feature) = ...;  // feature: "slot" | "hole"
```
Provisional defaults until the coupon is printed (mark `// PROVISIONAL`):

| fit | slot (total) | hole (diameter) |
|---|---|---|
| press | 0.10 | 0.10 |
| snug | 0.25 | 0.20 |
| slide | 0.40 | 0.35 |
| free | 0.70 | 0.60 |

PETG: add 0.05 to each until measured.
After the coupon, replace with measured values, remove PROVISIONAL, add date and filament brand per material.

`lib/common/printing.scad` constants: `nozzle=0.4`, `layer_h=0.2`, `min_wall=1.2`, `std_wall=2.4`, `bed_xy=250`, `bed_z=250`.

Fastener defaults (`lib/common/fasteners.scad`, override when user specifies hardware): M3 clearance hole 3.4, M3 self-tap hole 2.6, M3 heat-set insert hole 4.0 (verify against user's insert datasheet; ask), M3 hex nut trap 5.7 across flats + 0.3. M4 / M5 equivalents scaled; ask before using.

## 10. FDM design rules

- Walls: >= 1.2 mm anywhere; >= 2.4 mm for structural walls; >= 3.2 mm around screw holes.
- Overhangs: <= 45 degrees from vertical without support. Bridges <= 15 mm.
- Bed-face edges: chamfer (0.4-0.6 mm) instead of fillet; fillets on bed edges create overhangs and elephant foot.
- Vertical edges: fillet freely.
- Horizontal holes (axis parallel to bed): teardrop or flat-top profile, or design so they print vertical.
- Snap fits and thin flexures: PETG preferred; orient so flex is along layers, not across them.
- Load paths: layers are weakest in Z tension. Orient brackets so loads do not peel layers apart. State the load direction vs layers in print notes.
- Text: embossed or engraved >= 0.6 mm deep, font size >= 5 mm, on top face or vertical face.
- Minimum feature: 0.8 mm (2 extrusion widths).
- Avoid fully enclosed voids.
- Large flat parts: add chamfered or rounded corners to reduce warping.

## 11. Stop and ask the user when

- A real-object dimension is unknown or ambiguous.
- Spec and sketch disagree.
- A requested change contradicts the approved spec.
- You would change `lib/common/` or `tools/` behavior used by other designs.
- The same problem persists after 3 self-fix attempts.
- A part exceeds 250 mm in any axis, or needs supports the user did not approve.
- You cannot verify something critical (state what and why).
- Before: deleting files, rewriting git history, pushing to GitHub, upgrading OpenSCAD/BOSL2, installing system packages with sudo.

Do without asking: creating files inside `designs/<name>/`, running tools, local commits after user approval points, installing Python packages with `--user`.

## 12. Project 1: tolerance coupon

Design `designs/tolerance-coupon` after setup. Purpose: measure real clearances per material on this printer.

Parts:
1. `key`: flat bar 40 x 15 x 4.0 mm, printed flat (4.0 mm along Z). User measures its actual thickness with calipers.
2. `slot-block`: block with 7 slots for the key, widths 4.0 + [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6], depth 12 mm, slots open on top, block printed with slot walls vertical. Engraved labels above each slot ("0", "1", ... "6" = tenths of mm), font >= 5 mm.
3. `pin`: cylinder D 8.0 x 20 mm, printed upright, 0.4 mm chamfer at base.
4. `hole-plate`: plate 5 mm thick with 7 vertical holes, D 8.0 + [0.0 ... 0.6] step 0.1, labeled.

Parameters: key thickness, pin diameter, clearance list, label text size.
Print notes: one set per material, same settings as normal functional parts (0.20 mm, 3 walls), same filament the user prints with.
Fit test instructions for user:
- Measure printed key thickness (3 points, max) and pin diameter (3 points, max).
- For each slot and hole: record press / snug / slide / free / does-not-fit.
- Report table back.
Then compute effective clearance per fit class = nominal opening - measured key/pin, for each material, and propose `tolerances.scad` values. Write results in `designs/tolerance-coupon/log.md`.

## 13. Git

- Commit messages: `design(<name>): ...`, `lib: ...`, `tools: ...`, `docs: ...`, `chore: ...`.
- Commit at: spec approval, each user-approved iteration, export.
- Never commit `out/` or `ref/private/`.
- Never push unless user asks.
- Never edit `lib/BOSL2`.

## 14. Communication

- Terse. Lists over paragraphs.
- Each update to user: what changed, check result (pass/fail, warnings), REPORT values vs spec, unverified items, question(s) if any.
- Do not paste full `.scad` files into chat; user reads them in the editor/GUI.
- Do not claim a fit or dimension is correct without a REPORT value or assertion that shows it.

## 15. Publishing (deferred, not active)

MakerWorld Parametric Model Maker constraints: single file only; only MakerWorld-hosted libraries (BOSL2 available) may be included; generation timeout around 10 s. Future `tools/bundle.py` will inline `lib/common` code into one file, keep `include <BOSL2/std.scad>`, and produce `designs/<name>/dist/<name>-mw.scad`. Do not build until user asks.