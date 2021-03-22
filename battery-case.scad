// [Diameter, length], including clearance
aa_dimensions = [14.4, 51];
aaa_dimensions = [44.5, 10.85];

inner_wall_thickness = 0.8;
outer_wall_thickness = 0.8;
wall_clearance_x = 0.3;
wall_clearance_round = 0.0;
end_thickness = 0.8;

epsilon = 0.01;


battery_case(aa_dimensions, 3, false);


function spacing(dimensions) = dimensions.x * 1.1;
function last_x(dimensions, cell_count) = spacing(dimensions) * (cell_count - 1);
function outer_diameter(dimensions) = dimensions.x + (inner_wall_thickness + outer_wall_thickness + wall_clearance_round) * 2;


module battery_case(dimensions, cell_count, preview=false) {
    battery_case_inner(dimensions, cell_count);

    if (preview) {
        translate([0, 0, 10])
        color("white")
        battery_case_outer(dimensions, cell_count);
    } else {
        translate([0, dimensions.x + (inner_wall_thickness + outer_wall_thickness + wall_clearance_round * 2) + 5, 0])
        rotate([180, 0, 0])
        translate([0, 0, -dimensions.y])
        battery_case_outer(dimensions, cell_count);
    }
}

module battery_case_inner(dimensions, cell_count) {
    $fn = 60;

    difference() {
        union() {
            // Outer shell shape
            translate([0, 0, -end_thickness])
            hull() {
                translate([last_x(dimensions, cell_count), 0, 0])
                shell_cylinder();
                shell_cylinder();
            }

            end_cap(dimensions, cell_count);
        }
    
        for (i = [0:cell_count - 1]) {
            translate([spacing(dimensions) * i, 0, 0])
            cylinder(d=dimensions.x, h=dimensions.y);
        }
    }
    
    module shell_cylinder() {
        cylinder(d=dimensions.x + inner_wall_thickness * 2, h=dimensions.y + end_thickness - epsilon);
    }
}

module battery_case_outer(dimensions, cell_count) {
    $fn = 60;
    last_x = last_x(dimensions, cell_count);
    
    difference() {
        union() {
            translate([0, 0, 0])
            hull() {
                translate([last_x + wall_clearance_x, 0, 0])
                outer_cylinder(dimensions, dimensions.y + epsilon);
                translate([-wall_clearance_x, 0, 0])
                outer_cylinder(dimensions, dimensions.y + epsilon);
            }

            translate([0, 0, dimensions.y - epsilon])
            mirror([0, 0, 1])
            end_cap(dimensions, cell_count);
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
        cylinder(d=dimensions.x + (inner_wall_thickness + wall_clearance_round) * 2, h=dimensions.y);
    }
}

module end_cap(dimensions, cell_count) {
    translate([0, 0, -end_thickness])
    hull() {
        translate([last_x(dimensions, cell_count) + wall_clearance_x, 0, 0])
        end_cap_cylinder();
        translate([-wall_clearance_x, 0, 0])
        end_cap_cylinder();
    }
    
    module end_cap_cylinder() {
        hull() {
            cylinder(
                d=outer_diameter(dimensions) - end_thickness * 1.1,
                h=end_thickness / 2);
            translate([0, 0, end_thickness / 2 - epsilon])
            cylinder(
                d=outer_diameter(dimensions),
                h=end_thickness / 2);
        }
    }
}

module outer_cylinder(dimensions, h) {
    cylinder(d=outer_diameter(dimensions), h=h);
}
