# bee-gravestone print notes

Parts: `out/bee-gravestone-print.3mf` x1 (both halves on one plate, `170.1 x 141.6 x 5.2 mm`), or individually: `out/bee-gravestone-front.3mf` x1 (`82.55 x 141.6 x 5.2 mm`) and `out/bee-gravestone-back.3mf` x1 (`82.55 x 141.6 x 4.0 mm`)
Material: PETG (outdoor UV, moisture, and temperature resistance; higher toughness than PLA when pushing stakes into soil)
Orientation: flat inner split/glue face on bed (`Z = 0` as modeled; embossed features on `front` face upward `+Z`)
Supports: none
Layer height: 0.20 mm (default)
Walls: 4 loops (extra perimeter strength along the 10 mm wide stakes for ground insertion and bending loads)   Top/bottom: 5 / 4 layers   Infill: 20% gyroid
Brim: none (large flat bed contact area; ensure clean PEI plate for PETG to prevent corner lift)
Special:
- **Load direction vs. layers:** Printing flat on the split face (`Z = 0`) places continuous XY perimeter loops along the entire length of the gravestone body and stakes. Soil insertion axial load (`-Y`) and wind/soil bending loads act along the continuous filament strands rather than peeling layers apart in Z tension.
- **Ironing (optional):** Enable top-surface ironing on `front` (`Topmost surface only` or `All top surfaces`) for a smooth stone-like finish on the flat field and raised lettering/bee.
- **Two-color contrast (optional):** Add a pause / filament swap in Bambu Studio at layer 21 (`Z = 4.20 mm`) on `front` so the raised `1.2 mm` border frame, `"R.I.P."`, `"BEE"`, and bee symbol print in a contrasting PETG color.
- **Gluing:** Lightly scuff both flat `Z = 0` inner faces with 120–220 grit sandpaper, clean with isopropyl alcohol, apply two-part epoxy or outdoor-rated polyurethane/cyanoacrylate adhesive (including along the stakes), align the outer edges, and clamp until cured.
Fit test:
- Dry-fit `front` and `back` flat `Z = 0` faces together before gluing to confirm zero elephant-foot interference (`0.4 mm` bed chamfer provides relief) and flush outer perimeter alignment.
- Report back if stake thickness/stiffness needs adjustment for your soil conditions.
