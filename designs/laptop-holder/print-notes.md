# laptop-holder print notes

## Test pieces

### Stepped gauge (print first)
Parts: `out/laptop-holder-gauge.3mf` (4 bars, one plate, 144.3 x 131 x 35 mm)
Material: PLA, Bambu PLA Basic (same as the final stand)
Orientation: as modeled, floor on bed, walls vertical. Supports: none
Layer height: 0.20 mm   Walls: 6 loops, Arachne   Top/bottom: 5 / 4   Infill: 15% gyroid   Brim: none

Bars (back to front): 22.86 mm device, 20 mm, 11 mm, thin 7.6 mm.
Slots left to right, label = clearance in tenths of a mm:
| Bar | "2" | "4" | "6" | "8" | "10" |
|---|---|---|---|---|---|
| 22.86 | 23.06 | 23.26 | 23.46 | 23.66 | 23.86 |
| 20 | 20.20 | 20.40 | 20.60 | 20.80 | 21.00 |
| 11 | 11.20 | 11.40 | 11.60 | 11.80 | 12.00 |
| 7.6 | 7.80 | 8.00 | 8.20 | 8.40 | 8.60 |

Fit test:
1. Measure each slot width with calipers near the top of the walls (optional, a few slots is enough; tells whether slots print at nominal).
2. Stand each device on its edge in each slot of its bar (drop in from above, then slide it along the 20 mm slot). Rate each: binds / snug / good / wiggly.
3. Report the table back. I'll pick the clearance per device: the tightest slot that rated "good", plus a margin of one step (0.2) unless it felt clearly loose-free, because the stand slots are 120-160 mm long and its walls 90-115 mm tall (more room for print waviness than a 20 mm gauge).

### Test slice (after the gauge; reprint with the chosen clearances)
Parts: `out/laptop-holder-test-slice.3mf` x1 (89.6 x 80 x 45 mm). Same settings as the gauge.
- Ramp faces you. Slots left to right: 24.50, 21.64, 12.64, 8.80 (current spec; will change after the gauge result).
- Slide each device in from the front, up the ramp, as in daily use, also slightly off-center and tilted. Report any catch point (ramp, wall front edges, fillets) and any ridge at the fillet toe.
- Check the 1.6 mm wall front edges: clean print, no blobs, stiff enough when pushed sideways by hand?
- Devices lean more here (walls only 40 mm high). Judge fit, not lean.

## Full stand
To be written after the model is approved for export.

Filament option (user agreed 2026-10-10): the 11 walls are ~560 g of the ~780 g model when printed solid (6 loops). To save filament, print walls with 4 loops + 15% gyroid infill instead of solid (estimated 10-20% less total). Trade-off: slightly less stiff walls. Check the test slice printed this way if trying it.
