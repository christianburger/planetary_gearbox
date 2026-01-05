// ============================================================================
// 4.67:1 PLANETARY GEARBOX - REFACTORED (SEPARATE ASSEMBLY SCREWS)
// ============================================================================
// BOSL2 library required
// Refactored: 
// 1. Ring gear is main body. 
// 2. Top/Bottom are lids.
// 3. Assembly uses M4 screws at corners (separate from NEMA17 pattern).
// ============================================================================

include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 100;

// ============================================================================
// TOLERANCES & CLEARANCES
// ============================================================================
clearance_bearing_pocket = 0.2;
clearance_screw_hole = 0.2; // Generic clearance
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
// HOUSING & SCREW CONFIGURATION
// ============================================================================
wall_thickness = 3;
housing_wall_height_clearance = 4; 

// Ring Gear / Body Dimensions
ring_gear_thickness = carrier_total_height + 1.0; 
//ring_gear_outer_diameter = pitch_radius_ring * 2 + 8;
ring_gear_outer_diameter = 50 - wall_thickness;

housing_size = ring_gear_outer_diameter + wall_thickness;

box_chamfer_size = 4; 

// NEMA17 MOTOR (Only for Bottom Plate)
nema17_hole_spacing = 31;
nema17_hole_diameter = 3.2;
nema17_boss_diameter = 23;
nema17_boss_depth = 2.5;

// ASSEMBLY SCREWS (M4 - Top, Ring, Bottom)
m4_screw_diameter = 4.0;
diagonal_chamfer_clearance = 3.0;

// Calculate Assembly Screw Radius (Diagonal distance from center)
// Distance to square corner = size * sqrt(2) / 2
// Chamfer cuts off corner. Distance lost along diagonal = chamfer_size * sin(45)
// Position = (Corner_Dist) - (Chamfer_Depth) - (Clearance) - (Hole_Radius)
dist_to_corner_perfect = (housing_size / 2) * sqrt(2);
chamfer_depth_diagonal = box_chamfer_size * sqrt(2) / 2;
assembly_hole_radius = dist_to_corner_perfect - chamfer_depth_diagonal - diagonal_chamfer_clearance - (m4_screw_diameter / 2);

// ============================================================================
// 1. CALCULATED PARAMETERS (Single Source of Truth)
// ============================================================================

// Mesh Clearance: Adjust this to push planets outward if they are too tight.
// Standard is 0.17 * module. Your code used 0.6 * module (very loose).
// We calculate the exact radius here so the Carrier and Gears always match.
gear_mesh_clearance = 0.6 * gear_module; 

// Ring Gear Mesh Clearance: Adjust to enlarge internal diameter of ring gear
// Positive values make the internal teeth cavity larger (more clearance)
ring_mesh_clearance = 0.9 * gear_module;

// The Master Radius: Pitch Sum + Clearance
calculated_carrier_radius = pitch_radius_sun + pitch_radius_planet + gear_mesh_clearance;

// Sun Clearance Hole: Ensures the sun gear can spin freely inside the carrier
sun_clearance_hole_diam = outer_radius_sun * 2 + 5.0; 

// Planet gear angle
planet_angles_list = [planet_angle_1, planet_angle_2, planet_angle_3];

// PHASING LOGIC
ref_sun_angle = 10; 
planet_phase_rotation = 0;

// RING GEAR PHASING
ref_ring_angle = 8;  // Adjust to rotate ring gear teeth for alignment


// ============================================================================
// VISUALIZATION OFFSETS
// ============================================================================
z_offset_sun = 80;
z_offset_planets = 88;
z_offset_carrier = 83;
z_offset_ring = 140;           
z_offset_housing_bottom = 0;   
z_offset_housing_top = 180;    
z_offset_housing_wall = z_offset_carrier + carrier_total_height;

// ============================================================================
// HELPER MODULES
// ============================================================================
function polar_xy(radius, angle_deg) = [
    radius * cos(angle_deg),
    radius * sin(angle_deg)
];

// Reusable bearing pocket cutter
module bearing_pocket_cut(od, depth, clearance) {
    cylinder(d = od + clearance, h = depth + 0.05);
}

// Reusable housing profile
module housing_body_profile(size, height, chamfer_size) {
    difference() {
        translate([-size/2, -size/2, 0])
            cube([size, size, height]);

        cutting_offset = size/2;
        
        for(r = [0, 90, 180, 270]) {
            rotate([0, 0, r])
                translate([cutting_offset, cutting_offset, -0.1])
                    rotate([0, 0, 45])
                        translate([-chamfer_size/2, -chamfer_size, 0]) 
                            cube([chamfer_size*2, chamfer_size*2, height + 0.2]);
        }
    }
}

// Reusable Assembly Screw Pattern (M4 Corners)
module assembly_screw_holes(radius, screw_diam, height, clearance) {
    for (angle = [45, 135, 225, 315]) {
        translate(concat(polar_xy(radius, angle), [-0.1]))
            cylinder(d = screw_diam + clearance, h = height + 0.2);
    }
}

// Reusable NEMA17 Mount Pattern (Motor Mount Only)
module nema17_mount_holes(spacing, screw_diam, height, clearance) {
    // Spacing is side length, radius is spacing / sqrt(2)
    radius = spacing / sqrt(2);
    for (angle = [45, 135, 225, 315]) {
        translate(concat(polar_xy(radius, angle), [-0.1]))
            cylinder(d = screw_diam + clearance, h = height + 0.2);
    }
}



module gear_chamfer(gear_thickness, outer_radius, chamfer_base_radius, chamfer_height) {
    difference() {
        translate([0, 0, gear_thickness/2 - chamfer_height])
            cylinder(d = outer_radius * 2 + 4, h = chamfer_height + 5);
        translate([0, 0, gear_thickness/2 - chamfer_height])
            cylinder(r1 = outer_radius + 2, r2 = chamfer_base_radius, h = chamfer_height);
    }
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

module carrier(
    plate_diam, plate_thickness, spacing, total_height, 
    radius_to_pockets,      // <--- Critical: Received from calculated variable
    planet_angles, bearing_id, sun_clearance_hole, 
    shaft_diam, tolerance_bore, hub_diam, hub_height, setscrew_diam,
    planet_outer_diam, planet_clearance  // <--- ADD THESE PARAMETERS
) {
    difference() {
        // POSITIVE SHAPE
        union() {
            cylinder(d = plate_diam, h = plate_thickness);
            translate([0, 0, plate_thickness]) cylinder(d = plate_diam, h = spacing);
            translate([0, 0, spacing + plate_thickness]) cylinder(d = plate_diam, h = plate_thickness);
            translate([0, 0, total_height]) cylinder(d = hub_diam, h = hub_height);
        }

        // NEGATIVE SHAPES
        // Output shaft hole (through entire assembly including hub)
        translate([0, 0, -0.1]) cylinder(d = shaft_diam + tolerance_bore, h = total_height + hub_height + 0.2);
        
        // Sun Gear Clearance (through bottom plate AND middle spacing section)
        translate([0, 0, -0.1]) cylinder(d = sun_clearance_hole, h = plate_thickness + spacing + 0.2);

        // Planet Gear Body Clearance Holes (in middle spacing section)
        for (angle = planet_angles) {
            translate(concat(polar_xy(radius_to_pockets, angle), [plate_thickness - 0.1]))
                cylinder(d = planet_outer_diam + planet_clearance, h = spacing + 0.2);
        }

        // Planet Bearing Shaft Holes (through entire height)
        for (angle = planet_angles) {
            translate(concat(polar_xy(radius_to_pockets, angle), [-0.1]))
                cylinder(d = bearing_id + 0.3, h = total_height + 0.2);
        }

        // Setscrew (3mm below top of hub)
        translate([0, 0, total_height + hub_height - 3]) 
            rotate([90, 0, 0]) 
            cylinder(d = setscrew_diam, h = hub_diam * 2, center = true);
    }
}

module planet_gear(
    teeth, mod, thickness, pressure_angle, shaft_diam, 
    tolerance_shaft, outer_radius, chamfer_base_radius, 
    chamfer_height, bearing_od, bearing_pocket_depth
) {
    difference() {
        spur_gear(
            mod = mod, teeth = teeth, thickness = thickness, 
            shaft_diam = shaft_diam + tolerance_shaft, 
            pressure_angle = pressure_angle
        );

        // Bearing Pockets (corrected for centered gear)
        // Bottom pocket
        translate([0, 0, -thickness/2 - 0.01]) 
            bearing_pocket_cut(bearing_od, bearing_pocket_depth, 0.1);
        // Top pocket
        translate([0, 0, thickness/2 - bearing_pocket_depth]) 
            bearing_pocket_cut(bearing_od, bearing_pocket_depth, 0.1);

        // Chamfers
        gear_chamfer(thickness, outer_radius, chamfer_base_radius, chamfer_height);
    }
}

module ring_gear_box_body(teeth, mod, thickness, pressure_angle, housing_size, chamfer_size, ring_rotation, mesh_clearance) {
    difference() {
        // External Housing Shape
        housing_body_profile(housing_size, thickness, chamfer_size);
        
        // Internal Gear Teeth (with rotation and mesh clearance)
        translate([0, 0, thickness / 2])
            rotate([0, 0, ring_rotation]) {
                // Scale the ring gear to increase internal diameter
                // Clearance increases the internal cavity size
                scale_factor = 1 + (mesh_clearance / pitch_radius_ring);
                scale([scale_factor, scale_factor, 1])
                    spur_gear(mod = mod, teeth = teeth, thickness = thickness + 0.1, shaft_diam = 0, pressure_angle = pressure_angle);
            }
            
        // M4 Assembly Holes Only (No NEMA holes)
        assembly_screw_holes(assembly_hole_radius, m4_screw_diameter, thickness, clearance_screw_hole);
    }
}

module bottom_housing_plate(size, thickness, chamfer_size) {
    difference() {
        housing_body_profile(size, thickness, chamfer_size);
        
        // NEMA17 Boss Recess
        translate([0, 0, 0])
            cylinder(d = nema17_boss_diameter, h = thickness);
            
        // Sun Shaft / Motor Shaft Hole
        translate([0, 0, -0.1])
            cylinder(d = shaft_diameter_sun + tolerance_shaft + 2, h = thickness + 0.2);
            
        // NEMA17 Holes (Inner Pattern) - Kept for motor mount
        nema17_mount_holes(nema17_hole_spacing, nema17_hole_diameter, thickness, clearance_screw_hole);

        // NEW: M4 Assembly Holes (Outer Pattern) - Added to mate with Ring/Top
        assembly_screw_holes(assembly_hole_radius, m4_screw_diameter, thickness, clearance_screw_hole);
    }
}


module top_housing_plate(size, thickness, chamfer_size) {
    difference() {
        union() {
            // Base plate
            housing_body_profile(size, thickness, chamfer_size);
            // Bearing Boss (Outer Face)
            translate([0, 0, thickness - 0.01])
                cylinder(d = bearing_695_od + 2*wall_thickness, h = bearing_695_thickness);
        }
        
        // Center Clearance Hole
        translate([0, 0, -0.1])
            cylinder(d = bearing_695_id + 0.5, h = thickness + bearing_695_thickness + 0.2);
            
        // Bearing Pocket (Outer Face)
        translate([0, 0, thickness + bearing_695_thickness - bearing_695_thickness])
             bearing_pocket_cut(bearing_695_od, bearing_695_thickness, clearance_bearing_pocket);
            
        // NEW: M4 Assembly Holes Only (No NEMA holes)
        // Note: Height must include the boss thickness just in case, though screws are at corners
        assembly_screw_holes(assembly_hole_radius, m4_screw_diameter, thickness + bearing_695_thickness, clearance_screw_hole);
    }
}


// Cross removal pattern module
module cross_removal_pattern(size, arm_width, height) {
    // Horizontal arm
    translate([-arm_width/2, -size/2 - 0.1, 0])
        cube([arm_width, size + 0.2, height + 0.1]);
    
    // Vertical arm
    translate([-size/2 - 0.1, -arm_width/2, 0])
        cube([size + 0.2, arm_width, height + 0.1]);
}

module housing_wall(size, thickness, chamfer_size) {
  internal_removal_profile_size = size - m4_screw_diameter * 4;
  difference() {
      housing_body_profile(size, thickness, chamfer_size);
      housing_body_profile(internal_removal_profile_size, thickness, chamfer_size);
      assembly_screw_holes(assembly_hole_radius, m4_screw_diameter, thickness +   bearing_695_thickness, clearance_screw_hole);
      // Cross pattern removal (leaves 4 corner legs)
      cross_arm_width = housing_size - m4_screw_diameter * 4 - wall_thickness * 2 + 0.4;
      cross_arm_height = thickness;
      size= housing_size;
      translate([0, 0, 0]) {
        cross_removal_pattern(size - wall_thickness, cross_arm_width, cross_arm_height);
      }


  }
}
 
// ============================================================================
// PART INSTANTIATION
// ============================================================================

// RING GEAR BODY (Red)
color("red", 0.7)
translate([0, 0, 0]) {
    ring_gear_box_body(teeth_ring, gear_module, ring_gear_thickness, gear_pressure_angle, 
                       housing_size, box_chamfer_size, ref_ring_angle, ring_mesh_clearance);
}
