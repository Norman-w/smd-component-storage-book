// X1C-safe wrapper for the 12 mm tape / 12 mm label A5 page.
// The page geometry is unchanged; this only places it away from the X1C
// lower-left calibration exclusion region.

translate([54, 23, 0])
    import("../output/3d-print/0603_tape_page_12mm_label12_v1.stl");
