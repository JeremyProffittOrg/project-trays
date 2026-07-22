// =============================================================================
// Project Trays — USB Hub Stackable Tray  (first draft v1)
// =============================================================================
// Outer envelope: 9" W × 6" D × 3" H
// Front (one 9" side): open, with 1/4" bottom ledge
// Back (other 9" side): Anker USB-C hub mount + cable routing
// Hub: 151 × 20 × 50 mm (L × T × H)
// Walls: ≥ 4 mm outer thickness
// Units: millimetres
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

// --- Stackability ---
stack_lip_h   = 3;     // height of nesting lip at top of walls
stack_step    = 1.5;   // outer inset of top rim / bottom foot
stack_clear   = 0.5;   // print clearance for nested stack

// --- Anker hub ---
hub_L = 151;           // length along back wall (X)
hub_T = 20;            // thickness into tray (Y)
hub_H = 50;            // height (Z)

// End clearances (from outer tray ends, along X)
// "35 mm deep from top" end → 1/2" from that tray end
// other end → 48 mm from that side
clear_half_in = 0.5 * inch;  // 12.7  — end with 35 mm deep top slot
clear_48      = 48;          //      — end with 10×35 wire opening

// Place the 35 mm-deep (from top) end on the RIGHT (smaller clearance),
// and the 48 mm clearance / 10×35 wire opening on the LEFT.
hub_x0 = clear_48;                    // left face of hub cavity
hub_x1 = hub_x0 + hub_L;              // right face
// Right residual to outer end: W - hub_x1  (≥ clear_half_in)
// Assert at render time via echo:
echo("hub X range", hub_x0, "→", hub_x1, "  right residual", W - hub_x1);
assert(W - hub_x1 >= clear_half_in - 0.01, "Hub does not leave 1/2\" on right end");
assert(hub_x0 >= clear_48 - 0.01, "Hub does not leave 48 mm on left side");

// Hub vertical placement: sit on a small shelf above floor so cables can run under
hub_shelf_h = 6;                      // shelf under hub
hub_z0 = floor_t + hub_shelf_h;       // bottom of hub cavity
hub_z1 = hub_z0 + hub_H;              // top of hub cavity (≈ 60 mm; tray is 76.2)

// Hub depth placement: against back wall, ports face into tray (+Y from back is wrong)
// Coordinate system:
//   X: 0 = left outer,  W = right outer
//   Y: 0 = front outer, D = back outer
//   Z: 0 = bottom outer, H = top
// Back wall inner face at Y = D - wall
// Hub occupies Y from (D - wall - hub_T) to (D - wall)  — flush to back wall inside
hub_y1 = D - wall;                    // back of hub (against back-wall inner face)
hub_y0 = hub_y1 - hub_T;              // front face of hub (ports face -Y into tray)

// Behind-hub wire groove in the BACK WALL: 5 mm deep (into wall toward outside),
// 15 mm tall, spanning hub length (with a little margin).
groove_depth = 5;                     // into back wall (Y+)
groove_h     = 15;                    // tall (Z)
groove_z0    = hub_z0 + 5;            // mid-low on hub back for cable pass-by
groove_margin_x = 2;

// --- Hub end openings ---
// LEFT end (48 mm clearance side): 10 × 35 mm opening for wires
//   Interpreted as a through-opening in the left-side bay wall / back-wall region
//   adjacent to the hub's left end — 10 mm wide (X) × 35 mm tall (Z).
left_open_w = 10;
left_open_h = 35;
left_open_z0 = hub_z0 + (hub_H - left_open_h) / 2;

// RIGHT end (1/2" clearance side): 10 mm wide × 35 mm DEEP from the TOP
//   Slot cut down from the top of the back-wall / right bay, 10 mm in X, 35 mm down in Z.
right_slot_w = 10;
right_slot_d = 35;                    // depth from top
// Position the slot just outboard of the hub right end, within the 1/2" clearance zone.
right_slot_x0 = hub_x1 + (clear_half_in - right_slot_w) / 2;
// Also open a matching notch in the hub bay so cable can leave the hub end upward.

// --- Back-wall cable pass-through notches (one side of the back) ---
// On the LEFT half of the back wall (extra clearance zone): several U-notches
// 1/4" wide × 1/2" deep, with a 1/4" bottom ledge so cable is not cut at the floor.
notch_w      = 0.25 * inch;           // 6.35
notch_depth  = 0.5  * inch;           // 12.7  how far down from top of wall? NO —
// Re-read: "cut outs ... 1/4 wide by 1/2 inch deep with a 1/4 inch ledge"
// → classic floor-level U-notch: 1/4" wide, 1/2" tall opening, 1/4" floor ledge under cable.
notch_h      = 0.5  * inch;           // opening height above the ledge
notch_ledge  = 0.25 * inch;           // solid ledge under the cable
notch_count  = 3;
notch_pitch  = 18;                    // centre-to-centre spacing
// Place notches in the left clearance zone, through the back wall.
notch_x_start = wall + 10;            // first notch centre-ish region

// --- Fillet / print helpers ---
$fn = 48;
eps = 0.05;

// =============================================================================
// MODULES
// =============================================================================

module outer_shell() {
    // Solid outer block
    cube([W, D, H]);
}

module inner_cavity() {
    // Main interior void — open at the front (Y=0) above the front ledge.
    // Leaves wall on L/R/back, floor, and front ledge.
    translate([wall, -eps, floor_t])
        cube([W - 2*wall, D - wall + eps, H - floor_t + eps]);
}

module front_ledge_keep() {
    // Re-add the front 1/4" ledge (full width between side walls).
    // The cavity cut removed everything at the front; this restores the ledge.
    translate([wall, 0, floor_t])
        cube([W - 2*wall, wall, front_ledge_h]);
}

// Actually better approach: build as union of parts rather than difference of full
// block, so open front is natural. Rebuild cleaner below.

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

module back_wall() {
    translate([0, D - wall, 0])
        cube([W, wall, H]);
}

module front_ledge() {
    // 1/4" high ledge on the open 9" front, spanning full width (including under walls
    // for strength / continuous floor edge).
    cube([W, wall, floor_t + front_ledge_h]);
}

module stack_top_step() {
    // Carve outer step at the top of L/R/back walls so an upper tray can nest.
    // Removes stack_step from the outer faces over the top stack_lip_h.
    // Left outer
    translate([-eps, -eps, H - stack_lip_h])
        cube([stack_step + eps, D + 2*eps, stack_lip_h + eps]);
    // Right outer
    translate([W - stack_step, -eps, H - stack_lip_h])
        cube([stack_step + eps, D + 2*eps, stack_lip_h + eps]);
    // Back outer
    translate([-eps, D - stack_step, H - stack_lip_h])
        cube([W + 2*eps, stack_step + eps, stack_lip_h + eps]);
    // Front outer of side-wall tips (front is open; step only on L/R front corners already covered)
}

module stack_bottom_foot_cut() {
    // Inset the bottom outer perimeter so the foot nests into the tray below's top step.
    // Foot outer size = outer - 2*(stack_step + stack_clear) on L/R/back;
    // front edge of foot inset similarly for a clean stack.
    inset = stack_step + stack_clear;
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

// --- Hub bay ---
// A pocket carved into the interior against the back wall that the hub drops into.
// Side fences hold X; a floor shelf holds Z; back wall holds Y+.
// Ports face into the tray (toward -Y / front).

module hub_side_fence_left() {
    // Thin fence just left of hub to locate it (uses part of the 48 mm clearance).
    fw = 3;
    // Place fence immediately left of hub
    x = hub_x0 - fw;
    y = hub_y0;
    z = floor_t;
    translate([x, y, z])
        cube([fw, hub_T, hub_z1 - floor_t]);
}

module hub_side_fence_right() {
    fw = 3;
    x = hub_x1;
    y = hub_y0;
    z = floor_t;
    translate([x, y, z])
        cube([fw, hub_T, hub_z1 - floor_t]);
}

module hub_shelf() {
    // Shelf under the hub, spanning hub length + fences, depth = hub_T
    fw = 3;
    translate([hub_x0 - fw, hub_y0, floor_t])
        cube([hub_L + 2*fw, hub_T, hub_shelf_h]);
}

module hub_retainer_lips() {
    // Small top lips on the front edge of the hub bay so the hub clips in from above
    // but cannot fall forward.  Leave the top open for drop-in install.
    lip = 2;
    lip_h = 3;
    // Front lip along hub front face, at top of hub
    translate([hub_x0, hub_y0 - lip, hub_z1 - lip_h])
        cube([hub_L, lip, lip_h]);
}

// --- Cutters (voids) ---

module hub_body_void() {
    // Clearance pocket for the hub body itself (slightly oversized for fit).
    fit = 0.6;
    translate([hub_x0 - fit/2, hub_y0 - fit/2, hub_z0])
        cube([hub_L + fit, hub_T + fit, hub_H + 10]); // open to top for drop-in
}

module behind_hub_groove() {
    // 5 mm deep × 15 mm tall groove in the back wall behind the hub for wires.
    translate([
        hub_x0 - groove_margin_x,
        D - wall - eps,
        groove_z0
    ])
        cube([
            hub_L + 2*groove_margin_x,
            groove_depth + eps,
            groove_h
        ]);
    // Also open a thin vertical channel at each end of the groove so wires can
    // enter/leave the groove from the ends.
    ch = 8;
    // left end channel through remaining wall
    translate([hub_x0 - groove_margin_x, D - wall - eps, groove_z0])
        cube([ch, wall + 2*eps, groove_h]);
    // right end channel
    translate([hub_x1 + groove_margin_x - ch, D - wall - eps, groove_z0])
        cube([ch, wall + 2*eps, groove_h]);
}

module left_wire_opening() {
    // 10 × 35 mm opening at the LEFT end of the hub for wires.
    // Cut through the left fence and into the back-wall region outboard of the hub,
    // and also a pass-through forward so cable can route into the tray.
    // Opening centred on hub height band.
    z0 = hub_z0 + (hub_H - left_open_h) / 2;
    // Through the left fence (X)
    translate([hub_x0 - 3 - eps, hub_y0 + (hub_T - left_open_w) / 2, z0])
        cube([3 + 2*eps + 2, left_open_w, left_open_h]);
    // Slot in back wall just left of hub, 10 wide (X) × 35 tall (Z), full wall depth
    translate([hub_x0 - left_open_w - 2, D - wall - eps, z0])
        cube([left_open_w, wall + 2*eps, left_open_h]);
}

module right_top_slot() {
    // 10 mm wide × 35 mm deep-from-top opening at the RIGHT end of the hub.
    // Cut from the top of the tray down 35 mm, through the back wall and right fence.
    z0 = H - right_slot_d;
    // Position: between hub right end and tray right end (the 1/2" clearance band)
    x0 = hub_x1 + ( (W - hub_x1) - right_slot_w ) / 2;
    // Through back wall
    translate([x0, D - wall - eps, z0])
        cube([right_slot_w, wall + 2*eps, right_slot_d + eps]);
    // Through right fence / hub-end bay so cable can rise from hub end
    translate([hub_x1 - eps, hub_y0, z0])
        cube([right_slot_w + (x0 - hub_x1) + 2, hub_T + wall + eps, right_slot_d + eps]);
    // Also open the top of the right fence entirely above hub for cable drop-in
    translate([hub_x1 - eps, hub_y0 - eps, z0])
        cube([3 + 2*eps, hub_T + 2*eps, right_slot_d + eps]);
}

module back_cable_notches() {
    // U-notches through the back wall on the LEFT side (clearance zone):
    // 1/4" wide × 1/2" tall opening, sitting on a 1/4" floor ledge.
    for (i = [0 : notch_count - 1]) {
        cx = notch_x_start + i * notch_pitch;
        // Opening starts at z = floor_t - wait: ledge is part of floor extended?
        // Ledge = bottom notch_ledge of the wall remains solid; opening above it.
        // Floor is already floor_t. The "1/4 inch ledge" is a raised sill in the
        // notch so the cable rests above a sharp floor/wall corner.
        z_open0 = floor_t + notch_ledge;
        translate([cx - notch_w/2, D - wall - eps, z_open0])
            cube([notch_w, wall + 2*eps, notch_h]);
        // Round-ish relief at the sill top edge (chamfer block) — keep simple:
        // extra 1 mm radius-equivalent by slightly widening at the sill is skipped
        // for draft; the solid ledge itself prevents a knife edge at floor level.
    }
}

module hub_access_throat() {
    // Keep the area in front of the hub ports open (already is — interior cavity).
    // Add a shallow recess in the floor in front of the hub so fat USB plugs clear.
    plug_clear_d = 25;
    plug_clear_h = 8;
    translate([hub_x0, hub_y0 - plug_clear_d, floor_t - eps])
        cube([hub_L, plug_clear_d, plug_clear_h + eps]);
}

// =============================================================================
// ASSEMBLY
// =============================================================================

module tray() {
    difference() {
        union() {
            // Primary structure
            floor_plate();
            left_wall();
            right_wall();
            back_wall();
            front_ledge();

            // Hub location features
            hub_side_fence_left();
            hub_side_fence_right();
            hub_shelf();
            hub_retainer_lips();
        }

        // Stackability
        stack_top_step();
        stack_bottom_foot_cut();

        // Hub + cable features
        hub_body_void();
        behind_hub_groove();
        left_wire_opening();
        right_top_slot();
        back_cable_notches();
        hub_access_throat();
    }
}

// Ghost hub for preview (not in final solid when render_hub_ghost = false)
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

// Dimension reference echoes
echo("=== Tray v1 ===");
echo("Outer W×D×H mm:", W, D, H);
echo("Wall / floor:", wall, floor_t);
echo("Front ledge H:", front_ledge_h);
echo("Hub cavity X:", hub_x0, "→", hub_x1, " (L=", hub_L, ")");
echo("Hub cavity Y:", hub_y0, "→", hub_y1, " (T=", hub_T, ")");
echo("Hub cavity Z:", hub_z0, "→", hub_z1, " (H=", hub_H, ")");
echo("Left clearance (outer):", hub_x0, "mm (need ≥48)");
echo("Right clearance (outer):", W - hub_x1, "mm (need ≥12.7)");
echo("Groove behind hub: ", groove_depth, "×", groove_h, "mm");
