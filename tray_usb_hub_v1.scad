// =============================================================================
// Project Trays — USB Hub Stackable Tray  (v1.5)
// =============================================================================
// Outer envelope: 9" W × 6" D × 3" H
// Front (one 9" side): open, with 1/4" bottom ledge
// Back (other 9" side): Anker USB-C hub mount + cable routing
// Hub: 151 × 20 × 50 mm (L × T × H)
// Walls: ≥ 4 mm outer thickness
// Units: millimetres
//
// v1.5:
//  - Hub mount 5 mm out from back wall
//  - Right back wall thickened to 10 mm (full height on right side)
//  - Right cutout: 5 mm wide × 10 mm high + 5 mm-diameter half-circle below
// =============================================================================

// --- Conversions ---
inch = 25.4;

// --- Outer envelope ---
W = 9 * inch;          // 228.6  width  (X)
D = 6 * inch;          // 152.4  depth  (Y)
H = 3 * inch;          // 76.2   height (Z)

// --- Structure ---
wall      = 4;         // outer wall thickness (mm) — minimum per brief
floor_t   = 4;         // floor thickness
front_ledge_h = 0.25 * inch;  // 1/4" open-front ledge
corner_r  = 1;         // 1 mm rounding on corners

// --- Stackability (INNER ridge at top) ---
stack_lip_h   = 3;
stack_step    = 2;
stack_clear   = 0.5;

// --- Anker hub ---
hub_L = 151;
hub_T = 20;
hub_H = 50;

clear_half_in = 0.5 * inch;
clear_48      = 48;

hub_x0 = clear_48;
hub_x1 = hub_x0 + hub_L;
echo("hub X range", hub_x0, "→", hub_x1, "  right residual", W - hub_x1);
assert(W - hub_x1 >= clear_half_in - 0.01, "Hub does not leave 1/2\" on right end");
assert(hub_x0 >= clear_48 - 0.01, "Hub does not leave 48 mm on left side");

// Hub vertical placement
hub_shelf_h = 6;
hub_z0 = floor_t + hub_shelf_h;
hub_z1 = hub_z0 + hub_H;
hub_case_extra_h = 5;                 // extend hub casing up 5 mm
hub_case_z1 = hub_z1 + hub_case_extra_h;

// Coordinate system:
//   X: 0 = left outer,  W = right outer
//   Y: 0 = front outer, D = back outer
//   Z: 0 = bottom outer, H = top
// Hub mount stands 5 mm out from the back wall (cable gap behind hub).
hub_back_gap = 5;
hub_y1 = D - wall - hub_back_gap;
hub_y0 = hub_y1 - hub_T;

// --- Hub side / bottom hold ridges ---
ridge_w = 5;
ridge_overhang = 2.5;
ridge_z_pad = 2;

hub_front_y = hub_y0 - ridge_overhang;
hub_holder_d = hub_y1 - hub_front_y;

// Front foot cut into hub casing + floor ledge
hub_front_cut_d = 5;   // cut back into casing (Y+)
hub_front_cut_h = 5;   // from floor up
hub_front_ledge = 2;   // 2×2 mm ledge on floor in front of that cut

// --- Left hub-end wire relief ---
left_open_w = 10;
left_open_h = 35;

// --- Right back wall: 10 mm thick on the right side + cable cutout ---
// Cutout from the TOP down 15 mm total, fully through the thick wall
// (outer back face → inner front face). 5 mm wide; bottom is a 5 mm-diameter
// half-circle (rect portion = 15 - 2.5 = 12.5 mm).
right_wall_t = 10;
right_slot_w = 5;
right_slot_total_h = 15;               // from top of tray down
right_slot_dia = 5;                    // half-circle diameter (= width)
right_slot_r = right_slot_dia / 2;     // 2.5
right_slot_rect_h = right_slot_total_h - right_slot_r;  // 12.5

// Side-bracket cutout (right fence)
side_bracket_cut_w = 8;
side_bracket_cut_h = hub_H / 2 + 5;

fence_w = 3;

$fn = 48;
eps = 0.05;

// Centre the 5 mm cutout in the right residual band (between hub end and tray end)
right_slot_x0 = hub_x1 + ( (W - hub_x1) - right_slot_w ) / 2;

// =============================================================================
// PRIMITIVES — rounded boxes (vertical corners + optional full 3D corners)
// =============================================================================

// Rounded rectangle extruded (rounds all vertical corners). r clamped to size.
module rounded_rect_extrude(size, r, center = false) {
    x = size[0];
    y = size[1];
    z = size[2];
    rr = min(r, x / 2 - eps, y / 2 - eps);
    translate(center ? [-x/2, -y/2, -z/2] : [0, 0, 0])
        linear_extrude(height = z)
            offset(r = rr)
                offset(r = -rr)
                    square([x, y]);
}

// Full 3D corner rounding via minkowski (use sparingly on small parts).
module rounded_cube3(size, r) {
    rr = min(r, size[0]/2 - eps, size[1]/2 - eps, size[2]/2 - eps);
    if (rr <= 0) {
        cube(size);
    } else {
        minkowski() {
            translate([rr, rr, rr])
                cube([size[0] - 2*rr, size[1] - 2*rr, size[2] - 2*rr]);
            sphere(r = rr, $fn = 20);
        }
    }
}

// =============================================================================
// STRUCTURE
// =============================================================================

module floor_plate() {
    rounded_rect_extrude([W, D, floor_t], corner_r);
}

module left_wall() {
    // Outer front/back corners of left wall get rounding via outer envelope pass;
    // wall itself is a simple slab (joins floor/back).
    cube([wall, D, H]);
}

module right_wall() {
    translate([W - wall, 0, 0])
        cube([wall, D, H]);
}

module back_wall_main() {
    translate([0, D - wall, 0])
        cube([W, wall, H]);
}

// Full-height 10 mm thickening of the back wall on the RIGHT side of the tray
// (from hub right end to outer right). Thickens INWARD so outer envelope is unchanged.
module back_wall_right_thick() {
    x0 = hub_x1;
    translate([x0, D - right_wall_t, 0])
        cube([W - x0, right_wall_t - wall, H]);
}

module front_ledge() {
    // Rounded outer front corners of the ledge footprint
    rounded_rect_extrude([W, wall, floor_t + front_ledge_h], corner_r);
}

module stack_inner_ridge() {
    translate([wall, 0, H - stack_lip_h])
        cube([stack_step, D - wall, stack_lip_h]);
    translate([W - wall - stack_step, 0, H - stack_lip_h])
        cube([stack_step, D - wall, stack_lip_h]);
    translate([wall, D - wall - stack_step, H - stack_lip_h])
        cube([W - 2*wall, stack_step, stack_lip_h]);
}

module stack_bottom_foot_cut() {
    inset = wall + stack_clear;
    translate([-eps, -eps, -eps])
        cube([inset + eps, D + 2*eps, stack_lip_h + eps]);
    translate([W - inset, -eps, -eps])
        cube([inset + eps, D + 2*eps, stack_lip_h + eps]);
    translate([-eps, D - inset, -eps])
        cube([W + 2*eps, inset + eps, stack_lip_h + eps]);
    translate([-eps, -eps, -eps])
        cube([W + 2*eps, inset + eps, stack_lip_h + eps]);
}

// =============================================================================
// HUB BAY
// =============================================================================

module hub_side_fence_left() {
    x = hub_x0 - fence_w;
    translate([x, hub_front_y, floor_t])
        rounded_rect_extrude([fence_w, hub_holder_d, hub_case_z1 - floor_t], min(corner_r, fence_w/2 - eps));
}

module hub_side_fence_right() {
    translate([hub_x1, hub_front_y, floor_t])
        rounded_rect_extrude([fence_w, hub_holder_d, hub_case_z1 - floor_t], min(corner_r, fence_w/2 - eps));
}

module hub_shelf() {
    translate([hub_x0 - fence_w, hub_front_y, floor_t])
        cube([hub_L + 2*fence_w, hub_holder_d, hub_shelf_h]);
}

module hub_side_ridges() {
    z0 = hub_z0 + ridge_z_pad;
    // Extend ridges up with the casing (+5 mm above hub)
    zh = hub_H - 2*ridge_z_pad + hub_case_extra_h;
    translate([hub_x0, hub_front_y, z0])
        cube([ridge_w, ridge_overhang + eps, zh]);
    translate([hub_x1 - ridge_w, hub_front_y, z0])
        cube([ridge_w, ridge_overhang + eps, zh]);
}

module hub_bottom_ridge() {
    translate([hub_x0, hub_front_y, hub_z0])
        cube([hub_L, ridge_overhang + eps, ridge_w]);
}

// 2×2 mm ledge on the floor, level with the front of the hub casing,
// spanning the full casing width, in front of the front foot cutout.
module hub_front_floor_ledge() {
    x0 = hub_x0 - fence_w;
    xw = hub_L + 2*fence_w;
    // Front face of ledge flush with hub casing front (hub_front_y);
    // ledge occupies y in [hub_front_y - 2, hub_front_y], z floor_t .. floor_t+2
    translate([x0, hub_front_y - hub_front_ledge, floor_t])
        rounded_rect_extrude([xw, hub_front_ledge, hub_front_ledge], min(corner_r, 0.8));
}

// =============================================================================
// CUTTERS (voids)
// =============================================================================

module hub_body_void() {
    fit = 0.6;
    // Cavity for hub body; open above casing for drop-in
    translate([hub_x0 - fit/2, hub_y0, hub_z0])
        cube([hub_L + fit, hub_T + fit, H - hub_z0 + eps]);
}

module left_wire_relief() {
    z0 = hub_z0 + (hub_H - left_open_h) / 2;
    translate([hub_x0 - fence_w - eps, hub_y0 + (hub_T - left_open_w) / 2, z0])
        cube([fence_w + 2*eps + 2, left_open_w, left_open_h]);
}

// Right cable cutout: from the TOP of the tray down 15 mm, fully through the
// 10 mm thick right back wall (outer back face to inner front face of that wall).
// Profile: 5 mm wide × 12.5 mm rect + 5 mm-diameter half-circle at the bottom.
module right_cable_cutout() {
    w  = right_slot_w;
    rh = right_slot_rect_h;
    r  = right_slot_r;
    th = right_slot_total_h;
    x0 = right_slot_x0;
    cx = x0 + w / 2;

    // Full wall thickness: outer back (Y=D) through inner face of thick wall (Y=D-right_wall_t)
    y0 = D - right_wall_t - eps;
    yd = right_wall_t + 2 * eps;

    // 2D profile in XZ, extruded through the wall in +Y (back → front of wall)
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            linear_extrude(height = yd)
                translate([cx, 0])
                    union() {
                        // Open from top: z = H-rh .. H+
                        translate([-w/2, H - rh])
                            square([w, rh + 1]);
                        // Half-circle bottom (diameter 5 mm), centre at z = H - rh
                        translate([0, H - rh])
                            difference() {
                                circle(r = r, $fn = 32);
                                translate([-r - 1, 0])
                                    square([2*r + 2, r + 1]);
                            }
                    }

    // Also clear the thin outer 4 mm wall span if stacked (same volume — already covered
    // by yd through right_wall_t which includes the outer wall band).

    // Channel from hub right end through the 5 mm back gap to the cutout
    z0 = H - th;
    translate([hub_x1 - eps, hub_y1, z0])
        cube([
            x0 + w - hub_x1 + eps,
            (D - wall) - hub_y1 + eps,
            th + eps
        ]);
}

module right_side_bracket_cutout() {
    zh = side_bracket_cut_h;
    // Measured from original hub top; casing is higher but cut still from hub mid-band
    z0 = hub_z1 - zh;
    y0 = hub_y0 + (hub_T - side_bracket_cut_w) / 2;
    translate([hub_x1 - eps, y0, z0])
        cube([fence_w + 2*eps, side_bracket_cut_w, H - z0 + eps]);
}

// Front of hub casing: from floor to 5 mm up, cut back 5 mm into the casing
module hub_front_foot_cut() {
    x0 = hub_x0 - fence_w - eps;
    xw = hub_L + 2*fence_w + 2*eps;
    translate([x0, hub_front_y - eps, floor_t - eps])
        cube([xw, hub_front_cut_d + eps, hub_front_cut_h + eps]);
}

module hub_access_throat() {
    plug_clear_d = 25;
    plug_clear_h = 8;
    // Stop short of the 2 mm floor ledge
    y1 = hub_front_y - hub_front_ledge;
    y0 = y1 - plug_clear_d;
    translate([hub_x0 + ridge_w, y0, floor_t - eps])
        cube([hub_L - 2*ridge_w, plug_clear_d, plug_clear_h + eps]);
}

// Outer vertical corner fillet cutters: subtract (square − cylinder) at each
// outer corner so the remaining solid has a 1 mm rounded corner.
module outer_corner_fillet_cutters() {
    r = corner_r;
    // Front-left
    translate([0, 0, -eps])
        difference() {
            cube([r + eps, r + eps, H + 2*eps]);
            translate([r, r, -eps])
                cylinder(r = r, h = H + 4*eps, $fn = 32);
        }
    // Front-right
    translate([W - r, 0, -eps])
        difference() {
            cube([r + eps, r + eps, H + 2*eps]);
            translate([0, r, -eps])
                cylinder(r = r, h = H + 4*eps, $fn = 32);
        }
    // Back-right
    translate([W - r, D - r, -eps])
        difference() {
            cube([r + eps, r + eps, H + 2*eps]);
            translate([0, 0, -eps])
                cylinder(r = r, h = H + 4*eps, $fn = 32);
        }
    // Back-left
    translate([0, D - r, -eps])
        difference() {
            cube([r + eps, r + eps, H + 2*eps]);
            translate([r, 0, -eps])
                cylinder(r = r, h = H + 4*eps, $fn = 32);
        }
}

// =============================================================================
// ASSEMBLY
// =============================================================================

module tray_raw() {
    difference() {
        union() {
            floor_plate();
            left_wall();
            right_wall();
            back_wall_main();
            back_wall_right_thick();
            front_ledge();

            stack_inner_ridge();

            hub_side_fence_left();
            hub_side_fence_right();
            hub_shelf();
            hub_side_ridges();
            hub_bottom_ridge();
            hub_front_floor_ledge();
        }

        stack_bottom_foot_cut();

        hub_body_void();
        left_wire_relief();
        right_cable_cutout();
        right_side_bracket_cutout();
        hub_front_foot_cut();
        hub_access_throat();
    }
}

module tray() {
    // Apply 1 mm outer vertical corner rounding to the finished solid
    difference() {
        tray_raw();
        outer_corner_fillet_cutters();
    }
}

// Ghost hub: '%' = background only — visible in F5 preview, excluded from F6/STL.
render_hub_ghost = true;

module ghost_hub() {
    color([0.2, 0.55, 0.85, 0.45])
        translate([hub_x0, hub_y0, hub_z0])
            cube([hub_L, hub_T, hub_H]);
}

// --- Output ---
tray();

if (render_hub_ghost)
    %ghost_hub();

echo("=== Tray v1.5 ===");
echo("Outer W×D×H mm:", W, D, H);
echo("Corner radius:", corner_r);
echo("Wall / floor:", wall, floor_t);
echo("Hub back gap:", hub_back_gap, "mm from back wall");
echo("Hub casing top Z:", hub_case_z1, "(+5 mm over hub)");
echo("Front foot cut: d=", hub_front_cut_d, " h=", hub_front_cut_h, " ledge=", hub_front_ledge);
echo("Right wall thick:", right_wall_t, "mm (right side)");
echo("Right cutout: from top down", right_slot_total_h, "mm, w=", right_slot_w, " through", right_wall_t, "mm wall; half-circle d=", right_slot_dia);
echo("Hub cavity X:", hub_x0, "→", hub_x1);
echo("Hub cavity Y:", hub_y0, "→", hub_y1);
echo("Hub cavity Z:", hub_z0, "→", hub_z1);
