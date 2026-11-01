// hdd-cage.scad: Lightweight high-airflow 2-bay 3.5" HDD space-frame cage for HP EliteDesk 800 G3 TWR
// Spec: spec.md   License: CC BY-NC 4.0
include <BOSL2/std.scad>
use <common/tolerances.scad>
include <common/printing.scad>

/* [Part] */
// Printable part or assembly view
part = "assembly"; // [assembly, print, cage, screw-bar, test-slice, gauge]

/* [Main dimensions] */
// 3.5" HDD length, front-to-rear (mm)
hdd_l = 147.0; // [145:0.1:150]
// 3.5" HDD width, lateral slide depth (mm)
hdd_w = 101.6; // [100:0.1:104]
// 3.5" HDD thickness, vertical in bay (mm)
hdd_h = 26.1; // [25:0.1:28]
// Front grill to HDD front face standoff (mm)
front_standoff = 12.0; // [10:0.5:16]
// Setback depth on inner front face for 6 mm grill notch (mm)
notch_relief_d = 8.0; // [6:0.5:9.5]
// Raised open-arch base height under lower HDD, must exceed 8.0 mm case lip (mm)
base_h = 24.0; // [10:0.5:30]
// Total separation between HDD 1 and HDD 2 (two thin rails + open air gap) (mm)
mid_shelf_h = 22.0; // [12:0.5:26]
// Thin high-airflow horizontal shelf rail thickness (mm)
rail_t = 2.8; // [2.4:0.2:4.0]
// Structural frame wall thickness (mm)
wall_t = 3.2; // [2.4:0.2:4.5]

/* [Fasteners & Zip Ties] */
// #6-32 HDD screw clearance hole diameter (mm)
screw_hole_d = 3.8; // [3.4:0.1:4.2]
// Zip-tie slot width (mm)
ziptie_w = 4.5; // [3.0:0.5:6.0]
// Zip-tie slot thickness (mm)
ziptie_t = 2.0; // [1.5:0.1:3.0]

/* [Fit] */
// Snug vertical clearance in each HDD bay (mm)
hdd_slide_clr_h = 0.3; // [0.15:0.05:1.0]
// Snug front-to-rear length clearance in HDD bay (mm)
hdd_slide_clr_l = 0.4; // [0.2:0.1:1.5]
// Snug lateral depth clearance before outer lock (mm)
hdd_slide_clr_w = 0.2; // [0.1:0.05:1.0]
// Filament material
material = "PETG"; // [PLA, PETG]
// Fit class for printed parts
fit = "snug"; // [press, snug, slide, free]
// Per-side clearance for long 45-deg screw-bar dovetail (calibrated with gauge key "8" = 0.80 mm) (mm)
dovetail_clr = 0.80; // [0.20:0.05:1.20]

/* [Debug] */
// Cut-away view for checking internals
section = false;
// Axis for cut-away section ("y" reveals internals in section_front)
section_axis = "y"; // [x, y]

/* [Hidden] */
$fa = 1;
$fs = $preview ? 0.8 : 0.4;
eps = 0.01;

// Derived clearances & envelope dimensions
part_clr = clearance(material, fit, "slot"); // 0.10 mm for PETG snug

bay_l = hdd_l + hdd_slide_clr_l; // 147.4 mm
bay_w = hdd_w + hdd_slide_clr_w; // 101.8 mm
bay_h = hdd_h + hdd_slide_clr_h; // 26.4 mm

rear_stop_t  = 3.2;
top_rail_h   = 3.2;
outer_lock_t = 5.0; // reinforced 5.0 mm thick dovetail housing & screw-bar

// Overall cage dimensions:
// Print orientation matches PC case viewing orientation directly (no mirroring!):
// - Print Z=0 (bed)   = Inner skeleton wall facing Motherboard Tray
// - Print +Z (110 mm) = Outer face facing Open Side Panel (towards viewer)
// - Print +X (right)  = Front Grill face (with zip-tie ladders)
// - Print -X (left)   = Rear face (towards PSU, open for SATA/Power cables)
// - Print -Y (bottom) = Neoprene Floor feet
// - Print +Y (top)    = Top rail (towards Motherboard SATA ports / 5.25" cage)
cage_l = front_standoff + bay_l + rear_stop_t;          // 162.6 mm
cage_h = base_h + 2 * bay_h + mid_shelf_h + top_rail_h; // 92.0 mm
cage_w = wall_t + bay_w + outer_lock_t;                 // 110.0 mm

// Case envelope constants (from spec.md)
psu_dist        = 185.0;
case_lip_dist   = 125.0;
case_lip_h      = 8.0;
case_lip_clr    = 0.5;
base_outer_z    = wall_t + bay_w; // 105.0 mm (sits at 124.5 mm from MB tray)
mb_tray_gap     = (case_lip_dist - case_lip_clr) - base_outer_z; // 19.5 mm
rear_cable_gap  = psu_dist - cage_l; // 22.4 mm
under_drive_gap = base_h - rail_t;   // 11.2 mm open arch height under bottom HDD
inter_drive_gap = mid_shelf_h - 2 * rail_t; // 16.4 mm open air gap between thin rails

// SFF-8301 standard 3.5" HDD side hole coordinates (from rear connector edge: 28.50, 70.16, 130.10 mm; 6.35 mm from bottom)
hdd_side_hole_z_from_bot  = 6.35;
hdd_side_front_from_front = hdd_l - 130.10; // 16.90 mm from front of drive
hdd_side_rear_from_front  = hdd_l - 28.50;  // 118.50 mm from front of drive

// Coordinate helpers in cage print frame (centered on XY, Z=0 on bed):
// +X is Front Grill (right), -X is Rear toward PSU (left)
x_rear      = -cage_l / 2;
x_front     =  cage_l / 2;
x_bay_start = x_front - front_standoff; // front face of HDD bay (+69.3 mm)
x_bay_end   = x_bay_start - bay_l;      // rear face of HDD bay (-78.1 mm)

// HDD nominal front face inside bay
x_hdd_front  = x_bay_start - hdd_slide_clr_l / 2;
x_lock_front = x_hdd_front - hdd_side_front_from_front; // Front Lock Station (+52.2 mm)
x_lock_rear  = x_hdd_front - hdd_side_rear_from_front;  // Rear Lock Station (-49.4 mm)

y_floor    = -cage_h / 2;
y_top      =  cage_h / 2;
y_bay1_bot = y_floor + base_h;
y_bay1_top = y_bay1_bot + bay_h;
y_bay2_bot = y_bay1_top + mid_shelf_h;
y_bay2_top = y_bay2_bot + bay_h;

// Side screw Y centers in Bay 1 and Bay 2
y_screw_bay1 = y_bay1_bot + (hdd_slide_clr_h / 2) + hdd_side_hole_z_from_bot;
y_screw_bay2 = y_bay2_bot + (hdd_slide_clr_h / 2) + hdd_side_hole_z_from_bot;

// Reinforced Dovetail / screw-bar geometry
dt_boss_w   = 26.0; // full-rail-width monolithic boss
dt_gusset_d = 10.0; // 45-degree gusset depth into main rail (Z = 95.0 .. 105.0 mm)
dt_base_w   = 14.0; // dovetail inner width at Z = base_outer_z (105.0 mm)
dt_slope_h  = 2.8;  // 45-degree dovetail bevel height in Z
dt_top_w    = dt_base_w - 2 * dt_slope_h; // 8.4 mm neck opening at Z = 107.8 .. 110.0 mm

// Dovetail vertical bounds (moves up with y_bay1_bot, well above the 8.0 mm case lip)
dt_bot_y0   = y_bay1_bot - 5.5;   // 5.5 mm tall bottom dovetail boss on Rail 1 (18.5 mm above floor)
dt_bot_stop = dt_bot_y0 + 1.8;    // solid stop ledge inside bottom dovetail boss
bar_y_bot   = dt_bot_stop + 0.2;  // screw-bar bottom rests on stop ledge
bar_l       = y_top - bar_y_bot;  // 81.5 mm continuous straight dovetail bar

// Front grill notch relief Z bound (19.5 mm to 57.0 mm from MB tray => Z = 0 to 37.5 mm)
notch_zone_z = 37.5;
bevel_z_end  = notch_zone_z + notch_relief_d; // 45.5 mm (exact 45-deg bevel)

// Outer corner 45-degree slice sizes in XY plane
front_top_corner_ch = 7.5;
front_bot_corner_ch = 7.5; // reliefs lower-front chassis corner protrusion near grill
outer_corner_ch     = 3.0;

// Assertions
assert(wall_t >= std_wall && rail_t >= std_wall, "Structural walls and rails must be >= std_wall (2.4 mm)");
assert(hdd_slide_clr_h > 0 && hdd_slide_clr_l > 0 && hdd_slide_clr_w > 0, "HDD clearances must be positive");
assert(part_clr > 0, "Printed part clearance must be positive");
assert(base_h >= case_lip_h + 4.0, "base_h must raise bottom HDD well above 8.0 mm case lip for under-drive airflow");
assert(dt_bot_y0 - y_floor >= case_lip_h + 0.5, "Bottom dovetail boss must clear 8.0 mm case lip");
assert(inter_drive_gap >= 12.0, "Inter-drive open air gap must be >= 12.0 mm");
assert(front_standoff - notch_relief_d >= std_wall, "Front wall behind notch relief must be >= std_wall");
assert(notch_relief_d >= 7.5, "Notch relief must clear 6.0 mm grill tab with margin");
assert(rear_cable_gap >= 18.0, "Must leave >= 18 mm behind cage for SATA & power cables before PSU");
assert(mb_tray_gap >= 16.5, "Inner wall must stay >= 16.5 mm from MB tray to clear M.2 SSD & clips");
assert(cage_h <= 110.0, "Cage height must stay below 110 mm SATA cable clearance");
assert(cage_l <= bed_xy && cage_h <= bed_xy && cage_w <= bed_z, "Cage must fit 250x250x250 build volume");

// REPORT echo lines matching spec.md
echo(str("REPORT cage_l=", cage_l));
echo(str("REPORT cage_w=", cage_w));
echo(str("REPORT cage_h=", cage_h));
echo(str("REPORT bay_l=", bay_l));
echo(str("REPORT bay_w=", bay_w));
echo(str("REPORT bay_h=", bay_h));
echo(str("REPORT front_standoff=", front_standoff));
echo(str("REPORT notch_relief_d=", notch_relief_d));
echo(str("REPORT base_h=", base_h));
echo(str("REPORT under_drive_gap=", under_drive_gap));
echo(str("REPORT mid_shelf_h=", mid_shelf_h));
echo(str("REPORT rail_t=", rail_t));
echo(str("REPORT inter_drive_gap=", inter_drive_gap));
echo(str("REPORT rear_cable_gap=", rear_cable_gap));
echo(str("REPORT mb_tray_gap=", mb_tray_gap));
echo(str("REPORT part_clr=", part_clr));
echo(str("REPORT dovetail_clr=", dovetail_clr));

// ============================================================================
// Modules
// ============================================================================

// Dovetail cutter profile at a lock station X, spanning Y range [y0, y1]
// Cuts a 45-degree dovetail channel in Z = [base_outer_z, cage_w]
module dovetail_cutter(x_pos, y0, y1, clr=0) {
    len_y = y1 - y0;
    y_mid = (y0 + y1) / 2;
    w_bot = dt_base_w + 2 * clr;
    w_top = dt_top_w  + 2 * clr;
    translate([x_pos, y_mid, base_outer_z - eps])
        hull() {
            cuboid([w_bot, len_y, eps], anchor=BOTTOM);
            translate([0, 0, dt_slope_h])
                cuboid([w_top, len_y, eps], anchor=BOTTOM);
        }
    translate([x_pos, y_mid, base_outer_z + dt_slope_h - eps])
        cuboid([w_top, len_y, outer_lock_t - dt_slope_h + 2 * eps], anchor=BOTTOM);
}

// Support-free 45-degree pyramidal gusseted dovetail boss growing directly out of a thin rail!
// At Z = base_outer_z - dt_gusset_d, it starts at the exact thin rail height [y_rail0, y_rail1],
// and flares at <= 45 degrees in Y and Z to [y_boss0, y_boss1] at Z = base_outer_z .. cage_w!
module gusseted_rail_lock_boss(x_pos, y_rail0, y_rail1, y_boss0, y_boss1) {
    rail_ly = y_rail1 - y_rail0;
    rail_ym = (y_rail0 + y_rail1) / 2;
    boss_ly = y_boss1 - y_boss0;
    boss_ym = (y_boss0 + y_boss1) / 2;

    hull() {
        translate([x_pos, rail_ym, base_outer_z - dt_gusset_d])
            cuboid([dt_boss_w, rail_ly, eps], anchor=BOTTOM);
        translate([x_pos, boss_ym, base_outer_z])
            cuboid([dt_boss_w, boss_ly, outer_lock_t], chamfer=0.6, edges="Z", anchor=BOTTOM);
    }
}

// 45-degree diamond-ended airflow slot oriented along Z (for thin horizontal shelf rails)
module shelf_diamond_vent(x_c, y_c, z_c, w_x, h_y, l_z) {
    translate([x_c, y_c, z_c])
        hull() {
            cuboid([w_x, h_y, l_z - w_x], anchor=CENTER);
            cuboid([0.4, h_y, l_z], anchor=CENTER);
        }
}

// Thin, high-airflow horizontal shelf rail from Z = 0 to base_outer_z (x0 < x1)
// Uses 3 stacked 45-degree diamond vent tiers separated by two 4.5 mm horizontal Z-tie bridges
// so vertical strut slenderness is only ~7:1 (zero nozzle-drag wobble in PETG, zero supports).
module thin_shelf_rail(x0, x1, y0, y1) {
    seg_w = x1 - x0;
    seg_h = y1 - y0;
    x_mid = (x0 + x1) / 2;
    y_mid = (y0 + y1) / 2;

    ch_z0 = wall_t + 3.5;                     // 6.7 mm
    ch_z1 = base_outer_z - dt_gusset_d - 1.0; // 94.0 mm
    ch_lz = ch_z1 - ch_z0;                    // 87.3 mm

    num_z_tiers = 3;
    z_bridge_t  = 4.5;
    tier_lz     = (ch_lz - (num_z_tiers - 1) * z_bridge_t) / num_z_tiers; // 26.1 mm per tier

    slot_w    = 6.4;
    margin_x  = 5.2;
    num_slots = (seg_w >= 40.0) ? 3 : 2;
    avail_x   = seg_w - 2 * margin_x;
    slot_step = (avail_x - slot_w) / max(1, num_slots - 1);

    difference() {
        translate([x_mid, y_mid, 0])
            cuboid([seg_w, seg_h, base_outer_z],
                   chamfer=0.4, edges=[BOTTOM+FRONT, BOTTOM+BACK], anchor=BOTTOM);

        // Punch 3 tiers of wide 45-degree diamond airflow vents through the thin rail
        if (tier_lz > 12 && seg_w >= 24.0) {
            for (iz = [0 : num_z_tiers - 1]) {
                tz_c = ch_z0 + iz * (tier_lz + z_bridge_t) + tier_lz / 2;
                for (ix = [0 : num_slots - 1]) {
                    sx = x0 + margin_x + slot_w / 2 + ix * slot_step;
                    shelf_diamond_vent(sx, y_mid, tz_c, slot_w, seg_h + 2 * eps, tier_lz);
                }
            }
        }
    }
}

// 45-degree corner slice cutter in XY plane at corner (cx, cy) with normal signs (sx, sy)
module xy_corner_slice(cx, cy, sx, sy, ch) {
    translate([cx, cy, -eps])
        linear_extrude(height=cage_w + 2 * eps)
            polygon(points=[
                [sx * eps, sy * eps],
                [-sx * (ch + eps), sy * eps],
                [sx * eps, -sy * (ch + eps)]
            ]);
}

// Full 2-bay Space-Frame HDD Cage
module hdd_cage_body() {
    // Two clean guide bands (with x0 < x1):
    // Rear Guide (left, around x_lock_rear to x_rear) and Front Guide (right, around x_lock_front to x_bay_start)
    xr0 = x_rear;
    xr1 = x_lock_rear + dt_boss_w / 2;  // ~44.9 mm wide rear guide band (left side)

    xf0 = x_lock_front - dt_boss_w / 2;
    xf1 = x_bay_start + eps;            // ~30.6 mm wide front guide band (right side)

    difference() {
        union() {
            // ================================================================
            // 1. LIGHTWEIGHT OPEN-TRUSS FRONT GRILL STANDOFF (x = x_bay_start .. x_front, RIGHT side)
            // ================================================================
            inner_front_t = front_standoff - notch_relief_d; // 4.0 mm
            translate([x_bay_start + inner_front_t / 2, 0, 0])
                cuboid([inner_front_t, cage_h, base_outer_z],
                       chamfer=0.4, edges=[BOTTOM+RIGHT, BOTTOM+FRONT, BOTTOM+BACK], anchor=BOTTOM);

            // Two vertical zip-tie ladder columns on the 10x12 mesh grid (Z = 45.5..61.5 and 89.0..105.0)
            hull() {
                translate([x_bay_start + inner_front_t + eps, 0, notch_zone_z])
                    cuboid([eps, cage_h, 16.0], anchor=BOTTOM+RIGHT);
                translate([x_front, 0, bevel_z_end])
                    cuboid([notch_relief_d + eps, cage_h, 16.0], anchor=BOTTOM+RIGHT);
            }
            translate([x_front, 0, base_outer_z - 16.0])
                cuboid([notch_relief_d + eps, cage_h, 16.0], anchor=BOTTOM+RIGHT);

            // Slender horizontal front tie ribs at Floor, Bay 1 Bot, Bay 1 Top, Bay 2 Bot, and Top
            for (yb = [
                [y_floor,             y_floor + rail_t],
                [y_bay1_bot - rail_t, y_bay1_bot],
                [y_bay1_top,          y_bay1_top + rail_t],
                [y_bay2_bot - rail_t, y_bay2_bot],
                [y_bay2_top,          y_top]
            ]) {
                bh = yb[1] - yb[0];
                ym = (yb[0] + yb[1]) / 2;
                translate([x_front, ym, bevel_z_end])
                    cuboid([notch_relief_d + eps, bh, base_outer_z - bevel_z_end], anchor=BOTTOM+RIGHT);
            }

            // ================================================================
            // 2. FOUR SEPARATE THIN HIGH-AIRFLOW SHELF LAYERS (2 per HDD)
            //    + OPEN-ARCH FLOOR FEET (only under Front & Rear guides!)
            // ================================================================
            for (seg = [[xr0, xr1], [xf0, xf1]]) {
                // (a) Floor Foot Pad on neoprene (y = y_floor .. y_floor + rail_t)
                thin_shelf_rail(seg[0], seg[1], y_floor, y_floor + rail_t);

                // (b) Bay 1 Bottom Rail (y = y_bay1_bot - rail_t .. y_bay1_bot)
                thin_shelf_rail(seg[0], seg[1], y_bay1_bot - rail_t, y_bay1_bot);

                // (c) Bay 1 Top Rail (y = y_bay1_top .. y_bay1_top + rail_t) — thin layer 1 between HDDs
                thin_shelf_rail(seg[0], seg[1], y_bay1_top, y_bay1_top + rail_t);

                // (d) Bay 2 Bottom Rail (y = y_bay2_bot - rail_t .. y_bay2_bot) — thin layer 2 between HDDs
                thin_shelf_rail(seg[0], seg[1], y_bay2_bot - rail_t, y_bay2_bot);

                // (e) Bay 2 Top Rail (y = y_bay2_top .. y_top)
                thin_shelf_rail(seg[0], seg[1], y_bay2_top, y_top);
            }

            // Slender vertical arch leg posts under the Front & Rear Lock Columns + Rear Corner (y = y_floor .. y_bay1_bot)
            // Leaves open side-to-side windows under Bay 1 matching the upper bays to save filament & boost airflow!
            leg_ym = (y_floor + y_bay1_bot) / 2;
            for (lx = [x_lock_rear, x_lock_front]) {
                translate([lx, leg_ym, 0])
                    cuboid([12.0, base_h, 11.0],
                           chamfer=0.4, edges=[BOTTOM+FRONT, BOTTOM+BACK], anchor=BOTTOM);
                translate([lx, leg_ym, base_outer_z - 11.0])
                    cuboid([12.0, base_h, 11.0], anchor=BOTTOM);
            }
            // Rear-outer corner leg post under Bay 1 (y = y_floor .. y_bay1_bot)
            translate([x_rear + 3.2, leg_ym, base_outer_z - 11.0])
                cuboid([6.4, base_h, 11.0], anchor=BOTTOM);

            // Slender longitudinal side stringers (8.0 mm wide in Z) connecting Rear and Front guides
            // at the 4 HDD rail levels (NOT at the floor, keeping the bottom open to save filament!)
            for (yb = [
                [y_bay1_bot - rail_t, y_bay1_bot],
                [y_bay1_top,          y_bay1_top + rail_t],
                [y_bay2_bot - rail_t, y_bay2_bot],
                [y_bay2_top,          y_top]
            ]) {
                bh = yb[1] - yb[0];
                ym = (yb[0] + yb[1]) / 2;
                // Inner stringer (Z = 0 .. 8.0 mm)
                translate([(x_rear + x_bay_start) / 2, ym, 0])
                    cuboid([bay_l + rear_stop_t, bh, 8.0],
                           chamfer=0.4, edges=[BOTTOM+FRONT, BOTTOM+BACK, BOTTOM+LEFT], anchor=BOTTOM);
                // Outer stringer (Z = base_outer_z - 8.0 .. base_outer_z)
                translate([(x_rear + x_bay_start) / 2, ym, base_outer_z - 8.0])
                    cuboid([bay_l + rear_stop_t, bh, 8.0], anchor=BOTTOM);
            }

            // ================================================================
            // 3. REINFORCED, 4-RAIL GUSSETED DOVETAIL HOUSINGS (Zero mid-air bridges!)
            // ================================================================
            for (lx = [x_lock_front, x_lock_rear]) {
                // Rail 1 (Bay 1 Bot): flares 2.7 mm downward from thin rail to dt_bot_y0 over 10 mm Z rise (<= 45 deg!)
                gusseted_rail_lock_boss(lx, y_bay1_bot - rail_t, y_bay1_bot, dt_bot_y0, y_bay1_bot);

                // Rail 2 (Bay 1 Top): flares 3.5 mm upward into inter-drive gap over 10 mm Z rise (<= 45 deg!)
                gusseted_rail_lock_boss(lx, y_bay1_top, y_bay1_top + rail_t, y_bay1_top, y_bay1_top + rail_t + 3.5);

                // Rail 3 (Bay 2 Bot): flares 3.5 mm downward into inter-drive gap over 10 mm Z rise (<= 45 deg!)
                gusseted_rail_lock_boss(lx, y_bay2_bot - rail_t, y_bay2_bot, y_bay2_bot - rail_t - 3.5, y_bay2_bot);

                // Rail 4 (Bay 2 Top)
                gusseted_rail_lock_boss(lx, y_bay2_top, y_top, y_bay2_top, y_top);
            }

            // ================================================================
            // 4. INNER SKELETON WALL (Z = 0 .. wall_t = 3.2 mm)
            // ================================================================
            for (xp = [
                [x_rear,             x_bay_end + 6.5],
                [x_lock_rear - 4.0,  x_lock_rear + 4.0],
                [x_lock_front - 4.0, x_lock_front + 4.0],
                [x_bay_start - 7.0,  x_bay_start]
            ]) {
                pw = xp[1] - xp[0];
                pm = (xp[0] + xp[1]) / 2;
                translate([pm, 0, 0])
                    cuboid([pw, cage_h, wall_t],
                           chamfer=0.4, edges=[BOTTOM+FRONT, BOTTOM+BACK], anchor=BOTTOM);
            }

            // ================================================================
            // 5. REAR RETAINING STOP FLANGE (x = x_rear .. x_bay_end, LEFT side, Z = 0 .. 10.5 mm)
            // ================================================================
            translate([x_bay_end - rear_stop_t / 2 + eps, 0, 0])
                cuboid([rear_stop_t + eps, cage_h, 10.5],
                       chamfer=0.4, edges=[BOTTOM+LEFT, BOTTOM+FRONT, BOTTOM+BACK], anchor=BOTTOM);
        }

        // ====================================================================
        // Subtractive Cutouts
        // ====================================================================

        // A. 45-Degree Sliced Outer Corners in XY Plane (produces two 45-deg bevels per corner)
        xy_corner_slice(x_front, y_top,    1,  1, front_top_corner_ch); // Top-Front (Front Grill top)
        xy_corner_slice(x_rear,  y_top,   -1,  1, outer_corner_ch);     // Top-Rear (PSU side top)
        xy_corner_slice(x_front, y_floor,  1, -1, front_bot_corner_ch); // Bottom-Front (Front Grill bottom corner relief)
        xy_corner_slice(x_rear,  y_floor, -1, -1, outer_corner_ch);     // Bottom-Rear

        // B. Front Standoff Airflow Windows (aligned with Under-Drive Arch, Bay 1, Inter-Drive Gap, and Bay 2!)
        for (yw = [
            [y_floor + rail_t + 1.0,     y_bay1_bot - rail_t - 1.0],
            [y_bay1_bot + 1.5,           y_bay1_top - 1.5],
            [y_bay1_top + rail_t + 1.0,  y_bay2_bot - rail_t - 1.0],
            [y_bay2_bot + 1.5,           y_bay2_top - 1.5]
        ]) {
            win_h = yw[1] - yw[0];
            ym    = (yw[0] + yw[1]) / 2;
            if (win_h > 4.0) {
                win_ch = min(win_h / 2 - 2.0, 8.0);
                // Inner window (Z = wall_t + 2.0 .. notch_zone_z - 2.0) with 45-deg self-supporting roof
                translate([x_front - front_standoff / 2, ym, (wall_t + 2.0 + notch_zone_z - 2.0) / 2])
                    cuboid([front_standoff + 2 * eps, win_h, (notch_zone_z - wall_t - 4.0)],
                           chamfer=win_ch, edges="X", anchor=CENTER);
                // Center mesh window between Ladder Column 1 (Z=61.5) and Ladder Column 2 (Z=89.0) with 45-deg roof
                translate([x_front - front_standoff / 2, ym, (61.5 + 89.0) / 2])
                    cuboid([front_standoff + 2 * eps, win_h, 89.0 - 61.5 - 2.5],
                           chamfer=win_ch, edges="X", anchor=CENTER);
            }
        }

        // C. Front Grill Zip-Tie Ladder Tunnels (10 stations on 7.25 mm vertical pitch, below top corner slice)
        for (zc = [53.5, 97.0]) {
            for (i = [0 : 9]) {
                zy = y_floor + 12.5 + i * 7.25;
                if (zy + ziptie_w / 2 < y_top - front_top_corner_ch - 1.5) {
                    // Through-tunnel along Z behind 3.2 mm front bridge
                    translate([x_front - 3.2 - ziptie_t / 2, zy, zc])
                        cuboid([ziptie_t + 1.2, ziptie_w, 18.0], anchor=CENTER);
                    // Twin front entry slots
                    for (dz = [-4.2, 4.2]) {
                        translate([x_front + eps, zy, zc + dz])
                            cuboid([3.2 + ziptie_t + 1.5, ziptie_w, 4.4], anchor=RIGHT);
                    }
                }
            }
        }

        // D. Continuous Outer Dovetail Guide Channels at Front and Rear Lock Stations
        for (lx = [x_lock_front, x_lock_rear]) {
            dovetail_cutter(lx, dt_bot_stop, y_top + eps, clr=0);
        }
    }
}

// Reusable truncated 45-degree dovetail profile for screw-bar and fit gauge keys
// Blunts the sharp 45-deg knife edges and leaves 0.6 mm Z floor clearance (bar_t = 4.4 mm in 5.0 mm slot)
// so root-corner filament radius or overhang sag at Z = 105 mm never wedges the bar!
module dovetail_bar_profile(len_y, clr_side) {
    neck_h  = outer_lock_t - dt_slope_h; // 2.2 mm straight neck
    flare_h = 2.0;                       // 2.0 mm 45-deg flare (stops 0.8 mm short of root corner)
    flat_h  = 0.2;                       // 0.2 mm blunted vertical flat at widest point
    w_top   = dt_top_w - 2 * clr_side;
    w_bot   = w_top + 2 * flare_h;

    hull() {
        cuboid([w_top, len_y, neck_h], anchor=BOTTOM);
        translate([0, 0, neck_h + flare_h])
            cuboid([w_bot, len_y, flat_h], anchor=BOTTOM);
    }
}

// Method 1 Locking Bar: screw-bar
module screw_bar_shape(clr_side = dovetail_clr) {
    w_top  = dt_top_w - 2 * clr_side;
    w_bot  = w_top + 4.0;
    bar_t  = (outer_lock_t - dt_slope_h) + 2.0 + 0.2; // 4.4 mm
    bar_ym = (bar_y_bot + y_top) / 2;

    difference() {
        // Continuous straight dovetail bar from bar_y_bot to y_top (solid across inter-drive span for max stiffness)
        translate([0, bar_ym, 0])
            dovetail_bar_profile(bar_l, clr_side);

        // 45-deg lead-in entry chamfer on the bottom nose (bar_y_bot) so it self-centers into each dovetail boss
        translate([0, bar_y_bot, bar_t])
            rotate([45, 0, 0])
                cuboid([w_bot + 2, 1.6, 1.6], anchor=CENTER);
        for (sx = [-1, 1]) {
            translate([sx * (w_bot / 2), bar_y_bot, bar_t / 2])
                rotate([0, 0, sx * 45])
                    cuboid([1.6, 1.6, bar_t + 2], anchor=CENTER);
        }

        // #6-32 obround clearance slots + countersunk head recesses at Bay 1 and Bay 2 side screw holes
        for (ys = [y_screw_bay1, y_screw_bay2]) {
            translate([0, ys, -eps])
                hull() {
                    translate([0, -0.4, 0]) cyl(d=screw_hole_d, h=bar_t + 2 * eps, anchor=BOTTOM);
                    translate([0,  0.4, 0]) cyl(d=screw_hole_d, h=bar_t + 2 * eps, anchor=BOTTOM);
                }
            translate([0, ys, -eps])
                hull() {
                    translate([0, -0.4, 0]) cyl(d=6.8, h=1.0 + eps, anchor=BOTTOM);
                    translate([0,  0.4, 0]) cyl(d=6.8, h=1.0 + eps, anchor=BOTTOM);
                }
        }
    }
}

module screw_bar_part() {
    translate([0, -(bar_y_bot + y_top) / 2, 0])
        screw_bar_shape(dovetail_clr);
}

// Stepped Dovetail Fit Gauge (part = "gauge"):
// 5 short (34 mm) test screw-bar keys with per-side clearances [0.2, 0.3, 0.4, 0.6, 0.8] mm
// (total width clearances 0.4, 0.6, 0.8, 1.2, 1.6 mm), engraved "2", "3", "4", "6", "8" (tenths of mm per side).
// Each key includes a #6-32 screw slot and slides directly into the existing printed test-slice dovetail channel!
module gauge_part() {
    test_clrs   = [0.20, 0.30, 0.40, 0.60, 0.80];
    test_labels = ["2",  "3",  "4",  "6",  "8"];
    key_l       = 34.0;
    pitch_x     = 16.5;
    bar_t       = (outer_lock_t - dt_slope_h) + 2.0 + 0.2; // 4.4 mm

    for (i = [0 : 4]) {
        kx  = (i - 2) * pitch_x;
        clr = test_clrs[i];
        lbl = test_labels[i];

        translate([kx, 0, 0])
            difference() {
                dovetail_bar_profile(key_l, clr);

                // #6-32 obround screw test slot on lower half
                translate([0, -7.5, -eps])
                    hull() {
                        translate([0, -0.4, 0]) cyl(d=screw_hole_d, h=bar_t + 2 * eps, anchor=BOTTOM);
                        translate([0,  0.4, 0]) cyl(d=screw_hole_d, h=bar_t + 2 * eps, anchor=BOTTOM);
                    }
                translate([0, -7.5, -eps])
                    hull() {
                        translate([0, -0.4, 0]) cyl(d=7.2, h=1.2 + eps, anchor=BOTTOM);
                        translate([0,  0.4, 0]) cyl(d=7.2, h=1.2 + eps, anchor=BOTTOM);
                    }

                // Engraved clearance label on top face (font >= 5 mm, depth >= 0.6 mm per AGENTS.md §10)
                translate([0, 7.5, bar_t - 0.8])
                    linear_extrude(height=0.8 + eps)
                        text(lbl, size=6.0, font="Liberation Sans:style=Bold", halign="center", valign="center");
            }
    }
}

// Fast modular validation test-slice (< 50 min total, or split in slicer to print individually in ~20-25 min):
// 1. Shallow 4-Boss Dual-Bay Lock Frame (26.0 x 102.0 x 18.0 mm, Z=0..18 mm): tests all 4 dovetail bosses,
//    81.5 mm screw-bar slide, both 26.4 mm HDD bays, and #6-32 screw alignment in just 18 mm of Z height!
// 2. Single-Rail 110mm 3-Tier Vent Tower (30.1 x 8.8 x 110.0 mm): tests full-Z printability of 1 thin rail
//    with the 3-tier diamond vents and top dovetail boss (~1/10th the volume of the old 5-hour slice).
// 3. Full 81.5 mm calibrated screw-bar (dovetail_clr = 0.80 mm).
module test_slice_part() {
    shallow_z = 16.0; // top 16 mm of cage (Z = 94..110 mm shifted down to Z = 0..16 mm, 100% solid above vents!)

    // Piece 1 (Left, X = -31 .. -5 mm): Shallow 4-Boss Dual-Bay Lock Frame (only 16 mm tall in Z!)
    translate([-18.0, 0, 0]) {
        union() {
            // Top 16 mm of the Front Lock Column (Z = cage_w - shallow_z .. cage_w -> Z = 0 .. shallow_z)
            translate([0, 0, -(cage_w - shallow_z)])
                intersection() {
                    translate([-x_lock_front, 0, 0])
                        hdd_cage_body();
                    translate([0, 0, cage_w - shallow_z / 2])
                        cuboid([dt_boss_w, cage_h + 2, shallow_z], anchor=CENTER);
                }
            // 3.2 mm bed-side frame strips at Z = 0..3.2 mm tying the 5 rail stubs together
            for (sx = [-1, 1]) {
                translate([sx * (dt_boss_w / 2 - 3.5), 0, 0])
                    cuboid([7.0, cage_h, wall_t],
                           chamfer=0.4, edges=[BOTTOM+FRONT, BOTTOM+BACK], anchor=BOTTOM);
            }
        }
    }

    // Piece 2 (Right, X = +16 .. +26 mm): Single-Rail 110mm 3-Tier Vent Tower (Bay 1 Top rail + boss)
    xf0_rail = x_lock_front - dt_boss_w / 2;
    xf1_rail = x_bay_start - 0.5;
    rail_w   = xf1_rail - xf0_rail; // 29.6 mm
    rail_xm  = (xf0_rail + xf1_rail) / 2;
    rail_y0  = y_bay1_top;
    rail_y1  = y_bay1_top + rail_t + 3.5; // includes the 3.5 mm boss flare
    rail_ym  = (rail_y0 + rail_y1) / 2;

    translate([21.0, 0, 0])
        rotate([0, 0, 90]) {
            union() {
                intersection() {
                    translate([-rail_xm, -rail_ym, 0])
                        hdd_cage_body();
                    translate([0, 0, cage_w / 2])
                        cuboid([rail_w, (rail_y1 - rail_y0) + 0.2, cage_w], anchor=CENTER);
                }
                // 10 mm wide x 3.2 mm thick bed adhesion flange at Z = 0..3.2 mm
                cuboid([rail_w, 10.0, wall_t], chamfer=0.4, edges="Z", anchor=BOTTOM);
            }
        }

    // Piece 3 (Middle, X = +0.1 .. +10.9 mm): Calibrated 81.5 mm screw-bar
    translate([5.5, 0, 0])
        screw_bar_part();
}

// Assembly view: cage + 2x screw-bar fitted in Front and Rear Lock Stations
module assembly_view() {
    hdd_cage_body();

    for (lx = [x_lock_front, x_lock_rear]) {
        translate([lx, 0, cage_w])
            rotate([0, 180, 0])
                screw_bar_shape();
    }
}

// Print plate layout: cage + 2x screw-bar with >= 5 mm gaps, centered inside 250x250 bed
module print_plate() {
    bar_plate_y = y_top - 12.0 + 6.0 + dt_base_w / 2;
    translate([0, -12.0, 0])
        hdd_cage_body();

    translate([-45.0, bar_plate_y, 0])
        rotate([0, 0, 90])
            screw_bar_part();
    translate([ 45.0, bar_plate_y, 0])
        rotate([0, 0, 90])
            screw_bar_part();
}

// ============================================================================
// Dispatch with optional section cut
// ============================================================================

module render_part() {
    if (part == "assembly") {
        assembly_view();
    } else if (part == "print") {
        print_plate();
    } else if (part == "cage") {
        hdd_cage_body();
    } else if (part == "screw-bar") {
        screw_bar_part();
    } else if (part == "test-slice") {
        test_slice_part();
    } else if (part == "gauge") {
        gauge_part();
    } else {
        assert(false, str("Unknown part mode: ", part));
    }
}

if (section) {
    intersection() {
        render_part();
        if (section_axis == "x") {
            // Cut along X at x_lock_front to expose reinforced dovetail, gussets, and screw-bar
            translate([x_lock_front - 200, 0, 0])
                cuboid([400, 400, 400], anchor=CENTER);
        } else {
            // Cut along Y at Bay 1 side screw center (or gauge screw hole center)
            sec_y = (part == "gauge") ? -7.5 : y_screw_bay1;
            translate([0, sec_y + 200, 0])
                cuboid([400, 400, 400], anchor=CENTER);
        }
    }
} else {
    render_part();
}
