// X1C LAN-print wrapper: place the B5 page in a 256 × 256 mm bed envelope.
// The 40/3 mm source offset makes Bambu Studio retain a safe centroid at
// (128, 128), leaving the X1C lower-left calibration exclusion area clear.
include <params.scad>;
use <0603_tape_page.scad>;

translate([40, 3, 0])
    page_0603();
