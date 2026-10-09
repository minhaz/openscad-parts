# tolerance-coupon spec
Status: APPROVED (2026-10-09)

## Purpose
Empirical tolerance test coupon to measure real clearances per fit class (press, snug, slide, free) for PLA and PETG on Bambu Lab P1S (0.4 mm nozzle). Measured clearances will replace provisional values in `lib/common/tolerances.scad`.

## Real objects and interfaces
| Interface | Object dim (measured) | Fit class | Clearance (mm) | Axis |
|---|---|---|---|---|
| Key into Slot Block | 4.0 mm nominal thickness | press / snug / slide / free | 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6 | Z insertion |
| Pin into Hole Plate | 8.0 mm nominal diameter | press / snug / slide / free | 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6 | Z insertion |

## Overall geometry
### 1. Key (`key`)
- Flat rectangular bar: 40.0 mm (L) x 15.0 mm (W) x 4.0 mm (T, along Z).
- 0.4 mm chamfer on bed-contact perimeter to mitigate elephant's foot.
- Key thickness measured at 3 points post-print as standard reference.

### 2. Slot Block (`slot-block`)
- Block containing 7 slots with widths: 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6 mm.
- Slot depth: 12.0 mm (along Z). Key sticks out by 28.0 mm as handle.
- Slot length (Y): 16.0 mm (clears 15.0 mm key width with 1.0 mm total play to isolate thickness friction).
- Wall thickness between slots: 3.0 mm.
- Floor thickness below slots: 3.0 mm.
- Total block height: 15.0 mm (12.0 mm depth + 3.0 mm floor).
- Total block footprint: ~54.1 mm (X) x 26.0 mm (Y).
- Engraved labels "0" through "6" (representing tenths of mm clearance above 4.0 mm): 5.0 mm font, 0.6 mm deep, on top face adjacent to each slot.
- 0.4 mm chamfer on bed-contact perimeter.

### 3. Pin (`pin`)
- Cylinder: 8.0 mm diameter x 20.0 mm height (along Z).
- 0.4 mm chamfer at base (bed face).
- 0.5 mm chamfer at top edge for lead-in insertion.
- Pin diameter measured at 3 points post-print as standard reference.

### 4. Hole Plate (`hole-plate`)
- Flat plate 5.0 mm thick containing 7 through-holes.
- Hole diameters: 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6 mm.
- Hole center spacing: 15.0 mm; edge margins: 6.0 mm.
- Total plate footprint: 102.0 mm (X) x 22.0 mm (Y) x 5.0 mm (Z).
- Engraved labels "0" through "6": 5.0 mm font, 0.6 mm deep, on top face adjacent to each hole.
- 0.4 mm chamfer on bed-contact perimeter.

## Parameters (exposed)
| Name | Default | Range | Unit | Note |
|---|---|---|---|---|
| `part` | "assembly" | ["assembly", "print", "key", "slot-block", "pin", "hole-plate"] | string | Part selector |
| `key_l` | 40.0 | [20:1:60] | mm | Key bar length |
| `key_w` | 15.0 | [10:1:30] | mm | Key bar width |
| `key_t` | 4.0 | [2:0.5:8] | mm | Key nominal thickness |
| `slot_depth` | 12.0 | [6:1:20] | mm | Slot depth |
| `slot_w_clearance` | 1.0 | [0.5:0.5:3.0] | mm | Extra width along Y to avoid side binding |
| `pin_d` | 8.0 | [4:0.5:16] | mm | Pin nominal diameter |
| `pin_h` | 20.0 | [10:1:40] | mm | Pin cylinder height |
| `plate_t` | 5.0 | [3:0.5:10] | mm | Hole plate thickness |
| `clearances` | [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6] | - | mm list | Clearance steps |
| `label_size` | 5.0 | [4:0.5:8] | mm | Engraved text font size |
| `label_depth` | 0.6 | [0.4:0.1:1.2] | mm | Engraved text depth |

## Mounting
Freestanding gauge pieces; no hardware mounting.

## Material and environment
- Material: PLA, PETG.
- Environment: Indoor ambient.
- Single color.

## Print orientation and supports
- All parts printed flat on bed at Z=0.
- `key`: 40 x 15 mm face on bed, 4.0 mm height along Z.
- `slot-block`: bottom face on bed, slot openings facing upward (Z+), slot walls vertical.
- `pin`: cylinder base on bed, axis along Z.
- `hole-plate`: bottom face on bed, hole axes vertical along Z.
- Supports: none required.
- Print layout (`part = "print"`): all 4 parts spaced flat on bed with >= 5 mm spacing.

## Assumptions (things not stated by user)
- Slot length is 16.0 mm (1.0 mm wider than key) to prevent side-wall friction from interfering with thickness measurement.
- Engraved labels "0" to "6" correspond to tenths of a millimeter above nominal (0.0 to 0.6 mm).
- Wall between slots is 3.0 mm and floor is 3.0 mm (both exceed std_wall = 2.4 mm).
- Hole spacing on hole plate is 15.0 mm center-to-center (leaving 6.4 mm min wall between 8.6 mm hole and neighbor).
- Bed-contact edges chamfered at 0.4 mm to suppress elephant's foot.
- Pin top chamfered at 0.5 mm for lead-in.

## Out of scope
- Fastener threads, heat-set inserts, or countersinks (addressed in subsequent test blocks).
- Multi-material printing.
