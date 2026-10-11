# openscad-parts

Parametric OpenSCAD design library for functional FDM 3D printing (calibrated for Bambu Lab P1S, 0.4 mm nozzle). Built using [BOSL2](https://github.com/BelfrySCAD/BOSL2) with the Manifold geometry kernel.

---

## Overview & Workflow

This repository pairs parametric CAD with autonomous AI coding agents (Claude Code, Antigravity) in a rapid iteration loop:

* **Interactive GUI Reload**: Windows OpenSCAD runs natively with Automatic Reload and Manifold preview, updating live on every agent file save.
* **Headless Validation**: Automated bash scripts in WSL generate multi-angle PNG views, extract section cuts, and verify bounding boxes and assertion tolerances before slicing.
* **Empirical Tolerancing**: Fits are grounded in measured physical test coupons rather than slicer compensation.

For complete machine setup, WSL toolchain installation, and operational instructions, see the **[Workflow & Setup Guide](docs/GUIDE.md)**.
For AI agent design conventions and coding rules, see **[AGENTS.md](AGENTS.md)**.

---

## Designs Index

| Design | Status | Description |
|---|---|---|
| [**laptop-holder**](designs/laptop-holder/) | Validated | Parametric shelf organizer holding multiple laptops and tablets upright on edge. Features custom per-slot widths, $15^\circ$ raked & tapered entry noses, a $30\text{ mm}$ lead-in ramp, and a multi-step clearance test gauge. |
| [**tolerance-coupon**](designs/tolerance-coupon/) | Calibrated | Standardized test coupon measuring physical clearances for slot widths ($+0.0$ to $+0.6\text{ mm}$) and hole diameters ($\varnothing 8.0$ to $8.6\text{ mm}$) to establish press, snug, slide, and free fits. |

---

## Repository Structure

```text
designs/<name>/         Standalone designs (spec.md, CAD code, print-notes.md)
lib/common/             Shared modules (measured tolerances.scad, printing constants)
lib/BOSL2/              Pinned BOSL2 submodule
tools/                  Bash toolchain (render.sh, export.sh, check.sh, selftest.sh)
tests/                  Toolchain verification models (golden.scad)
docs/                   Setup, slicing, and operating guides (GUIDE.md)
```

---

## Quick Start

1. Clone the repository and submodules:
   ```bash
   git clone --recurse-submodules https://github.com/<user>/openscad-parts.git
   cd openscad-parts
   ```
2. Verify toolchain and geometry engine:
   ```bash
   bash tools/selftest.sh
   ```
3. Follow **[docs/GUIDE.md](docs/GUIDE.md)** to configure OpenSCAD Windows live-reloading and start a design session.

---

## License

* Models and original code: [CC BY-NC 4.0](LICENSE).
* BOSL2 submodule: [BSD-2-Clause](lib/BOSL2/LICENSE).
