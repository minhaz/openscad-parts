# laptop-holder idea

Input for `spec.md`. Revised 2026-10-10 after review. All review questions answered; ready for spec.

A parametric stand that holds several laptops and tablets upright on a shelf. Each device stands on one long edge: its longest edge is parallel to the shelf, its second-longest edge is vertical.

## Definitions

Device:
- Length: device's longest edge.
- Height: device's second-longest edge.
- Width: device's thickness (thinnest edge).

Model axes (as printed and as used on the shelf; same orientation):
- X: across the slots (stand width). "Left" = left side when facing the stand's front.
- Y: along the device length (stand length). Front = Y min (ramp end); devices slide in from the front toward the rear.
- Z: up. Bed and shelf face at Z = 0.

## Measurements (user, calipers, 3 points, max value, including rubber feet; not wedge shaped)

| Name | in | mm |
|---|---|---|
| `max_thick_device_length` | 14.25 | 361.95 |
| `max_thick_device_height` | 10.12 | 257.05 |
| `max_thick_device_width` | 0.90 | 22.86 |
| `max_thin_device_length` | 13.00 | 330.20 |
| `max_thin_device_height` | 8.25 | 209.55 |
| `max_thin_device_width` | 0.24 | 6.10 |
| `shelf_clear_height` | 13.25 | 336.55 |
| `shelf_depth` | 15+ (open back) | 381+ |

Which edge stands on the floor (opening edge or hinge) varies per device; user picks. Design must not depend on it.

## Parameters (values confirmed by user)

Slots and walls:

- `thick_device_count`: 2
- `thick_slot_width`: 24.5 mm (22.86 + 1.64 clearance)
- `thick_wall_width`: 4.5 mm
- `thick_wall_height`: 115.0 mm (about 45% of device height), above slot floor
- `thick_wall_length`: 160.0 mm
- `thin_device_count`: 3
- `thin_slot_width`: 7.3 mm (6.10 + 1.20 clearance)
- `thin_wall_width`: 4.0 mm
- `thin_wall_height`: 90.0 mm (about 43% of device height), above slot floor
- `thin_wall_length`: 120.0 mm
- `thick_side`: "left" | "right", default "left". Which side the thick group sits on.

Base and ramp:

- `base_height`: 5.0 mm (floor thickness; slot floor at Z = 5)
- `base_length`: 175.0 mm (excluding ramp)
- `slope_length`: 30.0 mm (front lead-in ramp across all slots; equals `device_front_overhang` so a stored device's front end is flush with the stand's front edge)
- `ramp_lip_height`: 1.0 mm (ramp front edge starts at this height instead of a 0 mm knife edge; ramp angle about 7.6 deg)
- `ramp_blend_r`: 20.0 mm (assumption). Rounds the bend where the ramp meets the slot floor so device edges don't catch.
- `base_corner_radius`: 5.0 mm (rounds the 4 footprint corners in XY, ramp corners included)

Edges:

- `root_fillet_r`: 1.5 mm (user confirmed). Rounded inside corner where each wall meets the slot floor. One value for both "slot floor fillet" and "wall root fillet" (they are the same corner).
- Wall nose: front vertical edge of every wall fully rounded (half-round, radius = wall_width / 2). Guides devices in; no corners to scratch. Replaces the earlier 2.5 mm chamfer, which did not fit on a 4.0 mm wall (needs 5 mm).
- Wall top: fully rounded (half-round, radius = wall_width / 2). Devices lean on it.
- `wall_front_corner_radius`: 15.0 mm. Large round on each wall's front-top corner (in side view). This corner faces the user's hand and is the main lean contact.
- Together these give every wall one soft profile: no sharp points anywhere (user approved 2026-10-10).
- `bed_chamfer`: 0.4 mm on bottom footprint edges (elephant foot). Not applied on the ramp lip (relaxed rule, user approved).

Optional features:

- `side_support_width`: 0.0 mm (0 = off; 25-35 mm typical for 1-2 device setups)
- `side_support_height`: 40.0 mm (where the triangular gusset meets the outer wall)
- `felt_thickness`: 0.0 mm (each slot widens by 2 x felt)
- `finger_grasp_style` (kept per user request; note it does not widen the gap between devices, so it adds little): "teardrop" | "shallow", default "teardrop"
- `finger_grasp_depth`: 0.0 mm (off by default, user chose; devices stick out 30 mm and are gripped there). Typical when on: 20 mm.
- `finger_grasp_radius`: 30.0 mm
- `wall_rear_height_ratio`: 0.7 (user chose). Wall top slopes linearly from full height at the wall front to 70% at the wall rear (thick: 115 to 80.5 mm, thin: 90 to 63 mm). 1.0 = flat top. Range 0.5-1.0.

## Layout rules

- Slot order across X: thick group on `thick_side`, thin group on the other side.
- Wall count and type:
  - Thick group present: `thick_device_count + 1` thick walls (outer wall, dividers, and the wall between groups). Thin group adds `thin_device_count` thin walls (dividers plus its outer wall).
  - Thin only: `thin_device_count + 1` thin walls.
- The wall between groups uses thick values (width, height, length).
- All walls start at the rear end of the ramp (front aligned) and run rearward. Rear of the stand is open.
- Ramp spans the full stand width.

## Derived dimensions (assert each)

```
thick_walls = thick_device_count > 0 ? thick_device_count + 1 : 0
thin_walls  = thick_device_count > 0 ? thin_device_count : thin_device_count + 1
slot_w(t)   = <t>_slot_width + 2 * felt_thickness

Total Width  = thick_device_count * slot_w(thick) + thin_device_count * slot_w(thin)
             + thick_walls * thick_wall_width + thin_walls * thin_wall_width
             + 2 * side_support_width                                    <= 250
Total Length = slope_length + base_length                                <= 250
Total Height = base_height + max(wall heights)                           <= 250
base_height + device height                                              <= shelf_clear_height
<t>_slot_width > max_<t>_device_width
wall lengths <= base_length
```

Reference configurations:

| Config | W | L | H |
|---|---|---|---|
| Default: 2 thick + 3 thin, no felt, no wings | 49.0 + 21.9 + 13.5 + 12.0 = **96.4** | 205.0 | 120.0 |
| 1 thick, wings 30 | 24.5 + 9.0 + 60.0 = **93.5** | 205.0 | 120.0 |
| Max thick only | 8 thick: **236.5** | | |
| Max thin only | 21 thin: **241.3** | | |
| 2 thick + max thin | 2 thick + 16 thin: **243.3** | | |

Shelf check: thick device top = 1.0 (pads) + 5.0 + 257.05 = 263.1 mm, under 336.55 (73 mm spare).
Shelf depth: 381+ mm with an open back, so depth does not limit the design. Device front is flush with the stand's front edge, so the stand can sit at the shelf edge. Device rear then sits 362 mm from the shelf edge, inside the shelf.

## Device placement and tipping (decided: option B)

- Devices slide in horizontally from the front, up the ramp, into the slot. No drop-in from above (shelf has no top clearance).
- Rear is open, so there is no hard stop. User pushes the device in until its front end is flush with the stand's front edge (ramp lip): a clear visual stop.
- Flush-front placement was rejected: the thick laptop's center (181 mm back from the wall front) would sit 6 mm behind the base's rear end, so it tips backward.
- **Decision (user, 2026-10-10):** devices stick out past the wall front by `device_front_overhang` = 30 mm (overhang = how far the device extends in front of the walls). `slope_length` = 30 mm, so the device front lands exactly at the ramp lip.
  - Thick device center: 181 - 30 = 151 mm behind the wall front; base ends 175 mm behind it (24 mm margin).
  - Thin device center: 165 - 30 = 135 mm (40 mm margin).
  - The device's bottom edge stays at slot-floor height over the ramp (the ramp is lower, no contact).
- `device_front_overhang` = `slope_length` (derived). Used for the tipping assertion below.
- Assert for each group: `max_<t>_device_length / 2 - device_front_overhang <= base_length - tip_margin`, where `tip_margin` = 15 mm (assumption).

## Features

- **Lead-in:** rounded wall noses (entry is effectively slot + wall width wide) plus the front ramp guide the device into the slot. Rounded ramp-to-floor bend.
- **Slot floor:** flat, with `root_fillet_r` rounded corners at each wall. The fillet removes the sharp inside corner where bending stress concentrates. Kept small so the device still sits flat on the floor (thin slot: 7.3 - 2 x 1.5 = 4.3 mm flat).
- **Leaning contact:** with clearance, devices lean slightly (thick: about 0.8 deg) and touch the rounded wall tops, mainly near the front (highest point, since the top slopes down to the rear). Rubber feet face the walls.
- **Felt tape (optional):** felt on the wall top rims; `felt_thickness` widens each slot by 2 x felt so the fit stays the same.
- **Finger grasp:** cut into the front vertical edge of each wall, centered at half the wall height above the slot floor. Gives fingers room to grip the device sides near the front. Off by default.
  - `teardrop`: full depth and radius as set; the upper part of the arc is replaced by a 45 deg line so it prints without supports.
  - `shallow`: plain circular arc, depth reduced automatically so the steepest overhang is 45 deg (with radius 30: depth about 8.8 mm).
- **Anti-slip (required):** pulling a device out drags the stand forward. User cuts 1.0 mm silicone pad sheet (12 x 11 in) into strips for the base underside. No pockets modeled; the stand sits 1.0 mm higher.
- **Side supports (optional):** triangular wings on both outer walls, widening the footprint against sideways tipping.
- **Warping:** rounded footprint corners (`base_corner_radius`).
- **Sloped top (on by default, 0.7):** lowers the wall top toward the rear to save filament. Full height stays at the front, where the device leans. Finger grasp center stays at half the *front* wall height.

## Daily use

- Insert: hold the device upright, slide its rear end onto the ramp and between the walls, push until its front is flush with the stand's front edge.
- Remove: grip the device by its top edge (front end) and pull forward. If needed, push neighbors back first so the target device sticks out. Gap between neighbors stays at 5-6 mm (user decision: no wider walls).
- No charging in the stand for now. Open rear and front leave both device ends reachable.

## Fit and clearance

- Not a press/snug fit: devices must slide in by hand and lean. Clearance is set per device group (1.64 thick, 1.20 thin) and does not use `lib/common/tolerances.scad` fit classes.
- Calibration (tolerance coupon, Bambu PLA Basic, 2026-10-10): PLA slot `free` = 0.20 mm total; slots print close to nominal width. So the effective clearance here is about the modeled value (1.64 / 1.20), 6-8x the `free` threshold. Intentional: room for slide-in and a slight lean (about 0.8 deg on both groups).
- Coupon slots were 12 mm deep. Tall walls (90-115 mm) may lean or warp slightly more; the large clearance absorbs this.

## Material and printing

- PLA (Bambu PLA Basic, the calibrated filament). Indoor shelf, no heat or sun.
- Print as used: base on the bed, walls vertical. No supports.
- Load direction: leaning devices bend the walls sideways, pulling layers apart at the wall root (the weakest direction). Root fillets and solid walls handle this; loads are small.
- Wall widths (4.5 / 4.0) are kept. Instead of matching line-width multiples, slice with Wall generator = Arachne and enough wall loops (about 6) that the walls print fully solid with no gap fill.
- Slicer defaults otherwise: 0.20 mm layers, 5 top / 4 bottom, 15% gyroid infill (base).
- Ironing on top surfaces (slot floors, ramp) for smoother sliding.
- Size about 205 x 96 x 120 mm. Filament and time estimate after first export.

## Out of scope

- Rear stop (rear open by design).
- Cable management and charging features (no charging for now).
- Modeled anti-slip pads, pad pockets, or felt.
- Wider finger gaps between devices (user keeps 5-6 mm).
