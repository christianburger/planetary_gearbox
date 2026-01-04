// ============================================================================
// PLANET SHAFT BEARING SEPARATOR (SPACER) - PLANETARY GEARBOX
// ============================================================================
// Purpose: Spacer sleeve that goes on each M3 planet shaft
// Keeps bearings centered and separated within each planet gear
// Print quantity: 6x (2 per planet gear × 3 planet gears)
// ============================================================================

include <BOSL2/std.scad>

$fn = 200;

// ============================================================================
// PARAMETERS FROM MAIN GEARBOX
// ============================================================================

// Planet shaft
planet_shaft_diameter = 3.0;
tolerance_shaft = 1.8;  // From main gearbox

// Planet gear
gear_thickness = 10;

// Bearing specifications (683ZZ: 3mm ID × 7mm OD × 3mm thick)
bearing_683_id = 3;
bearing_683_od = 7;
bearing_683_thickness = 3;

// Bearing pocket depth (from main gearbox)
planet_bearing_pocket_depth = bearing_683_thickness + 0.5;  // 3.5mm

// ============================================================================
// SEPARATOR PARAMETERS
// ============================================================================

// From planet gear module: through-hole is bearing_id + tolerance_shaft = 3 + 0.4 = 3.4mm

// Clearances
clearance_shaft = 0.1;          // Minimal clearance for M3 shaft
clearance_to_gear_bore = 0.1;   // Clearance to fit in gear's through-hole

// Separator dimensions
// Height = half the space between bearings (need 2 separators per planet)
separator_height = (gear_thickness - (2 * planet_bearing_pocket_depth)) / 2;

// Inner diameter: M3 shaft + minimal clearance
separator_inner_diameter = planet_shaft_diameter + clearance_shaft;  // 3.1mm

// Outer diameter: Must fit in gear's through-hole (3.4mm) without touching bearing
// The gear bore is 3.4mm, so separator OD should be ~3.2mm for clearance
separator_outer_diameter = (bearing_683_id + tolerance_shaft) - clearance_to_gear_bore;  // ~3.2mm

// ============================================================================
// SEPARATOR MODULE
// ============================================================================

module bearing_separator_sleeve(
    inner_diam,
    outer_diam,
    height
) {
    difference() {
        // Outer sleeve
        cylinder(d = outer_diam, h = height);
        
        // Inner bore for M3 shaft
        translate([0, 0, -0.1])
            cylinder(d = inner_diam, h = height + 0.2);
    }
}

// ============================================================================
// INSTANTIATION - ARRAY OF 6
// ============================================================================

// Create 6 separators arranged for printing
for (i = [0:5]) {
    color("orange")
    translate([i * (separator_outer_diameter + 2), 0, 0])
        bearing_separator_sleeve(
            inner_diam = separator_inner_diameter,
            outer_diam = separator_outer_diameter,
            height = separator_height
        );
}

// ============================================================================
// PARAMETERS SUMMARY
// ============================================================================

echo("\n");
echo("============================================================");
echo("    PLANET SHAFT BEARING SEPARATOR (SPACER)");
echo("============================================================");

echo("\n=== DIMENSIONS ===");
echo("Inner diameter: ", separator_inner_diameter, " mm (M3 shaft + clearance)");
echo("Outer diameter: ", separator_outer_diameter, " mm (bearing inner race OD)");
echo("Height: ", separator_height, " mm");

echo("\n=== CALCULATION ===");
echo("Planet gear thickness: ", gear_thickness, " mm");
echo("Bearing pocket depth (each): ", planet_bearing_pocket_depth, " mm");
echo("Space between bearings: ", gear_thickness, " - 2×", planet_bearing_pocket_depth, " = ", separator_height, " mm");

echo("\n=== BEARING INFO (683ZZ) ===");
echo("Bearing ID: ", bearing_683_id, " mm");
echo("Bearing OD: ", bearing_683_od, " mm");
echo("Bearing thickness: ", bearing_683_thickness, " mm");
echo("Planet gear through-hole: ", bearing_683_id + tolerance_shaft, " mm (bearing ID + tolerance)");

echo("\n=== INSTALLATION ===");
echo("Quantity needed: 6 total");
echo("  - 2 per planet gear (one above bottom bearing, one below top bearing)");
echo("  - 3 planet gears × 2 separators = 6 total");
echo("Position: On M3 shaft, between bearings within planet gear");
echo("Function: Centers and maintains bearing position on shaft");
echo("Note: Separator OD < bearing ID to avoid interference with bearing and gear");
echo("\nWARNING: Wall thickness is only ", (separator_outer_diameter - separator_inner_diameter)/2, " mm per side");
echo("Calculated as: (OD - ID) / 2 = (", separator_outer_diameter, " - ", separator_inner_diameter, ") / 2");
echo("This requires precise 3D printing. Consider:");
echo("  - Using 0.2mm or 0.1mm layer height");
echo("  - Printing with 100% infill");  
echo("  - Using a rigid material (PLA, PETG)");
echo("The separator fits in the gear's ", bearing_683_id + tolerance_shaft, "mm through-hole");

echo("\n============================================================\n");