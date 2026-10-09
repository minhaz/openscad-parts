// printing.scad: printer constants, min wall, layer height, helpers
// License: CC BY-NC 4.0
// PROVISIONAL

nozzle   = 0.4;
layer_h  = 0.2;
min_wall = 1.2;
std_wall = 2.4;
bed_xy   = 250;
bed_z    = 250;

// Helper function: calculate wall thickness for N perimeter loops
function wall_loops(loops=3) = loops * nozzle;
