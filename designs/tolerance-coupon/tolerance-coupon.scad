// tolerance-coupon.scad: Tolerance test coupon for slot and pin clearances
// Spec: spec.md   License: CC BY-NC 4.0
include <BOSL2/std.scad>
use <common/tolerances.scad>
include <common/printing.scad>

/* [Part] */
part = "assembly"; // [assembly, print, key, slot-block, pin, hole-plate]

/* [Main dimensions] */
// Key bar length (mm)
key_l = 40.0; // [20:1:60]
// Key bar width (mm)
key_w = 15.0; // [10:1:30]
// Key nominal thickness (mm)
key_t = 4.0; // [2:0.5:8]

// Slot depth (mm)
slot_depth = 12.0; // [6:1:20]
// Extra slot width along Y to avoid side binding (mm)
slot_w_clearance = 1.0; // [0.5:0.5:3.0]

// Pin nominal diameter (mm)
pin_d = 8.0; // [4:0.5:16]
// Pin cylinder height (mm)
pin_h = 20.0; // [10:1:40]

// Hole plate thickness (mm)
plate_t = 5.0; // [3:0.5:10]

// Engraved text font size (mm)
label_size = 5.0; // [4:0.5:8]
// Engraved text depth (mm)
label_depth = 0.6; // [0.4:0.1:1.2]

/* [Fit] */
material = "PLA"; // [PLA, PETG]

/* [Debug] */
section = false;    // cut-away view for checking internals
section_axis = "y"; // [x, y]

/* [Hidden] */
$fa = 1;
$fs = $preview ? 0.8 : 0.4;
eps = 0.01;

// Clearance steps (tenths of mm: 0.0 through 0.6)
clearances = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
num_steps = len(clearances);

// Slot block derived dimensions
slot_wall = 3.0;
end_wall = 3.0;
floor_t = 3.0;
shelf_w = 8.0;
back_wall = 3.0;

slot_l = key_w + slot_w_clearance;
block_w = back_wall + slot_l + shelf_w;
block_h = floor_t + slot_depth;

function slot_width(i) = key_t + clearances[i];
function _slot_x_offset(i) = (i == 0) ? 0 : _slot_x_offset(i - 1) + slot_width(i - 1) + slot_wall;

total_slot_w = sum([for (c = clearances) key_t + c]);
block_l = total_slot_w + (num_steps - 1) * slot_wall + 2 * end_wall;

function slot_x_center(i) = -block_l / 2 + end_wall + _slot_x_offset(i) + slot_width(i) / 2;

slot_y_center = (shelf_w - back_wall) / 2;
slot_text_y_center = -block_w / 2 + shelf_w / 2;

// Hole plate derived dimensions
hole_spacing = 15.0;
plate_end_margin = 8.0;
plate_l = (num_steps - 1) * hole_spacing + 2 * plate_end_margin;
plate_w = 26.0;

hole_y_center = 3.5;
plate_text_y_center = -6.5;

function hole_d(i) = pin_d + clearances[i];
function hole_x_center(i) = -plate_l / 2 + plate_end_margin + i * hole_spacing;

// Assertions
assert(key_l > 0 && key_w > 0 && key_t > 0, "Key dimensions must be positive");
assert(key_t >= min_wall, "Key thickness must be at least min_wall");
assert(pin_d >= min_wall, "Pin diameter must be at least min_wall");
assert(pin_h > 0, "Pin height must be positive");
assert(slot_depth > 0 && slot_depth < key_l, "Slot depth must be positive and less than key length");
assert(plate_t >= min_wall, "Plate thickness must be at least min_wall");
assert(slot_wall >= min_wall, "Slot divider wall must be at least min_wall");
assert(floor_t >= min_wall, "Slot block floor must be at least min_wall");
assert(block_l <= bed_xy && block_w <= bed_xy && block_h <= bed_z, "Slot block must fit build volume");
assert(plate_l <= bed_xy && plate_w <= bed_xy && plate_t <= bed_z, "Hole plate must fit build volume");

// Spec report values
echo(str("REPORT key_l=", key_l));
echo(str("REPORT key_w=", key_w));
echo(str("REPORT key_t=", key_t));
echo(str("REPORT pin_d=", pin_d));
echo(str("REPORT pin_h=", pin_h));
echo(str("REPORT plate_t=", plate_t));
echo(str("REPORT slot_depth=", slot_depth));
echo(str("REPORT slot_min_w=", slot_width(0)));
echo(str("REPORT slot_max_w=", slot_width(num_steps - 1)));
echo(str("REPORT hole_min_d=", hole_d(0)));
echo(str("REPORT hole_max_d=", hole_d(num_steps - 1)));
echo(str("REPORT block_l=", block_l));
echo(str("REPORT block_w=", block_w));
echo(str("REPORT block_h=", block_h));
echo(str("REPORT plate_l=", plate_l));
echo(str("REPORT plate_w=", plate_w));

// Dispatch
apply_section() {
    if (part == "assembly") {
        assembly();
    } else if (part == "print") {
        print_layout();
    } else if (part == "key") {
        part_key();
    } else if (part == "slot-block") {
        part_slot_block();
    } else if (part == "pin") {
        part_pin();
    } else if (part == "hole-plate") {
        part_hole_plate();
    }
}

// Section view debug wrapper
module apply_section() {
    if (section) {
        if (section_axis == "y") {
            back_half(y=0, s=500) children();
        } else {
            right_half(x=0, s=500) children();
        }
    } else {
        children();
    }
}

// 1. Key: flat bar 40 x 15 x 4 mm, printed flat, chamfered at bed face
module part_key() {
    cuboid([key_l, key_w, key_t], chamfer=0.4, edges=BOT, anchor=BOT);
}

// 2. Pin: cylinder D 8 x 20 mm, upright, 0.4 mm chamfer at base, 0.5 mm lead-in at top
module part_pin() {
    cyl(l=pin_h, d=pin_d, chamfer1=0.4, chamfer2=0.5, anchor=BOT, $fn=64);
}

// 3. Slot block: block with 7 slots and engraved labels
module part_slot_block() {
    difference() {
        cuboid([block_l, block_w, block_h], chamfer=0.4, edges=BOT, anchor=BOT);

        // Slots
        for (i = [0 : num_steps - 1]) {
            translate([slot_x_center(i), slot_y_center, floor_t + (slot_depth + eps) / 2])
                cube([slot_width(i), slot_l, slot_depth + eps], center=true);
        }

        // Engraved labels on top face
        for (i = [0 : num_steps - 1]) {
            translate([slot_x_center(i), slot_text_y_center, block_h - label_depth])
                linear_extrude(label_depth + eps)
                text(str(i), size=label_size, halign="center", valign="center");
        }
    }
}

// 4. Hole plate: plate 5 mm thick with 7 vertical holes and engraved labels
module part_hole_plate() {
    difference() {
        cuboid([plate_l, plate_w, plate_t], chamfer=0.4, edges=BOT, anchor=BOT);

        // Holes
        for (i = [0 : num_steps - 1]) {
            translate([hole_x_center(i), hole_y_center, plate_t / 2])
                cylinder(h=plate_t + 2 * eps, d=hole_d(i), center=true, $fn=64);
        }

        // Engraved labels on top face
        for (i = [0 : num_steps - 1]) {
            translate([hole_x_center(i), plate_text_y_center, plate_t - label_depth])
                linear_extrude(label_depth + eps)
                text(str(i), size=label_size, halign="center", valign="center");
        }
    }
}

// Assembly: shows parts in fitted positions with mating features at Y=0 for section analysis
module assembly() {
    // Slot block placed on left, shifted so slot centers are on Y=0
    translate([-40, -slot_y_center, 0]) {
        part_slot_block();
        // Key inserted into slot index 2 (clearance 0.2 mm)
        translate([slot_x_center(2), slot_y_center, floor_t])
            cuboid([key_t, key_w, key_l], chamfer=0.4, edges=BOT, anchor=BOT);
    }

    // Hole plate placed on right, shifted so hole centers are on Y=0
    translate([60, -hole_y_center, 0]) {
        part_hole_plate();
        // Pin inserted into hole index 2 (clearance 0.2 mm)
        translate([hole_x_center(2), hole_y_center, 0])
            cyl(l=pin_h, d=pin_d, chamfer1=0.4, chamfer2=0.5, anchor=BOT, $fn=64);
    }
}

// Print layout: lays all printable parts flat on the bed with >= 5 mm clearance
module print_layout() {
    // Hole plate at front
    translate([0, -20, 0])
        part_hole_plate();

    // Slot block at back left
    translate([-26, 20, 0])
        part_slot_block();

    // Key at back right
    translate([30, 26, 0])
        part_key();

    // Pin at middle right
    translate([30, 8, 0])
        part_pin();
}
