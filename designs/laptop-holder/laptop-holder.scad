// laptop-holder.scad: shelf stand holding laptops and tablets upright on a long edge
// Spec: spec.md   License: CC BY-NC 4.0
include <BOSL2/std.scad>
include <common/printing.scad>
// Slot clearances are set per device group (spec: custom slide + lean), not from tolerances.scad.

/* [Part] */
// stand: the full stand. test-slice: short front section, one slot per distinct width.
// gauge: stepped slot gauge, one bar per device thickness, slots at gauge_clearances.
part = "stand"; // [stand, test-slice, gauge]

/* [Thick group] */
// Thick device widths, measured max (mm); one slot each, left to right. [] = thin only.
thick_device_widths = [22.86, 20, 11, 11];
// Total clearance added to each thick device width (mm)
thick_clearance = 1.64; // [0.2:0.01:5]
// Wall height per thick slot, above slot floor at wall front (mm)
thick_wall_heights = [115, 103, 91, 91];
// Thick wall width, also used for the wall between groups (mm)
thick_wall_width = 4.5; // [2.4:0.1:10]
// Thick wall length (mm)
thick_wall_length = 160; // [20:1:220]
// Side the thick group sits on, facing the stand front
thick_side = "left"; // [left, right]

/* [Thin group] */
// Number of thin devices
thin_device_count = 6; // [0:1:19]
// Thin slot width: 7.60 measured + 1.20 clearance (mm)
thin_slot_width = 8.8; // [3:0.1:20]
// Thin wall width (mm)
thin_wall_width = 4.0; // [2.4:0.1:10]
// Thin wall height above slot floor, at wall front (mm)
thin_wall_height = 90; // [20:1:200]
// Thin wall length (mm)
thin_wall_length = 120; // [20:1:220]

/* [Base and ramp] */
// Floor thickness; slot floor Z (mm)
base_height = 5.0; // [2.4:0.1:15]
// Base length behind the ramp (mm)
base_length = 175; // [50:1:220]
// Front ramp length; equals device front overhang (mm)
slope_length = 30; // [5:1:60]
// Ramp front edge height (mm)
ramp_lip_height = 1.0; // [0.4:0.1:5]
// Radius of the ramp-to-floor bend, 0 = sharp (mm)
ramp_blend_r = 20; // [0:1:50]
// XY footprint corner radius (mm)
base_corner_radius = 5; // [0:0.5:20]
// Bottom footprint chamfer at sides and rear (mm)
bed_chamfer = 0.4; // [0:0.1:1]

/* [Edges] */
// Fillet where walls meet the slot floor (mm)
root_fillet_r = 1.5; // [0:0.1:5]
// Front-top wall corner radius, side view (mm)
wall_front_corner_radius = 15; // [0:1:50]
// Wall rear height as fraction of front height (1.0 = flat top)
wall_rear_height_ratio = 0.7; // [0.5:0.05:1.0]
// Wall front taper length in plan, measured back from the front edge (0 = no taper) (mm)
nose_taper_length = 25; // [0:1:60]
// Wall front edge width at the tip of the taper, fully rounded (mm)
nose_tip_width = 1.6; // [0.8:0.1:4.5]
// Front edge rake, leaning back from vertical (deg)
nose_rake = 15; // [0:1:30]

/* [Felt] */
// Felt thickness per side; each slot widens by 2x (mm)
felt_thickness = 0; // [0:0.1:3]

/* [Devices and shelf (measured, checks only)] */
// Thick device lengths, same order as widths (mm)
thick_device_lengths = [361.95, 323.85, 304.8, 304.8];
// Thick device heights, same order as widths (mm)
thick_device_heights = [257.05, 228.6, 203.2, 203.2];
// Thin device max length (mm)
max_thin_device_length = 330.20;
// Thin device max height (mm)
max_thin_device_height = 209.55;
// Thin device max width (mm)
max_thin_device_width = 7.60;
// Shelf clear height (mm)
shelf_clear_height = 336.55;
// Required distance between device center and base rear end (mm)
tip_margin = 15; // [0:1:50]

/* [Test pieces] */
// Test slice wall height above slot floor (mm)
test_wall_height = 40; // [20:1:120]
// Test slice wall length (mm)
test_wall_length = 40; // [20:1:100]
// Test slice base length behind the ramp (mm)
test_base_length = 50; // [30:1:120]
// Gauge clearances to test, total per slot, one slot each (mm)
gauge_clearances = [0.2, 0.4, 0.6, 0.8, 1.0];
// Gauge slot length along Y (mm)
gauge_length = 20; // [10:1:40]
// Gauge wall height above slot floor (mm)
gauge_wall_height = 30; // [5:1:60]
// Gauge label ledge in front of the slots (mm)
gauge_ledge = 9; // [6:1:15]
// Gauge label text size (mm)
gauge_label_size = 5; // [5:0.5:8]
// Gauge label engraving depth (mm)
gauge_label_depth = 0.6; // [0.4:0.1:1.2]

/* [Debug] */
section = false;    // cut-away view for checking internals
// y: XZ cut through the walls (see front view); x: YZ cut through a divider wall
section_axis = "y"; // [x, y]

/* [Hidden] */
$fa = 1;
$fs = $preview ? 0.8 : 0.4;
eps = 0.01;
// Segment count with a floor for small radii (the 0.8 mm nose tip would get ~12 by $fs)
function small_fn(r) = max(24, ceil(2 * PI * r / $fs));

// Silicone anti-slip pad under the base, user-stated (not modeled)
pad_t = 1.0;

is_test = part != "stand";
is_gauge = part == "gauge";

// Test pieces use one slot per distinct thick width (widest left) plus one thin slot.
// Widths, clearances, wall widths and edge shapes are the stand's; only lengths and heights change.
test_widths = let(u = unique(thick_device_widths)) [for (k = [len(u) - 1 : -1 : 0]) u[k]];
lay_thick_widths = is_test ? test_widths : thick_device_widths;
lay_thick_heights = is_test ? [for (d = test_widths) test_wall_height] : thick_wall_heights;
lay_thin_count = is_test ? min(thin_device_count, 1) : thin_device_count;
lay_thin_height = is_test ? test_wall_height : thin_wall_height;
lay_thick_length = is_test ? test_wall_length : thick_wall_length;
lay_thin_length = is_test ? test_wall_length : thin_wall_length;
lay_base_length = is_test ? test_base_length : base_length;

// Gauge bars: [device width, wall width], thickest first; slot = device + clearance
gauge_bars = concat([for (d = test_widths) [d, thick_wall_width]],
                    thin_device_count > 0 ? [[max_thin_device_width, thin_wall_width]] : []);
function gauge_bar_w(b) = len(gauge_clearances) * gauge_bars[b][0] + sum(gauge_clearances)
                        + (len(gauge_clearances) + 1) * gauge_bars[b][1];
gauge_bar_l = gauge_ledge + gauge_length;
gauge_gap = 5;
gauge_total_l = len(gauge_bars) * gauge_bar_l + (len(gauge_bars) - 1) * gauge_gap;

n_thick = len(lay_thick_widths);
n_thin = lay_thin_count;
n_slots = n_thick + n_thin;
has_thick = n_thick > 0;
has_thin = n_thin > 0;

thick_walls = has_thick ? n_thick + 1 : 0;
thin_walls = has_thick ? n_thin : n_thin + 1;
n_walls = thick_walls + thin_walls;

thick_slot_ws = [for (d = lay_thick_widths) d + thick_clearance + 2 * felt_thickness];
thin_slot_w = thin_slot_width + 2 * felt_thickness;

// Left-to-right order as modeled for thick_side = "left"; "right" mirrors in X.
// Wall i is thick for i < thick_walls; slot i is thick for i < n_thick.
// Wall i sits between slot i-1 and slot i.
function wall_is_thick(i) = i < thick_walls;
function slot_h(i) = i < 0 || i >= n_slots ? 0 : i < n_thick ? lay_thick_heights[i] : lay_thin_height;
function wall_w(i) = wall_is_thick(i) ? thick_wall_width : thin_wall_width;
function wall_h(i) = wall_is_thick(i) ? max(slot_h(i - 1), slot_h(i)) : lay_thin_height;
function wall_l(i) = wall_is_thick(i) ? lay_thick_length : lay_thin_length;
function slot_w(i) = i < n_thick ? thick_slot_ws[i] : thin_slot_w;

wall_hs = [for (i = [0 : n_walls - 1]) wall_h(i)];
total_w = sum([for (i = [0 : n_walls - 1]) wall_w(i)])
        + (n_slots > 0 ? sum([for (i = [0 : n_slots - 1]) slot_w(i)]) : 0);
total_l = slope_length + lay_base_length;
total_h = base_height + max(wall_hs);

// X of each wall's left face: wall i is preceded by walls 0..i-1 and slots 0..i-1
pitch = [for (i = [0 : n_walls - 1]) wall_w(i) + (i < n_slots ? slot_w(i) : 0)];
wall_x0 = concat([-total_w / 2], [for (c = cumsum(pitch)) -total_w / 2 + c]);

// Y datums (footprint centered on origin)
y_front = -total_l / 2;           // ramp lip
y_wall = y_front + slope_length;  // ramp end = wall fronts = slot floor start
y_rear = total_l / 2;

device_front_overhang = slope_length;
ramp_rise = base_height - ramp_lip_height;
ramp_angle = atan(ramp_rise / slope_length);
blend_t = ramp_blend_r * tan(ramp_angle / 2);  // tangent length of ramp bend

function tip_spare(len) = (base_length - tip_margin) - (len / 2 - device_front_overhang);
thick_tip_spares = [for (l = thick_device_lengths) tip_spare(l)];
thin_tip_spare = tip_spare(max_thin_device_length);
max_dev_h = max(concat(has_thick ? thick_device_heights : [], has_thin ? [max_thin_device_height] : [], [0]));
shelf_spare = shelf_clear_height - (pad_t + base_height + max_dev_h);
thin_slot_flat = thin_slot_w - 2 * root_fillet_r;
thick_slot_flat = has_thick ? min(thick_slot_ws) - 2 * root_fillet_r : 0;

// Assertions
assert(n_slots >= 1, "need at least one device");
assert(len(thick_wall_heights) == len(thick_device_widths) && len(thick_device_lengths) == len(thick_device_widths)
       && len(thick_device_heights) == len(thick_device_widths), "thick lists must have equal length");
assert(total_w <= bed_xy, str("total width ", total_w, " exceeds bed"));
assert(total_l <= bed_xy, str("total length ", total_l, " exceeds bed"));
assert(total_h <= bed_z, str("total height ", total_h, " exceeds bed"));
assert(ramp_lip_height < base_height, "ramp lip must be below slot floor");
assert(base_height >= std_wall, "base must be >= std_wall");
assert(thick_wall_width >= std_wall && thin_wall_width >= std_wall, "walls must be >= std_wall");
assert(blend_t < slope_length, "ramp blend longer than ramp");
assert(thick_clearance > 0, "thick clearance must be positive");
assert(!has_thin || thin_slot_width > max_thin_device_width, "thin slot must exceed device width");
assert(!has_thick || lay_thick_length <= lay_base_length, "thick walls longer than base");
assert(!has_thin || lay_thin_length <= lay_base_length, "thin walls longer than base");
// Tipping and shelf checks apply to the full stand only
assert(is_test || !has_thick || min(thick_tip_spares) >= 0, "thick device tips: center too far behind base");
assert(is_test || !has_thin || thin_tip_spare >= 0, "thin device tips: center too far behind base");
assert(is_test || shelf_spare >= 0, "tallest device does not fit under shelf");
assert(max([for (b = [0 : len(gauge_bars) - 1]) gauge_bar_w(b)]) <= bed_xy && gauge_total_l <= bed_xy,
       "gauge layout exceeds bed");
assert(min(gauge_clearances) > 0, "gauge clearances must be positive");
assert(nose_tip_width >= 2 * nozzle, "nose tip below minimum feature (2 extrusion widths)");
assert(nose_tip_width <= min(thick_wall_width, thin_wall_width), "nose tip wider than wall");
assert(wall_front_corner_radius >= max(thick_wall_width, thin_wall_width) / 2,
       "front corner radius must be at least half the wall width");
// Per wall: taper ends before the rear end; corner arc center leaves room for the
// sloped top (also the convergence condition of slope_solve)
assert(min([for (i = [0 : n_walls - 1]) wall_l(i) - wall_w(i) - nose_taper_length]) > 0,
       "nose taper runs past the wall rear");
assert(min([for (i = [0 : n_walls - 1])
           wall_l(i) - (sin(nose_rake) * (wall_h(i) - wall_front_corner_radius) + wall_front_corner_radius) / cos(nose_rake)
           - wall_front_corner_radius]) > 0,
       "wall too short for rake + front corner radius")
assert(wall_front_corner_radius <= min(wall_hs) * wall_rear_height_ratio,
       "front corner radius exceeds lowest rear wall height");
assert(!has_thick || thick_slot_flat > 0, "thick slot fillets overlap");
assert(!has_thin || thin_slot_flat > 0, "thin slot fillets overlap");
assert(base_corner_radius > bed_chamfer || base_corner_radius == 0, "corner radius must exceed bed chamfer");

// Spec report values
echo(str("REPORT part=", part));
echo(str("REPORT total_w=", total_w));
echo(str("REPORT total_l=", total_l));
echo(str("REPORT total_h=", total_h));
if (is_gauge) {
    echo(str("REPORT gauge_size=", [max([for (b = [0 : len(gauge_bars) - 1]) gauge_bar_w(b)]), gauge_total_l, base_height + gauge_wall_height]));
    for (b = [0 : len(gauge_bars) - 1])
        echo(str("REPORT gauge_bar_", b, " device=", gauge_bars[b][0], " slots=", [for (c = gauge_clearances) gauge_bars[b][0] + c]));
}
echo(str("REPORT walls=", n_walls, " (thick ", thick_walls, ", thin ", thin_walls, ")"));
echo(str("REPORT thick_slot_w=", thick_slot_ws));
echo(str("REPORT thin_slot_w=", thin_slot_w));
echo(str("REPORT wall_h_front=", wall_hs));
echo(str("REPORT wall_h_rear=", [for (h = wall_hs) h * wall_rear_height_ratio]));
echo(str("REPORT ramp_angle=", ramp_angle));
echo(str("REPORT thick_tip_spare=", thick_tip_spares));
echo(str("REPORT thin_tip_spare=", thin_tip_spare));
echo(str("REPORT shelf_spare=", shelf_spare));
echo(str("REPORT thin_slot_flat=", thin_slot_flat));
echo(str("REPORT nose taper=", nose_taper_length, " tip=", nose_tip_width, " rake=", nose_rake));
// Slot opening at the front edge: slot + the taper on both neighboring walls
echo(str("REPORT slot_entry_w=", [for (i = [0 : n_slots - 1])
    slot_w(i) + (nose_taper_length > 0 ? (wall_w(i) + wall_w(i + 1)) / 2 - min(nose_tip_width, wall_w(i), wall_w(i + 1)) : 0)]));

// Dispatch
apply_section()
    if (part == "gauge") gauge();
    else if (thick_side == "right") mirror([1, 0, 0]) stand();
    else stand();

// Gauge: bars laid out along Y (thickest at the back), 5 mm apart. Each bar has
// one slot per gauge clearance (smallest left), walls and root fillets as on the
// stand, slots open at both ends, and engraved labels on a front ledge:
// clearance in tenths of a mm ("2" = 0.2).
module gauge() {
    for (b = [0 : len(gauge_bars) - 1])
        translate([0, gauge_total_l / 2 - gauge_bar_l / 2 - b * (gauge_bar_l + gauge_gap), 0])
            gauge_bar(gauge_bars[b][0], gauge_bars[b][1]);
}

module gauge_bar(dev_w, w) {
    n = len(gauge_clearances);
    slots = [for (c = gauge_clearances) dev_w + c];
    bw = sum(slots) + (n + 1) * w;
    // left face of wall k
    wx = [for (k = [0 : n]) -bw / 2 + k * w + (k > 0 ? sum([for (j = [0 : k - 1]) slots[j]]) : 0)];
    y_back = gauge_bar_l / 2;
    rt = min(1, w / 2);   // wall top edge round
    r = root_fillet_r;
    difference() {
        union() {
            cuboid([bw, gauge_bar_l, base_height], chamfer=bed_chamfer, edges=BOT, anchor=BOT);
            translate([0, y_back, 0]) rotate([90, 0, 0]) linear_extrude(gauge_length) {
                for (k = [0 : n]) {
                    // wall with rounded top edges
                    hull() {
                        translate([wx[k], base_height - eps]) square([w, eps]);
                        translate([wx[k] + rt, base_height + gauge_wall_height - rt]) circle(r=rt, $fn=small_fn(rt));
                        translate([wx[k] + w - rt, base_height + gauge_wall_height - rt]) circle(r=rt, $fn=small_fn(rt));
                    }
                    // root fillets on slot sides
                    if (r > 0) for (side = [0, 1]) if ((side == 0 && k > 0) || (side == 1 && k < n)) {
                        xe = side == 0 ? wx[k] : wx[k] + w;
                        dir = side == 0 ? -1 : 1;
                        difference() {
                            translate([min(xe, xe + dir * r) - (dir > 0 ? eps : 0), base_height - eps])
                                square([r + eps, r + eps]);
                            translate([xe + dir * r, base_height + r]) circle(r=r);
                        }
                    }
                }
            }
        }
        // labels on the ledge, centered under each slot
        for (i = [0 : n - 1])
            translate([wx[i] + w + slots[i] / 2, -gauge_bar_l / 2 + gauge_ledge / 2, base_height - gauge_label_depth])
                linear_extrude(gauge_label_depth + eps)
                    text(str(round(gauge_clearances[i] * 10)), size=gauge_label_size, halign="center", valign="center");
    }
}

// Section view debug wrapper
module apply_section() {
    if (section) {
        if (section_axis == "y") {
            // XZ cut 40 mm behind the wall fronts
            back_half(y=y_wall + 40, s=600) children();
        } else {
            // YZ cut through the middle of wall 1 (first divider)
            right_half(x=wall_x0[min(1, n_walls - 1)] + wall_w(min(1, n_walls - 1)) / 2, s=600) children();
        }
    } else {
        children();
    }
}

module stand() {
    // Wall rounding below Z=0 is clipped by the bed half-space
    intersection() {
        union() {
            base();
            for (i = [0 : n_walls - 1]) {
                wall(i);
                root_fillets(i);
            }
        }
        translate([0, 0, total_h / 2])
            cube([total_w + 2, total_l + 2, total_h + eps], center=true);
    }
}

// Rounded rectangle centered on origin
module rrect(size, r) {
    if (r > 0)
        offset(r=r) square([size[0] - 2 * r, size[1] - 2 * r], center=true);
    else
        square(size, center=true);
}

// Footprint prism with bottom chamfer on sides and rear (not on the ramp lip)
module footprint_prism(h) {
    c = bed_chamfer;
    hull() {
        translate([0, -c / 2, 0])
            linear_extrude(eps) rrect([total_w - 2 * c, total_l - c], max(base_corner_radius - c, 0));
        translate([0, 0, c])
            linear_extrude(h - c) rrect([total_w, total_l], base_corner_radius);
    }
}

// Side profile (Y, Z) of base + ramp, with rounded ramp-to-floor bend
function base_profile() =
    let(
        a = ramp_angle,
        // arc center below the floor, tangent to floor at y_wall + blend_t
        cy = y_wall + blend_t,
        cz = base_height - ramp_blend_r,
        n = max(2, ceil(a / 2)),
        arc = ramp_blend_r > 0
            ? [for (k = [0 : n]) let(t = 90 + a - a * k / n) [cy + ramp_blend_r * cos(t), cz + ramp_blend_r * sin(t)]]
            : [[y_wall, base_height]]
    )
    concat([[y_front, 0], [y_front, ramp_lip_height]], arc, [[y_rear, base_height], [y_rear, 0]]);

// Map 2D (u, v) to 3D (Y, Z), extruded along X
module yz_extrude(h) {
    rotate([90, 0, 90]) linear_extrude(h, center=true) children();
}

module base() {
    intersection() {
        footprint_prism(base_height + 1);
        yz_extrude(total_w + 2) polygon(base_profile());
    }
}

// Inner side profile (Y, Z) of wall i; Minkowski with a sphere r = w/2 gives
// half-round nose, top and rear end, and the front-top corner radius.
// Outer top line: peak of the corner round (Rc behind the nose) at full height h,
// sloping to h * wall_rear_height_ratio at the wall rear.
// Top slope s: s = (c0 + R * sqrt(1 + s^2)) / Lc, solved by fixed-point iteration
function slope_solve(c0, R, Lc, s, n) =
    n == 0 ? s : slope_solve(c0, R, Lc, (c0 + R * sqrt(1 + s * s)) / Lc, n - 1);

// Wall i as a hull of spheres, listed as [y, z, r] (y from the wall front at floor
// level, z from the slot floor). Side profile (YZ): front edge raked back by
// nose_rake, front-top corner round R, top sloping from full height h at the
// corner peak to h * wall_rear_height_ratio at the wall rear. Each sphere sits
// r inside the profile, so the profile is exact and every edge is rounded with
// the local half-width r. In plan the half-width tapers from nose_tip_width / 2
// at the front edge to w / 2 over nose_taper_length (measured behind the raked edge).
function wall_spheres(i) =
    let(
        w = wall_w(i), rw = w / 2,
        rt = min(nose_tip_width / 2, rw),
        Lt = nose_taper_length,
        h = wall_h(i), L = wall_l(i),
        R = wall_front_corner_radius,
        ra = nose_rake, tr = tan(ra),
        ratio = wall_rear_height_ratio,
        // corner arc center: R behind the raked front line, R below the peak
        Cz = h - R,
        Cy = (sin(ra) * Cz + R) / cos(ra),
        s = slope_solve(Cz - h * ratio, R, L - Cy, 0, 40),
        k = sqrt(1 + s * s),
        A = h * ratio + s * L,                    // top line: z = A - s * y
        zb = min(base_height / 2, base_height - rw) - base_height,   // buried bottom
        ru = function(u) Lt > 0 ? min(rw, rt + (rw - rt) * max(u, 0) / Lt) : rw,
        rad = function(p) ru(p[0] - p[1] * tr),  // u = distance behind the raked front line
        n1 = [-cos(ra), sin(ra)],                 // front line outward normal
        n2 = [s, 1] / k,                          // top line outward normal
        a0 = 180 - ra, a1 = 90 - atan(s),
        na = max(2, ceil((a0 - a1) / 5)),
        arc = [for (j = [0 : na]) let(
                   a = a0 - (a0 - a1) * j / na,
                   nrm = [cos(a), sin(a)],
                   P = [Cy, Cz] + R * nrm,
                   r = rad(P))
               concat(P - r * nrm, [r])],
        y_arc_end = Cy + R * cos(a1),
        y_te = (Lt + A * tr) / (1 + s * tr),      // top line point where the taper ends
        top_te = Lt > 0 && y_te > y_arc_end && y_te < L - rw
            ? [concat([y_te, A - s * y_te] - rw * n2, [rw])] : [],
        bot_te = Lt > 0 ? [[Lt + zb * tr, zb, rw]] : []
    )
    concat(
        [concat([0, 0] - rt * n1, [rt]), [rt, zb, rt]],   // nose at floor, buried below
        arc,
        top_te,
        [[L - rw, A - s * (L - rw) - rw * k, rw], [L - rw, zb, rw]],   // rear end
        bot_te
    );

module wall(i) {
    translate([wall_x0[i] + wall_w(i) / 2, y_wall, base_height])
        hull()
            for (c = wall_spheres(i))
                translate([0, c[0], c[1]]) sphere(r=c[2], $fn=small_fn(c[2]));
}

// Wall cross-section (XY) at height z above the floor: rounded tip, taper,
// half-round rear end. The front part shifts back with the rake (none below the floor).
module wall_footprint(i, z=0) {
    w = wall_w(i);
    rt = min(nose_tip_width / 2, w / 2);
    x = wall_x0[i] + w / 2;
    dy = max(z, 0) * tan(nose_rake);
    hull() {
        translate([x, y_wall + dy + rt]) circle(r=rt, $fn=small_fn(rt));
        translate([x, y_wall + dy + max(nose_taper_length, w / 2)]) circle(d=w);
        translate([x, y_wall + wall_l(i) - w / 2]) circle(d=w);
    }
}

// Concave fillet all around wall i's footprint (sides, nose, rear end), so no
// end faces catch a sliding device. Built from hulls of offset slices; the
// part outside the stand's side faces (outer walls) is clipped.
module root_fillets(i) {
    r = root_fillet_r;
    n = 8;
    // offset of the fillet surface from the wall at height z above the floor
    // Below the floor (z < 0) the flare continues as a shallow wedge (toe_rise per mm)
    // instead of a vertical skirt: where the ramp bend dips below floor level
    // in front of the nose (up to 0.2 mm), the exposed edge is a slope, not a step.
    toe_rise = 1 / 3;
    function d(z) = z < 0 ? r - z / toe_rise : r - sqrt(max(r * r - (r - z) * (r - z), 0));
    zs = concat([-0.5], [for (k = [0 : n]) r * k / n]);
    if (r > 0) {
        intersection() {
            union() {
                for (k = [0 : len(zs) - 2]) {
                    hull() {
                        for (z = [zs[k], zs[k + 1]])
                            translate([0, 0, base_height + z])
                                linear_extrude(eps) offset(delta=d(z)) wall_footprint(i, z);
                    }
                }
            }
            cube([total_w - 2 * eps, total_l, 2 * (base_height + r + 1)], center=true);
        }
    }
}
