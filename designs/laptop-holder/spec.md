# laptop-holder spec
Status: APPROVED (2026-10-10)

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
| Thick device in thick slot | width 22.86 (0.90 in) | custom slide + lean (not tolerances.scad) | 1.64 total (slot 24.5) | Y (slide in from front) |
| Thin device in thin slot | width 7.60 (user, 2026-10-10; was 6.10 in idea.md) | custom slide + lean (not tolerances.scad) | 1.20 total (slot 8.8) | Y (slide in from front) |
| Thick device length / height | 361.95 / 257.05 | - | - | tipping, shelf checks |
| Thin device length / height | 330.20 / 209.55 | - | - | tipping, shelf checks |
| Shelf clear height | 336.55 | - | - | Z |
| Shelf depth | 381+ (open back) | - | - | not limiting |

All device dims: calipers, 3 points, max value, including rubber feet, not wedge-shaped. Which device edge (hinge or opening) stands on the floor varies; design does not depend on it.

Clearance rationale: tolerance coupon (Bambu PLA Basic, 2026-10-10) gives PLA slot `free` = 0.20 mm and slots print near nominal, so effective clearance is about the modeled 1.64 / 1.20. Intentional: hand slide-in plus about 0.8 deg lean (thick 0.82 deg, thin 0.76 deg).

## Overall geometry

### Layout across X
- Thick group on `thick_side` (default left), thin group on the other side.
- Walls:
  - Thick group present: `thick_device_count + 1` thick walls (outer, dividers, wall between groups). Thin group adds `thin_device_count` thin walls (dividers + its outer wall).
  - Thin only: `thin_device_count + 1` thin walls.
  - Wall between groups uses thick values (width, height, length).
- Slot width = `<t>_slot_width + 2 * felt_thickness`.

### Base and ramp (Y)
- Ramp: Y = 0 to `slope_length` (30), full stand width. Top rises linearly from `ramp_lip_height` (1.0) at the front edge to `base_height` (5.0). Angle 7.6 deg.
- Ramp-to-floor bend rounded with `ramp_blend_r` (20); tangent length about 1.3 mm each side.
- Slot floor / base: Y = `slope_length` to `slope_length + base_length` (30 to 205), thickness `base_height` (5.0). Slot floor at Z = 5.
- Footprint corners rounded in XY with `base_corner_radius` (5), ramp corners included.
- `bed_chamfer` (0.4) on bottom footprint edges at sides and rear. Not on the front ramp lip.

### Walls
- Every wall starts at Y = `slope_length` (front aligned, rear of ramp) and runs rearward for its `<t>_wall_length` (thick 160, thin 120). Rear 15 mm of base (thick) / 55 mm (thin) has no walls.
- Height above slot floor: full `<t>_wall_height` at wall front, sloping linearly to `wall_rear_height_ratio` x height at wall rear (thick 115 -> 80.5, thin 90 -> 63).
- Edge profile (no sharp points anywhere):
  - Nose (front vertical edge): half-round, r = wall_width / 2.
  - Top: half-round, r = wall_width / 2, following the slope.
  - Front-top corner (side view, YZ): round, r = `wall_front_corner_radius` (15).
  - Root (wall meets slot floor): concave fillet r = `root_fillet_r` (1.5), both sides of dividers; inner side of outer walls.
- Thin slot flat floor between fillets: 8.8 - 2 x 1.5 = 5.8 mm.

### Optional features
- Felt (`felt_thickness` > 0): widens each slot by 2 x felt. Felt not modeled.

### Derived dimensions (asserted)
```
thick_walls  = thick_device_count > 0 ? thick_device_count + 1 : 0
thin_walls   = thick_device_count > 0 ? thin_device_count : thin_device_count + 1
total_w = thick_device_count * slot_w(thick) + thin_device_count * slot_w(thin)
        + thick_walls * thick_wall_width + thin_walls * thin_wall_width <= 250
total_l = slope_length + base_length                               <= 250
total_h = base_height + max(wall heights in use)                   <= 250
base_height + max_<t>_device_height                                <= shelf_clear_height
<t>_slot_width > max_<t>_device_width
<t>_wall_length <= base_length
max_<t>_device_length / 2 - device_front_overhang <= base_length - tip_margin
device_front_overhang = slope_length
thick_device_count + thin_device_count >= 1
ramp_lip_height < base_height
wall widths >= std_wall (2.4); base_height >= 2.4
wall_front_corner_radius <= rear wall height of each type
```

### Reference configurations
| Config | W | L | H |
|---|---|---|---|
| Default: 5 thick + 6 thin, no felt | 122.5 + 52.8 + 27.0 + 24.0 = **226.3** | 205.0 | 120.0 |
| Max thick only | 8 thick: **236.5** | 205.0 | 120.0 |
| Max thin only | 19 thin: **247.2** | 205.0 | 95.0 |
| 5 thick + max thin | 5 thick + 7 thin: **239.1** | 205.0 | 120.0 |

Checks at default:
- Shelf: thick device top = 1.0 (pads) + 5.0 + 257.05 = 263.1, under 336.55 (73 mm spare).
- Tipping: thick center 181.0 - 30 = 151.0 behind wall front, limit 175 - 15 = 160 (9 mm spare vs margin, 24 mm to base end). Thin 135.1 (24.9 mm spare vs margin).

## Parameters (exposed)
| Name | Default | Range | Unit | Note |
|---|---|---|---|---|
| `thick_device_count` | 5 | 0:1:8 | - | |
| `thick_slot_width` | 24.5 | 10:0.1:40 | mm | 22.86 + 1.64 |
| `thick_wall_width` | 4.5 | 2.4:0.1:10 | mm | also wall between groups |
| `thick_wall_height` | 115 | 20:1:200 | mm | above slot floor, at wall front |
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
| `felt_thickness` | 0 | 0:0.1:3 | mm | per side |
| `max_thick_device_length` / `_height` / `_width` | 361.95 / 257.05 / 22.86 | - | mm | measured; checks only |
| `max_thin_device_length` / `_height` / `_width` | 330.20 / 209.55 / 7.60 | - | mm | measured; checks only |
| `shelf_clear_height` | 336.55 | - | mm | measured; checks only |
| `tip_margin` | 15 | 0:1:50 | mm | assumption |
| `section`, `section_axis` | false, "x" | x, y | - | debug cut-away |

Single printable part: no `part` parameter.

REPORT keys: `total_w`, `total_l`, `total_h`, `thick_slot_w`, `thin_slot_w`, `thick_wall_h_front/rear`, `thin_wall_h_front/rear`, `ramp_angle`, `thick_tip_spare`, `thin_tip_spare`, `shelf_spare`, `thin_slot_flat`.

## Mounting
Freestanding on shelf. Anti-slip required: user cuts 1.0 mm silicone pad sheet into strips for the underside (not modeled; stand sits 1.0 mm higher). Placed at the shelf front edge.

## Material and environment
- PLA, Bambu PLA Basic (calibrated filament). Single color.
- Indoor shelf. No heat, sun, moisture.
- Loads: small. Leaning devices bend walls sideways (layer peel at wall root, weakest direction); root fillets and solid walls handle it.

## Print orientation and supports
- As used: base on bed, walls vertical. No supports.
- Default size about 226.3 x 205 x 120 mm (fits 250 bed; 23.7 mm spare in X).
- Slicer notes (for print-notes.md): Arachne wall generator, about 6 wall loops so 4.0/4.5 mm walls print fully solid; 0.20 mm layers; 5 top / 4 bottom; 15% gyroid (base); ironing on top surfaces (slot floors, ramp).

## Assumptions (things not stated by user)
1. `tip_margin` = 15 mm.
2. `ramp_blend_r` = 20 mm.
3. Root fillet runs along the wall's long sides only (full wall length), not around the nose or rear end.
4. Wall rear end: vertical edge half-round (r = wall_width / 2), same as the nose. Not stated in idea.md.
5. Front-top corner round is tangent to the vertical nose line and the sloped top line.
6. Ramp top is flat across X (walls start where the ramp ends; no wall on the ramp).
7. Datum: footprint centered on XY origin (ramp front at Y = -total_l / 2).
8. `wall_front_corner_radius` on a thin wall: 15 <= 63 rear height, no conflict at defaults.

## Out of scope
- Rear stop (rear open by design).
- Cable management, charging features.
- Modeled anti-slip pads, pad pockets, or felt.
- Finger grasp cutouts and side-support wings (dropped for iteration 1, user 2026-10-10; may return later).
- Wider finger gaps between devices (user keeps 5-6 mm).
