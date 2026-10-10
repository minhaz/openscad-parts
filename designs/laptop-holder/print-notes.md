# laptop-holder print notes

## Test pieces (print first: gauge, then test slice)

Parts: `out/laptop-holder-gauge.3mf` x1, `out/laptop-holder-test-slice.3mf` x1 (STL alongside)
Material: PLA, Bambu PLA Basic (calibrated filament; same as the final stand)
Orientation: as modeled, base on bed (Z=0), walls vertical
Supports: none
Layer height: 0.20 mm
Walls: 6 loops, Wall generator = Arachne (4.0 / 4.5 mm walls print fully solid, no gap fill)   Top/bottom: 5 / 4 layers   Infill: 15% gyroid
Brim: none
Special: ironing on top surfaces (slot floors, ramp) for smoother sliding. Same settings planned for the full stand, so the test is representative.

Sizes: gauge 89.6 x 20 x 15 mm; test slice 89.6 x 80 x 45 mm.

### Fit test
Slot widths (nominal): 24.50 (23 mm device), 21.64 (20 mm devices), 12.64 (11 mm devices), 8.80 (thin devices).
The gauge has no labels: the widest slot (24.50) is at one end, the narrowest (8.80) at the other.

1. Gauge (fit only):
   - Measure each slot width with calipers at the top of the walls (gauge cut is 10 mm tall). Report 4 values.
   - Stand each device on its edge in its slot (drop in from above). Rate each: binds / snug / good slide / loose. Target: slides in by hand without force, small visible gap.
2. Test slice (entry + slide; walls taper to a 1.6 mm rounded front edge and lean back 15 deg):
   - Ramp faces you. Slots left to right: 24.50, 21.64, 12.64, 8.80.
   - Slide each device in from the front, up the ramp, as in daily use. Try it slightly off-center and slightly tilted too. Report: does it catch anywhere (ramp, wall front edges, fillets at the wall base)? Any ridge felt at the fillet toe in front of the walls?
   - Check the 1.6 mm front edges: printed cleanly, no stringing or blobs, stiff enough when pushed sideways by hand?
   - Feel the wall faces and tops: any rough seams, zits or blobs where a device rubs?
   - Note: devices lean about 2.3 deg here (walls only 40 mm high); the full stand leans about 0.8 deg. Judge fit, not lean.
3. Report back: 4 gauge widths, per-slot fit rating, any catch points (where), surface issues.

## Full stand
To be written after the model is approved for export.

Filament option (user agreed 2026-10-10): the 11 walls are ~560 g of the ~780 g model when printed solid (6 loops). To save filament, print walls with 4 loops + 15% gyroid infill instead of solid (estimated 10-20% less total). Trade-off: slightly less stiff walls. Check the test slice printed this way if trying it.
