
# Planetary Gearbox for NEMA17 Motor

A fully parametric **3D printable planetary gearbox** designed in OpenSCAD, intended for NEMA17 stepper motors.

This compact single-stage planetary reduction provides high torque in a small package. It features a fixed ring gear integrated into the housing, a sun gear driven by the motor, three planet gears, and a planet carrier as the output.

**Gear ratio**: Approximately **4:1** (exact ratio = (ring teeth + sun teeth) / sun teeth)

## Features

- Direct mount to standard NEMA17 motors (31 mm hole pattern)
- Sun gear with D-shaft bore for standard 5 mm motor shafts
- Three planet gears for balanced load distribution
- Integrated ring gear in the housing for simplicity and strength
- Planet carrier output with setscrew hub
- Split housing (top + bottom) for easy assembly and access
- Bearing pockets for improved smoothness (uses 695ZZ bearings)

## Files

- `planetary.gearbox.scad` – Full assembly view (open this to preview the complete gearbox)
- `bottom_housing.scad` – Bottom half of the housing (with motor mounting)
- `top_housing.scad` – Top half of the housing
- `sun_gear.scad` – Input sun gear with D-bore
- `planet_gear.scad` – Individual planet gear (three needed)
- `ring_gear.scad` – Fixed ring gear (integrated into housing)
- `carrier.scad` – Output planet carrier
- `.stl` files – Pre-exported meshes ready for slicing/printing (sun_gear.stl, planet_gear.stl ×3, ring_gear.stl, carrier.stl)

## How to Generate STL Files and 3D Print

### Using OpenSCAD (recommended for custom versions)

1. Install OpenSCAD (free from https://openscad.org/)
2. Open each part file you want to print:
   - `bottom_housing.scad`
   - `top_housing.scad`
   - `sun_gear.scad`
   - `planet_gear.scad` (print three copies)
   - `carrier.scad`
   - (Optional: open `planetary.gearbox.scad` first to preview the full assembly)
3. Press **F5** to preview the model
4. Press **F6** to render (this computes the full geometry – takes a few seconds)
5. Once rendered, go to **File > Export > Export as STL** and save the file
6. Repeat for each part

### Using Pre-exported STLs

The repository includes ready-to-print STL files for most parts. Download and slice them directly.

### Slicing and Printing Recommendations

- **Material**: PETG or PLA+ recommended for strength and durability (ABS/ASA if you have an enclosure)
- **Layer height**: 0.15–0.2 mm for good detail and gear meshing
- **Infill**: 40–60% (higher for loaded parts like carrier and housing)
- **Perimeters/Walls**: 4+ for strength
- **Supports**: Minimal – mostly needed for overhangs in housing and carrier
- **Orientation**: Print housing halves and carrier flat on the bed for best strength
- **Brim**: Recommended for better adhesion on larger parts

## Required Hardware

- 695ZZ bearings (5 × 13 × 4 mm) – quantity depends on design (typically 2–4 for sun and carrier support)
- M3 or M4 grub screws for carrier output setscrew
- A 5–8 mm diameter output shaft (smooth round rod)
- Optional brass tube/bushing (matching carrier hub bore OD, 5 mm ID) for durable shaft interface
- Optional: M3/M4 screws or glue to secure top and bottom housing

## Assembly Notes – Output Shaft

The planet carrier serves as the output and has a central hub with setscrew. Similar to common 3D printed planetary designs, the hub bore is sized to accept a press-fit **brass tube or bushing** (outer diameter matching the printed bore, inner diameter 5 mm) for better wear resistance. Insert the brass bushing, secure with the setscrew if desired, then pass your 5 mm output shaft through it.

## Customization

All parameters (tooth counts, module, clearances, bearing sizes, etc.) are defined at the top of the individual SCAD files. Modify them to adjust ratio, size, or fit for your printer/filament.

Open `planetary.gearbox.scad` to visualize the full assembly and check meshing before printing.

Enjoy the build! High-torque planetary gears are great for robotics and automation. If you print it, feel free to share photos or improvements. 🚀


