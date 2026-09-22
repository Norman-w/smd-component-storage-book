// X1C print wrapper for the committed 16 mm tape / 12 mm label page.
// The STL geometry is unchanged; only the bed coordinates are shifted so the
// A5 page sits at x=54..202, y=23..233 and avoids the lower-left calibration
// exclusion area of the X1C.

translate([54, 23, 0])
    import("../output/3d-print/0603_tape_page_16mm_label12_v1.stl");
