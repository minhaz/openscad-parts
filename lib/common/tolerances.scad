// tolerances.scad: measured clearances per material
// License: CC BY-NC 4.0
// Calibration date: 2026-10-10
// Printer: Bambu Lab P1S (0.4 mm nozzle, 0.20 mm layer height)
// Calibrated filaments:
//   - PLA: Bambu PLA Basic (measured via designs/tolerance-coupon)
//   - PETG: provisional (+0.05 mm offset over PLA)

// Returns total clearance (mm) added to nominal object dimension.
// material: "PLA" | "PETG"
// fit:      "press" | "snug" | "slide" | "free"
// feature:  "slot" | "hole"
function clearance(material="PLA", fit="snug", feature="slot") =
    let(
        mat_offset = (material == "PETG") ? 0.05 : 0.0,
        base_clr = (feature == "hole") ?
            ((fit == "press") ? 0.10 :
             (fit == "snug")  ? 0.20 :
             (fit == "slide") ? 0.30 :
             (fit == "free")  ? 0.40 : 0.20) :
            ((fit == "press") ? 0.00 :
             (fit == "snug")  ? 0.05 :
             (fit == "slide") ? 0.10 :
             (fit == "free")  ? 0.20 : 0.05)
    )
    base_clr + mat_offset;
