# laptop-holder spec
Status: APPROVED (2026-10-10), rev 2 (2026-10-10, per-slot thick widths; user chose option 1), rev 3 (2026-10-10, 4 thick devices: one 20 mm device dropped), rev 4 (2026-10-10, nose taper + rake, user), rev 5 (2026-10-10, stepped gauge)

Source: `ref/idea.md` (user, revised 2026-10-10). Numbers below are user-stated or user-measured unless listed under Assumptions.

## Purpose
Parametric shelf stand that holds several laptops and tablets upright, each standing on a long edge (longest edge parallel to shelf, second-longest edge vertical). Devices slide in horizontally from the front over a lead-in ramp, lean slightly against rounded wall tops, and stick out 30 mm in front of the walls (flush with the stand's front edge). Open rear, no stop.

Terms: device length = longest edge, height = second-longest edge, width = thickness.

Axes (print = use orientation):
- X: across slots. Left = left when facing the stand front.
- Y: along device length. Front = Y min (ramp end). Devices enter from the front toward +Y.
- Z: up. Bed/shelf face at Z = 0. Datum: footprint centered on XY origin.

## Real objects and interfaces
| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
|---|---|---|---|---|
| Thick device 1 (slot 1) | width 22.86 (0.90 in) | custom slide + lean (not tolerances.scad) | 1.64 total (slot 24.50) | Y (slide in from front) |
| Thick device 2 | width 20.0 | same | 1.64 total (slot 21.64) | Y |
| Thick devices 3, 4 | width 11.0 | same | 1.64 total (slot 12.64) | Y |
| Thin device in thin slot | width 7.60 (user, 2026-10-10; was 6.10 in idea.md) | custom slide + lean (not tolerances.scad) | 1.20 total (slot 8.8) | Y (slide in from front) |
| Thick device 1 length / height | 361.95 / 257.05 | - | - | tipping, shelf checks |
| Thick device 2 length / height | 323.85 / 228.60 (12.75 x 9 in, user-stated) | - | - | tipping, shelf checks |
| Thick devices 3, 4 length / height | 304.80 / 203.20 (12 x 8 in, user-stated) | - | - | tipping, shelf checks |
| Thin device length / height | 330.20 / 209.55 | - | - | tipping, shelf checks |
| Shelf clear height | 336.55 | - | - | Z |
| Shelf depth | 381+ (open back) | - | - | not limiting |

All device widths: calipers, 3 points, max value, including rubber feet, not wedge-shaped. Which device edge (hinge or opening) stands on the floor varies; design does not depend on it.

Clearance rationale: tolerance coupon (Bambu PLA Basic, 2026-10-10) gives PLA slot `free` = 0.20 mm and slots print near nominal, so effective clearance is about the modeled 1.64 / 1.20. Intentional: hand slide-in plus about 0.8 deg lean (thick 0.82 / 0.91 / 1.03 deg for 115 / 103 / 91 mm walls, thin 0.76 deg).

## Overall geometry

### Layout across X
- Thick group on `thick_side` (default left), thin group on the other side.
- Thick group: one slot per entry of `thick_device_widths`, in list order from the outer (left) edge inward: 22.86, 20, 11, 11 -> slots 24.50, 21.64, 12.64, 12.64. `thick_device_count` = list length (derived).
- Walls:
  - Thick group present: `thick_device_count + 1` thick walls (outer, dividers, wall between groups). Thin group adds `thin_device_count` thin walls (dividers + its outer wall).
  - Thin only: `thin_device_count + 1` thin walls.
  - Wall between groups uses thick width and length; height per the Walls section.
- Slot width: thick slot i = `thick_device_widths[i] + thick_clearance + 2 * felt_thickness`; thin = `thin_slot_width + 2 * felt_thickness`.

### Base and ramp (Y)
- Ramp: Y = 0 to `slope_length` (30), full stand width. Top rises linearly from `ramp_lip_height` (1.0) at the front edge to `base_height` (5.0). Angle 7.6 deg.
- Ramp-to-floor bend rounded with `ramp_blend_r` (20); tangent length about 1.3 mm each side.
- Slot floor / base: Y = `slope_length` to `slope_length + base_length` (30 to 205), thickness `base_height` (5.0). Slot floor at Z = 5.
- Footprint corners rounded in XY with `base_corner_radius` (5), ramp corners included.
- `bed_chamfer` (0.4) on bottom footprint edges at sides and rear. Not on the front ramp lip.

### Walls
- Every wall starts at Y = `slope_length` (front aligned, rear of ramp) and runs rearward for its `<t>_wall_length` (thick 160, thin 120). Rear 15 mm of base (thick) / 55 mm (thin) has no walls.
- Wall height (front): thin walls `thin_wall_height`. Thick walls: each thick slot i has `thick_wall_heights[i]` (115, 103, 91, 91 = about 45% of device height); a thick wall takes the max of its neighboring slots' heights (wall between groups: max of last thick slot and `thin_wall_height`). Default thick walls left to right: 115, 115, 103, 91, 91.
- Height above slot floor: full wall height at the peak of the front-top corner round (`wall_front_corner_radius` behind the nose), sloping linearly to `wall_rear_height_ratio` x height at wall rear (thick 115 -> 80.5, thin 90 -> 63). (Clarified 2026-10-10: a slope starting at the nose let the corner round cut peak height to 111.4 mm.)
- Front lead-in (rev 4, user: devices seemed likely to catch on the rounded noses):
  - Taper (plan view): wall half-width grows linearly from `nose_tip_width` / 2 (1.6 mm tip, fully rounded) at the front edge to wall_width / 2 over `nose_taper_length` (25), measured behind the raked front edge. Taper per side 3.3 deg (thick) / 2.7 deg (thin). Slot opening at the front edge = slot + taper of both neighbors (e.g. 24.50 -> 27.40, 8.80 -> 11.20).
  - Rake (side view): front edge leans back `nose_rake` (15 deg) from vertical, so the device bottom enters first. Setback at the top: 30.8 mm (115 wall), 24.1 (90 wall).
- Edge profile (no sharp points anywhere):
  - Front edge: rounded with the local half-width (0.8 mm at the tip).
  - Top: half-round with the local half-width, following the slope.
  - Front-top corner (side view, YZ): round, r = `wall_front_corner_radius` (15), tangent to the raked front edge and the sloped top. Must be >= wall_width / 2.
  - Root (wall meets slot floor): concave fillet r = `root_fillet_r` (1.5), all around each wall incl. tapered nose and rear end, following the rake; outer walls: not on the outer face.
- Thin slot flat floor between fillets: 8.8 - 2 x 1.5 = 5.8 mm.

### Optional features
- Felt (`felt_thickness` > 0): widens each slot by 2 x felt. Felt not modeled.

### Derived dimensions (asserted)
```
thick_device_count = len(thick_device_widths); lists must have equal length
thick_walls  = thick_device_count > 0 ? thick_device_count + 1 : 0
thin_walls   = thick_device_count > 0 ? thin_device_count : thin_device_count + 1
total_w = sum(thick slot widths) + thin_device_count * slot_w(thin)
        + thick_walls * thick_wall_width + thin_walls * thin_wall_width <= 250
total_l = slope_length + base_length                               <= 250
total_h = base_height + max(wall heights in use)                   <= 250
pad + base_height + max(all device heights)                        <= shelf_clear_height
thick_clearance > 0; thin_slot_width > max_thin_device_width
<t>_wall_length <= base_length
device_length / 2 - device_front_overhang <= base_length - tip_margin   (each thick device, thin max)
device_front_overhang = slope_length
thick_device_count + thin_device_count >= 1
ramp_lip_height < base_height
wall widths >= std_wall (2.4); base_height >= 2.4
wall_front_corner_radius <= rear wall height of each type
```

### Reference configurations
| Config | W | L | H |
|---|---|---|---|
| Default: 4 thick (per-slot) + 6 thin, no felt | 71.42 + 52.8 + 22.5 + 24.0 = **170.72** | 205.0 | 120.0 |
| Max thin only | 19 thin: **247.2** | 205.0 | 95.0 |
| 4 thick (per-slot) + max thin | 4 thick + 12 thin: **247.52** | 205.0 | 120.0 |

Checks at default:
- Shelf: thick device top = 1.0 (pads) + 5.0 + 257.05 = 263.1, under 336.55 (73 mm spare).
- Tipping (limit 175 - 15 = 160 behind wall front): thick 1: 181.0 - 30 = 151.0 (9.0 spare); thick 2: 161.9 - 30 = 131.9 (28.1); thick 3, 4: 152.4 - 30 = 122.4 (37.6); thin: 135.1 (24.9).

## Parameters (exposed)
| Name | Default | Range | Unit | Note |
|---|---|---|---|---|
| `thick_device_widths` | [22.86, 20, 11, 11] | - | mm | measured; one slot each, left to right; [] = thin only |
| `thick_clearance` | 1.64 | 0.2:0.01:5 | mm | total, added to each thick device width |
| `thick_wall_heights` | [115, 103, 91, 91] | - | mm | per thick slot, front height above floor |
| `thick_wall_width` | 4.5 | 2.4:0.1:10 | mm | also wall between groups |
| `thick_wall_length` | 160 | 20:1:220 | mm | |
| `thin_device_count` | 6 | 0:1:19 | - | |
| `thin_slot_width` | 8.8 | 3:0.1:20 | mm | 7.60 + 1.20 |
| `thin_wall_width` | 4.0 | 2.4:0.1:10 | mm | |
| `thin_wall_height` | 90 | 20:1:200 | mm | above slot floor, at wall front |
| `thin_wall_length` | 120 | 20:1:220 | mm | |
| `thick_side` | "left" | left, right | - | |
| `base_height` | 5.0 | 2.4:0.1:15 | mm | slot floor Z |
| `base_length` | 175 | 50:1:220 | mm | excl. ramp |
| `slope_length` | 30 | 5:1:60 | mm | = device_front_overhang |
| `ramp_lip_height` | 1.0 | 0.4:0.1:5 | mm | |
| `ramp_blend_r` | 20 | 0:1:50 | mm | 0 = sharp bend |
| `base_corner_radius` | 5 | 0:0.5:20 | mm | XY footprint corners |
| `root_fillet_r` | 1.5 | 0:0.1:5 | mm | |
| `wall_front_corner_radius` | 15 | 0:1:50 | mm | |
| `bed_chamfer` | 0.4 | 0:0.1:1 | mm | |
| `wall_rear_height_ratio` | 0.7 | 0.5:0.05:1.0 | - | 1.0 = flat top |
| `nose_taper_length` | 25 | 0:1:60 | mm | 0 = no taper |
| `nose_tip_width` | 1.6 | 0.8:0.1:4.5 | mm | >= 2 extrusion widths |
| `nose_rake` | 15 | 0:1:30 | deg | from vertical, leaning back |
| `felt_thickness` | 0 | 0:0.1:3 | mm | per side |
| `thick_device_lengths` | [361.95, 323.85, 304.8, 304.8] | - | mm | checks only |
| `thick_device_heights` | [257.05, 228.6, 203.2, 203.2] | - | mm | checks only |
| `max_thin_device_length` / `_height` / `_width` | 330.20 / 209.55 / 7.60 | - | mm | measured; checks only |
| `shelf_clear_height` | 336.55 | - | mm | measured; checks only |
| `tip_margin` | 15 | 0:1:50 | mm | assumption |
| `section`, `section_axis` | false, "y" | x, y | - | debug cut-away; y = XZ cut 40 mm behind wall fronts, x = YZ cut through first divider |

`part` parameter (added 2026-10-10, user): `stand` (default, the full stand), `test-slice`, `gauge`. See Test pieces.
Lists with more than 4 entries are not editable in the OpenSCAD Customizer panel; edit them in the file.

REPORT keys: `slot_entry_w` (list), `nose`, `total_w`, `total_l`, `total_h`, `thick_slot_w` (list), `thin_slot_w`, `thick_wall_h_front` (list per wall), `thin_wall_h_front/rear`, `thin_wall_h_front/rear`, `ramp_angle`, `thick_tip_spare` (min over thick devices), `thin_tip_spare`, `shelf_spare`, `thin_slot_flat`.

## Test pieces (added 2026-10-10, user)
Fit tests before the full print. Both use the stand's code, slot widths, clearances, wall widths and edge shapes; only lengths and heights change.
- `test-slice`: one slot per distinct thick width (widest left: 24.50, 21.64, 12.64) + one thin slot (8.8); 5 walls. Full ramp (30) + `test_base_length` 50 of base; walls `test_wall_length` 40 long, `test_wall_height` 40 high (rear 28). Size 89.58 x 80 x 45. Tests fit, slide-in over ramp/noses/fillets, wall surface. Not tipping (base too short), not lean at full height (lean about 2.3 deg vs 0.8), not base warping. Tipping and shelf assertions are off in test modes.
- `gauge` (rev 5, stepped; user: all test-print slots felt wiggly): 4 separate bars on one plate, one per device thickness (22.86, 20, 11, 7.6), thickest at the back, 5 mm apart. Each bar: 5 slots at device + `gauge_clearances` [0.2, 0.4, 0.6, 0.8, 1.0], smallest left; stand wall widths (4.5 thick / 4.0 thin) and 1.5 root fillets; walls `gauge_wall_height` 30 above a 5 mm floor (taller than the old 10 so tilt in the slot is closer to the stand's), tops rounded r 1; slots `gauge_length` 20, open at both ends; 9 mm front ledge with engraved labels = clearance in tenths (5 mm text, 0.6 deep). Layout 144.3 x 131 x 35. Bars are separate because a 300+ mm device standing in one bar would cross the others.

| Name | Default | Range | Unit |
|---|---|---|---|
| `test_wall_height` | 40 | 20:1:120 | mm |
| `test_wall_length` | 40 | 20:1:100 | mm |
| `test_base_length` | 50 | 30:1:120 | mm |
| `gauge_clearances` | [0.2, 0.4, 0.6, 0.8, 1.0] | - | mm |
| `gauge_length` | 20 | 10:1:40 | mm |
| `gauge_wall_height` | 30 | 5:1:60 | mm |
| `gauge_ledge` | 9 | 6:1:15 | mm |
| `gauge_label_size` / `_depth` | 5 / 0.6 | - | mm |

## Mounting
Freestanding on shelf. Anti-slip required: user cuts 1.0 mm silicone pad sheet into strips for the underside (not modeled; stand sits 1.0 mm higher). Placed at the shelf front edge.

## Material and environment
- PLA, Bambu PLA Basic (calibrated filament). Single color.
- Indoor shelf. No heat, sun, moisture.
- Loads: small. Leaning devices bend walls sideways (layer peel at wall root, weakest direction); root fillets and solid walls handle it.

## Print orientation and supports
- As used: base on bed, walls vertical. No supports.
- Default size about 170.7 x 205 x 120 mm.
- Slicer notes (for print-notes.md): Arachne wall generator, about 6 wall loops so 4.0/4.5 mm walls print fully solid; 0.20 mm layers; 5 top / 4 bottom; 15% gyroid (base); ironing on top surfaces (slot floors, ramp).

## Assumptions (things not stated by user)
1. `tip_margin` = 15 mm.
2. `ramp_blend_r` = 20 mm.
3. Root fillet wraps all around each wall's footprint (both sides, nose, rear end); on outer walls the part outside the stand's side face is clipped. (Changed 2026-10-10: square fillet ends at the nose caught sliding devices, observed in CAD inspection.) Where the ramp bend dips below floor level in front of the nose (<= 0.2 mm), the fillet toe continues as an 18 deg wedge, not a step.
4. Wall rear end: vertical edge half-round (r = wall_width / 2), same as the nose. Not stated in idea.md.
5. Front-top corner round is tangent to the vertical nose line and the sloped top line.
6. Ramp top is flat across X (walls start where the ramp ends; no wall on the ramp).
7. Datum: footprint centered on XY origin (ramp front at Y = -total_l / 2).
8. `wall_front_corner_radius` on a thin wall: 15 <= 63 rear height, no conflict at defaults.
9. Thick wall heights 103 / 91 (about 45% of device heights 228.6 / 203.2, same ratio as the approved 115 for 257.05). Wall lengths stay 160 for all thick walls.
10. Rake 15 deg: user asked for a rake, value chosen from the proposed 15-20 range (low end keeps more wall at the front-top lean contact).

## Out of scope
- Rear stop (rear open by design).
- Cable management, charging features.
- Modeled anti-slip pads, pad pockets, or felt.
- Finger grasp cutouts and side-support wings (dropped for iteration 1, user 2026-10-10; may return later).
- Wider finger gaps between devices (user keeps 5-6 mm).
