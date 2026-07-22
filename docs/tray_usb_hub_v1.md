# USB Hub Tray — v1.1

Parametric model: [`tray_usb_hub_v1.scad`](../tray_usb_hub_v1.scad)  
STL: [`export/tray_usb_hub_v1.stl`](../export/tray_usb_hub_v1.stl)  
Renders: [`renders/v1/`](../renders/v1/) (v1.0 review set)

## Envelope

| Dim | Imperial | Metric |
|-----|----------|--------|
| Width (X) | 9 in | 228.6 mm |
| Depth (Y) | 6 in | 152.4 mm |
| Height (Z) | 3 in | 76.2 mm |
| Wall / floor | — | 4 mm min |
| Right-of-hub back wall | — | **10 mm** thick |

## Layout

- **Front** (Y = 0, one 9" side): open, with a **1/4" (6.35 mm)** high ledge.
- **Back** (Y = D, other 9" side): Anker USB-C hub mount.
- **Sides**: full-height 4 mm walls.
- **Stackable**: **inner** ridge at top (2 mm step, 3 mm lip) + inset bottom foot that sits on that ridge.

## Hub mount (Anker USB-C hub)

Body: **151 × 20 × 50 mm** (L × T × H). Ghosted blue in OpenSCAD preview.

| Side | Clearance from outer end | Opening |
|------|--------------------------|---------|
| Left | 48 mm | In-tray wire relief only (no left back-wall holes) |
| Right | ≥ 1/2" (actual ~29.6 mm) | 10 mm wide top slot (35 mm from top) + second 10 mm slot 15 mm lower |

- Hub sits on a **6 mm shelf** against the back wall; ports face into the tray.
- **Hold**: 5 mm wide side ridges (left & right) catch the front of the hub — no full-width front bar.
- **Behind hub**: 5 mm deep × 15 mm tall groove in the back wall for cables.
- Right-of-hub back wall thickened to **10 mm** around the cutouts.
- Shallow floor recess in front of ports for fat USB plugs.

## Coordinate system

- X: 0 = left outer → W = right outer  
- Y: 0 = front (open) → D = back (hub)  
- Z: 0 = bottom → H = top  

## v1.1 changes (from review)

- Removed front retainer bar across hub top.
- Added 5 mm side ridges to hold hub.
- Removed left-back cable notches / left back-wall holes.
- Right cutout fixed to 10 mm wide; wall around it 10 mm thick.
- Second right-of-hub cutout 10 mm wide, 15 mm lower.
- Stacking ridge moved to the **inside** of the walls.
