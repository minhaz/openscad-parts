# tolerance-coupon print notes

Parts:
- `key`: 1 piece
- `slot-block`: 1 piece
- `pin`: 1 piece
- `hole-plate`: 1 piece
(All 4 parts can be printed together using `tolerance-coupon-print.3mf` / `.stl`, or individually)

Material: PLA first, then PETG (to empirically calibrate clearances for both materials in `lib/common/tolerances.scad`)
Orientation: As modeled, all bed-contact faces at Z=0 flat on the build plate
Supports: none
Layer height: 0.20 mm (standard)
Walls: 3 loops (0.4 mm nozzle -> 1.2 mm wall perimeter)
Top/bottom: 5 top / 4 bottom layers
Infill: 15% gyroid
Brim: none (unless bed adhesion issues occur; pin has 8 mm circular base)
Special: Ensure elephant foot compensation in slicer is standard/default so test coupon reflects real production parts

## Fit test instructions
1. Use digital calipers to measure:
   - Printed `key` thickness at 3 distinct points along its length; record the maximum measured value ($T_{\text{meas}}$).
   - Printed `pin` diameter at 3 distinct points along its height; record the maximum measured value ($D_{\text{meas}}$).
2. For each slot ("0" through "6") on `slot-block`:
   - Insert `key` vertically into the slot.
   - Record fit classification: `does-not-fit`, `press`, `snug`, `slide`, or `free`.
3. For each hole ("0" through "6") on `hole-plate`:
   - Insert `pin` vertically into the hole from the top face.
   - Record fit classification: `does-not-fit`, `press`, `snug`, `slide`, or `free`.
4. Report back the completed table to calculate empirical clearances and update `lib/common/tolerances.scad`.
