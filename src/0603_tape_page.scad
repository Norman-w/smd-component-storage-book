// 0603 编带收纳活页页 v22：标签槽改为完整底板上的上凸 T 形墙
//
// 机械契约：
// - FDM / PETG；页面平放，底面贴打印平台，设计目标为无支撑打印。
// - 页面没有分型面、螺钉或密封件；标签从右向左插入，编带从每条滑道左端的开放装入窗口放入。
// - 双侧 T 形限位覆盖编带两侧边缘；轨道支脚与隔档最薄处约 0.8 mm。
// - 入口横挡防止编带自行滑回，外圈围墙承担末端止挡。
// - 载带尺寸为可调包络，默认按 8 mm 压纹塑料带的保守初值建模。

include <params.scad>;

eps = 0.01;
$fn = 32;

function channel_clear_width() = tape_width + 2 * tape_side_clearance;
function lane_outer_width() = channel_clear_width() + 2 * rail_stem_width;
function rail_stem_height() = tape_height + top_clearance;
function rail_total_height() = rail_stem_height() + rail_cap_thickness;
function label_pocket_x0() = binding_full_fill_until_x;
function track_start_x() = label_pocket_x0() + label_column_width + track_gap_after_label;
function track_end_x(page_w = page_width) =
    page_w - (perimeter_wall_enabled ? perimeter_wall_inset + perimeter_wall_width : right_edge_margin) +
        (perimeter_wall_enabled ? eps : 0);
function row_center(index, page_h = page_height, count = lane_count, pitch = lane_pitch) =
    (page_h - (count - 1) * pitch) / 2 + index * pitch;
function binding_hole_y(index, page_h = page_height, count = binding_hole_count, pitch = binding_hole_pitch) =
    binding_hole_pattern_enabled
        ? binding_hole_positions[index]
        : (page_h - (count - 1) * pitch) / 2 + index * pitch;

module rounded_profile(w, h, r) {
    hull() {
        translate([r, r]) circle(r = r);
        translate([w - r, r]) circle(r = r);
        translate([w - r, h - r]) circle(r = r);
        translate([r, h - r]) circle(r = r);
    }
}

module rounded_plate(w, h, r, z) {
    linear_extrude(height = z)
        rounded_profile(w, h, r);
}

module reinforced_plate(
    w,
    h,
    radius,
    base_t = base_thickness,
    with_perimeter = perimeter_wall_enabled
) {
    wall_h = max(base_t, perimeter_wall_height);
    inner_offset = perimeter_wall_inset + perimeter_wall_width;
    inner_w = w - 2 * inner_offset;
    inner_h = h - 2 * inner_offset;
    inner_radius = max(0.5, radius - inner_offset);

    // 将围墙与底板合并为一个连续实体：底板保留完整，只有底板以上的
    // 中央区域被挖空，从而避免独立墙体与底板重叠造成非流形接缝。
    if (with_perimeter) {
        difference() {
            rounded_plate(w, h, radius, wall_h);
            translate([inner_offset, inner_offset, base_t]) {
                difference() {
                    linear_extrude(height = max(eps, wall_h - base_t + eps))
                        rounded_profile(inner_w, inner_h, inner_radius);

                    // 装订边不挖空，形成从页面左缘到加强脊的整块高台。
                    // 其右端面就是标签的左端止档。
                    if (binding_full_fill_enabled &&
                        binding_full_fill_until_x > inner_offset) {
                        translate([-eps, -eps, -eps])
                            cube([
                                binding_full_fill_until_x - inner_offset + eps,
                                inner_h + 2 * eps,
                                wall_h - base_t + 2 * eps
                            ]);
                    }
                }
            }
        }
    } else {
        rounded_plate(w, h, radius, base_t);
    }
}

module binding_spine_wall(
    h,
    x0 = binding_spine_wall_x,
    wall_w = binding_spine_wall_width,
    wall_h = perimeter_wall_height
) {
    // 放在圆孔列内侧，孔本身仍保持完整通孔；上下端与外圈围墙重叠连接。
    wall_z = max(0, base_thickness);
    wall_height = max(eps, wall_h - wall_z);
    translate([x0, 0, wall_z])
        cube([wall_w, h, wall_height]);
}

module label_recess_cut(
    cy,
    x0 = label_pocket_x0(),
    base_t = base_thickness,
    label_w = label_width,
    label_h = label_height,
    label_clear = label_clearance,
    recess_depth = label_recess_depth
) {
    pocket_w = label_w + 2 * label_clear;
    inner_h = label_h + 2 * label_clear;
    frame_depth = label_stem_width;
    mouth_depth = min(frame_depth, label_entry_frame_depth);
    relief_len = min(pocket_w, label_entry_relief_length);
    mouth_h = inner_h + 2 * (frame_depth - mouth_depth);

    // v22 默认不挖底板：标签槽的底面就是完整底板顶面。
    // 只有显式给出正的 recess_depth 时才保留旧版浅槽行为，便于
    // 后续做对照测试；默认值为 0，避免把 0.6 mm 底板削穿。
    if (recess_depth > eps) {
        if (pocket_w - relief_len > eps) {
            translate([x0, cy - inner_h / 2, base_t - recess_depth])
                cube([
                    pocket_w - relief_len,
                    inner_h,
                    recess_depth + 2 * eps
                ]);
        }
        if (relief_len > eps && mouth_h > inner_h) {
            translate([
                x0 + pocket_w - relief_len,
                cy - mouth_h / 2,
                base_t - recess_depth
            ])
                cube([relief_len + eps, mouth_h, recess_depth + 2 * eps]);
        }
    }
}

// 沿 X 方向延伸的一段 T 形导轨。
// 截面在 YZ 平面：底部是 stem_w 窄支脚，顶部压边向槽内伸出
// cap_overlap，因此两条相向导轨之间形成“下宽、上窄”的卡槽。
// 标签和编带都必须调用这一模块，避免两套截面再次漂移。
module t_rail_segment(
    x0,
    stem_y,
    length,
    z0,
    stem_w,
    stem_h,
    cap_overlap,
    cap_t,
    upper = false
) {
    if (length > eps && stem_w > eps && stem_h > eps && cap_t > eps) {
        translate([x0, stem_y, z0])
            cube([length, stem_w, stem_h + eps]);
        translate([
            x0,
            upper ? stem_y - cap_overlap : stem_y,
            z0 + stem_h - eps
        ])
            cube([length, stem_w + cap_overlap, cap_t + eps]);
    }
}

module label_lip(
    x0,
    y0,
    pocket_w,
    pocket_h,
    full_depth,
    mouth_depth,
    relief_len,
    base_t,
    lip_h,
    point_depth = label_entry_point_depth,
    stem_w = label_stem_width,
    cap_overlap = label_cap_overlap,
    cap_t = label_cap_thickness,
    recess_depth = label_recess_depth,
    lower = true
) {
    safe_relief = min(max(0, relief_len), pocket_w);
    main_w = pocket_w - safe_relief;
    safe_point = min(max(point_depth, eps), full_depth);
    cap_depth = full_depth + max(0, cap_overlap);
    cap_height = min(max(eps, cap_t), lip_h);
    stem_height = max(eps, lip_h - cap_height);
    stem_depth = min(max(eps, stem_w), full_depth);
    // v22 的支脚从完整底板顶面起；标签槽通过向上增高的墙体形成，
    // 不再依赖削薄底板来取得卡住标签的空间。
    z0 = base_t - recess_depth;
    cap_z = z0 + lip_h - cap_height - eps;

    if (main_w > eps && full_depth > eps) {
        if (lower) {
            t_rail_segment(
                x0,
                y0,
                main_w + eps,
                z0,
                stem_depth,
                stem_height,
                cap_overlap,
                cap_height,
                upper = false
            );
        } else {
            t_rail_segment(
                x0,
                y0 + pocket_h - stem_depth,
                main_w + eps,
                z0,
                stem_depth,
                stem_height,
                cap_overlap,
                cap_height,
                upper = true
            );
        }

        if (safe_relief > eps && mouth_depth > eps) {
            if (lower) {
                hull() {
                    translate([x0, y0, cap_z])
                        cube([main_w, cap_depth, cap_height + 2 * eps]);
                    translate([
                        x0 + main_w,
                        // 外侧边保持直线，只让靠标签内侧的边收窄；
                        // 关闭参数时保留旧版居中的收窄方式做对照。
                        label_entry_inner_edge_only
                            ? y0
                            : y0 + (cap_depth - safe_point) / 2,
                        cap_z
                    ])
                        cube([
                            safe_relief,
                            safe_point,
                            cap_height + 2 * eps
                        ]);
                }
            } else {
                hull() {
                    translate([
                        x0,
                        y0 + pocket_h - cap_depth,
                        cap_z
                    ])
                        cube([main_w, cap_depth, cap_height + 2 * eps]);
                    translate([
                        x0 + main_w,
                        // 上侧导轨同样固定外侧边，只收窄朝标签内侧的边。
                        label_entry_inner_edge_only
                            ? y0 + pocket_h - safe_point
                            : y0 + pocket_h - cap_depth +
                                (cap_depth - safe_point) / 2,
                        cap_z
                    ])
                        cube([
                            safe_relief,
                            safe_point,
                            cap_height + 2 * eps
                        ]);
                }
            }
        } else if (lower) {
            t_rail_segment(
                x0,
                y0,
                main_w,
                z0,
                stem_depth,
                stem_height,
                cap_overlap,
                cap_height,
                upper = false
            );
        } else {
            t_rail_segment(
                x0,
                y0 + pocket_h - stem_depth,
                main_w,
                z0,
                stem_depth,
                stem_height,
                cap_overlap,
                cap_height,
                upper = true
            );
        }
    }
}

module label_frame(
    cy,
    x0 = label_pocket_x0(),
    base_t = base_thickness,
    label_w = label_width,
    label_h = label_height,
    label_clear = label_clearance,
    frame_t = label_frame_thickness,
    lip_inset = label_lip_inset,
    lip_h = label_lip_height,
    entry_relief_len = label_entry_relief_length,
    entry_depth = label_entry_frame_depth,
    point_depth = label_entry_point_depth,
    stem_w = label_stem_width,
    cap_overlap = label_cap_overlap,
    cap_t = label_cap_thickness,
    recess_depth = label_recess_depth
) {
    pocket_w = label_w + 2 * label_clear;
    // 只用窄支脚确定外轮廓；顶部横梁的内收量由 cap_overlap 单独给出。
    pocket_h = label_h + 2 * label_clear + 2 * stem_w;
    frame_depth = stem_w;
    relief_len = min(max(0, entry_relief_len), pocket_w);
    mouth_depth = min(max(0, entry_depth), frame_depth);
    // 上下两侧始终镜像：一个向上张开，一个向下张开；
    // 每一个标签格都有自己的凸字八字口，不再按行交错。
    lower_relief = relief_len;
    upper_relief = relief_len;
    y0 = cy - pocket_h / 2;
    // 标签导轨左端轻微嵌入装订边高台，避开两个实体只在 x=12.25
    // 共面相接时的重复边；嵌入量远小于标签端部余量，不改变右侧开口。
    rail_x0 = x0 - 0.1;

    // 右端开放，纸片从页面右侧向左滑入；上下压边在 YZ 截面
    // 与编带槽完全同构，形成上窄下宽的卡口，入口端在 XY 俯视图
    // 收成单尖点。
    // 左端不再单独做挡墙，直接使用装订边整块高台的右端面止挡。
    // 轻微穿入底板，避免导出 STL 时形成共面接触边。
    label_lip(
        rail_x0,
        y0,
        pocket_w,
        pocket_h,
        frame_depth,
        mouth_depth,
        lower_relief,
        base_t,
        lip_h,
        point_depth,
        stem_w,
        cap_overlap,
        cap_t,
        recess_depth,
        lower = true
    );
    label_lip(
        rail_x0,
        y0,
        pocket_w,
        pocket_h,
        frame_depth,
        mouth_depth,
        upper_relief,
        base_t,
        lip_h,
        point_depth,
        stem_w,
        cap_overlap,
        cap_t,
        recess_depth,
        lower = false
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
        t_rail_segment(
            cap_start,
            y0,
            rail_len,
            base_t - eps,
            stem_w,
            stem_h,
            cap_overlap,
            cap_t,
            upper = false
        );

        // 上侧导轨：dual_t 为完整 T；single_7 只保留低导向边。
        if (profile == "dual_t") {
            t_rail_segment(
                cap_start,
                y1,
                rail_len,
                base_t - eps,
                stem_w,
                stem_h,
                cap_overlap,
                cap_t,
                upper = true
            );
        } else {
            translate([cap_start, y1, base_t - eps])
                cube([rail_len, stem_w, single_hook_guide_height + eps]);
        }
    }

    // 有围墙时由页面最外圈直接承担末端止挡；无围墙时保留独立右端挡块。
    if (end_stop_t > 0) {
        translate([x1 - end_stop_t, y0, base_t - eps])
            cube([end_stop_t, outer_w, total_h + eps]);
    }
}

module shared_lane_partition(
    x0,
    x1,
    separator_cy,
    pitch = lane_pitch,
    tape_w = tape_width,
    tape_side_clear = tape_side_clearance,
    stem_w = rail_stem_width,
    top_w = lane_partition_top_width,
    base_t = base_thickness,
    partition_h = rail_stem_height(),
    overlap = lane_partition_overlap
) {
    clear_w = tape_w + 2 * tape_side_clear;
    rail_outer_w = clear_w + 2 * stem_w;
    gap_w = pitch - rail_outer_w;
    base_w = gap_w + 2 * overlap;
    z0 = max(0, base_t - eps);
    z1 = z0 + partition_h + eps;

    // 相邻轨道底部连续相接，用约 0.8 mm 的共用薄墙填满中间。
    // 采用单一连续实体，避免多个相切渐缩多面体在 STL 中留下重合面。
    if (x1 > x0 && gap_w > 0 && top_w > 0 && base_w >= top_w) {
        translate([x0, separator_cy - base_w / 2, z0])
            cube([x1 - x0, base_w, z1 - z0]);
    }
}

module base_with_label_recess(
    w,
    h,
    base_t,
    radius,
    count,
    pitch,
    add_binding_holes = false,
    add_perimeter_wall = false
) {
    difference() {
        reinforced_plate(
            w,
            h,
            radius,
            base_t = base_t,
            with_perimeter = add_perimeter_wall
        );

        if (add_binding_holes) {
            for (i = [0 : binding_hole_count - 1]) {
                translate([
                    binding_hole_center_x,
                    binding_hole_y(i, h),
                    -eps
                ])
                    cylinder(
                        h = max(
                            base_t,
                            binding_full_fill_enabled
                                ? perimeter_wall_height
                                : base_t
                        ) + 2 * eps,
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
            add_binding_holes = binding_holes_enabled,
            add_perimeter_wall = perimeter_wall_enabled
        );
        if (binding_spine_wall_enabled) {
            binding_spine_wall(page_height);
        }

        if (lane_partition_enabled) {
            for (i = [0 : lane_count - 2]) {
                shared_lane_partition(
                    x0,
                    x1,
                    (row_center(i) + row_center(i + 1)) / 2
                );
            }
        }

        for (i = [0 : lane_count - 1]) {
            cy = row_center(i);
            label_frame(cy);
            lane(
                x0,
                x1,
                cy,
                profile = rail_profile,
                end_stop_t = perimeter_wall_enabled ? 0 : end_stop_thickness
            );
        }
    }
}

module fit_coupon(profile = "dual_t") {
    coupon_w = 140;
    coupon_h = 75;
    coupon_count = 3;
    coupon_pitch = lane_pitch;
    // 测试片也必须沿用页面的标签列结束位置，避免滑道压到标签槽。
    coupon_x0 = track_start_x();
    coupon_x1 = coupon_w -
        (perimeter_wall_enabled ? perimeter_wall_inset + perimeter_wall_width : 5) +
        (perimeter_wall_enabled ? eps : 0);

    union() {
        base_with_label_recess(
            coupon_w,
            coupon_h,
            base_thickness,
            corner_radius,
            coupon_count,
            coupon_pitch,
            add_binding_holes = false,
            add_perimeter_wall = perimeter_wall_enabled
        );

        for (i = [0 : coupon_count - 1]) {
            cy = row_center(i, coupon_h, coupon_count, coupon_pitch);
            label_frame(cy);
            lane(
                coupon_x0,
                coupon_x1,
                cy,
                profile = profile,
                end_stop_t = perimeter_wall_enabled ? 0 : end_stop_thickness
            );
        }

        if (lane_partition_enabled) {
            for (i = [0 : coupon_count - 2]) {
                shared_lane_partition(
                    coupon_x0,
                    coupon_x1,
                    (row_center(i, coupon_h, coupon_count, coupon_pitch) +
                        row_center(i + 1, coupon_h, coupon_count, coupon_pitch)) / 2,
                    pitch = coupon_pitch
                );
            }
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
