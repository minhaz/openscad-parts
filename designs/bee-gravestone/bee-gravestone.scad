// bee-gravestone.scad: 2-piece split garden gravestone with "RIP BEE" and bee icon
// Spec: spec.md   License: CC BY-NC 4.0
include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
use <common/tolerances.scad>
include <common/printing.scad>

/* [Part] */
// Printable layout, assembled preview, or individual halves
part = "print"; // [assembly, print, front, back]

/* [Main dimensions] */
// Gravestone body width (mm, 3.25 in = 82.55)
body_w = 82.55; // [50:0.05:200]
// Gravestone body height above stakes (mm, 4.00 in = 101.60)
body_h = 101.60; // [60:0.1:200]
// Base slab thickness per half (mm; glued slab = 2 * half_t)
half_t = 4.0; // [2.4:0.2:10]
// Embossed feature height on front half (mm)
emboss_h = 1.2; // [0.6:0.2:3.0]

/* [Stakes] */
// Stake length extending below body (mm)
stake_l = 40.0; // [15:1:80]
// Width of each stake (mm)
stake_w = 10.0; // [5:0.5:20]
// Center-to-center spacing between the two stakes (mm)
stake_spacing = 45.0; // [20:1:150]
// Length of tapered point at bottom of each stake (mm)
stake_tip_l = 18.0; // [5:1:30]
// Blunt tip width at the very bottom of each stake (mm)
stake_tip_w = 0.8; // [0.8:0.2:5.0]
// Z thickness of each half at the very bottom tip of each stake (mm)
stake_tip_h = 0.8; // [0.6:0.2:4.0]
// Concave fillet radius where stakes meet body bottom edge (mm)
stake_fillet_r = 3.0; // [0:0.5:8.0]

/* [Cosmetics & Relief] */
// Lower outer corner radius of gravestone body (mm)
bottom_corner_r = 3.0; // [0:0.5:10.0]
// Top outer edge 45-deg chamfer on each half (mm)
edge_chamfer = 1.2; // [0.4:0.2:2.5]
// Bed-face (Z=0 glue face) chamfer for elephant-foot relief (mm)
bed_chamfer = 0.4; // [0:0.1:1.0]
// Raised perimeter border frame width (mm)
border_w = 3.0; // [1.2:0.2:6.0]
// Inset of border frame from outer body perimeter (mm)
border_inset = 1.5; // [1.2:0.1:4.0]
// First text line (upper)
text_line1 = "R.I.P.";
// Second text line (lower)
text_line2 = "BEE";
// Font height for text lines (mm)
text_size = 15.0; // [8:0.5:25]
// Scale factor for the geometric bee icon
bee_scale = 1.0; // [0.5:0.05:1.5]
// Gap between front and back halves in print mode (mm)
print_gap = 5.0; // [2:1:20]

/* [Debug] */
// Cut-away view for checking cross-section
section = false;
// Axis for section cut ("y" cuts at Y=y_bee showing XZ profile in front view; "x" cuts through front center)
section_axis = "y"; // [x, y]

/* [Hidden] */
$fa = 1;
$fs = $preview ? 0.8 : 0.4;
eps = 0.01;

// Derived dimensions
arch_r = body_w / 2;
rect_h = body_h - arch_r;
total_h = body_h + stake_l;
front_h = half_t + emboss_h;
back_h = half_t;
assembled_t = 2 * half_t + emboss_h;
print_w = 2 * body_w + print_gap;

// Y coordinates (centered on overall height total_h)
y_min = -total_h / 2;
y_tip_top = y_min + stake_tip_l;
y_ground = y_min + stake_l;
y_max = total_h / 2;
y_arch = y_max - arch_r;

// Stake X centers
sx_l = -stake_spacing / 2;
sx_r = stake_spacing / 2;

// Layout Y positions on front face (relative to y_ground)
y_line1 = y_ground + 73.0 * (body_h / 101.60);
y_line2 = y_ground + 52.0 * (body_h / 101.60);
y_bee   = y_ground + 22.0 * (body_h / 101.60);

// Assertions
assert(body_w >= 50 && body_w <= bed_xy, "body_w out of bounds");
assert(rect_h >= bottom_corner_r + 10, "body_h must exceed arch radius + bottom corner radius");
assert(total_h <= bed_xy, "total_h exceeds usable bed size");
assert(print_w <= bed_xy, "print layout width exceeds usable bed size");
assert(assembled_t <= bed_z, "assembled thickness exceeds bed_z");
assert(half_t >= std_wall, "half_t must be at least std_wall (2.4 mm)");
assert(edge_chamfer + bed_chamfer < half_t - 0.4, "chamfers exceed slab thickness");
assert(emboss_h >= 0.6, "emboss_h must be >= 0.6 mm (3 layers)");
assert(border_w >= min_wall, "border_w must be >= min_wall (1.2 mm)");
assert(border_inset >= edge_chamfer, "border_inset must be >= edge_chamfer so border sits on flat top");
assert(stake_w >= 2 * edge_chamfer + 2.0, "stake_w too narrow for edge_chamfer");
assert(stake_tip_w >= 2 * nozzle, "stake_tip_w must be >= 0.8 mm (2 extrusion widths)");
assert(stake_tip_h >= 0.6 && stake_tip_h <= half_t, "stake_tip_h must be between 0.6 mm and half_t");
assert(stake_tip_l < stake_l - stake_fillet_r - 2.0, "stake_tip_l must leave straight root section for fillet");
assert(stake_spacing - stake_w >= 2 * stake_fillet_r + 2.0, "stakes too close together for inner root fillets");
assert(stake_spacing / 2 + stake_w / 2 + stake_fillet_r + bottom_corner_r <= body_w / 2, "stakes too wide for body width and corners");
assert(text_size >= 5.0, "text_size must be >= 5.0 mm per FDM rules");

// REPORT lines
echo(str("REPORT body_w=", body_w));
echo(str("REPORT body_h=", body_h));
echo(str("REPORT stake_l=", stake_l));
echo(str("REPORT total_h=", total_h));
echo(str("REPORT half_t=", half_t));
echo(str("REPORT emboss_h=", emboss_h));
echo(str("REPORT front_h=", front_h));
echo(str("REPORT back_h=", back_h));
echo(str("REPORT assembled_t=", assembled_t));
echo(str("REPORT print_w=", print_w));

// ---------------------------------------------------------------------------
// 2D Profiles
// ---------------------------------------------------------------------------

// Tombstone body 2D path (above stakes, y_ground to y_max)
function tombstone_body_path() =
    let(
        lower_pts = [
            [-arch_r, y_arch],
            [-arch_r, y_ground],
            [ arch_r, y_ground],
            [ arch_r, y_arch]
        ],
        lower_rounded = round_corners(
            lower_pts,
            radius = [0, bottom_corner_r, bottom_corner_r, 0],
            closed = false
        ),
        top_arch = arc(r = arch_r, cp = [0, y_arch], angle = [0, 180])
    )
    [each list_tail(list_head(lower_rounded)), each top_arch];

// Upper silhouette path for offset_sweep (body + root fillets + upper stake shafts down to y_tip_top + 2)
function upper_sweep_path() =
    let(
        y_stub = y_tip_top + 2.0,
        lower_pts = [
            [-arch_r, y_arch],
            [-arch_r, y_ground],
            [sx_l - stake_w/2, y_ground],
            [sx_l - stake_w/2, y_stub],
            [sx_l + stake_w/2, y_stub],
            [sx_l + stake_w/2, y_ground],
            [sx_r - stake_w/2, y_ground],
            [sx_r - stake_w/2, y_stub],
            [sx_r + stake_w/2, y_stub],
            [sx_r + stake_w/2, y_ground],
            [ arch_r, y_ground],
            [ arch_r, y_arch]
        ],
        radii = [
            0,
            bottom_corner_r,
            stake_fillet_r,
            0,
            0,
            stake_fillet_r,
            stake_fillet_r,
            0,
            0,
            stake_fillet_r,
            bottom_corner_r,
            0
        ],
        lower_rounded = round_corners(lower_pts, radius = radii, closed = false),
        top_arch = arc(r = arch_r, cp = [0, y_arch], angle = [0, 180])
    )
    [each list_tail(list_head(lower_rounded)), each top_arch];

// XZ cross-section of a stake at given width w, height h, bottom chamfer cb, top chamfer ct
module stake_section_2d(cx, w, h, cb, ct) {
    polygon([
        [cx - w/2 + cb, 0],
        [cx + w/2 - cb, 0],
        [cx + w/2,      cb],
        [cx + w/2,      h - ct],
        [cx + w/2 - ct, h],
        [cx - w/2 + ct, h],
        [cx - w/2,      h - ct],
        [cx - w/2,      cb]
    ]);
}

// Stake 3D solid: chamfered straight shaft + 3D pyramid tip tapered in both X and Z
module stake_solid(cx) {
    y_top = y_ground - stake_fillet_r;
    slice_y = 0.002;
    cb_tip = min(bed_chamfer, stake_tip_w * 0.25, stake_tip_h * 0.25);
    ct_tip = min(edge_chamfer, stake_tip_w * 0.25, stake_tip_h * 0.25);

    union() {
        // Straight upper shaft (y_tip_top to y_top)
        translate([0, y_top, 0])
            rotate([90, 0, 0])
                linear_extrude(height = y_top - y_tip_top)
                    stake_section_2d(cx, stake_w, half_t, bed_chamfer, edge_chamfer);

        // 3D pyramid point (y_min to y_tip_top) tapering in width (X) and thickness (Z)
        hull() {
            translate([0, y_tip_top + slice_y, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = slice_y)
                        stake_section_2d(cx, stake_w, half_t, bed_chamfer, edge_chamfer);
            translate([0, y_min + slice_y, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = slice_y)
                        stake_section_2d(cx, stake_tip_w, stake_tip_h, cb_tip, ct_tip);
        }
    }
}

// Base half-slab (shared by both front and back halves)
module base_half_slab() {
    union() {
        offset_sweep(
            upper_sweep_path(),
            height = half_t,
            bottom = os_chamfer(width = bed_chamfer),
            top    = os_chamfer(width = edge_chamfer)
        );
        stake_solid(sx_l);
        stake_solid(sx_r);
    }
}

// ---------------------------------------------------------------------------
// Front Embossed Features (2D)
// ---------------------------------------------------------------------------

// Perimeter border frame 2D
module border_frame_2d() {
    difference() {
        offset(r = -border_inset)
            polygon(tombstone_body_path());
        offset(r = -(border_inset + border_w))
            polygon(tombstone_body_path());
    }
}

// Stacked text "RIP" / "BEE" 2D
module gravestone_text_2d() {
    translate([0, y_line1])
        text(
            text_line1,
            size   = text_size,
            font   = "Liberation Sans:style=Bold",
            halign = "center",
            valign = "center"
        );
    translate([0, y_line2])
        text(
            text_line2,
            size   = text_size,
            font   = "Liberation Sans:style=Bold",
            halign = "center",
            valign = "center"
        );
}

// Minimalist geometric bee symbol 2D (centered at origin before translation)
module bee_symbol_2d() {
    scale([bee_scale, bee_scale]) {
        // 1. Head + antennae (shifted up cleanly above thorax)
        translate([0, 9.2]) {
            circle(d = 6.2);
            // Left and right antennae (solidly joined to head)
            for (side = [-1, 1]) {
                rotate([0, 0, side * 30])
                    translate([0, 2.4]) {
                        hull() {
                            circle(d = 1.6);
                            translate([0, 3.6]) circle(d = 2.0);
                        }
                    }
            }
        }

        // 2. Striped oval body + stinger tip (3 raised segments separated by 1.8 mm gaps)
        difference() {
            // Outer body tear/oval shape
            hull() {
                translate([0, 1.0]) scale([1.0, 1.15]) circle(d = 13.0);
                translate([0, -10.8]) circle(d = 1.6);
            }
            // Two horizontal stripe gaps (1.8 mm wide)
            translate([0, 2.2]) square([20, 1.8], center = true);
            translate([0, -3.2]) square([20, 1.8], center = true);
        }

        // 3. Left and right wings (bold 2.1 mm outlined loops, clipped 1.4 mm outside body)
        difference() {
            for (side = [-1, 1]) {
                translate([side * 9.5, 1.2])
                    rotate([0, 0, side * 22])
                        difference() {
                            scale([1.55, 1.0]) circle(d = 9.0);
                            scale([1.55, 1.0]) circle(d = 9.0 - 2 * 2.1);
                        }
            }
            // Clearance halo around body and head so wings have a crisp 1.4 mm gap
            offset(r = 1.4) {
                hull() {
                    translate([0, 1.0]) scale([1.0, 1.15]) circle(d = 13.0);
                    translate([0, -10.8]) circle(d = 1.6);
                }
                translate([0, 9.2]) circle(d = 6.2);
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Printable Parts
// ---------------------------------------------------------------------------

module front_part() {
    union() {
        base_half_slab();
        color("Goldenrod")
            translate([0, 0, half_t - eps])
                linear_extrude(height = emboss_h + eps) {
                    border_frame_2d();
                    gravestone_text_2d();
                    translate([0, y_bee]) bee_symbol_2d();
                }
    }
}

module back_part() {
    base_half_slab();
}

module model_geometry() {
    if (part == "front") {
        front_part();
    } else if (part == "back") {
        back_part();
    } else if (part == "print") {
        translate([-(body_w / 2 + print_gap / 2), 0, 0])
            front_part();
        translate([ (body_w / 2 + print_gap / 2), 0, 0])
            back_part();
    } else if (part == "assembly") {
        // Back half on bottom (outer face at Z=0, flat split face at Z=half_t)
        translate([0, 0, half_t])
            rotate([0, 180, 0])
                back_part();
        // Front half on top (flat split face at Z=half_t, embossed top at Z=2*half_t+emboss_h)
        translate([0, 0, half_t])
            front_part();
    }
}

// ---------------------------------------------------------------------------
// Dispatch (with section cut support)
// ---------------------------------------------------------------------------
if (section) {
    x_cut = (part == "print") ? -(body_w / 2 + print_gap / 2) : 0;
    intersection() {
        model_geometry();
        if (section_axis == "x") {
            translate([x_cut, -250, -50]) cube([500, 500, 200]);
        } else {
            translate([-250, y_bee, -50]) cube([500, 500, 200]);
        }
    }
} else {
    model_geometry();
}
