// tolerances.scad: measured clearances per material
// License: CC BY-NC 4.0
// PROVISIONAL

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
             (fit == "slide") ? 0.35 :
             (fit == "free")  ? 0.60 : 0.20) :
            ((fit == "press") ? 0.10 :
             (fit == "snug")  ? 0.25 :
             (fit == "slide") ? 0.40 :
             (fit == "free")  ? 0.70 : 0.25)
    )
    base_clr + mat_offset;
