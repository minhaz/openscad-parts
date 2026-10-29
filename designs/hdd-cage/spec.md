# hdd-cage spec

Status: APPROVED (2026-10-29)

## Purpose

A compact, high-airflow, industrial-style 2-bay 3.5" HDD enclosure for an HP EliteDesk 800 G3 TWR desktop PC (replacing the removed factory drive cage in the lower-front bay). Holds two standard 3.5" 8TB HGST hard drives in a horizontal flat stack (`147.0 mm` length running front-to-PSU, `101.6 mm` width running side-panel-to-motherboard-tray, `26.1 mm` thickness stacked vertically).

Designed so SATA data (90° right-angle) and SATA power (straight) cables are attached to each HDD first, and the HDD is then slid straight in laterally from the open side panel over the case's `8 mm` bottom lip. Includes **both** mechanical locking options (`screw-bar` using the HDDs' outer `#6-32` side holes and `pin-latch` sliding through integrated frame loops, plus bottom `#6-32` screw slots) so both can be tested and used to lock the drives against movement, tilting, or full case inversion.

## Real objects and interfaces

| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
|---|---|---|---|---|
| 3.5" HGST HDD thickness (height in bay) | 26.1 mm (standard SFF-8301, user-approved) | custom slide (long lateral slide) | +0.90 mm (bay height = 27.0 mm) | Z (bay vertical) |
| 3.5" HGST HDD width (lateral slide depth) | 101.6 mm (standard SFF-8301, user-approved) | custom slide (bounded between inner stop & outer lock) | +0.80 mm (pocket depth = 102.4 mm) | Y (lateral slide) |
| 3.5" HGST HDD length (front-to-rear bay span) | 147.0 mm (standard SFF-8301, user-approved) | custom slide (long lateral entry) | +1.00 mm (bay length = 148.0 mm) | X (front-to-rear) |
| HDD side threaded holes (`#6-32` UNC, 3 per side) | 28.50, 70.16, 130.10 mm from rear; 6.35 mm from bottom (SFF-8301) | free (screw clearance slot) | 3.8 mm × 5.0 mm obround slot for `#6-32` (3.5 mm OD) | Y (outer side face) |
| HDD bottom threaded holes (`#6-32` UNC, outer pair) | 44.45, 120.65 mm from rear; 3.18 mm from outer side (SFF-8301) | free (screw clearance slot) | 3.8 mm × 5.5 mm countersunk slot | Z (shelf underside) |
| Front grill to PSU cavity length | 185.0 mm (user-measured) | free | 21.5 mm rear cable space (163.5 mm cage length) | X (front-to-rear) |
| Front grill to HDD front face offset | 12.0 mm target (11–14 mm user-stated) | N/A (structural standoff) | 12.0 mm front standoff | X (front-to-rear) |
| Front grill square mesh (10 × 12 grid) | ~7.2 mm pitch, ~5.5 mm square openings, Y = 53–125 mm (user photo) | free (zip-tie passage) | 5.0 mm × 2.2 mm zip-tie tunnels on 7.25 mm vertical pitch | X / Z |
| Front grill inward notch & rib bumps | 6.0 mm protrusion in Y < 55 mm zone (user-measured) | free (setback clearance) | +2.0 mm margin (8.0 mm full-height setback on inner front zone) | X |
| Case floor (with 1 mm neoprene) to side lip | 125.0 mm width to lip; lip 8.0 mm high × 13.0 mm wide (user-measured) | slide / rest | Base sits at Y <= 124.5 mm; lower drive bottom at 9.5 mm (> 8.0 mm lip) | Y / Z |
| Motherboard tray obstacles (M.2 SSD & C-clips) | SSD 12.0 mm, C-clips 15.0 mm protrusion from tray (user-measured) | free | Cage inner wall stays >= 18.5 mm from motherboard tray (3.5–6.5 mm gap) | Y |
| Height under motherboard SATA ports / 5.25" cage | 95.0 mm to MB edge, 195.0 mm under upper structure (user-measured) | free | Cage total height 78.0 mm (>= 17.0 mm clear below MB edge) | Z |
| Locking bar / pin-latch mating slots | 8.0 mm × 3.2 mm tenon / channel (printed PETG-to-PETG) | slide (`tolerances.scad` PETG) | +0.15 mm (`clearance("PETG", "slide", "slot")`) | Z / Y |

## Overall geometry

* **Case coordinate reference (installed in PC)**:
  * **Front-to-Rear (`L`, `163.5 mm` total)**:
    * `0` to `12.0 mm`: Front grill standoff wall with two vertical zip-tie ladder pillars positioned in the flat `10 × 12` mesh zone (`56–124 mm` from motherboard tray), and an `8.0 mm` deep setback across the inner zone (`18.5–56 mm` from motherboard tray) to clear the `6.0 mm` inward notch and all stamped rib bumps.
    * `12.0` to `160.0 mm`: `148.0 mm` HDD bay span (`147.0 mm` drive + `1.0 mm` clearance).
    * `160.0` to `163.5 mm`: `3.5 mm` rear retaining stop flange at the top/bottom corners (leaves the middle `110 mm` rear connector zone completely open for right-angle SATA data and straight SATA power plugs, with `21.5 mm` clear behind the cage to the `185 mm` PSU face).
  * **Width: Motherboard Tray to Open Side Panel (`W`, `109.5 mm` total)**:
    * Cage sits against the inside of the `8.0 mm` side-panel lip (`124.5 mm` from motherboard tray at the base, overhanging `3.5 mm` above the `8.0 mm` lip to `128.0 mm` for the outer locking channel).
    * Inner wall (`3.6 mm` open-truss skeleton) is at `18.5 mm` from the motherboard tray, clearing the `12 mm` M.2 SSD and `15 mm` cable clips without contact.
    * HDD pocket spans `102.4 mm` (`101.6 mm` HDD + `0.8 mm` clearance) from the inner stop wall to the outer locking plane.
  * **Height: From Neoprene Floor Upward (`H`, `78.0 mm` total)**:
    * `0` to `9.5 mm`: Vented bottom plinth resting on the `1 mm` neoprene floor inside the `125 mm` lip. Elevates the bottom face of HDD 1 to `9.5 mm` so HDD 1 slides straight in over the `8.0 mm` side-panel lip with `1.5 mm` vertical margin.
    * `9.5` to `36.5 mm`: Bay 1 (`27.0 mm` tall for `26.1 mm` HDD).
    * `36.5` to `46.5 mm`: `10.0 mm` ventilated middle truss shelf (`6.8 mm` open air gap between drives + `1.6 mm` upper/lower slide rails).
    * `46.5` to `73.5 mm`: Bay 2 (`27.0 mm` tall for `26.1 mm` HDD).
    * `73.5` to `78.0 mm`: `4.5 mm` top retaining frame with diagonal airflow trusses.
* **Dual HDD Locking System (both included so you can test and choose)**:
  1. **`screw-bar` (Method 1 — Side `#6-32` Screw Retainer Bars, ×2)**: Vertical bars at the front (`16.9 mm` from front of drive) and rear (`28.5 mm` from rear of drive) side-hole positions. Each bar keys into top/middle/bottom dovetail pockets on the outer face of the cage and has obround `#6-32` clearance slots (`3.8 × 5.0 mm`) aligned with the outer `#6-32` side holes of both HDDs. Fastening 2 standard `#6-32` HDD screws per drive locks both drives and the bars to the cage.
  2. **`pin-latch` (Method 2 — Slide-In Locking Pins, ×2)**: Vertical locking bars that slide downward through aligned loops on the top, middle, and bottom outer frame rails right across the outer face of both HDDs, with a snap-detent + optional M3/`#6-32` retaining screw hole at the top.
  3. **Direct Bottom `#6-32` Screw Slots**: Countersunk `#6-32` clearance slots (`3.8 × 5.5 mm`) in the outer shelf rails aligned with the outer bottom `#6-32` holes of the HDD (`3.18 mm` inward from the outer side edge).

## Parameters (exposed)

| Name | Default | Range | Unit | Note |
|---|---|---|---|---|
| `part` | `"assembly"` | `["assembly", "print", "cage", "screw-bar", "pin-latch", "test-slice"]` | — | Part selector |
| `hdd_l` | `147.0` | `[145:0.1:150]` | mm | 3.5" HDD length |
| `hdd_w` | `101.6` | `[100:0.1:104]` | mm | 3.5" HDD width |
| `hdd_h` | `26.1` | `[25:0.1:28]` | mm | 3.5" HDD thickness |
| `hdd_slide_clr_h` | `0.9` | `[0.3:0.1:2.0]` | mm | Vertical clearance in each HDD bay |
| `hdd_slide_clr_l` | `1.0` | `[0.4:0.1:2.5]` | mm | Front-to-rear length clearance in bay |
| `hdd_slide_clr_w` | `0.8` | `[0.3:0.1:2.0]` | mm | Lateral depth clearance before outer lock |
| `front_standoff` | `12.0` | `[10:0.5:16]` | mm | Front grill to HDD front face distance |
| `notch_relief_d` | `8.0` | `[6:0.5:10]` | mm | Setback depth on inner front face for 6 mm grill notch |
| `base_h` | `9.5` | `[8.5:0.5:14]` | mm | Bottom plinth height (must exceed 8.0 mm side lip) |
| `mid_shelf_h` | `10.0` | `[6:0.5:16]` | mm | Middle divider thickness (includes inter-drive air gap) |
| `wall_t` | `3.6` | `[2.4:0.4:5.0]` | mm | Structural frame wall thickness |
| `screw_hole_d` | `3.8` | `[3.4:0.1:4.2]` | mm | `#6-32` HDD screw clearance hole diameter |
| `ziptie_w` | `4.5` | `[3.0:0.5:6.0]` | mm | Zip-tie slot width |
| `ziptie_t` | `2.0` | `[1.5:0.1:3.0]` | mm | Zip-tie slot thickness |
| `material` | `"PETG"` | `["PLA", "PETG"]` | — | Filament material |
| `fit` | `"slide"` | `["press", "snug", "slide", "free"]` | — | Fit class for printed locking bars |
| `section` | `false` | `[true, false]` | — | Cut-away view for inspecting rails & channels |
| `section_axis` | `"x"` | `["x", "y"]` | — | Axis for cut-away section |

## Mounting

* **Front grill attachment**: Two vertical zip-tie ladder columns on the front standoff (`12.0 mm` deep), aligned with the `10 × 12` front grill mesh (`7.25 mm` vertical hole pitch). Provides 8 pairs of horizontal zip-tie tunnels (`4.5 × 2.0 mm`) so 3–4 standard zip ties can loop through the front grill mesh at top and bottom corners with locking heads recessed inside the front standoff channels.
* **Bottom floor & side-lip indexing**: The `9.5 mm` base plinth rests flat on the `1 mm` adhesive neoprene pad on the case floor and butts directly against the inner vertical face of the `8.0 mm` side-panel lip, while the `3.5 mm` outer locking flange steps over the top of the `8.0 mm` lip to prevent inward/outward shifting.

## Material and environment

* **Material**: PETG (higher temperature resistance, toughness, and slight compliance for latches/vibration inside an enclosed 24×7 PC chassis).
* **Environment**: Indoor PC case running 24×7, drives mostly spun down; open hex/truss frame maximizes passive and front-grill convective airflow across top, bottom, and sides of both HDDs.

## Print orientation and supports

* **Cage (`part="cage"`)**: Modeled and printed **Inner-Wall-Down** on the print bed (`Z = 0` is the flat motherboard-side frame face; footprint `163.5 × 78.0 mm`, height `109.5 mm` in Z).
  * All shelf rails, front standoff wall, and rear stop pillars stand vertically from the bed (`90°`).
  * The `8.0 mm` front-grill notch relief is at the bottom of the front wall (`Z = 0..38 mm`) and transitions via a `45°` bevel to the full `12.0 mm` front standoff (`Z >= 46 mm`), requiring **zero supports**.
  * Continuous XY filament loops wrap around the entire `163.5 × 78.0 mm` side profile, carrying front zip-tie tension and vertical gravity loads along layer strands rather than across layer lines.
* **Locking bars (`screw-bar`, `pin-latch`) and `test-slice`**: Printed flat on their wide side faces (`Z = 0`), **zero supports**.

## Assumptions (things not stated by user)

* Standard SFF-8301 3.5" HDD hole locations: side holes at `28.50 mm`, `70.16 mm`, and `130.10 mm` from the rear connector edge (`16.90 mm`, `76.84 mm`, `118.50 mm` from front face), `6.35 mm` up from the bottom face; outer bottom holes at `44.45 mm` and `120.65 mm` from rear, `3.18 mm` from outer side face.
* Obround screw slots (`±1.0 mm` longitudinal play) on the locking bars and bottom rails accommodate minor drive/print tolerances while still locking lateral motion positively.
* Zip-tie tunnels sized at `4.5 × 2.0 mm` with `5.5 mm` head recesses fit standard thin (`2.5–3.6 mm` wide) and medium (`4.8 mm` wide) nylon zip ties.

## Out of scope

* Active cooling fan mounts (relies on existing case airflow through the front grill).
* Custom SATA power or data cable routing clips outside the enclosure footprint.
