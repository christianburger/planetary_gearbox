// ============================================================================
// 4.67:1 PLANETARY GEARBOX - MODULAR DESIGN
// ============================================================================
// BOSL2 library required
// Based on the spur gearbox design
// ============================================================================

include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 100;

// ============================================================================
// TOLERANCES & CLEARANCES
// ============================================================================
clearance_bearing_pocket = 0.3;
clearance_screw_hole = 0.0;
clearance_boss_center = 0.3;
tolerance_shaft = 0.4;
tolerance_output_bore = 0.4;

// ============================================================================
// GEAR PARAMETERS
// ============================================================================
teeth_sun = 9;           // Sun gear (input)
teeth_planet = 12;       // Planet gears (3x)
teeth_ring = 33;         // Ring gear (fixed) = sun + 2*planet
gear_module = 1.156;
gear_thickness = 10;
gear_pressure_angle = 20;

// Calculated gear dimensions
pitch_radius_sun = (gear_module * teeth_sun) / 2;
pitch_radius_planet = (gear_module * teeth_planet) / 2;
pitch_radius_ring = (gear_module * teeth_ring) / 2;
outer_radius_sun = (gear_module * (teeth_sun + 2)) / 2;
outer_radius_planet = (gear_module * (teeth_planet + 2)) / 2;
outer_radius_ring = (gear_module * (teeth_ring + 2)) / 2;

// Planet carrier circle radius
carrier_radius = pitch_radius_sun + pitch_radius_planet;

// Gear ratio calculation (ring fixed, sun input, carrier output)
gear_ratio = (teeth_ring + teeth_sun) / teeth_sun;

// Gear chamfers
chamfer_height = 2.0;
chamfer_angle = 45;
chamfer_base_radius_sun = outer_radius_sun - chamfer_height * tan(chamfer_angle);
chamfer_base_radius_planet = outer_radius_planet - chamfer_height * tan(chamfer_angle);

// ============================================================================
// BEARING SPECIFICATIONS
// ============================================================================
// 683ZZ: 3mm ID, 7mm OD, 3mm thickness (for planet shafts)
bearing_683_id = 3;
bearing_683_od = 7;
bearing_683_thickness = 3;

// 695ZZ: 5mm ID, 13mm OD, 4mm thickness (for sun gear support)
bearing_695_id = 5;
bearing_695_od = 13;
bearing_695_thickness = 4;

// ============================================================================
// SUN GEAR PARAMETERS
// ============================================================================
shaft_diameter_sun = 5.0;      // D-shaped shaft
shaft_flat_height = 4.0;       // D-shaft flat dimension
hub_diameter_sun = 12;
hub_height_sun = 10;
setscrew_sun_diameter = 5.0;
setscrew_sun_clearance = 0.6;

// ============================================================================
// PLANET GEAR PARAMETERS
// ============================================================================
planet_shaft_diameter = 3.0;
planet_shaft_length = gear_thickness + 2;

// Planet shaft positions (120° apart)
planet_angle_1 = 0;
planet_angle_2 = 120;
planet_angle_3 = 240;

// ============================================================================
// CARRIER PARAMETERS
// ============================================================================
carrier_plate_thickness = 6;
carrier_plate_diameter = pitch_radius_ring * 2 - 4;
carrier_bearing_pocket_depth = bearing_683_thickness + 0.5;
clearance_gear_to_plate = 1.5;      // Clearance above and below gears
carrier_to_planets_clearance = 5;   // Clearance around planet gears
carrier_spacing = gear_thickness + clearance_gear_to_plate * 2;
carrier_total_height = carrier_plate_thickness * 2 + carrier_spacing;

// Output shaft parameters
shaft_diameter_output = 9.0;
hub_diameter_output = 18;
hub_height_output = 22 - carrier_plate_thickness;

// Output setscrew parameters
setscrew_output_diameter = 3.0;
setscrew_output_clearance = 0.6;
setscrew_output_height = hub_height_output - 3;

// Sun gear insertion clearance
clearance_sun_insertion = 3.0;
sun_insertion_bore_diameter = outer_radius_sun * 2 + clearance_sun_insertion;

// ============================================================================
// RING GEAR PARAMETERS
// ============================================================================
ring_gear_thickness = carrier_total_height;  // Match carrier height
ring_gear_outer_diameter = pitch_radius_ring * 2 + 12;
ring_gear_wall_thickness = 4;

// ============================================================================
// HOUSING PARAMETERS
// ============================================================================
wall_thickness = 3;
housing_inner_clearance = 1;
housing_size = ring_gear_outer_diameter + wall_thickness;
housing_height_bottom = carrier_total_height / 2 + wall_thickness + 2;
housing_height_top = carrier_total_height / 2 + wall_thickness + 2;
box_chamfer_size = 4;  // 4mm corner chamfers

// ============================================================================
// NEMA17 MOTOR PARAMETERS
// ============================================================================
nema17_body_size = 42.3;
nema17_hole_spacing = 31;
nema17_hole_diameter = 3.2;
nema17_boss_diameter = 23;
nema17_boss_depth = 2.5;

// ============================================================================
// VISUALIZATION OFFSETS
// ============================================================================
z_offset_sun = 80;
z_offset_carrier = 83;
z_offset_planets = 88;
z_offset_ring = 120;
z_offset_housing_bottom = 0;
z_offset_housing_top = 180;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
function polar_xy(radius, angle_deg) = [
    radius * cos(angle_deg),
    radius * sin(angle_deg)
];

// ============================================================================
// MODULES
// ============================================================================

// Corner chamfer module (from original design)
module corner_chamfer(chamfer_width, chamfer_size) {
    cube([chamfer_width, chamfer_size, housing_height_bottom * 2]);
}

// Gear chamfer module
module gear_chamfer(gear_thickness, outer_radius, chamfer_base_radius, chamfer_height) {
    // Top chamfer
    difference() {
        translate([0, 0, gear_thickness/2 - chamfer_height])
            cylinder(d = outer_radius * 2 + 4, h = chamfer_height + 5);
        translate([0, 0, gear_thickness/2 - chamfer_height])
            cylinder(r1 = outer_radius + 2, 
                   r2 = chamfer_base_radius, 
                   h = chamfer_height);
    }
    
    // Bottom chamfer
    mirror([0, 0, 1])
        difference() {
            translate([0, 0, gear_thickness/2 - chamfer_height])
                cylinder(d = outer_radius * 2 + 4, h = chamfer_height + 5);
            translate([0, 0, gear_thickness/2 - chamfer_height])
                cylinder(r1 = outer_radius + 2, 
                       r2 = chamfer_base_radius, 
                       h = chamfer_height);
        }
}

// Sun gear module
module sun_gear(
    teeth,
    mod,
    thickness,
    pressure_angle,
    shaft_diam,
    shaft_flat_height,
    hub_diam,
    hub_height,
    tolerance_shaft,
    setscrew_diam,
    setscrew_clearance,
    outer_radius,
    chamfer_base_radius,
    chamfer_height
) {
    // Hub with D-bore
    translate([0, 0, thickness/2 + hub_height])
        rotate([180, 0, 0])
            difference() {
                translate([0, 0, thickness/2])
                    cylinder(d = hub_diam, h = hub_height);
                
                // D-shaped bore
                translate([0, 0, thickness/2 - 0.1])
                    linear_extrude(height = hub_height + 0.2) {
                        difference() {
                            circle(r = (shaft_diam + tolerance_shaft) / 2);
                            translate([-(shaft_diam + tolerance_shaft)/2, 
                                     -(shaft_diam + tolerance_shaft)/2])
                                square([shaft_diam + tolerance_shaft, 
                                       (shaft_diam + tolerance_shaft)/2 - shaft_flat_height/2]);
                        }
                    }
                
                // Setscrew hole
                translate([0, -hub_diam, thickness/2 + hub_height/2])
                    rotate([90, 0, 0])
                        cylinder(d = setscrew_diam - setscrew_clearance, 
                               h = hub_diam * 2, 
                               center = true);
            }
    
    // Gear body with chamfers
    translate([0, 0, thickness/2 + hub_height])
        difference() {
            spur_gear(
                mod = mod,
                teeth = teeth,
                thickness = thickness,
                shaft_diam = shaft_diam + tolerance_shaft,
                pressure_angle = pressure_angle
            );
            
            // Apply chamfers
            gear_chamfer(thickness, outer_radius, chamfer_base_radius, chamfer_height);
        }
}

// Planet gear module
module planet_gear(
    teeth,
    mod,
    thickness,
    pressure_angle,
    shaft_diam,
    tolerance_shaft,
    outer_radius,
    chamfer_base_radius,
    chamfer_height
) {
    difference() {
        spur_gear(
            mod = mod,
            teeth = teeth,
            thickness = thickness,
            shaft_diam = shaft_diam + tolerance_shaft,
            pressure_angle = pressure_angle
        );
        
        // Bore for planet shaft
        translate([0, 0, -0.1])
            cylinder(d = shaft_diam + tolerance_shaft, 
                   h = thickness + 0.2);
        
        // Apply chamfers
        gear_chamfer(thickness, outer_radius, chamfer_base_radius, chamfer_height);
    }
}

// Ring gear module
module ring_gear_internal(
    teeth,
    mod,
    thickness,
    pressure_angle,
    outer_diam
) {
    difference() {
        // Outer cylinder (tube)
        cylinder(d = outer_diam, h = thickness);
        
        // Internal gear teeth (created by subtracting a spur gear)
        translate([0, 0, thickness / 2])
            spur_gear(
                mod = mod,
                teeth = teeth,
                thickness = thickness,
                shaft_diam = 0,
                pressure_angle = pressure_angle
            );
    }
}

// Carrier hub module
module carrier_hub(
    hub_diam,
    hub_height,
    shaft_diam,
    tolerance_bore,
    setscrew_diam,
    setscrew_clearance,
    setscrew_height
) {
    difference() {
        // Hub body
        cylinder(d = hub_diam, h = hub_height);
        
        // Central bore for output shaft
        translate([0, 0, -0.1])
            cylinder(d = shaft_diam + tolerance_bore, 
                   h = hub_height + 0.2);
        
        // Setscrew hole
        translate([0, 0, setscrew_height])
            rotate([90, 0, 0])
                cylinder(d = setscrew_diam - setscrew_clearance, 
                       h = hub_diam, center = true);
    }
}

// Carrier module
module carrier(
    plate_diam,
    plate_thickness,
    spacing,
    total_height,
    carrier_radius,
    planet_angles,
    bearing_od,
    bearing_id,
    bearing_pocket_depth,
    clearance_bearing,
    clearance_boss,
    planet_outer_radius,
    planet_clearance,
    shaft_diam,
    tolerance_bore,
    sun_bore_diam,
    clearance_plate,
    hub_diam,
    hub_height,
    setscrew_diam,
    setscrew_clearance,
    setscrew_height
) {
    difference() {
        union() {
            // Bottom cylinder
            cylinder(d = plate_diam, h = plate_thickness);
            
            // Middle cylinder
            translate([0, 0, plate_thickness])
                cylinder(d = plate_diam, h = spacing);
            
            // Top cylinder
            translate([0, 0, spacing + plate_thickness])
                cylinder(d = plate_diam, h = plate_thickness);
            
            // Output hub (top only)
            translate([0, 0, total_height])
                carrier_hub(
                    hub_diam = hub_diam,
                    hub_height = hub_height,
                    shaft_diam = shaft_diam,
                    tolerance_bore = tolerance_bore,
                    setscrew_diam = setscrew_diam,
                    setscrew_clearance = setscrew_clearance,
                    setscrew_height = setscrew_height
                );
        }
        
        // Central bore for output shaft
        translate([0, 0, -0.1])
            cylinder(d = shaft_diam + tolerance_bore, 
                   h = total_height + 0.2);
        
        // Sun gear insertion bore through bottom
        translate([0, 0, -0.1])
            cylinder(d = sun_bore_diam, 
                   h = plate_thickness + clearance_plate + 0.1);
        
        // Planet gear pockets in middle section
        for (angle = planet_angles) {
            translate(concat(polar_xy(carrier_radius, angle), 
                           [plate_thickness - 0.1]))
                cylinder(d = planet_outer_radius * 2 + planet_clearance, 
                       h = spacing + 0.2);
        }
        
        // Bearing pockets in BOTTOM plate (on inner face)
        for (angle = planet_angles) {
            translate(concat(polar_xy(carrier_radius, angle), 
                           [plate_thickness - bearing_pocket_depth]))
                cylinder(d = bearing_od + clearance_bearing, 
                       h = bearing_pocket_depth + 0.1);
        }
        
        // Bearing pockets in TOP plate
        for (angle = planet_angles) {
            translate(concat(polar_xy(carrier_radius, angle), 
                           [spacing + plate_thickness]))
                cylinder(d = bearing_od + clearance_bearing, 
                       h = bearing_pocket_depth + 0.1);
        }
        
        // Through holes for planet shafts
        for (angle = planet_angles) {
            translate(concat(polar_xy(carrier_radius, angle), [-0.1]))
                cylinder(d = bearing_id + clearance_boss, 
                       h = total_height + 0.2);
        }
    }
}

// PLANET GEARS (3x - Yellow)
for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
    color("yellow")
    translate(concat(polar_xy(carrier_radius, angle), 
                    [z_offset_planets + carrier_plate_thickness + clearance_gear_to_plate])) {
        planet_gear(
            teeth = teeth_planet,
            mod = gear_module,
            thickness = gear_thickness,
            pressure_angle = gear_pressure_angle,
            shaft_diam = planet_shaft_diameter,
            tolerance_shaft = tolerance_shaft,
            outer_radius = outer_radius_planet,
            chamfer_base_radius = chamfer_base_radius_planet,
            chamfer_height = chamfer_height
        );
    }
}

// ============================================================================
// PARAMETERS SUMMARY
// ============================================================================
echo("\n");
echo("============================================================");
echo("    PLANETARY GEARBOX PARAMETERS SUMMARY");
echo("============================================================");

echo("\n=== GEAR RATIO ===");
echo("Gear Ratio: ", gear_ratio, ":1");
echo("Formula: (teeth_ring + teeth_sun) / teeth_sun");

echo("\n=== SUN GEAR ===");
echo("Teeth: ", teeth_sun);
echo("Pitch radius: ", pitch_radius_sun, " mm");
echo("Outer radius: ", outer_radius_sun, " mm");
echo("Shaft diameter: ", shaft_diameter_sun, " mm (D-shaped)");
echo("Shaft flat height: ", shaft_flat_height, " mm");
echo("Hub diameter: ", hub_diameter_sun, " mm");
echo("Hub height: ", hub_height_sun, " mm");
echo("Setscrew diameter: ", setscrew_sun_diameter, " mm");
echo("Setscrew clearance: ", setscrew_sun_clearance, " mm");

echo("\n=== PLANET GEARS ===");
echo("Number of planets: 3");
echo("Teeth per planet: ", teeth_planet);
echo("Pitch radius: ", pitch_radius_planet, " mm");
echo("Outer radius: ", outer_radius_planet, " mm");
echo("Shaft diameter: ", planet_shaft_diameter, " mm");
echo("Carrier radius: ", carrier_radius, " mm");
echo("Planet angles: ", planet_angle_1, "°, ", planet_angle_2, "°, ", planet_angle_3, "°");

echo("\n=== RING GEAR ===");
echo("Teeth: ", teeth_ring);
echo("Pitch radius: ", pitch_radius_ring, " mm");
echo("Outer radius: ", outer_radius_ring, " mm");
echo("Outer diameter: ", ring_gear_outer_diameter, " mm");
echo("Wall thickness: ", ring_gear_wall_thickness, " mm");
echo("Height: ", ring_gear_thickness, " mm");

echo("\n=== GEAR COMMON ===");
echo("Module: ", gear_module);
echo("Thickness: ", gear_thickness, " mm");
echo("Pressure angle: ", gear_pressure_angle, "°");
echo("Chamfer height: ", chamfer_height, " mm");
echo("Chamfer angle: ", chamfer_angle, "°");

echo("\n=== CARRIER ===");
echo("Plate diameter: ", carrier_plate_diameter, " mm");
echo("Plate thickness: ", carrier_plate_thickness, " mm");
echo("Spacing (middle section): ", carrier_spacing, " mm");
echo("Total height: ", carrier_total_height, " mm");
echo("Clearance to gears (top/bottom): ", clearance_gear_to_plate, " mm");
echo("Clearance to planets (radial): ", carrier_to_planets_clearance, " mm");
echo("Sun insertion bore: ", sun_insertion_bore_diameter, " mm");

echo("\n=== OUTPUT HUB ===");
echo("Shaft diameter: ", shaft_diameter_output, " mm");
echo("Hub diameter: ", hub_diameter_output, " mm");
echo("Hub height: ", hub_height_output, " mm");
echo("Setscrew diameter: ", setscrew_output_diameter, " mm");
echo("Setscrew clearance: ", setscrew_output_clearance, " mm");
echo("Setscrew height position: ", setscrew_output_height, " mm");

echo("\n=== BEARINGS ===");
echo("Planet bearings (683ZZ): ", bearing_683_od, " mm OD × ", bearing_683_id, " mm ID × ", bearing_683_thickness, " mm thick");
echo("Number of planet bearings: 6 (3 top + 3 bottom)");
echo("Bearing pocket depth: ", carrier_bearing_pocket_depth, " mm");
echo("Sun support bearings (695ZZ): ", bearing_695_od, " mm OD × ", bearing_695_id, " mm ID × ", bearing_695_thickness, " mm thick");

echo("\n=== HOUSING ===");
echo("Size (square): ", housing_size, " × ", housing_size, " mm");
echo("Bottom height: ", housing_height_bottom, " mm");
echo("Top height: ", housing_height_top, " mm");
echo("Wall thickness: ", wall_thickness, " mm");
echo("Corner chamfer: ", box_chamfer_size, " mm");

echo("\n=== NEMA17 MOTOR ===");
echo("Body size: ", nema17_body_size, " mm");
echo("Hole spacing: ", nema17_hole_spacing, " mm");
echo("Hole diameter: ", nema17_hole_diameter, " mm");
echo("Boss diameter: ", nema17_boss_diameter, " mm");
echo("Boss depth: ", nema17_boss_depth, " mm");

echo("\n=== TOLERANCES ===");
echo("Bearing pocket clearance: ", clearance_bearing_pocket, " mm");
echo("Screw hole clearance: ", clearance_screw_hole, " mm");
echo("Boss center clearance: ", clearance_boss_center, " mm");
echo("Shaft tolerance: ", tolerance_shaft, " mm");
echo("Output bore tolerance: ", tolerance_output_bore, " mm");
echo("Sun insertion clearance: ", clearance_sun_insertion, " mm");

echo("\n============================================================\n");