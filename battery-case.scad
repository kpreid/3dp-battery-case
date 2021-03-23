// [Diameter, length], including clearance
aa_dimensions = [14.7, 51];
aaa_dimensions = [10.8, 44.5];

inner_wall_thickness = 0.8;
outer_wall_thickness = 0.8;
inter_cell_wall = 0.8;
wall_clearance_x = 0.2;
wall_clearance_round = 0.25;
end_thickness = 0.8;
end_bevel = 0.6;

epsilon = 0.01;


battery_case(aa_dimensions, [2, 1], false);


function spacing(dimensions) = dimensions.x + inter_cell_wall;
function last_x(dimensions, cell_counts) = spacing(dimensions) * (cell_counts.x - 1);
function last_y(dimensions, cell_counts) = spacing(dimensions) * (cell_counts.y - 1);
function outer_diameter(dimensions) = dimensions.x + (inner_wall_thickness + outer_wall_thickness + wall_clearance_round) * 2;
function y_size(dimensions, cell_counts) = outer_diameter(dimensions) + last_y(dimensions, cell_counts);


module battery_case(dimensions, cell_counts, preview=false) {
    battery_case_inner(dimensions, cell_counts);

    if (preview) {
        translate([0, 0, 1])
        color("white")
        battery_case_outer(dimensions, cell_counts);
    } else {
        translate([
            last_x(dimensions, cell_counts),
            last_y(dimensions, cell_counts) + outer_diameter(dimensions) + 5,
            0
        ])
        rotate([0, 180, 0])
        translate([0, 0, -dimensions.y])
        battery_case_outer(dimensions, cell_counts);
    }
}

module battery_case_inner(dimensions, cell_counts) {
    $fn = 60;

    difference() {
        union() {
            // Outer shell shape
            translate([0, 0, -end_thickness])
            outer_positions_hull(dimensions, cell_counts)
            shell_cylinder();

            end_cap(dimensions, cell_counts);
        }
    
        for (xi = [0:cell_counts.x - 1]) 
        for (yi = [0:cell_counts.y - 1]) {
            translate([spacing(dimensions) * xi, spacing(dimensions) * yi, 0])
            cylinder(d=dimensions.x, h=dimensions.y);
        }
    }
    
    finger_grip(dimensions, cell_counts, false);
    
    module shell_cylinder() {
        cylinder(d=dimensions.x + inner_wall_thickness * 2, h=dimensions.y + end_thickness - epsilon);
    }
}

module outer_positions_hull(dimensions, cell_counts, extra=0) {
    last_x = last_x(dimensions, cell_counts);
    last_y = last_y(dimensions, cell_counts);
    extra_x = extra;
    extra_y = 0; //dimensions.y > 1 ? extra : 0;
    hull() {
        translate([last_x + extra_x, -extra_y, 0])
        children();
        translate([-extra_x, -extra_y, 0])
        children();
        translate([last_x + extra_x, last_y + extra_y, 0])
        children();
        translate([-extra_x, last_y + extra_y, 0])
        children();
    }
}

module battery_case_outer(dimensions, cell_counts) {
    $fn = 60;
    
    render()
    difference() {
        union() {
            outer_positions_hull(dimensions, cell_counts, extra=wall_clearance_x)
            outer_cylinder(dimensions, dimensions.y + epsilon);

            translate([0, 0, dimensions.y - epsilon])
            mirror([0, 0, 1])
            end_cap(dimensions, cell_counts);
        }

        outer_positions_hull(dimensions, cell_counts, extra=wall_clearance_x)
        inside_of_outer_cylinder();
        
        finger_grip(dimensions, cell_counts, true);
    }
    
    module inside_of_outer_cylinder() {
        translate([0, 0, -epsilon])
        cylinder(d=dimensions.x + (inner_wall_thickness + wall_clearance_round) * 2, h=dimensions.y);
    }
}

module finger_grip(dimensions, cell_counts, negative=false) {
    d = min(20, dimensions.x) + (negative ? 0.4 : 0);
    y_size = y_size(dimensions, cell_counts);
    mid_y = last_y(dimensions, cell_counts) / 2;
    extra_size_y = 0;//spacing(dimensions) * (cell_counts.y - 1);
    
    translate([last_x(dimensions, cell_counts) / 2, mid_y, 0])
    mirrored([0, 1, 0])
    translate([0, y_size / 2 + epsilon, -epsilon])
    scale(negative ? [1, 1, 1] : [1, 1, 0.5])
    rotate([90, 0, 0])
    linear_extrude((outer_diameter(dimensions) - dimensions.x) / 2)
    intersection() {
        circle(d=d, $fn=120);
        translate([0, d / 2])
        square([d, d + epsilon * 2], center=true);
    }
}

module end_cap(dimensions, cell_counts) {
    translate([0, 0, -end_thickness])
    outer_positions_hull(dimensions, cell_counts, extra=wall_clearance_x)
    end_cap_cylinder();
    
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

module mirrored(axis) {
    children();
    mirror(axis) children();
}
