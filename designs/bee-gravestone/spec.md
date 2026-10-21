# bee-gravestone spec
Status: APPROVED (2026-10-20), rev 2 (2026-10-20, sharper 3D pyramid stake tips in XY and Z)

## Purpose
Small decorative outdoor garden gravestone (`3.25 in` wide x `4.00 in` body height) with two bottom ground stakes, embossed `"RIP"` / `"BEE"` text, a simple geometric bee symbol, and a raised perimeter border frame. Designed as a 2-piece split model (`front` and `back` halves) printed flat on their inner split faces (`Z = 0`) without supports and glued together back-to-back.

Axes (print orientation for `front` and `back`):
- X: across gravestone width (`body_w`).
- Y: along gravestone height (`-Y` = stake tips, `+Y` = arch top).
- Z: thickness up from print bed (`Z = 0` = flat inner split/glue face). Datum: overall XY bounding box centered on origin.

## Real objects and interfaces
| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
|---|---|---|---|---|
| Front/back split glue face | flat planar mate (`82.55 x 141.60` envelope) | glued (flat face) | 0.00 | Z |
| Garden soil (2 stakes) | `10.0 x 8.0` cross-section, `40.0` long | ground insertion | - | Y |

No mating mechanical slots or holes; `tolerances.scad` clearances are not active.

## Overall geometry

### Tombstone body (XY)
- Width: `body_w = 82.55 mm` (`3.25 in`, user-stated).
- Height above stakes (ground line to arch apex): `body_h = 101.60 mm` (`4.00 in`, user-stated).
- Profile:
  - Upper semicircular arch of radius `arch_r = body_w / 2 = 41.275 mm`.
  - Lower rectangular section of height `rect_h = body_h - arch_r = 60.325 mm`.
  - Bottom outer corners (at ground line `Y_ground`) rounded with `bottom_corner_r = 3.0 mm`.

### Ground stakes (XY & Z)
- Count: 2 stakes extending `-Y` from the bottom edge of the body.
- Length: `stake_l = 40.0 mm` below body (`total_h = body_h + stake_l = 141.60 mm`).
- Width: `stake_w = 10.0 mm` each.
- Spacing: `stake_spacing = 45.0 mm` center-to-center (`X = -22.5 mm` and `+22.5 mm`).
- Tips: bottom `stake_tip_l = 18.0 mm` tapers symmetrically in X down to `stake_tip_w = 0.8 mm` (2 extrusion widths) and slopes in Z from `half_t = 4.0 mm` down to `stake_tip_h = 0.8 mm` at the tip (forming a `0.8 x 1.6 mm` 4-sided pyramid point when the two halves are glued together, while keeping the `Z = 0` glue face completely flat).
- Root fillets: `stake_fillet_r = 3.0 mm` concave XY fillets where stake sides meet the bottom edge of the body.

### Split halves, thickness, and chamfers (Z)
- Each half base thickness: `half_t = 4.0 mm` (glued slab thickness `2 * half_t = 8.0 mm`).
- Outer top edge chamfer (`Z = half_t` face on both `front` and `back`): `edge_chamfer = 1.2 mm` (45 deg) around the entire outer contour (arch, sides, bottom edge, and stakes, doubling as a wedge lead-in at the stake tips).
- Bed-face chamfer (`Z = 0` glue face on both halves): `bed_chamfer = 0.4 mm` around the perimeter to prevent elephant foot from interfering with flat face-to-face gluing.
- `back` half: plain outer face (`Z = half_t`), no embossed text, bee, or border.
- `front` half: base slab (`Z = 0` to `4.0 mm`) plus embossed features raised by `emboss_h = 1.2 mm` (to `Z = 5.2 mm`).
- Glued assembly total thickness: `2 * half_t + emboss_h = 9.2 mm`.

### Front embossed features (`Z = half_t` to `half_t + emboss_h`)
1. **Perimeter border frame**:
   - Follows the tombstone body contour (arch, vertical sides, and horizontal bottom edge above stakes).
   - Inset from outer body edge by `border_inset = 1.5 mm` (just inside `edge_chamfer`), frame width `border_w = 3.0 mm`, corner radius matching outer bottom corners.
2. **Stacked text (`"RIP"` over `"BEE"`)**:
   - Font: `Liberation Sans:style=Bold`, centered on X.
   - Line 1 (`"RIP"`): height `text_size_rip = 15.0 mm`, centered at `Y = Y_ground + 73.0 mm`.
   - Line 2 (`"BEE"`): height `text_size_bee = 15.0 mm`, centered at `Y = Y_ground + 52.0 mm`.
3. **Simple geometric bee symbol**:
   - Centered at `X = 0`, `Y = Y_ground + 22.0 mm` (overall height `~26.0 mm`, width `~32.0 mm`):
     - **Body**: oval `13.0 mm` wide x `17.0 mm` tall with a pointed stinger bottom, divided horizontally by two `1.8 mm` wide gaps into 3 bold raised segments (thorax + 2 abdomen stripes).
     - **Head**: `6.2 mm` diameter circle above the body (`1.2 mm` gap), topped with two simple angled antennae (`1.6 mm` wide, solidly joined to the head at `±30 deg`).
     - **Wings**: two symmetric angled oval loops (`14.0 mm` long x `9.0 mm` wide, `2.1 mm` wall width with recessed interior, angled at `±22 deg`) flanking the upper body.

## Parameters (exposed)
| Name | Default | Range | Unit | Note |
|---|---|---|---|---|
| `part` | `"print"` | `assembly, print, front, back` | - | `print` lays both halves flat on bed with 5 mm gap |
| `body_w` | 82.55 | 50:0.5:200 | mm | 3.25 in gravestone width |
| `body_h` | 101.60 | 60:0.5:200 | mm | 4.00 in gravestone body height (excl. stakes) |
| `half_t` | 4.0 | 2.4:0.2:10 | mm | slab thickness per half (glued slab = `2 * half_t`) |
| `emboss_h` | 1.2 | 0.6:0.2:3.0 | mm | raised height of border, text, and bee |
| `stake_l` | 40.0 | 15:1:80 | mm | stake length below body |
| `stake_w` | 10.0 | 5:0.5:20 | mm | width of each stake |
| `stake_spacing` | 45.0 | 20:1:150 | mm | center-to-center distance between stakes |
| `stake_tip_l` | 18.0 | 5:1:30 | mm | length of tapered point at bottom of stake |
| `stake_tip_w` | 0.8 | 0.8:0.2:5.0 | mm | blunt tip width (>= 2 extrusion widths) |
| `stake_tip_h` | 0.8 | 0.6:0.2:4.0 | mm | Z height of each half at stake tip |
| `stake_fillet_r` | 3.0 | 0:0.5:8.0 | mm | concave fillet radius at stake-to-body root |
| `bottom_corner_r` | 3.0 | 0:0.5:10.0 | mm | lower outer corner radius of gravestone body |
| `edge_chamfer` | 1.2 | 0.4:0.2:2.5 | mm | top outer perimeter chamfer on each half |
| `bed_chamfer` | 0.4 | 0:0.1:1.0 | mm | Z=0 split-face edge chamfer (elephant-foot relief) |
| `border_w` | 3.0 | 1.2:0.2:6.0 | mm | width of raised perimeter border frame |
| `border_inset` | 1.5 | 1.2:0.1:4.0 | mm | inset of border frame from outer edge |
| `text_line1` | `"RIP"` | - | string | top text line |
| `text_line2` | `"BEE"` | - | string | second text line |
| `text_size` | 15.0 | 8:0.5:25 | mm | font height for both lines |
| `bee_scale` | 1.0 | 0.5:0.05:1.5 | - | scale factor for geometric bee symbol |
| `print_gap` | 5.0 | 2:1:20 | mm | X gap between halves in `print` mode |
| `section` | false | - | bool | cut-away debug view |
| `section_axis` | `"y"` | `x, y` | - | default `"y"` cuts at `Y = y_bee` showing XZ cross-section in `section_front` |

REPORT keys: `body_w`, `body_h`, `stake_l`, `total_h`, `half_t`, `emboss_h`, `front_h`, `back_h`, `assembled_t`, `print_w`.

## Mounting
Planted directly in outdoor soil via the two integrated bottom stakes. Front and back halves are bonded flat face-to-face using weather-resistant adhesive (two-part epoxy or polyurethane/outdoor cyanoacrylate).

## Material and environment
- Material: PETG (weather, UV, and moisture resistant; tougher than PLA when pushing stakes into soil).
- Single color (optional filament color swap at `Z = 4.20 mm` on `front` part if contrasting border/text/bee is desired).

## Print orientation and supports
- Both `front` and `back` print flat on their inner split face (`Z = 0`).
- Supports: none (all features face upward; outer edges chamfered at 45 deg).
- Default `print` layout footprint: `170.10 x 141.60 x 5.20 mm` (fits well within `250 x 250 x 250 mm`).

## Assumptions (things not stated by user)
1. Stake dimensions: `40.0 mm` length, `10.0 mm` width, `45.0 mm` center-to-center spacing, `18.0 mm` tip taper to `0.8 mm` width and `0.8 mm` Z height per half, `3.0 mm` root fillet.
2. Slab thickness: `4.0 mm` per half (`8.0 mm` glued slab) + `1.2 mm` embossed height on `front` (`9.2 mm` total assembled thickness).
3. Chamfers: `1.2 mm` outer edge chamfer on both halves; `0.4 mm` bed-edge chamfer on the `Z = 0` split face for elephant-foot relief.
4. Raised border frame: `3.0 mm` wide, inset `1.5 mm` from the outer body edge, around the gravestone body above the stakes.
5. Font and bee geometry: `15.0 mm` bold sans-serif text (`"RIP"` above `"BEE"`) and a minimalist 3-stripe oval bee with circular head, 2 antennae, and 2 outlined oval wings.

## Out of scope
- Back-face lettering or border.
- Separate alignment dowel pins (flat glue faces selected by user).
- Multi-material MMU/AMS painting files (standard layer-height pause works if color change is wanted).
