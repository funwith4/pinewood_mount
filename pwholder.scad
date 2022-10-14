epsilon = 0.001;

// Dimensions
body_width=46;
wheel_width=10;
body_to_wheel_width=2;
rear_axle_y = 30;
axle_width = body_width+2*(wheel_width+body_to_wheel_width);
axle_radius = 1.25;
axle_notch_radius = 2.5;
back_flat_width = 10;
back_flat_length = 40;
back_cube_length = 10;
back_incline_length = 5;
back_incline_height = 16;

car_length = 178;
car_width = 45;
car_height = 32;
car_back_axle = 35;
car_front_axle = 112;

// Undercarriage
uc_span_x = 5;
uc_span_y = 100;
uc_span_z = 5;

uc_bracket_rotation=[0, -60, 0];

// Struts
strut_span_x = 45;
strut_span_y = 5;
strut_span_z = uc_span_z;
strut_y_1 = 55;
strut_y_2 = 100;
strut_cap_span_x = 2;
strut_cap_span_z = 8;  // Above uc.

wall_mount_span_x = 10;
wall_mount_span_y = 3;
wall_mount_span_z = 15;
wall_mount_radius_fudge = 0.2;

screw_hole_radius = 2.5;
screw_hole_fudge = [0, -3, wall_mount_span_z-1];



module reflect_x() {
    union() {
        children(0);
        mirror([1, 0, 0]) children(0);
    }
}

module reflect_y() {
    union() {
        children(0);
        mirror([0, 1, 0]) children(0);
    }
}

module reflect_z() {
    union() {
        children(0);
        mirror([0, 0, 1]) children(0);
    }
}

module reflect_xy() {
    reflect_x() reflect_y() children(0);
}

module reflect_yz() {
    reflect_y() reflect_z() children(0);
}

module reflect_xyz() {
    reflect_z() reflect_y() reflect_x() children(0);
}


module mink_it(sphere_r) {
    $fn=16;
    minkowski() {
        children(0);
        sphere(r=sphere_r);
    }
}

module wheel() {
    translate([-(wheel_width/2), 0, 0])
    rotate([0, 90, 0]) cylinder(h=wheel_width, r=15);
}

module axle() {
    translate([-(axle_width/2), 0, 0])
    rotate([0, 90, 0]) cylinder(h=axle_width, r=axle_radius, $fn=8);
}


module debug_wheels() {
    translate([0, 0, 3]) {
        axle();
        reflect_x() {
            translate([+(body_to_wheel_width+wheel_width/2+body_width/2), 0, 0])
                wheel();
        }
    }
}

module uc_bracket() {
    union() {
        /*
        translate([0, rear_axle_y, 0])
            #debug_wheels();
        */
        translate([0, uc_span_y/2, 0])
            cube([uc_span_x, uc_span_y, uc_span_z], center=true);
        translate([0, strut_y_1, 0])
            strut();
        translate([0, strut_y_2, 0])
            strut();
    }
}

module screw_mount_neg() {
    translate([0, -50, 0]) cube([100, 100, 100], center=true);
}

module screw_hole_neg() {
    $fn=16;
    rotate([90, 0, 0]) cylinder(h = 30, r = screw_hole_radius, center=true);
}

module hanger(extra_radius) {
            hull() {
                translate([0, 0, wall_mount_span_z])
                    rotate([90, 0, 0])
                        cylinder(h = wall_mount_span_y, r=wall_mount_span_x/2+extra_radius, center=true);
                rotate([90, 0, 0])
                    cylinder(h = wall_mount_span_y, r=wall_mount_span_x/2+extra_radius, center=true);
            }   
}

// The part that attaches to the wall, where the screw goes.
module wall_mount() {
    translate([-.5, 0.5, 0])
        difference() {
            hanger(wall_mount_radius_fudge);
            translate(screw_hole_fudge) #screw_hole_neg();
        }
}

/*]
module helper1() {
intersection() {
difference() {
    hanger(wall_mount_radius_fudge+4);
    scale([1, 1.01, 1]) hanger(wall_mount_radius_fudge+1);
}
translate([0, 0, 25]) cube([50, 50, 50], center=true);
}

translate([-(50/2+wall_mount_radius_fudge+4), 0, wall_mount_span_z/2])

cube([50-(wall_mount_span_x/2+wall_mount_radius_fudge+4), wall_mount_span_y, 4], center=true);

translate([-58, -5, 10])
union() {
translate([0, -5, 0])
cube([3, 20, 20], center=true);

rotate([0, 0, 90])
    translate([5, -3.5, 0])
cube([3, 10, 20], center=true);
}

difference() {
    by = 15;
    bz = 40;
    union() {
        //translate([1, 0, 0]) cube([62, 2, 10], center=true);
        translate([62-3, 0, 0]) rotate([90, 0, 0])
            cylinder(h=2, r=4, center=true);
        
        translate([62/2, 0, 0])
        cube([62, 2, 4], center=true);

        translate([0, -(by/2-2/2), 0])
        cube([2, by, bz], center=true);
    }
    
    translate([62-3, 0, 0])
    rotate([90, 0, 0])
    #cylinder(h=50, r=1.5, center=true, $fn=16);
    
    translate([0, -8, 0])
    #cube([10, 12+epsilon, bz-6*2], center=true);
}

module guide() {
    reflect_z() translate([0, 0, -40]) helper1();
    cube([3, 3, 36], center=true);
    //translate([-51, 0, 0]) cube([3, 3, 42], center=true);
}

//guide();
*/
// Used to cut off excess so it can lay flat on the printbed.
module flush_intersect() {
    translate([0, 0, 250-uc_span_z/2])
        cube([500, 500, 500], center = true);
}

module wall_bracket() {
    intersection() {
        union() {
            rotate(uc_bracket_rotation)
                uc_bracket();
            wall_mount();
        }
        // Trim the bottom of the mount so it sits flush against the bed. 
        rotate(uc_bracket_rotation) flush_intersect();
        // Trim the back so it sits flush against the wall.
        translate([0, 250, 0]) cube([500, 500, 500], center = true);
    }
}

module strut_cap() {
    r = 1;
    hull() {
        translate([0, 0, strut_cap_span_z - r])
            rotate([0,90,0])
                cylinder(h = strut_cap_span_x, r = 1, center =true, $fn=16);
        translate([0, -(strut_span_y/2 - r), 0])
            rotate([0,90,0])
                cylinder(h = strut_cap_span_x, r = 1, center =true, $fn=16);
        translate([0, +(strut_span_y/2 - r), 0])
            rotate([0,90,0])
                cylinder(h = strut_cap_span_x, r = 1, center =true, $fn=16);
    }
}

module strut() {
    union() {
        cube([strut_span_x, strut_span_y, strut_span_z], center=true);
        translate([-(strut_span_x/2-strut_cap_span_x/2), 0, strut_span_z/2])
            strut_cap();
    }
}

//strut();
//strut_cap();
//uc_bracket();
//wall_mount();
wall_bracket();
