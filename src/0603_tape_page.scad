// 0603 编带收纳活页页 v1
//
// 机械契约：
// - FDM / PETG；页面平放，底面贴打印平台，设计目标为无支撑打印。
// - 页面没有分型面、螺钉或密封件；编带从每条滑道左端的开放装入窗口放入。
// - 双侧 T 形限位覆盖编带两侧边缘；入口横挡防止编带自行滑回，右端止挡防止冲出。
// - 载带尺寸为可调包络，默认按 8 mm 压纹塑料带的保守初值建模。

include <params.scad>;

eps = 0.01;
$fn = 32;

function channel_clear_width() = tape_width + 2 * tape_side_clearance;
function lane_outer_width() = channel_clear_width() + 2 * rail_stem_width;
function rail_stem_height() = tape_height + top_clearance;
function rail_total_height() = rail_stem_height() + rail_cap_thickness;
function track_start_x() = binding_margin + label_column_width + track_gap_after_label;
function track_end_x(page_w = page_width) = page_w - right_edge_margin;
function row_center(index, page_h = page_height, count = lane_count, pitch = lane_pitch) =
    (page_h - (count - 1) * pitch) / 2 + index * pitch;
function binding_hole_y(index, page_h = page_height, count = binding_hole_count, pitch = binding_hole_pitch) =
    binding_hole_pattern_enabled
        ? binding_hole_positions[index]
        : (page_h - (count - 1) * pitch) / 2 + index * pitch;

module rounded_plate(w, h, r, z) {
    linear_extrude(height = z)
        hull() {
            translate([r, r]) circle(r = r);
            translate([w - r, r]) circle(r = r);
            translate([w - r, h - r]) circle(r = r);
            translate([r, h - r]) circle(r = r);
        }
}

module label_recess_cut(
    cy,
    x0 = binding_margin,
    base_t = base_thickness,
    label_w = label_width,
    label_h = label_height,
    label_clear = label_clearance,
    recess_depth = label_recess_depth
) {
    pocket_w = label_w + 2 * label_clear;
    pocket_h = label_h + 2 * label_clear +
        2 * (label_frame_thickness + label_lip_inset);

    // 从页面左边缘开口，底部仍然保留，不形成穿透孔。
    translate([x0 - eps, cy - pocket_h / 2, base_t - recess_depth])
        cube([pocket_w + eps, pocket_h, recess_depth + 2 * eps]);
}

module label_frame(
    cy,
    x0 = binding_margin,
    base_t = base_thickness,
    label_w = label_width,
    label_h = label_height,
    label_clear = label_clearance,
    frame_t = label_frame_thickness,
    lip_inset = label_lip_inset,
    lip_h = label_lip_height
) {
    pocket_w = label_w + 2 * label_clear;
    pocket_h = label_h + 2 * label_clear + 2 * (frame_t + lip_inset);
    frame_depth = frame_t + lip_inset;
    y0 = cy - pocket_h / 2;

    // 左端开放，纸片从页面外侧滑入；上下边缘向内压住纸片。
    // 轻微穿入底板，避免导出 STL 时形成共面接触边。
    translate([x0, y0, base_t - eps])
        cube([pocket_w, frame_depth, lip_h + eps]);
    translate([x0, y0 + pocket_h - frame_depth, base_t - eps])
        cube([pocket_w, frame_depth, lip_h + eps]);
    translate([x0 + pocket_w - frame_t, y0, base_t - eps])
        cube([frame_t, pocket_h, lip_h + eps]);
}

module label_entry_latch(
    cy,
    x0 = binding_margin,
    base_t = base_thickness,
    label_w = label_width,
    label_h = label_height,
    label_clear = label_clearance,
    frame_t = label_frame_thickness,
    lip_inset = label_lip_inset,
    latch_len = label_entry_latch_length,
    latch_h = label_entry_latch_height
) {
    pocket_w = label_w + 2 * label_clear;
    pocket_h = label_h + 2 * label_clear + 2 * (frame_t + lip_inset);
    frame_depth = frame_t + lip_inset;
    y0 = cy - pocket_h / 2;
    inner_y0 = y0 + frame_depth;
    inner_h = pocket_h - 2 * frame_depth;
    z0 = base_t - label_recess_depth;

    // 低斜台只放在标签入口中央通道，平放打印，无悬空。
    // 斜坡朝内，推入容易；反向退出会遇到较高的一侧。
    translate([x0, inner_y0, z0])
        polyhedron(
            points = [
                [0, 0, 0],
                [latch_len, 0, 0],
                [latch_len, 0, latch_h],
                [0, inner_h, 0],
                [latch_len, inner_h, 0],
                [latch_len, inner_h, latch_h]
            ],
            faces = [
                [0, 1, 4, 3],
                [0, 2, 1],
                [3, 4, 5],
                [0, 3, 5, 2],
                [1, 2, 5, 4]
            ]
        );
}

module lane(
    x0,
    x1,
    cy,
    profile = "dual_t",
    base_t = base_thickness,
    tape_h = tape_height,
    tape_side_clear = tape_side_clearance,
    top_clear = top_clearance,
    stem_w = rail_stem_width,
    cap_overlap = rail_cap_overlap,
    cap_t = rail_cap_thickness,
    entry_len = entry_zone_length,
    entry_stop_t = entry_stop_thickness,
    entry_stop_h = entry_stop_height,
    end_stop_t = end_stop_thickness
) {
    clear_w = tape_width + 2 * tape_side_clear;
    outer_w = clear_w + 2 * stem_w;
    y0 = cy - outer_w / 2;
    y1 = y0 + outer_w - stem_w;
    stem_h = tape_h + top_clear;
    total_h = stem_h + cap_t;
    cap_start = x0 + entry_len;
    cap_end = x1 - end_stop_t;
    rail_len = max(0, cap_end - cap_start);
    entry_len_actual = max(0, entry_len - entry_stop_t);

    // 左端低横挡：编带从上方放入入口窗口，装入后不会轻易向左滑出。
    translate([x0, y0, base_t - eps])
        cube([entry_stop_t, outer_w, entry_stop_h + eps]);

    // 入口窗口的低导向边，保留顶部空间作为镊子操作豁口。
    if (entry_len_actual > 0) {
        translate([x0 + entry_stop_t, y0, base_t - eps])
            cube([entry_len_actual, stem_w, entry_guide_height + eps]);
        translate([x0 + entry_stop_t, y1, base_t - eps])
            cube([entry_len_actual, stem_w, entry_guide_height + eps]);
    }

    if (rail_len > 0) {
        // 下侧导轨：双 T 和单 7 都保留这一侧的上压边。
        translate([cap_start, y0, base_t - eps])
            cube([rail_len, stem_w, stem_h + eps]);
        translate([cap_start, y0, base_t + stem_h - eps])
            cube([rail_len, stem_w + cap_overlap, cap_t + eps]);

        // 上侧导轨：dual_t 为完整 T；single_7 只保留低导向边。
        if (profile == "dual_t") {
            translate([cap_start, y1, base_t - eps])
                cube([rail_len, stem_w, stem_h + eps]);
            translate([cap_start, y1 - cap_overlap, base_t + stem_h - eps])
                cube([rail_len, stem_w + cap_overlap, cap_t + eps]);
        } else {
            translate([cap_start, y1, base_t - eps])
                cube([rail_len, stem_w, single_hook_guide_height + eps]);
        }
    }

    // 右端止挡与导轨连接，防止编带向前冲出。
    translate([x1 - end_stop_t, y0, base_t - eps])
        cube([end_stop_t, outer_w, total_h + eps]);
}

module base_with_label_recess(
    w,
    h,
    base_t,
    radius,
    count,
    pitch,
    add_binding_holes = false
) {
    difference() {
        rounded_plate(w, h, radius, base_t);

        if (add_binding_holes) {
            for (i = [0 : binding_hole_count - 1]) {
                translate([
                    binding_hole_center_x,
                    binding_hole_y(i, h),
                    -eps
                ])
                    cylinder(
                        h = base_t + 2 * eps,
                        d = binding_hole_diameter
                    );
            }
        }

        for (i = [0 : count - 1]) {
            label_recess_cut(
                row_center(i, h, count, pitch),
                base_t = base_t
            );
        }
    }
}

module page_0603() {
    x0 = track_start_x();
    x1 = track_end_x(page_width);

    union() {
        base_with_label_recess(
            page_width,
            page_height,
            base_thickness,
            corner_radius,
            lane_count,
            lane_pitch,
            add_binding_holes = binding_holes_enabled
        );

        for (i = [0 : lane_count - 1]) {
            cy = row_center(i);
            label_frame(cy);
            label_entry_latch(cy);
            lane(x0, x1, cy, profile = rail_profile);
        }
    }
}

module fit_coupon(profile = "dual_t") {
    coupon_w = 140;
    coupon_h = 75;
    coupon_count = 3;
    coupon_pitch = 15;
    // 测试片也必须沿用页面的标签列结束位置，避免滑道压到标签槽。
    coupon_x0 = track_start_x();
    coupon_x1 = coupon_w - 5;

    union() {
        base_with_label_recess(
            coupon_w,
            coupon_h,
            base_thickness,
            corner_radius,
            coupon_count,
            coupon_pitch,
            add_binding_holes = false
        );

        for (i = [0 : coupon_count - 1]) {
            cy = row_center(i, coupon_h, coupon_count, coupon_pitch);
            label_frame(cy);
            label_entry_latch(cy);
            lane(coupon_x0, coupon_x1, cy, profile = profile);
        }
    }
}

// 根文件默认生成完整 A5 页面；测试片使用独立 wrapper，便于分别导出。
if (model_selector == "page") {
    page_0603();
} else if (model_selector == "fit_dual_t") {
    fit_coupon("dual_t");
} else if (model_selector == "fit_single_7") {
    fit_coupon("single_7");
}
