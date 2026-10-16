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
docs/GUIDE.md             user's setup & workflow guide (do not edit unless asked)
lib/BOSL2/                submodule, never edit
lib/common/               shared modules (this repo's own library)
  tolerances.scad         measured clearances per material (from tolerance coupon)
  printing.scad           printer constants, min wall, layer height, helpers
  fasteners.scad          screw holes, heat-set insert holes, countersinks (create when needed by 2+ designs)
  ...                     add modules only when used by 2+ designs
tools/
  env.sh                  exports OPENSCADPATH, OPENSCAD binary path
  versions.env            OPENSCAD_SNAPSHOT=..., BOSL2_COMMIT=...
  render.sh               PNG views (iso, back-iso, front, right, top, bottom, section_iso, section_front)
  export.sh               STL + 3MF + summary_<part>.json for all printable parts
  check.sh                fast iteration check: render + single-pass summary + warning scan + REPORT echo report
  selftest.sh             verifies toolchain against tests/golden.scad
  new-design.sh           scaffolds designs/<name>/ (idempotent; preserves existing ref/, spec.md, log.md)
tests/
  golden.scad             uses BOSL2 + lib/common; fixed expected bounding box
designs/<name>/
  spec.md                 approved spec (source of truth for intent)
  <name>.scad             the model
  print-notes.md          orientation + slicer settings + fit test
  log.md                  iteration log, print results, decisions (gitignored)
  ref/                    sketches, photos (committed, public)
  ref/private/            gitignored; anything user does not want public
  out/                    renders, STL, 3MF, summary*.json (committed on export; *.log and *.tmp ignored)
```

Naming: `designs/` folders and files in kebab-case. One primary `.scad` per design.

## 4. Toolchain verification

The repository and toolchain are already initialized. For full machine setup or bootstrapping on a new host, see `docs/GUIDE.md` (Section 2).

When asked to verify the environment or when diagnosing toolchain errors:
1. Confirm `uname -s` is `Linux`, `mount | grep ' /mnt/c '` includes `metadata`, and `git config core.autocrlf` is `input`.
2. Run `bash tools/selftest.sh` to verify the OpenSCAD snapshot binary (`--backend=manifold`), `lib/BOSL2` submodule commit against `tools/versions.env`, headless PNG rendering (direct or via `xvfb-run -a`), and `tests/golden.scad` bounding box.
3. If `openscad` is missing or reports `2021.01`, stop and refer the user to `docs/GUIDE.md` Step 3.

## 5. Workflow per design

States: INTERVIEW -> SPEC -> (approval) -> BUILD -> ITERATE -> (approval) -> EXPORT -> PRINT NOTES -> (print) -> FEEDBACK.

### 5.1 Interview
- Start with `tools/new-design.sh <name>` (safe to run even if `designs/<name>/ref/` already exists).
- Read everything in `ref/` and `ref/private/` (sketch photos, notes, measurements). Describe back what you see in the sketch in one short list; ask user to correct.
- Ask questions in batches of at most 5. Prefer specific questions with a proposed default: "Wall thickness 2.4 mm OK?".
- Cover:
  - Function: what it holds/mounts, what it attaches to, loads, how often inserted/removed.
  - Every interface with a real object: object dimension (caliper-measured), fit class (press / snug / slide / free, or custom clearance with lean/slide; see section 9), axis of insertion.
  - Mounting: screws (size, head type), heat-set inserts, adhesive tape, magnets, anti-slip pads, freestanding.
  - Material (PLA/PETG) and environment (heat, sun, moisture, outdoor).
  - Envelope limits: max footprint, height, clearance around neighbors.
  - Cosmetics: edge rounding radius, chamfers, text/labels.
  - Print constraints: preferred bed face, supports allowed (default: no).
  - Test pieces: if the full print is large (>100 g or >2 h) or has non-standard fit geometry (long slides, tall walls with tilt, entry over fillets), propose a `test-slice` and/or stepped `gauge` part mode.
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
- One coherent change set per iteration. Re-run `tools/check.sh` after every edit (pass `-D part="<mode>"` when checking non-default part modes like `test-slice` or `gauge`).
- Append to `log.md` each iteration: date, change, reason, check result.
- Feedback mapping: user refers to views by name (`iso`, `back-iso`, `front`, `right`, `top`, `bottom`, `section_iso`, `section_front`). Ask for a dimension when feedback is qualitative and the fix is ambiguous ("thicker" -> "by how much? propose 1.2 mm").
- If a change contradicts the approved spec, update `spec.md` first and note it in `log.md`.
- Commit after each user-approved iteration: `design(<name>): <what changed>`.

### 5.5 Export
- On user approval: run `tools/export.sh designs/<name>/<name>.scad`. Produces `out/<name>[-<part>].stl` (binary), `.3mf`, and `out/summary[_<part>].json` for each printable part.
- Confirm zero warnings in `out/export.log`. Confirm bounding box fits 250 x 250 x 250.

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
Special: <pauses for magnets/nuts, heat-set inserts after print, ironing, etc.>
Fit test: <how to check fit (or test-slice/gauge first), what to measure, what to report back>
```

Default settings for functional parts: 0.20 mm layers, 3 walls (4 for brackets under load; more if thin divider walls should print solid without sparse infill), 5 top / 4 bottom layers, 15-25% gyroid infill. Deviate only with a stated reason.

### 5.7 Feedback after print
- User reports fit results ("snug slot too tight, needed force") and/or measurements from test pieces or full print.
- Adjust the clearance parameter for this design; record in `log.md` with the printed value and the new value.
- If the same correction applies across designs (same material, same fit class, short rigid feature), propose an update to `lib/common/tolerances.scad`. Do not change shared values without approval.

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
- Customizer vector limit: OpenSCAD Customizer GUI cannot edit vector parameters with more than 4 elements (`[a, b, c, d]`). Keep exposed lists <= 4 elements when practical, or note in `spec.md` and code comments that longer lists are edited directly in the `.scad` file.
- No magic numbers in geometry. Every dimension traces to a parameter, a derived value, or a named constant.
- `part` parameter:
  - Multi-part designs: `assembly` shows parts in fitted position (for review), `print` lays all parts flat on the bed with 5 mm gaps, individual part names export one part each.
  - Large (>100 g / >2 h) or fit-critical designs: include fast validation modes such as `test-slice` (short cross-section of functional features) and/or `gauge` (stepped clearance bar).
- `section` debug parameter: when true, intersect the model with a half-space to show a cut-away along `section_axis`. Required for any design with slots, internal cavities, or mating features. Default `section_axis` to the axis (`"x"` or `"y"`) that reveals internal features in the `front` view (`section_front`).
- Assertions: assert every relationship that, if violated, makes the part useless (clearances positive, walls >= min wall, fits within build volume, mating parts agree). Gate full-envelope assertions (e.g., tipping or shelf clearance) on the full part mode so `test-slice` and `gauge` modes pass `tools/check.sh`.
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
- Renders with `--render` (final geometry, not preview) and Manifold backend, `--imgsize=1200,900`, a light colorscheme (`Cornfield`).
- Views (camera gimbal form `tx,ty,tz,rx,ry,rz,dist` with `--viewall --autocenter`):
  - `iso`: rotation 55,0,25, perspective
  - `back-iso`: rotation 55,0,205, perspective
  - `front`: 90,0,0, orthographic
  - `right`: 90,0,90, orthographic
  - `top`: 0,0,0, orthographic
  - `bottom`: 180,0,0, orthographic
  - `section_iso` and `section_front`: only if file declares `section`; renders iso and front with `-D section=true`
- Output: `out/<name>_<view>.png`.
- On GL/display failure, retry the same command under `xvfb-run -a`.

### export.sh `<file.scad> [-D ...]`
- Exports binary STL (`--export-format binstl`) and 3MF.
- If file has `part` parameter: exports each non-`assembly` part option (`-D part="<name>"`), including `print` layout if present, writing `out/summary_<part>.json` plus `out/summary.json`.
- Captures stderr to `out/export.log`.

### check.sh `<file.scad> [-D ...]`
- Runs `render.sh` + a single-pass Manifold geometry summary check (`--summary all --summary-file out/summary.json` via temporary `out/check.tmp` export, without running full multi-part STL/3MF export).
- Scans `out/render.log` and `out/check.log`: `grep -iE 'warning|error|deprecated|manifold|assert'` and prints matches.
- Prints: all `REPORT` echo lines, bounding box (x, y, z), render time.
- Exits non-zero on any warning, error, or failed assertion.

### selftest.sh
- Runs `check.sh` on `tests/golden.scad`; compares bounding box to expected values stored in the test file; prints OpenSCAD version and BOSL2 commit.

### new-design.sh `<name>`
- Idempotently creates `designs/<name>/{spec.md,log.md,ref/private/,out/}` from templates, preserving any existing `ref/` files, `spec.md`, or `log.md`. Does not create `.scad` (written after spec approval).

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
Current values in `lib/common/tolerances.scad`:

| fit | PLA slot (total, calibrated) | PLA hole (diam, calibrated) | PETG offset (provisional) |
|---|---|---|---|
| press | 0.00 | 0.10 | +0.05 |
| snug | 0.05 | 0.20 | +0.05 |
| slide | 0.10 | 0.30 | +0.05 |
| free | 0.20 | 0.40 | +0.05 |

- PLA calibrated 2026-10-10 with Bambu PLA Basic via `designs/tolerance-coupon`.
- PETG remains provisional (`+0.05` over PLA) until calibrated with `designs/tolerance-coupon`.
- Scope of `tolerances.scad`: short, rigid vertical holes and slots. When a part has long sliding engagement, tall walls where device tilt/lean can bind, or entry over fillets/ramps, specify a custom clearance in `spec.md` and validate with a `gauge` or `test-slice` before printing the full model.

`lib/common/printing.scad` constants: `nozzle=0.4`, `layer_h=0.2`, `min_wall=1.2`, `std_wall=2.4`, `bed_xy=250`, `bed_z=250`.

Fastener defaults (`lib/common/fasteners.scad` when created, override when user specifies hardware): M3 clearance hole 3.4, M3 self-tap hole 2.6, M3 heat-set insert hole 4.0 (verify against user's insert datasheet; ask), M3 hex nut trap 5.7 across flats + 0.3. M4 / M5 equivalents scaled; ask before using.

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

## 12. Tolerance calibration protocol (`designs/tolerance-coupon`)

Use `designs/tolerance-coupon` whenever calibrating a new filament material (e.g., PETG), filament brand, nozzle size, or slicer profile.

Parts in `designs/tolerance-coupon`:
1. `key`: flat bar 40 x 15 x 4.0 mm, printed flat (4.0 mm along Z). User measures its actual thickness with calipers (3 points, max).
2. `slot-block`: block with 7 slots for the key, widths 4.0 + [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6], depth 12 mm, slots open on top, block printed with slot walls vertical. Engraved labels ("0".."6" = tenths of mm), font >= 5 mm.
3. `pin`: cylinder D 8.0 x 20 mm, printed upright, 0.4 mm chamfer at base. User measures diameter (3 points, max).
4. `hole-plate`: plate 5 mm thick with 7 vertical holes, D 8.0 + [0.0 ... 0.6] step 0.1, labeled.

Calibration procedure:
- Print all 4 parts using standard functional settings (0.20 mm layer height, 3 walls).
- User reports max measured `key` thickness, max measured `pin` diameter, and fit rating (`press` / `snug` / `slide` / `free` / `does-not-fit`) for each slot and hole.
- Compute effective clearance per fit class = nominal opening - measured key/pin, log in `designs/tolerance-coupon/log.md`, and propose updated values for `lib/common/tolerances.scad` (with calibration date and filament brand).

## 13. Git

- Commit messages: `design(<name>): ...`, `lib: ...`, `tools: ...`, `docs: ...`, `chore: ...`.
- Commit at: spec approval, each user-approved iteration, export.
- Never commit `tests/out/` or `ref/private/` or `log.md` or `*.log` or `*.tmp`.
- Never push unless user asks.
- Never edit `lib/BOSL2`.

## 14. Communication

- Terse. Lists over paragraphs.
- Each update to user: what changed, check result (pass/fail, warnings), REPORT values vs spec, unverified items, question(s) if any.
- Do not paste full `.scad` files into chat; user reads them in the editor/GUI.
- Do not claim a fit or dimension is correct without a REPORT value or assertion that shows it.

## 15. Publishing (deferred, not active)

MakerWorld Parametric Model Maker constraints: single file only; only MakerWorld-hosted libraries (BOSL2 available) may be included; generation timeout around 10 s. Future `tools/bundle.py` will inline `lib/common` code into one file, keep `include <BOSL2/std.scad>`, and produce `designs/<name>/dist/<name>-mw.scad`. Do not build until user asks.