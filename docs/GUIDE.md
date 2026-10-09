# OpenSCAD + AI agent workflow: personal guide

Location in repo: `docs/GUIDE.md`. Agent instructions: `AGENTS.md` (repo root).

## 1. Overview

Pipeline:
1. You: requirements, caliper measurements, sketch photos.
2. Agent: interviews you, writes `spec.md`. You approve.
3. Agent: writes `.scad`, renders PNGs from 6 angles + section view, checks dimensions and warnings, fixes obvious problems.
4. You: inspect in OpenSCAD GUI (auto-reloads on each agent save). Give feedback. Repeat.
5. Agent: exports STL + 3MF, writes `print-notes.md`.
6. You: slice in Bambu Studio, print, test fit, report results.
7. Agent: adjusts clearances, logs results. Systematic corrections go into shared `tolerances.scad`.

Stack:

| Component | Where | Role |
|---|---|---|
| WSL2 `Ubuntu` | Windows 11 | Repo, agents, headless OpenSCAD |
| OpenSCAD dev snapshot (AppImage) | WSL | Agent renders/exports |
| OpenSCAD dev snapshot (installer) | Windows | Your viewer, auto-reload |
| BOSL2 | `lib/BOSL2` git submodule | Rounding, chamfers, attachments, threads |
| Claude Code / Antigravity | WSL / Antigravity IDE | Agents; both read `AGENTS.md` |
| GitHub + `gh` CLI | WSL | Public repo |
| Bambu Studio | Windows | Slicing |

## 4. First agent session: setup

Start agent in repo root (`<repo-path>`, WSL shell). Prompt:
```
Read AGENTS.md. Do first-run setup (section 4). Report missing prerequisites before installing anything.
```
Expected result:
- OpenSCAD snapshot installed in WSL, date reported. Install matching Windows snapshot (2.7).
- `lib/BOSL2` submodule, `lib/common/`, `tools/`, `tests/golden.scad`, `.gitignore`, `.gitattributes`, `LICENSE`.
- `tools/selftest.sh` passes.
- Local commit `chore: initial scaffold`.

Then: open `tests/golden.scad` in Windows OpenSCAD (2.7 step 5). Then `git push`.

## 5. Second session: tolerance coupon

Purpose: replace guessed clearances with measured ones. Do once per material (PLA, PETG). Redo when switching filament brand or after major printer changes.

Prompt:
```
Read AGENTS.md. Start project 1: tolerance coupon (section 12).
```
Then:
1. Approve spec. Review renders. Agent exports + writes print notes.
2. Print all 4 parts in PLA, same settings as normal functional prints.
3. Measure key thickness at 3 points; record max. Same for pin diameter.
4. Insert key into each slot, pin into each hole. Classify each:
   - press: needs real force, stays
   - snug: friction hold, removable by hand
   - slide: moves freely, little play
   - free: loose
   - no fit
5. Report to agent as a table:
   ```
   Material: PLA, <brand>
   key measured 4.03, pin measured 7.98
   slot 0: no fit, 1: press, 2: snug, 3: snug, 4: slide, 5: free, 6: free
   hole 0: no fit, 1: no fit, 2: press, 3: snug, 4: slide, 5: slide, 6: free
   ```
6. Agent proposes `tolerances.scad` values. Approve. Repeat for PETG.

## 6. Running a design session

### 6.1 Before
- Sketch on paper. Mark known dimensions. Photograph straight-on, good light.
- Measure real objects with calipers. Each dimension at 3 points, use max. Note where measured (e.g. "tablet thickness at edge, excluding camera bump").
- Note: what it holds, what it mounts to, how it mounts, which material.

### 6.2 Start
```
./tools/new-design.sh tablet-stand          # or let the agent run it
```
Put photos in `designs/tablet-stand/ref/` (or `ref/private/`).
Prompt:
```
Read AGENTS.md. New design: tablet-stand. Sketch and notes in designs/tablet-stand/ref/. Interview me.
```

### 6.3 Interview and spec
- Answer the agent's batches of questions. Accept or override its proposed defaults.
- Read `spec.md` fully. Check: every real-object dimension is one you measured; fit classes are right; Assumptions section has nothing wrong.
- Approve explicitly: "Spec approved."

### 6.4 Iterate
- Keep `<name>.scad` open in Windows OpenSCAD. It refreshes on each agent save.
- Use the Customizer panel to try parameter values without editing code. Customizer changes are not saved to the file; tell the agent the values you want as defaults.
- Feedback that works well:
  - Reference views by name: iso, back-iso, front, right, top, bottom, section.
  - Give numbers: "front lip 3 mm taller", "corner radius 2 mm".
  - Point to locations by feature: "the left mounting tab", "slot floor".
- Agent's update after each iteration lists: change, check result, REPORT values vs spec, unverified items. Read the unverified items.
- Approve iteration explicitly ("approved") so it commits.

### 6.5 Export and print
- "Export." Agent writes STL/3MF to `designs/<name>/out/` and `print-notes.md`.
- Open `<repo-path>\designs\<name>\out\` in Explorer; drag files into Bambu Studio. Slice per section 7.

### 6.6 After print
Report fit and problems:
```
Printed in PETG. Tablet fits but too tight, needs force. Base wobbles on left side.
```
Agent adjusts, logs in `log.md`, re-exports. Systematic fit corrections get proposed for `tolerances.scad`.

### 6.7 Prompt cheat sheet

| Goal | Prompt |
|---|---|
| Setup | `Read AGENTS.md. Do first-run setup.` |
| New design | `Read AGENTS.md. New design: <name>. Refs in designs/<name>/ref/. Interview me.` |
| Resume | `Read AGENTS.md. Resume designs/<name>. Read spec.md and log.md, summarize state.` |
| Variant | `Add parameter <x> to <name> so I can make a <variant>. Update spec first.` |
| New shared module | `<name> and <other> both need <feature>. Propose a lib/common module.` |
| Push | `Push to GitHub.` |

### 6.8 Comparing Claude Code and Antigravity
Both read the same `AGENTS.md`. For a fair comparison use the same approved `spec.md` and the same refs. Work on separate branches (`git switch -c try-claude`, `git switch -c try-antigravity`) so outputs do not collide.

## 7. Bambu Studio slicing pointers

### 7.1 Import
- Drag STL or 3MF onto the plate. For OpenSCAD 3MF, if asked, load geometry only.
- Units are mm; if the part appears tiny or huge, unit detection went wrong; re-import STL.
- Multiple parts from `print` layout arrive as one object; right-click > Split to objects if you want per-part settings.

### 7.2 Orientation
- Models arrive in print orientation (bed face at Z=0). Keep it unless print notes say otherwise.
- If needed: Lay on face tool, click the face that should touch the bed.
- Strength: layers separate most easily when pulled apart in Z. For brackets, orient so the load does not peel layers. Print notes state this.

### 7.3 Plate and filament
- Select the plate type you actually have (Textured PEI common). Wrong plate = wrong bed temp.
- Filament: pick the matching Bambu or generic profile (PLA Basic / PETG HF / Generic PETG). Use your own calibrated profile if you have one.
- PETG on smooth PEI: use glue stick as release agent (PETG can bond too strongly). Textured PEI usually fine without.

### 7.4 Process settings for functional parts
Start from the 0.20 mm Standard profile, then:

| Setting | Location (Process tab) | Value |
|---|---|---|
| Wall loops | Strength > Walls | 3 (4 for loaded brackets) |
| Top / bottom shell layers | Strength > Top/bottom shells | 5 / 4 |
| Sparse infill density | Strength > Infill | 15-25% |
| Sparse infill pattern | Strength > Infill | Gyroid or grid |
| Supports | Support | Off unless print notes say otherwise |
| Brim | Others > Bed adhesion | Off; on (5 mm) for small footprints or tall thin parts, often for PETG |
| Elephant foot compensation | Quality > Precision | Leave default; adjust if bottom layers flare into fits |
| X-Y hole compensation | Quality > Precision | 0; clearance lives in the model, not the slicer |

Keep slicer settings consistent with the settings used for the tolerance coupon. Changing walls, flow, or compensation changes fits.

### 7.5 Supports (when unavoidable)
- Type: Tree (auto). "On build plate only" when internal supports would be hard to remove.
- Better fix: ask the agent to redesign (chamfer the overhang, split the part, change orientation).

### 7.6 Check before print
- Preview tab: scrub the layer slider through slots, holes, overhangs. Look for missing walls, unsupported islands, bridging over long spans.
- Check estimated time and filament.
- Save the Bambu project (`.3mf`) next to the design's `out/` files if you want to reprint with the same settings (gitignored location: copy elsewhere if you want it versioned).

## 8. Maintenance

- Update OpenSCAD and BOSL2 together, deliberately, not mid-project. Prompt: `Upgrade OpenSCAD snapshot and BOSL2 to latest. Run selftest and re-check all designs. Report diffs.` Then install matching Windows snapshot.
- Re-run the tolerance coupon after: new filament brand, nozzle change, major firmware/slicer profile changes.
- Periodically: `git push`; review `lib/common/` for modules worth documenting in README.

## 9. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Can't open include file BOSL2/std.scad` (Windows GUI) | OPENSCADPATH wrong or OpenSCAD not restarted | Check path in Explorer, restart OpenSCAD |
| Same error in WSL | `tools/env.sh` not sourced | Run via `tools/*.sh`, not raw `openscad` |
| GUI does not refresh | Auto-reload off | Enable Design > Automatic Reload and Preview; F5 |
| `Permission denied` running `tools/*.sh` | `/mnt/c` mounted without `metadata`, or exec bit lost | Fix `/etc/wsl.conf` (2.1), `wsl --shutdown`; meanwhile `bash tools/<script>.sh` |
| `git status` shows every file modified | File mode or line-ending noise on `/mnt/c` | Confirm `metadata` mount and `core.autocrlf input`; if mode-only: `git config core.fileMode false` |
| Agent runs PowerShell commands / cannot find `openscad` | Antigravity opened folder in Windows mode | Reopen in WSL mode (2.5) |
| Git conflicts or corrupt `.git` | OneDrive syncing the repo | Exclude folder from OneDrive (2.1) |
| Slow `git status` / agent file ops | `/mnt/c` I/O overhead | Expected; acceptable. If painful, move repo to `~/` and point Windows paths at `\\wsl.localhost\Ubuntu\...` |
| PNG export fails in WSL (GL/display error) | No GL context | `render.sh` retries with `xvfb-run -a`; check `xvfb` installed |
| Render very slow | Not using Manifold, or heavy minkowski/high `$fn` | Check backend; ask agent to simplify |
| Renders differ between GUI and agent | Different snapshot dates | Install matching versions |
| Part fits too tight everywhere | Clearances provisional or filament changed | Run/redo tolerance coupon |
| Bottom edge of slot too tight | Elephant foot | Agent adds bed-face chamfer at slot entry |
| Agent invents BOSL2 functions | Did not check source | Remind: "grep lib/BOSL2 before using unfamiliar functions (AGENTS.md 6.2)" |
| Agent skips steps | Long session context drift | New session: `Read AGENTS.md. Resume designs/<name>.` |
| `gh` push asks for password | Credential helper not set | `gh auth setup-git` |
| Submodule folder empty after clone | Cloned without submodules | `git submodule update --init` |

## 10. Later: publishing (P4)

- MakerWorld Parametric Model Maker: single `.scad` file only; your own includes do not load; MakerWorld-hosted libraries (BOSL2) do; generation times out around 10 s.
- Plan: agent writes `tools/bundle.py` to inline `lib/common` into one file. Ask when needed.
- Printables: upload STL/3MF + `.scad`; no single-file constraint.
- License on both: CC BY-NC 4.0, matching repo.