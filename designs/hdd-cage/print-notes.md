# hdd-cage print notes

Parts:
- Step 1 — Fast Dovetail Fit Gauge (`~12 min` print, tests directly in your existing printed `test-slice`!):
  - `hdd-cage-gauge` (1x) — `77.4 x 34.0 x 4.4 mm` plate with 5 stepped test `screw-bar` keys engraved `"2"`, `"3"`, `"4"`, `"6"`, `"8"` (representing `0.20, 0.30, 0.40, 0.60, 0.80 mm` per-side clearance = `0.40, 0.60, 0.80, 1.20, 1.60 mm` total width clearance, plus `0.6 mm` Z-floor relief and blunted `45°` corners so the sharp tips never wedge in the dovetail root corner).
- Step 2 — Slimmed-Down Fast Validation Plate (`hdd-cage-test-slice`, `< 50 min` total, or right-click -> **Split to Objects** in Bambu Studio to print any of the 3 pieces individually in `10–25 min`!):
  - **Object 1 (Left) — Shallow 4-Boss Dual-Bay Lock Frame (`26.0 x 102.0 x 18.0 mm`, only `18 mm` tall in Z, `~20 min` print)**: Takes just the top `18 mm` of the Front Lock Column (`Z = 92..110 mm` shifted to `Z = 0..18 mm`). Lets you test sliding both 8TB HGST drives into the two `26.4 mm` bays, sliding the full `81.5 mm` `screw-bar` through all 4 bosses, and threading `#6-32` screws into the drives without waiting for a `110 mm` tall print!
  - **Object 2 (Middle) — Calibrated `screw-bar` (`10.8 x 81.5 x 4.4 mm`, `dovetail_clr = 0.80 mm` from gauge key `"8"`, `~10 min` print)**.
  - **Object 3 (Right) — Single-Rail `110 mm` 3-Tier Vent Tower (`10.0 x 30.1 x 110.0 mm`, `~25 min` print, `~7 g`)**: Just ONE thin rail (`Bay 1 Top`) + its top dovetail boss to verify that the 3-tier diamond vents print cleanly up to `Z = 110 mm` with zero wobble (`< 1/10th` the volume of the previous 5-hour block).
- Full enclosure print:
  - `hdd-cage-cage` (1x) — full 2-bay space-frame enclosure (`162.6 x 102.0 x 110.0 mm`)
  - `hdd-cage-screw-bar` (2x) — front and rear dovetail locking bars (or print `hdd-cage-print` which lays the cage and both bars flat on one plate, `171.5 x 122.9 x 110.0 mm`)

Material: PETG (required for continuous 24x7 indoor PC bay thermal stability near 8TB 7200 RPM HGST drives and tougher layer adhesion on the dovetail housings)

Orientation:
- All parts print as modeled with the `Z = 0` face flat on the build plate:
  - `cage` / `test-slice`: Inner motherboard-side frame face sits flat on the bed (`Z = 0`), with the 4 horizontal shelf rails and `45°`-gusseted dovetail bosses growing vertically up to `Z = 110.0 mm`.
  - `screw-bar`: Narrower outer counterbore face (`8.8 mm` wide) sits flat on the bed (`Z = 0`) and flares out at `45°` to the `13.8 mm` wide inner HDD clamping face at `Z = 5.0 mm` (clean `45°` outward overhang, zero supports).
- Load direction vs. layers:
  - When installed in the PC case, gravity pulls the HDDs downward along the `Y` axis (`-Y` toward the neoprene floor), which runs **parallel to the printed XY layer planes** (extrusion perimeters carry the weight continuously in shear/compression rather than Z-axis layer tension).
  - Lateral retention (preventing the HDDs from sliding out toward the open side panel or when the PC is tilted/inverted) is carried along the `Z` axis by the `26.0 mm` wide, `10.0 mm` deep `45°`-gusseted dovetail housings and the 4x `#6-32` screws threaded into the steel HDD chassis.

Supports: none (all horizontal shelf cutouts, zip-tie tunnels, and dovetail gussets use `<= 45°` self-supporting bevels)

Layer height: 0.20 mm (default)

Walls: 4 loops   Top/bottom: 5 top / 4 bottom layers   Infill: 20% gyroid
- Reason for 4 wall loops: Structural load-bearing bracket (`AGENTS.md` Section 5.6); 4 walls (`1.6 mm` per side) also make the `2.8 mm` thin shelf rails and `3.2 mm` structural walls print nearly solid with continuous perimeters for maximum stiffness-to-weight.

Brim:
- `test-slice` and `screw-bar`: none
- `cage` (full print): 5 mm outer brim recommended on textured PEI with PETG to keep the high-aspect-ratio open frame corners (`162.6 x 92.0 mm` footprint, `110.0 mm` Z height) anchored flat with zero corner lift.

Special:
- Hardware needed for final installation: 4x standard `#6-32` UNC HDD screws (`6–8 mm` thread length, pan or hex-washer head `<= 7.2 mm` OD) and 4–6x standard thin zip ties (`<= 4.5 x 2.0 mm`).

Fit test:
1. Slice and print `hdd-cage-test-slice.3mf` (or `.stl`) and 1x `hdd-cage-screw-bar.3mf` first.
2. Check **dovetail sliding fit**: Slide `screw-bar` down through the 4 gusseted dovetail bosses on `test-slice` until it seats against the bottom stop ledge (`y = 8.5 mm`). It should slide smoothly by hand with minimal play (`snug` fit, `0.10 mm` total clearance).
3. Check **HDD bay fit & `#6-32` screw alignment**: Slide the front end of one 8TB HGST HDD into Bay 1 and Bay 2 of `test-slice`, insert the `screw-bar`, and thread a `#6-32` screw through the obround slot into the HDD's front side hole (`16.90 mm` from the drive's front face). Confirm the screw pulls the drive snug against the bar with zero rattle.
4. Check **in-case front grill fit**: Place `test-slice` against the inside of the PC's front grill on the neoprene floor inside the `8.0 mm` side-panel lip:
   - Confirm the `8.0 mm` inner front setback clears the `6.0 mm` inward metal notch and stamped rib bumps cleanly.
   - Confirm the zip-tie ladder slots align with the `10 x 12` square mesh holes and that the `8.0 mm` side-panel lip sits below the `y = 8.5 mm` outer dovetail overhang.
5. Report back:
   - How the `screw-bar` dovetail fit feels (`press` / `snug` / `slide` / `free` / `too tight`).
   - How the HDD vertical (`26.4 mm`) and lateral depth (`101.8 mm`) fit feels once the `#6-32` screw is tightened.
   - Whether any clearance or dimension needs tweaking before printing the full `hdd-cage-cage`.
