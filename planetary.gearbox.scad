// ============================================================================
// 3.5:1 PLANETARY GEARBOX
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

// Gear ratio calculation
gear_ratio = (teeth_ring + teeth_sun) / teeth_sun;
echo("Gear Ratio: ", gear_ratio, ":1");

// ============================================================================
// BEARING SPECIFICATIONS
// ============================================================================
// 683ZZ: 3mm ID, 7mm OD, 3mm thickness
bearing_683_id = 3;
bearing_683_od = 7;
bearing_683_thickness = 3;

// 695ZZ for ring gear support: 5mm ID, 13mm OD, 4mm thickness
bearing_695_id = 5;
bearing_695_od = 13;
bearing_695_thickness = 4;

// ============================================================================
// SHAFT & HUB PARAMETERS (from original design)
// ============================================================================
// Sun shaft (D-shaped, matches input gear)
shaft_diameter_sun = 5.0;
shaft_flat_height = 4.0;
hub_diameter_sun = 12;
hub_height_sun = 10;

// Output shaft (carrier output, matches original output gear)
shaft_diameter_output = 9.0;
hub_diameter_output = 18;
hub_height_output = 10;

// Planet shafts (fixed to carrier)
planet_shaft_diameter = 3.0;
planet_shaft_length = gear_thickness + 2; // Slightly longer than gear

// Setscrews
setscrew_output_diameter = 3.0;
setscrew_output_clearance = 0.6;
setscrew_sun_diameter = 5.0;
setscrew_sun_clearance = 0.6;

// Gear chamfers
chamfer_height = 2.0;
chamfer_angle = 45;
chamfer_base_radius_sun = outer_radius_sun - chamfer_height * tan(chamfer_angle);
chamfer_base_radius_planet = outer_radius_planet - chamfer_height * tan(chamfer_angle);

// ============================================================================
// CARRIER PARAMETERS
// ============================================================================
carrier_plate_thickness = 6;
carrier_plate_diameter = pitch_radius_ring * 2 - 4;
carrier_bearing_pocket_depth = bearing_683_thickness + 0.5;
clearance_gear_to_plate = 1.5;  // Clearance above and below gears
carrier_spacing = gear_thickness + clearance_gear_to_plate * 2;  // Distance between plates
carrier_total_height = carrier_plate_thickness * 2 + carrier_spacing;

// Sun gear clearance for insertion through bottom
clearance_sun_insertion = 3.0;  // Clearance around sun gear
sun_insertion_bore_diameter = outer_radius_sun * 2 + clearance_sun_insertion;

// Planet shaft positions (120° apart)
planet_angle_1 = 0;
planet_angle_2 = 120;
planet_angle_3 = 240;

// ============================================================================
// RING GEAR HOUSING PARAMETERS
// ============================================================================
ring_gear_thickness = carrier_total_height;  // Match carrier height exactly
ring_gear_outer_diameter = pitch_radius_ring * 2 + 12;
ring_gear_wall_thickness = 4;  // Wall thickness for the ring
ring_bearing_pocket_depth = bearing_695_thickness + 0.5;

wall_thickness = 3;
housing_inner_clearance = 1;
housing_height = carrier_total_height + bearing_695_thickness * 2 + 4;

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
z_offset_carrier = 80;
z_offset_planets = 48;
z_offset_sun = 40;
z_offset_ring = 0;
z_offset_housing_top = 0;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
function polar_xy(radius, angle_deg) = [
    radius * cos(angle_deg),
    radius * sin(angle_deg)
];

// ============================================================================
// GEAR CHAMFER MODULE
// ============================================================================
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

// ============================================================================
// SUN GEAR (Input - Blue)
// ============================================================================
color("lightblue")
translate([0, 0, z_offset_sun + housing_height/2 - bearing_695_thickness]) {
    // Hub with D-bore
    translate([0, 0, gear_thickness/2 + hub_height_sun])
        rotate([180, 0, 0])
            difference() {
                translate([0, 0, gear_thickness/2])
                    cylinder(d = hub_diameter_sun, h = hub_height_sun);
                
                // D-shaped bore
                translate([0, 0, gear_thickness/2 - 0.1])
                    linear_extrude(height = hub_height_sun + 0.2) {
                        difference() {
                            circle(r = (shaft_diameter_sun + tolerance_shaft) / 2);
                            translate([-(shaft_diameter_sun + tolerance_shaft)/2, 
                                     -(shaft_diameter_sun + tolerance_shaft)/2])
                                square([shaft_diameter_sun + tolerance_shaft, 
                                       (shaft_diameter_sun + tolerance_shaft)/2 - shaft_flat_height/2]);
                        }
                    }
                
                // Setscrew hole
                translate([0, -hub_diameter_sun, gear_thickness/2 + hub_height_sun/2])
                    rotate([90, 0, 0])
                        cylinder(d = setscrew_sun_diameter - setscrew_sun_clearance, 
                               h = hub_diameter_sun * 2, 
                               center = true);
            }
    
    // Gear body
    translate([0, 0, gear_thickness/2 + hub_height_sun])
        difference() {
            spur_gear(
                mod = gear_module,
                teeth = teeth_sun,
                thickness = gear_thickness,
                shaft_diam = shaft_diameter_sun + tolerance_shaft,
                pressure_angle = gear_pressure_angle
            );
            
            // Apply chamfers
            gear_chamfer(gear_thickness, outer_radius_sun, chamfer_base_radius_sun, chamfer_height);
        }
}

// ============================================================================
// PLANET GEARS (3x - Yellow)
// ============================================================================
for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
    color("yellow")
    translate(concat(polar_xy(carrier_radius, angle), 
                    [z_offset_planets + housing_height/2 - bearing_695_thickness + carrier_plate_thickness + clearance_gear_to_plate])) {
        difference() {
            spur_gear(
                mod = gear_module,
                teeth = teeth_planet,
                thickness = gear_thickness,
                shaft_diam = planet_shaft_diameter + tolerance_shaft,
                pressure_angle = gear_pressure_angle
            );
            
            // Bore for planet shaft
            translate([0, 0, -0.1])
                cylinder(d = planet_shaft_diameter + tolerance_shaft, 
                       h = gear_thickness + 0.2);
            
            // Apply chamfers
            gear_chamfer(gear_thickness, outer_radius_planet, chamfer_base_radius_planet, chamfer_height);
        }
    }
}

// ============================================================================
// PLANET SHAFTS (3x - Dark Gray) 
// NOTE: FOR VISUALIZATION ONLY - REMOVE IN FINAL DESIGN
// In reality, planet gears just have 3mm holes for shafts to pass through
// ============================================================================
for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
    color("dimgray")
    translate(concat(polar_xy(carrier_radius, angle), 
                    [z_offset_planets + housing_height/2 - bearing_695_thickness + carrier_plate_thickness + clearance_gear_to_plate])) {
        cylinder(d = planet_shaft_diameter, 
               h = gear_thickness);
    }
}

// ============================================================================
// CARRIER (Green)
// ============================================================================
color("lightgreen")
translate([0, 0, z_offset_carrier + housing_height/2 - bearing_695_thickness]) {
    difference() {
        union() {
            // Bottom cylinder with bearing pockets
            cylinder(d = carrier_plate_diameter, h = carrier_plate_thickness);
            
            // Middle cylinder (full height of gears + clearances)
            translate([0, 0, carrier_plate_thickness])
                cylinder(d = carrier_plate_diameter, h = carrier_spacing);
            
            // Top cylinder with bearing pockets
            translate([0, 0, carrier_spacing + carrier_plate_thickness])
                cylinder(d = carrier_plate_diameter, h = carrier_plate_thickness);
            
            // Output hub (top only)
            translate([0, 0, carrier_total_height])
                cylinder(d = hub_diameter_output, h = hub_height_output);
        }
        
        // Central bore for output shaft
        translate([0, 0, -0.1])
            cylinder(d = shaft_diameter_output + tolerance_output_bore, 
                   h = carrier_total_height + hub_height_output + 0.2);
        
        // Sun gear insertion bore through bottom cylinder
        translate([0, 0, -0.1])
            cylinder(d = sun_insertion_bore_diameter, 
                   h = carrier_plate_thickness + clearance_gear_to_plate + 0.1);
        
        // Planet gear pockets in MIDDLE section (3 circular cutouts)
        for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
            translate(concat(polar_xy(carrier_radius, angle), 
                           [carrier_plate_thickness - 0.1]))
                cylinder(d = outer_radius_planet * 2 + 1, 
                       h = carrier_spacing + 0.2);
        }
        
        // Bearing pockets in BOTTOM plate (3 for planet shafts - on inner face)
        for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
            translate(concat(polar_xy(carrier_radius, angle), 
                           [carrier_plate_thickness - carrier_bearing_pocket_depth]))
                cylinder(d = bearing_683_od + clearance_bearing_pocket, 
                       h = carrier_bearing_pocket_depth + 0.1);
        }
        
        // Bearing pockets in TOP plate (3 for planet shafts)
        for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
            translate(concat(polar_xy(carrier_radius, angle), 
                           [carrier_spacing + carrier_plate_thickness]))
                cylinder(d = bearing_683_od + clearance_bearing_pocket, 
                       h = carrier_bearing_pocket_depth + 0.1);
        }
        
        // Through holes for planet shafts (bottom to top)
        for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
            translate(concat(polar_xy(carrier_radius, angle), [-0.1]))
                cylinder(d = bearing_683_id + clearance_boss_center, 
                       h = carrier_total_height + 0.2);
        }
        
        // Setscrew hole (top hub only)
        translate([0, 0, carrier_total_height + hub_height_output/2])
            rotate([90, 0, 0])
                cylinder(d = setscrew_output_diameter - setscrew_output_clearance, 
                       h = hub_diameter_output, center = true);
    }
}

// ============================================================================
// RING GEAR (Red - internal teeth, open top and bottom)
// ============================================================================
color("red", 0.7)
translate([0, 0, z_offset_ring + housing_height/2 - bearing_695_thickness]) {
    difference() {
        // Outer cylinder (tube)
        cylinder(d = ring_gear_outer_diameter,  h = ring_gear_thickness);
        
        // Internal gear teeth (created by subtracting a spur gear)
        // Extend slightly beyond ring height for clean boolean
            // Internal gear teeth (created by subtracting a spur gear)
        // Extend slightly beyond ring height for clean boolean
        translate([0, 0, ring_gear_thickness/2])
            spur_gear(
                mod = gear_module,
                teeth = teeth_ring,
                thickness = ring_gear_thickness + 2,
                shaft_diam = 0,
                pressure_angle = gear_pressure_angle
            );
    }

}

// ============================================================================
// ANNOTATIONS
// ============================================================================
echo("=== PLANETARY GEARBOX SPECIFICATIONS ===");
echo("Gear Ratio: ", gear_ratio, ":1");
echo("Sun teeth: ", teeth_sun);
echo("Planet teeth: ", teeth_planet, " (3 planets)");
echo("Ring teeth: ", teeth_ring, " (calculated: sun + 2*planet)");
echo("Module: ", gear_module);
echo("Carrier radius: ", carrier_radius, "mm");
echo("Carrier spacing: ", carrier_spacing, "mm");
echo("Total carrier height: ", carrier_total_height, "mm");
echo("Output shaft diameter: ", shaft_diameter_output, "mm");
echo("Planet bearing: 683ZZ (6 total - 3 top, 3 bottom)");