// golden.scad: toolchain verification test
// Spec: AGENTS.md   License: CC BY-NC 4.0
include <BOSL2/std.scad>
use <common/tolerances.scad>
include <common/printing.scad>

/* [Test Dimensions] */
expected_x = 30;
expected_y = 20;
expected_z = 10;

/* [Hidden] */
$fa = 1;
$fs = $preview ? 0.8 : 0.4;
clr = clearance("PLA", "snug", "slot");

assert(clr > 0, "clearance must be positive");
assert(min_wall > 0, "min_wall must be positive");

echo(str("REPORT expected_x=", expected_x));
echo(str("REPORT expected_y=", expected_y));
echo(str("REPORT expected_z=", expected_z));
echo(str("REPORT clr=", clr));

// Geometry: cuboid using BOSL2 primitives and anchors
cuboid([expected_x, expected_y, expected_z], rounding=2, edges="Z", anchor=BOTTOM);
