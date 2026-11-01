# hdd-cage spec

Status: APPROVED (2026-10-29, rev 2)

## Purpose

A lightweight, high-airflow, industrial space-frame 2-bay 3.5" HDD enclosure for an HP EliteDesk 800 G3 TWR desktop PC (replacing the removed factory drive cage in the lower-front bay). Holds two standard 3.5" 8TB HGST hard drives in a horizontal flat stack (`147.0 mm` length running front-to-PSU, `101.6 mm` width running side-panel-to-motherboard-tray, `26.1 mm` thickness stacked vertically) with a snug, rattle-free fit.

Designed so SATA data (90° right-angle) and SATA power (straight) cables are attached to each HDD first, and the HDD is then slid straight in laterally from the open side panel over the case's `8.0 mm` bottom lip. Uses reinforced, gusseted dovetail housings and a continuous `5.0 mm` thick `screw-bar` (Method 1) that bolts directly into the HDDs' outer `#6-32` side holes to clamp both drives snugly with zero rattle.

## Real objects and interfaces

| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
|---|---|---|---|---|
| 3.5" HGST HDD thickness (height in bay) | 26.1 mm (standard SFF-8301, user-approved) | snug slide | +0.30 mm (bay height = 26.4 mm) | Z (bay vertical) |
| 3.5" HGST HDD width (lateral slide depth) | 101.6 mm (standard SFF-8301, user-approved) | snug slide | +0.20 mm (pocket depth = 101.8 mm) | Y (lateral slide) |
| 3.5" HGST HDD length (front-to-rear bay span) | 147.0 mm (standard SFF-8301, user-approved) | snug slide | +0.40 mm (bay length = 147.4 mm) | X (front-to-rear) |
| HDD side threaded holes (`#6-32` UNC, 3 per side) | 28.50, 70.16, 130.10 mm from rear; 6.35 mm from bottom (SFF-8301) | free (screw clearance slot) | 3.8 mm × 4.6 mm obround slot for `#6-32` (3.5 mm OD) | Y (outer side face) |
| Front grill to PSU cavity length | 185.0 mm (user-measured) | free | 22.4 mm rear cable space (162.6 mm cage length) | X (front-to-rear) |
| Front grill to HDD front face offset | 12.0 mm target (11–14 mm user-stated) | N/A (structural standoff) | 12.0 mm front standoff | X (front-to-rear) |
| Front grill square mesh (10 × 12 grid) | ~7.2 mm pitch, ~5.5 mm square openings, Y = 53–125 mm (user photo) | free (zip-tie passage) | 4.5 mm × 2.0 mm zip-tie tunnels on 7.25 mm vertical pitch | X / Z |
| Front grill inward notch & rib bumps | 6.0 mm protrusion in Y < 55 mm zone (user-measured) | free (setback clearance) | +2.0 mm margin (8.0 mm full-height setback on inner front zone) | X |
| Case floor (with 1 mm neoprene) to side lip | 125.0 mm width to lip; lip 8.0 mm high × 13.0 mm wide (user-measured) | slide / rest | Base sits at Y <= 124.5 mm; lower drive bottom raised to 24.0 mm (> 8.0 mm lip) | Y / Z |
| Motherboard tray obstacles (M.2 SSD & C-clips) | SSD 12.0 mm, C-clips 15.0 mm protrusion from tray (user-measured) | free | Cage inner wall stays >= 19.5 mm from motherboard tray (4.5–7.5 mm gap) | Y |
| Height under motherboard SATA ports / 5.25" cage | 95.0 mm to MB edge (at Y=0), 110+ mm to SATA cables, 195.0 mm under 5.25" bay (user-measured) | free | Cage total height 102.0 mm (inner wall at Y>=19.5 mm clears MB edge; stays below 110 mm SATA cables) | Z |
| `screw-bar` dovetail mating channel | 14.0 mm wide × 5.0 mm deep dovetail (long multi-boss slide) | snug (calibrated via `gauge` key `"8"`) | `dovetail_clr = 0.80 mm`/side (`1.60 mm` total width) + `0.6 mm` Z floor relief & blunted `45°` corners | Z / Y |

## Overall geometry

* **Case coordinate reference (installed in PC, right-handed print coordinates)**:
  * **Front-to-Rear (`X`, `162.6 mm` total, `-X` = Rear / PSU on left, `+X` = Front Grill on right)**:
    * `x_rear` (`-81.3 mm`) to `x_bay_min` (`-78.1 mm`): `3.2 mm` rear retaining stop flange at the inner corner (`22.4 mm` clear behind the cage to the `185 mm` PSU face).
    * `x_bay_min` (`-78.1 mm`) to `x_bay_max` (`+69.3 mm`): `147.4 mm` snug HDD bay span (`147.0 mm` drive + `0.4 mm` clearance).
    * `x_bay_max` (`+69.3 mm`) to `x_front` (`+81.3 mm`): `12.0 mm` open-truss front grill standoff wall with two vertical zip-tie ladder columns positioned in the flat `10 × 12` mesh zone (`57–124.5 mm` from motherboard tray), an `8.0 mm` deep setback across the inner zone (`19.5–57 mm` from motherboard tray) to clear the `6.0 mm` inward notch and all stamped rib bumps, and `45°` sliced outer XY corners (`7.5 mm` chamfer on both front grill corners `(x_front, y_top)` and `(x_front, y_floor)` to clear upper and lower front-wall protrusions, and `3.0 mm` on `(x_rear, y_top)` and `(x_rear, y_floor)`).
  * **Width: Motherboard Tray to Open Side Panel (`W`, `110.0 mm` total)**:
    * Base feet sit inside the `8.0 mm` side-panel lip (`124.5 mm` from motherboard tray; inner wall + pocket = `3.2 + 101.8 = 105.0 mm`), keeping the inner skeleton wall `19.5 mm` away from the motherboard tray.
    * Above `y = 8.5 mm` (clearing the `8.0 mm` case lip), the outer dovetail housings flare out by `5.0 mm` (`Z = 105.0` to `110.0 mm`) backed by `22.0 mm` wide × `8.0 mm` deep `45°` structural gussets into the main rails.
  * **Height: From Neoprene Floor Upward (`H`, `102.0 mm` total)**:
    * `0` to `24.0 mm`: Raised open-arch base (`base_h = 24.0 mm`). Uses `2.8 mm` floor feet + a **`21.2 mm` tall wide-open under-drive airflow arch** + `2.8 mm` Bay 1 bottom rail so air circulates freely underneath the bottom HDD while using minimal filament.
    * `24.0` to `50.4 mm`: Bay 1 (`26.4 mm` snug height for `26.1 mm` HDD).
    * `50.4` to `72.4 mm`: **`22.0 mm` two-layer inter-drive separator (`mid_shelf_h = 22.0 mm`)** consisting of a dedicated **`2.8 mm` thin perforated top rail for HDD 1**, a **`16.4 mm` completely open air gap**, and a dedicated **`2.8 mm` thin perforated bottom rail for HDD 2**.
    * `72.4` to `98.8 mm`: Bay 2 (`26.4 mm` snug height for `26.1 mm` HDD).
    * `98.8` to `102.0 mm`: `3.2 mm` thin perforated top rail for HDD 2.
* **Reinforced `screw-bar` Locking System (Method 1)**:
  * Two `5.0 mm` thick × `14.0 mm` wide straight dovetail bars (`part="screw-bar"`) slide through three monolithic, full-rail-width (`22.0 mm` wide) gusseted dovetail housings (Bottom `y = 8.5..14.0 mm` with a solid stop ledge at `y = 8.5 mm`, Middle `y = 40.4..62.4 mm` spanning the entire `22.0 mm` inter-drive zone, and Top `y = 86.5..92.0 mm`).
  * Fastening 2 standard `#6-32` HDD screws per bar (`4` total) into the HDDs' outer side holes clamps both drives tightly against the bars and locks the bars vertically in the dovetails.

## Parameters (exposed)

| Name | Default | Range | Unit | Note |
|---|---|---|---|---|
| `part` | `"assembly"` | `["assembly", "print", "cage", "screw-bar", "test-slice", "gauge"]` | — | Part selector |
| `hdd_l` | `147.0` | `[145:0.1:150]` | mm | 3.5" HDD length |
| `hdd_w` | `101.6` | `[100:0.1:104]` | mm | 3.5" HDD width |
| `hdd_h` | `26.1` | `[25:0.1:28]` | mm | 3.5" HDD thickness |
| `hdd_slide_clr_h` | `0.3` | `[0.15:0.05:1.0]` | mm | Snug vertical clearance in each HDD bay |
| `hdd_slide_clr_l` | `0.4` | `[0.2:0.1:1.5]` | mm | Snug front-to-rear length clearance in bay |
| `hdd_slide_clr_w` | `0.2` | `[0.1:0.05:1.0]` | mm | Snug lateral depth clearance before outer lock |
| `front_standoff` | `12.0` | `[10:0.5:16]` | mm | Front grill to HDD front face distance |
| `notch_relief_d` | `8.0` | `[6:0.5:9.5]` | mm | Setback depth on inner front face for 6 mm grill notch |
| `base_h` | `24.0` | `[10:0.5:30]` | mm | Raised open-arch base height under lower HDD |
| `mid_shelf_h` | `22.0` | `[12:0.5:26]` | mm | Total separation between HDD 1 and HDD 2 |
| `rail_t` | `2.8` | `[2.4:0.2:4.0]` | mm | Thin high-airflow shelf rail thickness |
| `wall_t` | `3.2` | `[2.4:0.2:4.5]` | mm | Structural frame wall thickness |
| `screw_hole_d` | `3.8` | `[3.4:0.1:4.2]` | mm | `#6-32` HDD screw clearance hole diameter |
| `ziptie_w` | `4.5` | `[3.0:0.5:6.0]` | mm | Zip-tie slot width |
| `ziptie_t` | `2.0` | `[1.5:0.1:3.0]` | mm | Zip-tie slot thickness |
| `material` | `"PETG"` | `["PLA", "PETG"]` | — | Filament material |
| `fit` | `"snug"` | `["press", "snug", "slide", "free"]` | — | Fit class for printed parts |
| `dovetail_clr` | `0.80` | `[0.20:0.05:1.20]` | mm | Per-side clearance for `screw-bar` dovetail (calibrated with `gauge` key `"8"`) |
| `section` | `false` | `[true, false]` | — | Cut-away view for inspecting rails & channels |
| `section_axis` | `"y"` | `["x", "y"]` | — | Axis for cut-away section |

## Mounting

* **Front grill attachment**: Two vertical zip-tie ladder columns on the front standoff (`12.0 mm` deep), aligned with the `10 × 12` front grill mesh (`7.25 mm` vertical hole pitch, 10 stations across the `92.0 mm` height).
* **Bottom floor & side-lip indexing**: Open-arch feet rest on the `1 mm` adhesive neoprene pad on the case floor and butt against the inner vertical face of the `8.0 mm` side-panel lip, while the reinforced dovetail housings step over the lip at `y >= 8.5 mm`.

## Material and environment

* **Material**: PETG.
* **Environment**: Indoor PC case running 24×7; lightweight space-frame with `11.2 mm` under-drive arch and `16.4 mm` inter-drive gap maximizes passive and front-grill airflow while minimizing filament usage.

## Print orientation and supports

* **Cage (`part="cage"`)**: Modeled and printed **Inner-Wall-Down** on the print bed (`Z = 0` is the flat motherboard-side frame face; footprint `162.6 × 92.0 mm`, height `110.0 mm` in Z). All 4 thin shelf rails, front standoff trusses, and `45°` gusseted dovetail housings print with **zero supports**.
* **Locking bar (`screw-bar`) and `test-slice`**: Printed flat on the bed (`Z = 0`), **zero supports**.

## Assumptions (things not stated by user)

* Standard SFF-8301 3.5" HDD hole locations (`16.90 mm` and `118.50 mm` from front face, `6.35 mm` from bottom face).

## Out of scope

* Active cooling fan mounts.
* Custom SATA power or data cable routing clips outside the enclosure footprint.
