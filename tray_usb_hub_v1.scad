// =============================================================================
// Project Trays — USB Hub Stackable Tray  (v1.3)
// =============================================================================
// Outer envelope: 9" W × 6" D × 3" H
// Front (one 9" side): open, with 1/4" bottom ledge
// Back (other 9" side): Anker USB-C hub mount + cable routing
// Hub: 151 × 20 × 50 mm (L × T × H)
// Walls: ≥ 4 mm outer thickness
// Units: millimetres
//
// v1.3: 10 mm wall thickness only at the right cutout bottom sill (not full height)
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

// --- Stackability (INNER ridge at top) ---
// Upper tray bottom sits on an inward ledge near the top of the lower tray.
stack_lip_h   = 3;     // vertical thickness of inner ridge / bottom foot height
stack_step    = 2;     // how far the inner ridge projects into the cavity
stack_clear   = 0.5;   // print clearance between foot and ridge

// --- Anker hub ---
hub_L = 151;           // length along back wall (X)
hub_T = 20;            // thickness into tray (Y)
hub_H = 50;            // height (Z)

// End clearances (from outer tray ends, along X)
clear_half_in = 0.5 * inch;  // 12.7  — end with right slots
clear_48      = 48;          //      — left clearance

// Left: 48 mm clearance. Right: residual ≥ 1/2".
hub_x0 = clear_48;
hub_x1 = hub_x0 + hub_L;
echo("hub X range", hub_x0, "→", hub_x1, "  right residual", W - hub_x1);
assert(W - hub_x1 >= clear_half_in - 0.01, "Hub does not leave 1/2\" on right end");
assert(hub_x0 >= clear_48 - 0.01, "Hub does not leave 48 mm on left side");

// Hub vertical placement
hub_shelf_h = 6;
hub_z0 = floor_t + hub_shelf_h;
hub_z1 = hub_z0 + hub_H;

// Coordinate system:
//   X: 0 = left outer,  W = right outer
//   Y: 0 = front outer, D = back outer
//   Z: 0 = bottom outer, H = top
// Main back wall inner face at Y = D - wall (4 mm wall).
// Right-of-hub zone uses a thicker 10 mm back wall.
hub_y1 = D - wall;
hub_y0 = hub_y1 - hub_T;

// Behind-hub wire groove (main 4 mm back wall only, under hub span)
groove_depth = 5;
groove_h     = 15;
groove_z0    = hub_z0 + 5;
groove_margin_x = 2;

// --- Hub side / bottom hold ridges ---
// 5 mm ridges that catch the front of the hub (sides + bottom).
ridge_w = 5;           // side ridge width (X) / bottom ridge height (Z)
ridge_overhang = 2.5;  // how far in front of hub face (Y-) to hold it
ridge_z_pad = 2;       // small clearance under/over hub for drop-in on side ridges

// Front face of hub holder (side brackets + ridges align here)
hub_front_y = hub_y0 - ridge_overhang;
hub_holder_d = hub_y1 - hub_front_y;  // = hub_T + ridge_overhang

// --- Left hub-end wire relief (in-tray only; NO holes through left back wall) ---
left_open_w = 10;
left_open_h = 35;

// --- Right cutout: 10 mm wide; 10 mm wall thickness ONLY at cutout bottom sill ---
right_wall_t = 10;     // thickness at the sill under the cutout (not full wall height)
right_slot_w = 10;     // cutout width (exactly 10 mm)
right_slot_d = 35;     // top cutout depth from top of tray
right_sill_h = 8;      // height of the thick pad under the cutout bottom
right_sill_x_pad = 3;  // extra shoulder either side of the 10 mm slot

// Side-bracket cutout (right fence): 8 mm wide, down hub_H/2 + 5 from top of holder
side_bracket_cut_w = 8;
side_bracket_cut_h = hub_H / 2 + 5;  // 30 mm for 50 mm hub

// Fence thickness at hub ends
fence_w = 3;

// --- Fillet / print helpers ---
$fn = 48;
eps = 0.05;

// Right cutout X placement: centred in the right residual band, but only 10 mm wide.
// Prefer hugging the hub right end so cable leaves the hub cleanly.
right_slot_x0 = hub_x1 + ( (W - hub_x1) - right_slot_w ) / 2;

// =============================================================================
// STRUCTURE
// =============================================================================

module floor_plate() {
    cube([W, D, floor_t]);
}

module left_wall() {
    cube([wall, D, H]);
}

module right_wall() {
    translate([W - wall, 0, 0])
        cube([wall, D, H]);
}

module back_wall_main() {
    // 4 mm back wall across full width (base)
    translate([0, D - wall, 0])
        cube([W, wall, H]);
}

module back_wall_right_cutout_sill() {
    // 10 mm thick pad ONLY at the bottom of the right cutout — not full height
    // up the side. Forms a deep sill so the cable rests on 10 mm of material
    // instead of a thin 4 mm wall edge. Thickens INWARD (outer envelope unchanged).
    x0 = right_slot_x0 - right_sill_x_pad;
    xw = right_slot_w + 2 * right_sill_x_pad;
    z_sill = H - right_slot_d;           // bottom of the cutout
    z0 = z_sill - right_sill_h;          // thick pad sits under the sill
    translate([x0, D - right_wall_t, z0])
        cube([xw, right_wall_t - wall, right_sill_h]);
}

module front_ledge() {
    cube([W, wall, floor_t + front_ledge_h]);
}

// --- Inner stacking ridge (at top) ---
// Projects inward from L/R/back walls. Front is open (no ridge on front ledge).
module stack_inner_ridge() {
    // Left inner ridge
    translate([wall, 0, H - stack_lip_h])
        cube([stack_step, D - wall, stack_lip_h]);
    // Right inner ridge
    translate([W - wall - stack_step, 0, H - stack_lip_h])
        cube([stack_step, D - wall, stack_lip_h]);
    // Back inner ridge
    translate([wall, D - wall - stack_step, H - stack_lip_h])
        cube([W - 2*wall, stack_step, stack_lip_h]);
}

// Bottom foot: outer perimeter cut away so the remaining foot is small enough
// to drop into the tray below and rest on its INNER ridge.
// Foot outer size = full_inner - 2*stack_clear = (W - 2*wall) - 2*stack_clear  on X
// and similarly on Y (front/back).
module stack_bottom_foot_cut() {
    // Full inner opening of tray below (no ridge): W - 2*wall
    // Ridge opening: W - 2*wall - 2*stack_step
    // Foot must be: ridge_opening < foot < full_inner
    // foot half-inset from outer = wall + stack_clear
    inset = wall + stack_clear;

    // Left strip
    translate([-eps, -eps, -eps])
        cube([inset + eps, D + 2*eps, stack_lip_h + eps]);
    // Right strip
    translate([W - inset, -eps, -eps])
        cube([inset + eps, D + 2*eps, stack_lip_h + eps]);
    // Back strip
    translate([-eps, D - inset, -eps])
        cube([W + 2*eps, inset + eps, stack_lip_h + eps]);
    // Front strip
    translate([-eps, -eps, -eps])
        cube([W + 2*eps, inset + eps, stack_lip_h + eps]);
}

// =============================================================================
// HUB BAY
// =============================================================================

module hub_side_fence_left() {
    // Extends forward to the front face of the side ridges
    x = hub_x0 - fence_w;
    translate([x, hub_front_y, floor_t])
        cube([fence_w, hub_holder_d, hub_z1 - floor_t]);
}

module hub_side_fence_right() {
    // Extends forward to the front face of the side ridges
    translate([hub_x1, hub_front_y, floor_t])
        cube([fence_w, hub_holder_d, hub_z1 - floor_t]);
}

module hub_shelf() {
    // Shelf under hub, also extends to front of ridges
    translate([hub_x0 - fence_w, hub_front_y, floor_t])
        cube([hub_L + 2*fence_w, hub_holder_d, hub_shelf_h]);
}

// 5 mm side ridges that catch the front of the hub (flush with extended brackets)
module hub_side_ridges() {
    z0 = hub_z0 + ridge_z_pad;
    zh = hub_H - 2*ridge_z_pad;
    // Left ridge: at left end of hub, in front of hub face
    translate([hub_x0, hub_front_y, z0])
        cube([ridge_w, ridge_overhang + eps, zh]);
    // Right ridge: at right end of hub
    translate([hub_x1 - ridge_w, hub_front_y, z0])
        cube([ridge_w, ridge_overhang + eps, zh]);
}

// Same ridge treatment along the bottom front of the hub holder
module hub_bottom_ridge() {
    // 5 mm tall lip in front of the hub bottom face, full hub length
    // (side ridges cover the corners; this spans the middle)
    translate([hub_x0, hub_front_y, hub_z0])
        cube([hub_L, ridge_overhang + eps, ridge_w]);
}

// =============================================================================
// CUTTERS (voids)
// =============================================================================

module hub_body_void() {
    fit = 0.6;
    // Open all the way to the top for drop-in (also clears the inner stack ridge
    // over the hub span). Do NOT cut into Y < hub_y0 — side ridges live there.
    translate([hub_x0 - fit/2, hub_y0, hub_z0])
        cube([hub_L + fit, hub_T + fit, H - hub_z0 + eps]);
}

module behind_hub_groove() {
    // Groove only under the hub span in the main (4 mm) back wall.
    // No through-holes on the left of the back wall.
    translate([
        hub_x0 + groove_margin_x,
        D - wall - eps,
        groove_z0
    ])
        cube([
            hub_L - 2*groove_margin_x,
            groove_depth + eps,
            groove_h
        ]);
}

module left_wire_relief() {
    // Wire clearance at LEFT end of hub — stays INSIDE the tray (through the
    // left fence into the bay). Does NOT pierce the left back wall.
    z0 = hub_z0 + (hub_H - left_open_h) / 2;
    translate([hub_x0 - fence_w - eps, hub_y0 + (hub_T - left_open_w) / 2, z0])
        cube([fence_w + 2*eps + 2, left_open_w, left_open_h]);
}

module right_top_slot() {
    // Exactly 10 mm wide × 35 mm deep from top.
    // Upper span cuts the normal 4 mm back wall; at the sill the pad is 10 mm thick.
    z0 = H - right_slot_d;
    x0 = right_slot_x0;

    // Through main back wall (full cutout height)
    translate([x0, D - wall - eps, z0])
        cube([right_slot_w, wall + 2*eps, right_slot_d + eps]);

    // Clear the thick sill pad at the bottom of the cutout (same X/width)
    // so the opening lands cleanly on the 10 mm sill top.
    translate([x0, D - right_wall_t - eps, z0 - eps])
        cube([right_slot_w, right_wall_t - wall + 2*eps, eps + 1]);

    // Channel from hub right end to the slot (through extended fence / bay)
    // Only needs normal wall depth — not a full-height thick wall.
    translate([hub_x1 - eps, hub_front_y, z0])
        cube([x0 + right_slot_w - hub_x1 + eps, hub_holder_d + wall, right_slot_d + eps]);
}

module right_side_bracket_cutout() {
    // Cutout on the RIGHT side bracket of the hub holder (not through the back wall).
    // 8 mm wide (along Y), goes down (hub_H/2 + 5) from the top of the holder.
    // Open to the top for cable drop-in.
    zh = side_bracket_cut_h;
    z0 = hub_z1 - zh;
    // Place the 8 mm slot through the thickness of the right fence, starting at
    // the hub front face and going back (into the holder).
    translate([hub_x1 - eps, hub_y0, z0])
        cube([fence_w + 2*eps, side_bracket_cut_w, H - z0 + eps]);
}

module hub_access_throat() {
    // Floor recess in front of the holder for fat USB plugs — stops at holder front
    // so it does not undercut the bottom ridge / extended shelf.
    plug_clear_d = 25;
    plug_clear_h = 8;
    y0 = hub_front_y - plug_clear_d;
    translate([hub_x0 + ridge_w, y0, floor_t - eps])
        cube([hub_L - 2*ridge_w, plug_clear_d, plug_clear_h + eps]);
}

// =============================================================================
// ASSEMBLY
// =============================================================================

module tray() {
    difference() {
        union() {
            floor_plate();
            left_wall();
            right_wall();
            back_wall_main();
            back_wall_right_cutout_sill();
            front_ledge();

            // Inner stacking ridge at top
            stack_inner_ridge();

            // Hub location features
            hub_side_fence_left();
            hub_side_fence_right();
            hub_shelf();
            hub_side_ridges();
            hub_bottom_ridge();
        }

        // Bottom foot for nesting onto the tray below's INNER ridge
        stack_bottom_foot_cut();

        // Hub + cable features
        hub_body_void();
        behind_hub_groove();
        left_wire_relief();
        right_top_slot();
        right_side_bracket_cutout();
        hub_access_throat();
    }
}

// Ghost hub for preview
render_hub_ghost = true;

module ghost_hub() {
    color([0.2, 0.55, 0.85, 0.45])
        translate([hub_x0, hub_y0, hub_z0])
            cube([hub_L, hub_T, hub_H]);
}

// --- Output ---
tray();

if (render_hub_ghost)
    ghost_hub();

echo("=== Tray v1.2 ===");
echo("Outer W×D×H mm:", W, D, H);
echo("Wall / floor:", wall, floor_t);
echo("Right cutout sill thick (bottom only):", right_wall_t, " sill_h=", right_sill_h);
echo("Front ledge H:", front_ledge_h);
echo("Hub cavity X:", hub_x0, "→", hub_x1, " (L=", hub_L, ")");
echo("Hub cavity Y:", hub_y0, "→", hub_y1, " (T=", hub_T, ")");
echo("Hub cavity Z:", hub_z0, "→", hub_z1, " (H=", hub_H, ")");
echo("Holder front Y:", hub_front_y, " depth:", hub_holder_d);
echo("Ridges: w/h=", ridge_w, " overhang=", ridge_overhang, " (sides + bottom)");
echo("Right top slot: w=", right_slot_w, " d_from_top=", right_slot_d, " x0=", right_slot_x0);
echo("Right side-bracket cutout: w=", side_bracket_cut_w, " h=", side_bracket_cut_h);
echo("Stack: INNER ridge step", stack_step, " lip_h", stack_lip_h, " clear", stack_clear);
echo("Left clearance (outer):", hub_x0, "mm");
echo("Right clearance (outer):", W - hub_x1, "mm");
