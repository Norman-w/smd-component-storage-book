// X1C LAN-print wrapper: place the A5 page in a 256 × 256 mm bed envelope.
// Center the 148 × 210 mm page at (128, 128), leaving the X1C lower-left
// calibration exclusion area clear.
include <params.scad>;
use <0603_tape_page.scad>;

translate([54, 23, 0])
    page_0603();
