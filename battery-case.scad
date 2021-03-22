// [Diameter, length], including clearance
aa_dimensions = [14.4, 51];
aaa_dimensions = [44.5, 10.85];

inner_wall_thickness = 0.8;
end_thickness = 0.8;
epsilon = 0.01;

battery_case_inner(aa_dimensions, 3);


module battery_case_inner(dimensions, cell_count) {
    $fn = 60;
    spacing = dimensions.x * 1.1;
    
    difference() {
        // Outer shell shape
        translate([0, 0, -end_thickness])
        hull() {
            translate([spacing * (cell_count - 1), 0, 0])
            cylinder(d=dimensions.x + inner_wall_thickness * 2, h=dimensions.y + end_thickness - epsilon);
            cylinder(d=dimensions.x + inner_wall_thickness * 2, h=dimensions.y + end_thickness - epsilon);
        }
    
        for (i = [0:cell_count - 1]) {
            translate([spacing * i, 0, 0])
            cylinder(d=dimensions.x, h=dimensions.y);
        }
    }
}
