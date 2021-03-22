// [Diameter, length], including clearance
aa_dimensions = [14.7, 51];
aaa_dimensions = [44.5, 10.85];

inner_wall_thickness = 0.8;
outer_wall_thickness = 0.8;
inter_cell_wall = 0.8;
wall_clearance_x = 0.2;
wall_clearance_round = 0.25;
end_thickness = 0.8;
end_bevel = 0.6;

epsilon = 0.01;


battery_case(aa_dimensions, 3, false);


function spacing(dimensions) = dimensions.x + inter_cell_wall;
function last_x(dimensions, cell_count) = spacing(dimensions) * (cell_count - 1);
function outer_diameter(dimensions) = dimensions.x + (inner_wall_thickness + outer_wall_thickness + wall_clearance_round) * 2;


module battery_case(dimensions, cell_count, preview=false) {
    battery_case_inner(dimensions, cell_count);

    if (preview) {
        translate([0, 0, 1])
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
    
    finger_grip(dimensions, cell_count, false);
    
    module shell_cylinder() {
        cylinder(d=dimensions.x + inner_wall_thickness * 2, h=dimensions.y + end_thickness - epsilon);
    }
}

module battery_case_outer(dimensions, cell_count) {
    $fn = 60;
    last_x = last_x(dimensions, cell_count);
    
    render()
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
        
        finger_grip(dimensions, cell_count, true);
    }
    
    module inside_of_outer_cylinder() {
        translate([0, 0, -epsilon])
        cylinder(d=dimensions.x + (inner_wall_thickness + wall_clearance_round) * 2, h=dimensions.y);
    }
}

module finger_grip(dimensions, cell_count, negative=false) {
    d = 20 + (negative ? 0.4 : 0);
    
    translate([last_x(dimensions, cell_count) / 2, 0, 0])
    intersection() {
        rotate([90, 0, 0])
        cylinder(h=outer_diameter(dimensions) + (negative ? epsilon * 2 : 0), d=d, center=true, $fn=120);
        
        // Cut to half cylinder
        translate([0, 0, -epsilon])
        linear_extrude(d/2 + epsilon)
        square([d, d], center=true);
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
                d1=outer_diameter(dimensions) - end_thickness * 1.1,
                d2 = dimensions.x + inner_wall_thickness * 2, // inner case diameter
                h=end_thickness + end_bevel);
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
