// ============================================================================
// 4.67:1 PLANETARY GEARBOX - REFACTORED (BOX RING + BEARING TOP)
// ============================================================================
// BOSL2 library required
// Refactored: 
// 1. Ring gear is main body. 
// 2. Top/Bottom are lids.
// 3. Top lid has 695ZZ bearing pocket for output/support.
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
teeth_ring = 33;         // Ring gear (fixed)

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

// Gear chamfers
chamfer_height = 2.0;
chamfer_angle = 45;
chamfer_base_radius_sun = outer_radius_sun - chamfer_height * tan(chamfer_angle);
chamfer_base_radius_planet = outer_radius_planet - chamfer_height * tan(chamfer_angle);

// ============================================================================
// BEARING SPECIFICATIONS
// ============================================================================
// 683ZZ (Planets)
bearing_683_id = 3;
bearing_683_od = 7;
bearing_683_thickness = 3;

// 695ZZ (Top Housing Support)
bearing_695_id = 5;
bearing_695_od = 13;
bearing_695_thickness = 4;

// ============================================================================
// COMPONENT PARAMETERS
// ============================================================================

// SUN GEAR
shaft_diameter_sun = 5.0;      
shaft_flat_height = 4.0;
hub_diameter_sun = 12;
hub_height_sun = 10;
setscrew_sun_diameter = 5.0;
setscrew_sun_clearance = 0.6;
clearance_sun_insertion = 3.0;
sun_insertion_bore_diameter = outer_radius_sun * 2 + clearance_sun_insertion;

// PLANET GEARS
planet_shaft_diameter = 3.0;
planet_bearing_pocket_depth = bearing_683_thickness + 0.5;
planet_angle_1 = 0;
planet_angle_2 = 120;
planet_angle_3 = 240;

// CARRIER
carrier_plate_thickness = 6;
carrier_plate_diameter = pitch_radius_ring * 2 - 4;
clearance_gear_to_plate = 1.5;
carrier_to_planets_clearance = 5;   
carrier_spacing = gear_thickness + clearance_gear_to_plate * 2;
carrier_total_height = carrier_plate_thickness * 2 + carrier_spacing;

// OUTPUT SHAFT
shaft_diameter_output = 9.0;
hub_diameter_output = 18;
hub_height_output = 22 - carrier_plate_thickness;
setscrew_output_diameter = 3.0;
setscrew_output_clearance = 0.6;
setscrew_output_height = hub_height_output - 3;

// ============================================================================
// REFACTORED HOUSING & RING PARAMETERS
// ============================================================================
wall_thickness = 3;

// The Ring Gear is now the main body height
ring_gear_thickness = carrier_total_height + 1.0; 
ring_gear_outer_diameter = pitch_radius_ring * 2 + 12;

// Housing Size (Square box)
housing_size = ring_gear_outer_diameter + wall_thickness;
box_chamfer_size = 4; 

// NEMA17 MOTOR
nema17_hole_spacing = 31;
nema17_hole_diameter = 3.2;
nema17_boss_diameter = 23;
nema17_boss_depth = 2.5;

// ============================================================================
// VISUALIZATION OFFSETS
// ============================================================================
z_offset_sun = 80;
z_offset_planets = 88;
z_offset_carrier = 83;
z_offset_ring = 120;           // Ring gear (Body)
z_offset_housing_bottom = 0;   // Bottom Plate
z_offset_housing_top = 180;    // Top Plate

// ============================================================================
// HELPER MODULES
// ============================================================================
function polar_xy(radius, angle_deg) = [
    radius * cos(angle_deg),
    radius * sin(angle_deg)
];

// Reusable bearing pocket cutter (subtractive)
module bearing_pocket_cut(od, depth, clearance) {
    cylinder(d = od + clearance, h = depth + 0.05);
}

// Reusable shape for Top, Bottom, and Ring Gear external profile
module housing_body_profile(size, height, chamfer_size) {
    difference() {
        // Main square
        translate([-size/2, -size/2, 0])
            cube([size, size, height]);

        // Corner Chamfers
        cutting_offset = size/2;
        chamfer_hyp = chamfer_size / sqrt(2);
        
        // Loop through 4 corners to cut chamfers
        for(r = [0, 90, 180, 270]) {
            rotate([0, 0, r])
                translate([cutting_offset, cutting_offset, -0.1])
                    rotate([0, 0, 45])
                        translate([-chamfer_size/2, -chamfer_size, 0]) 
                            cube([chamfer_size*2, chamfer_size*2, height + 0.2]);
        }
    }
}

// Gear Chamfer Logic
module gear_chamfer(gear_thickness, outer_radius, chamfer_base_radius, chamfer_height) {
    // Top
    difference() {
        translate([0, 0, gear_thickness/2 - chamfer_height])
            cylinder(d = outer_radius * 2 + 4, h = chamfer_height + 5);
        translate([0, 0, gear_thickness/2 - chamfer_height])
            cylinder(r1 = outer_radius + 2, r2 = chamfer_base_radius, h = chamfer_height);
    }
    // Bottom
    mirror([0, 0, 1])
        difference() {
            translate([0, 0, gear_thickness/2 - chamfer_height])
                cylinder(d = outer_radius * 2 + 4, h = chamfer_height + 5);
            translate([0, 0, gear_thickness/2 - chamfer_height])
                cylinder(r1 = outer_radius + 2, r2 = chamfer_base_radius, h = chamfer_height);
        }
}

// ============================================================================
// PART MODULES
// ============================================================================

module sun_gear(teeth, mod, thickness, pressure_angle, shaft_diam, shaft_flat_height, hub_diam, hub_height, tolerance_shaft, setscrew_diam, setscrew_clearance, outer_radius, chamfer_base_radius, chamfer_height) {
    translate([0, 0, thickness/2 + hub_height])
        rotate([180, 0, 0])
            difference() {
                translate([0, 0, thickness/2]) cylinder(d = hub_diam, h = hub_height);
                translate([0, 0, thickness/2 - 0.1])
                    linear_extrude(height = hub_height + 0.2) {
                        difference() {
                            circle(r = (shaft_diam + tolerance_shaft) / 2);
                            translate([-(shaft_diam + tolerance_shaft)/2, -(shaft_diam + tolerance_shaft)/2])
                                square([shaft_diam + tolerance_shaft, (shaft_diam + tolerance_shaft)/2 - shaft_flat_height/2]);
                        }
                    }
                translate([0, -hub_diam, thickness/2 + hub_height/2])
                    rotate([90, 0, 0])
                        cylinder(d = setscrew_diam - setscrew_clearance, h = hub_diam * 2, center = true);
            }
    translate([0, 0, thickness/2 + hub_height])
        difference() {
            spur_gear(mod = mod, teeth = teeth, thickness = thickness, shaft_diam = shaft_diam + tolerance_shaft, pressure_angle = pressure_angle);
            gear_chamfer(thickness, outer_radius, chamfer_base_radius, chamfer_height);
        }
}

module planet_gear(teeth, mod, thickness, pressure_angle, shaft_diam, tolerance_shaft, outer_radius, chamfer_base_radius, chamfer_height, bearing_od, bearing_id, bearing_pocket_depth, clearance_bearing) {
    difference() {
        spur_gear(mod = mod, teeth = teeth, thickness = thickness, shaft_diam = shaft_diam + tolerance_shaft, pressure_angle = pressure_angle);
        
        // Through bore
        translate([0, 0, -thickness/2 - 0.1]) 
            cylinder(d = bearing_id + tolerance_shaft, h = thickness + 0.2);
            
        // Bottom Bearing Pocket (Using Module)
        translate([0, 0, -thickness/2 - 0.01])
            bearing_pocket_cut(bearing_od, bearing_pocket_depth, clearance_bearing);
            
        // Top Bearing Pocket (Using Module)
        translate([0, 0, thickness/2 - bearing_pocket_depth])
            bearing_pocket_cut(bearing_od, bearing_pocket_depth, clearance_bearing);
            
        gear_chamfer(thickness, outer_radius, chamfer_base_radius, chamfer_height);
    }
}

module carrier(plate_diam, plate_thickness, spacing, total_height, carrier_radius, planet_angles, bearing_id, clearance_boss, planet_outer_radius, planet_clearance, shaft_diam, tolerance_bore, sun_bore_diam, clearance_plate, hub_diam, hub_height, setscrew_diam, setscrew_clearance, setscrew_height) {
    difference() {
        union() {
            cylinder(d = plate_diam, h = plate_thickness);
            translate([0, 0, plate_thickness]) cylinder(d = plate_diam, h = spacing);
            translate([0, 0, spacing + plate_thickness]) cylinder(d = plate_diam, h = plate_thickness);
            translate([0, 0, total_height])
                difference() {
                    cylinder(d = hub_diam, h = hub_height);
                    translate([0, 0, -0.1]) cylinder(d = shaft_diam + tolerance_bore, h = hub_height + 0.2);
                    translate([0, 0, setscrew_height]) rotate([90, 0, 0]) cylinder(d = setscrew_diam - setscrew_clearance, h = hub_diam, center = true);
                }
        }
        translate([0, 0, -0.1]) cylinder(d = shaft_diam + tolerance_bore, h = total_height + 0.2);
        translate([0, 0, -0.1]) cylinder(d = sun_bore_diam, h = plate_thickness + clearance_plate + 0.1);
        for (angle = planet_angles) {
            translate(concat(polar_xy(carrier_radius, angle), [plate_thickness - 0.1]))
                cylinder(d = planet_outer_radius * 2 + planet_clearance, h = spacing + 0.2);
        }
        for (angle = planet_angles) {
            translate(concat(polar_xy(carrier_radius, angle), [-0.1]))
                cylinder(d = bearing_id + clearance_boss, h = total_height + 0.2);
        }
    }
}

// ============================================================================
// REFACTORED MODULES
// ============================================================================

module ring_gear_box_body(teeth, mod, thickness, pressure_angle, housing_size, chamfer_size) {
    difference() {
        // External Housing Shape
        housing_body_profile(housing_size, thickness, chamfer_size);
        
        // Internal Gear Teeth
        translate([0, 0, thickness / 2])
            spur_gear(
                mod = mod,
                teeth = teeth,
                thickness = thickness + 0.1, 
                shaft_diam = 0,
                pressure_angle = pressure_angle
            );
            
        // Through-holes for NEMA17 screws
        for (angle = [45, 135, 225, 315]) {
            translate(concat(polar_xy(nema17_hole_spacing/sqrt(2), angle), [-0.1]))
                cylinder(d = nema17_hole_diameter + clearance_screw_hole, h = thickness + 0.2);
        }
    }
}

module bottom_housing_plate(size, thickness, chamfer_size) {
    difference() {
        housing_body_profile(size, thickness, chamfer_size);
        
        // NEMA17 Boss Recess
        translate([0, 0, -0.1])
            cylinder(d = nema17_boss_diameter, h = nema17_boss_depth + 0.1);
            
        // Sun Shaft / Motor Shaft Hole
        translate([0, 0, -0.1])
            cylinder(d = shaft_diameter_sun + tolerance_shaft + 2, h = thickness + 0.2);
            
        // Mounting Holes
        for (angle = [45, 135, 225, 315]) {
            translate(concat(polar_xy(nema17_hole_spacing/sqrt(2), angle), [-0.1]))
                cylinder(d = nema17_hole_diameter + clearance_screw_hole, h = thickness + 0.2);
        }
    }
}

module top_housing_plate(size, thickness, chamfer_size) {
    difference() {
        union() {
            // Base plate
            housing_body_profile(size, thickness, chamfer_size);
            
            // BEARING BOSS (Added to Top/Outer Face)
            // Adds material to support the bearing thickness
            translate([0, 0, thickness - 0.01])
                cylinder(d = bearing_695_od + 2*wall_thickness, h = bearing_695_thickness);
        }
        
        // Center Clearance Hole (for shaft passing through bearing)
        // Uses bearing ID + 0.5mm clearance
        translate([0, 0, -0.1])
            cylinder(d = bearing_695_id + 0.5, h = thickness + bearing_695_thickness + 0.2);
            
        // BEARING POCKET (Top/Outer Face)
        // Uses the reusable module
        translate([0, 0, thickness + bearing_695_thickness - bearing_695_thickness])
             bearing_pocket_cut(bearing_695_od, bearing_695_thickness, clearance_bearing_pocket);
            
        // Mounting Holes
        for (angle = [45, 135, 225, 315]) {
            translate(concat(polar_xy(nema17_hole_spacing/sqrt(2), angle), [-0.1]))
                cylinder(d = nema17_hole_diameter + clearance_screw_hole, h = thickness + bearing_695_thickness + 0.2);
        }
    }
}

// ============================================================================
// INSTANTIATION
// ============================================================================

// SUN GEAR (Blue)
color("lightblue")
translate([0, 0, z_offset_sun]) {
    sun_gear(teeth_sun, gear_module, gear_thickness, gear_pressure_angle, shaft_diameter_sun, shaft_flat_height, hub_diameter_sun, hub_height_sun, tolerance_shaft, setscrew_sun_diameter, setscrew_sun_clearance, outer_radius_sun, chamfer_base_radius_sun, chamfer_height);
}

// PLANET GEARS (Yellow)
for (angle = [planet_angle_1, planet_angle_2, planet_angle_3]) {
    color("yellow")
    translate(concat(polar_xy(carrier_radius, angle), [z_offset_planets + carrier_plate_thickness + clearance_gear_to_plate])) {
        planet_gear(teeth_planet, gear_module, gear_thickness, gear_pressure_angle, planet_shaft_diameter, tolerance_shaft, outer_radius_planet, chamfer_base_radius_planet, chamfer_height, bearing_683_od, bearing_683_id, planet_bearing_pocket_depth, clearance_bearing_pocket);
    }
    // Planet Shafts Visual
    color("dimgray")
    translate(concat(polar_xy(carrier_radius, angle), [z_offset_planets + carrier_plate_thickness + clearance_gear_to_plate]))
        cylinder(d = planet_shaft_diameter, h = gear_thickness);
}

// CARRIER (Green)
color("lightgreen")
translate([0, 0, z_offset_carrier]) {
    carrier(carrier_plate_diameter, carrier_plate_thickness, carrier_spacing, carrier_total_height, carrier_radius, [planet_angle_1, planet_angle_2, planet_angle_3], bearing_683_id, clearance_boss_center, outer_radius_planet, carrier_to_planets_clearance, shaft_diameter_output, tolerance_output_bore, sun_insertion_bore_diameter, clearance_gear_to_plate, hub_diameter_output, hub_height_output, setscrew_output_diameter, setscrew_output_clearance, setscrew_output_height);
}

// RING GEAR BODY (Red)
color("red", 0.7)
translate([0, 0, z_offset_ring]) {
    ring_gear_box_body(
        teeth = teeth_ring,
        mod = gear_module,
        thickness = ring_gear_thickness,
        pressure_angle = gear_pressure_angle,
        housing_size = housing_size,
        chamfer_size = box_chamfer_size
    );
}

// BOTTOM HOUSING PLATE (Gray)
color("gray", 0.5)
translate([0, 0, z_offset_housing_bottom]) {
    bottom_housing_plate(housing_size, wall_thickness, box_chamfer_size);
}

// TOP HOUSING PLATE (Gray)
color("gray", 0.5)
translate([0, 0, z_offset_housing_top]) {
    // Flipped to show flat face (Z=0 in module) towards gear box
    rotate([0, 180, 0])
        top_housing_plate(housing_size, wall_thickness, box_chamfer_size);
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

echo("\n=== HOUSING (REFACTORED) ===");
echo("Design Style: Sandwich (Bottom Plate + Ring Gear Body + Top Plate)");
echo("Housing Size (Square): ", housing_size, " mm");
echo("Ring Gear (Body) Height: ", ring_gear_thickness, " mm");
echo("Bottom Plate Thickness: ", wall_thickness, " mm");
echo("Top Plate Thickness: ", wall_thickness, " mm (plus bearing boss)");

echo("\n=== BEARING UPDATES ===");
echo("Top Housing Pocket: 695ZZ (", bearing_695_od, "mm OD x ", bearing_695_thickness, "mm Depth)");
echo("Bearing Position: Outer Face (requires support if printed flat)");
echo("Planet Bearings: 683ZZ (Pocketed in gear)");

echo("\n============================================================\n");