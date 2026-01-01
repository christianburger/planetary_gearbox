include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 100;

input_teeth = 8;
output_teeth = 32;
module_size = 1.156;
tooth_width = 8;
pressure_angle = 20;

input_pitch_radius = (module_size * input_teeth) / 2;
output_pitch_radius = (module_size * output_teeth) / 2;
center_distance = input_pitch_radius + output_pitch_radius + 0.5;
input_outer_radius = (module_size * (input_teeth + 2)) / 2;
output_outer_radius = (module_size * (output_teeth + 2)) / 2;

input_bore = 2.8;
input_bore_tolerance = 0;

input_hub_diameter = 12;
input_hub_height = 8;
setscrew_diameter = 3.0;
setscrew_diameter_tolerance = 0.0;

chamfer_height = 2.0;
chamfer_angle = 45;

chamfer_cone_base_radius = input_outer_radius - chamfer_height * tan(chamfer_angle);
base_radius = input_outer_radius + 0.5;

difference() {
    spur_gear(
        mod = module_size,
        teeth = input_teeth,
        thickness = tooth_width,
        shaft_diam = input_bore,
        pressure_angle = pressure_angle
    );
    
    difference() {
        translate([0, 0, tooth_width/2 - chamfer_height])
            cylinder(d = base_radius + 12, h = input_hub_height - chamfer_height);
        
        translate([0, 0, tooth_width/2 - chamfer_height])
            cylinder(
                r1 = base_radius + 0.5,
                r2 = chamfer_cone_base_radius,
                h = chamfer_height
            );
    }
    
    mirror([0, 0, 1])
        difference() {
            translate([0, 0, tooth_width/2 - chamfer_height])
                cylinder(d = base_radius + 12, h = input_hub_height - chamfer_height);
            
            translate([0, 0, tooth_width/2 - chamfer_height])
                cylinder(
                    r1 = base_radius + 0.5,
                    r2 = chamfer_cone_base_radius,
                    h = chamfer_height
                );
        }
}