epsilon = 0.001;

// Dimensions
body_width=52;
wheel_width=10;
body_to_wheel_width=2;
rear_to_axle = 35;
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
uc_length = 40;
uc_width = 10;
uc_height = 2;

// Side support at axle.
ssa_radius = 7;
ssa_depth = 1;
ssa_base_length = ssa_radius*2;
ssa_width = body_width;


screw_head_radius = 3;
screw_head_height = 4;
screw_head_fudge = 0.2;
screw_hole_radius = 1.5;

screw_mount_depth = 1;
screw_mount_height = 5;
screw_mount_radius_fudge = 0.2;


car_bracket_rotation=[-30, -30, 0];

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

module uc_base() {
    hull() {
        reflect_xyz()
            translate([(uc_width/2-ssa_depth/2), uc_length/2-ssa_depth/2, uc_height/2-ssa_depth/2]) 
                sphere(r = ssa_depth/2);
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
    //translate([-(body_width/2-uc_width/2), uc_length/2, 0]) {
    translate([0, uc_length/2, 0]) {
        uc_base();
    }
}

module axle_slot_neg() {
    hull() {
        translate([0, -10, uc_height+0.]) axle_notch();
        translate([0, 0, uc_height+0.]) axle_notch();
    }
}

module ssa() {
    intersection() {
        translate([0, 0, ssa_radius])
            cube([ssa_depth, ssa_radius*2, ssa_radius*2], center=true);
        mink_it(0.5) difference() {
            rotate([0, 90, 0])
                cylinder(r = ssa_radius, h=epsilon, center=true);
            axle_slot_neg();
    
       }
    }
}

module ssa_base() {
    hull() {
        reflect_xyz()
            translate([(body_width/2-ssa_depth/2), ssa_base_length/2-ssa_depth/2, uc_height/2-ssa_depth/2]) 
                sphere(r = ssa_depth/2);
    }
}

module axle_notch() {
    translate([-(axle_width/2), 0, 0])
    rotate([0, 90, 0]) cylinder(h=axle_width, r=axle_notch_radius, $fn=16);
}


module ssa_bracket() {
    difference() {
        union() {
            ssa_base();
            reflect_x() 
                translate([body_width/2-ssa_depth/2, 0, 0])
                    ssa();
        }
    }
}

fudge_incline_width=3;
module back_bracket() {
    translate([0, -back_flat_length/2+fudge_incline_width-ssa_depth/2, 0]) {
        hull() {
            reflect_xyz()
                translate([(back_flat_width/2-ssa_depth/2), back_flat_length/2+back_incline_length/2-ssa_depth/2, uc_height/2-ssa_depth/2]) 
                    sphere(r = ssa_depth/2);        
        }
    }
}

module car_bracket() {
    //#debug_wheels();
    ssa_bracket();
    uc_bracket();
    back_bracket();
}

module screw_mount_neg() {
    translate([0, -50, 0]) cube([100, 100, 100], center=true);
}

module screw_hole_neg() {
    $fn=16;
    rotate([90, 0, 0]) cylinder(h = 30, r = screw_hole_radius, center=true);
    translate([0, screw_head_height+screw_head_fudge, 0])
    rotate([90, 0, 0]) cylinder(h = screw_head_height + epsilon, r2 = screw_hole_radius, r1 = screw_head_radius, center=true);
}

// The part that attaches to the wall, where the screw goes.
module wall_mount() {
    difference() {
        mink_it(0.2) {
            hull() {
                translate([0, 0, screw_mount_height])
                    rotate([90, 0, 0])
                        cylinder(h = screw_mount_depth, r=back_flat_width/2+screw_mount_radius_fudge, center=true);
                rotate([90, 0, 0])
                    cylinder(h = screw_mount_depth, r=back_flat_width/2+screw_mount_radius_fudge, center=true);
            }
        }
        translate([0, -3, 5]) #screw_hole_neg();
    }
}

// Used to cut off excess so it can lay flat on the printbed.
module flush_intersect() {
    translate([0, 0, 20]) hull() {
        reflect_xyz()
            translate([(60-ssa_depth/2), 200-ssa_depth/2, 20-ssa_depth/2]) 
                sphere(r = ssa_depth/2);
    }
}

module wall_bracket() {
    intersection() {
        union() {
            rotate(car_bracket_rotation)
                translate([0, back_flat_length, 0])
                    car_bracket();
            wall_mount();
        }
        // Trim the bottom of the mount so it sits flush. 
        rotate(car_bracket_rotation) flush_intersect();
    }
}

wall_bracket();
//car_bracket();