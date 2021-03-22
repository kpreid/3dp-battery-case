// [Diameter, length], including clearance
aa_dimensions = [14.4, 51];
aaa_dimensions = [44.5, 10.85];

inner_wall_thickness = 0.8;
outer_wall_thickness = 0.8;
wall_clearance_x = 0.3;
wall_clearance_round = 0.0;
end_thickness = 0.8;

epsilon = 0.01;


preview(aa_dimensions, 3);

module preview(dimensions, cell_count) {
    battery_case_inner(dimensions, cell_count);
    translate([0, 0, 10])
    color("white")
    battery_case_outer(dimensions, cell_count);
}


module battery_case_inner(dimensions, cell_count) {
    $fn = 60;
    spacing = dimensions.x * 1.1;
    last_x = spacing * (cell_count - 1);
    
    difference() {
        union() {
            // Outer shell shape
            translate([0, 0, -end_thickness])
            hull() {
                translate([last_x, 0, 0])
                shell_cylinder();
                shell_cylinder();
            }

            // Bottom rim
            translate([0, 0, -end_thickness])
            hull() {
                translate([last_x + wall_clearance_x, 0, 0])
                outer_cylinder(dimensions, end_thickness);
                translate([-wall_clearance_x, 0, 0])
                outer_cylinder(dimensions, end_thickness);
            }
        }
    
        for (i = [0:cell_count - 1]) {
            translate([spacing * i, 0, 0])
            cylinder(d=dimensions.x, h=dimensions.y);
        }
    }
    
    module shell_cylinder() {
        cylinder(d=dimensions.x + inner_wall_thickness * 2, h=dimensions.y + end_thickness - epsilon);
    }
}

module battery_case_outer(dimensions, cell_count) {
    $fn = 60;
    spacing = dimensions.x * 1.1;
    last_x = spacing * (cell_count - 1);
    
    difference() {
        translate([0, 0, 0])
        hull() {
            translate([last_x + wall_clearance_x, 0, 0])
            outer_cylinder(dimensions, dimensions.y + end_thickness);
            translate([-wall_clearance_x, 0, 0])
            outer_cylinder(dimensions, dimensions.y + end_thickness);
        }

        translate([0, 0, 0])
        hull() {
            translate([last_x + wall_clearance_x, 0, 0])
            inside_of_outer_cylinder();
            translate([-wall_clearance_x, 0, 0])
            inside_of_outer_cylinder();
        }
    }
    
    module inside_of_outer_cylinder() {
        translate([0, 0, -epsilon])
        cylinder(d=dimensions.x + (inner_wall_thickness + wall_clearance_round) * 2, h=dimensions.y + end_thickness + epsilon);
    }
}


module outer_cylinder(dimensions, h) {
    cylinder(d=dimensions.x + (inner_wall_thickness + outer_wall_thickness + wall_clearance_round) * 2, h=h);
}
