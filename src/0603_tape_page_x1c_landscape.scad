// X1C 局域网打印专用横向摆放包装。
// 将 B5 页面从 176 × 250 mm 旋转为 250 × 176 mm，避开 X1C 底部左侧校准避让区。
include <params.scad>;
use <0603_tape_page.scad>;

eps = 0.01;
$fn = 32;

translate([page_height, 0, 0])
    rotate([0, 0, 90])
        page_0603();
