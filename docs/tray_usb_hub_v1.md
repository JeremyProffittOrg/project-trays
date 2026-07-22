# USB Hub Tray — first draft v1

Parametric model: [`tray_usb_hub_v1.scad`](../tray_usb_hub_v1.scad)  
STL: [`export/tray_usb_hub_v1.stl`](../export/tray_usb_hub_v1.stl)  
Renders: [`renders/v1/`](../renders/v1/)

## Envelope

| Dim | Imperial | Metric |
|-----|----------|--------|
| Width (X) | 9 in | 228.6 mm |
| Depth (Y) | 6 in | 152.4 mm |
| Height (Z) | 3 in | 76.2 mm |
| Wall / floor | — | 4 mm min |

## Layout

- **Front** (Y = 0, one 9" side): open, with a **1/4" (6.35 mm)** high ledge.
- **Back** (Y = D, other 9" side): Anker USB-C hub mount.
- **Sides**: full-height 4 mm walls.
- **Stackable**: 3 mm top outer step + inset bottom foot (1.5 mm step, 0.5 mm clearance).

## Hub mount (Anker USB-C hub)

Body: **151 × 20 × 50 mm** (L × T × H). Ghosted blue in review renders.

| Side | Clearance from outer end | Opening |
|------|--------------------------|---------|
| Left | 48 mm | 10 × 35 mm wire opening |
| Right | ≥ 1/2" (actual ~29.6 mm) | 10 mm wide × 35 mm deep from top |

- Hub sits on a **6 mm shelf** against the back wall; ports face into the tray.
- Side fences + front retainer lip: drop-in from above.
- **Behind hub**: 5 mm deep × 15 mm tall groove in the back wall for cables.
- Shallow floor recess in front of ports for fat USB plugs.

## Cable pass-throughs (left side of back wall)

3× U-notches:

- 1/4" wide
- 1/2" tall opening
- 1/4" solid ledge under the cable (no sharp floor edge)

## Coordinate system

- X: 0 = left outer → W = right outer  
- Y: 0 = front (open) → D = back (hub)  
- Z: 0 = bottom → H = top  

## Review renders (10 angles)

1. Iso front-right  
2. Iso front-left  
3. Front (open ledge)  
4. Back (hub + notches)  
5. Left (48 mm clearance)  
6. Right (1/2" + top slot)  
7. Top down  
8. Bottom (stack foot)  
9. Iso back-left  
10. Iso back-right  

Plus `00_contact_sheet.png` composite.

## Open questions for next draft

- Confirm which physical hub end is left vs right (host cable vs DC-IN).
- Exact Anker model fit tolerance / clip force.
- Notch count and side preference.
- Whether front ledge should span full width under side walls only or include center lip shape.
- Print orientation and material (PETG vs ABS, etc.).
