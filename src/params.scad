// 0603 编带收纳页 v3 参数
// 单位：mm；默认按 A5 纵向页面、PETG、0.4 mm 喷嘴、平放无支撑打印。

// 页面：ISO A5 纵向比例；比 B5 更紧凑，适合常见活页夹系统。
page_width = 148;
page_height = 210;
// 极薄底板：按 0.2 mm 层高约 3 层设计；优先减薄，必须先做翘曲实测。
base_thickness = 0.6;
corner_radius = 3;

// A5 常见 6 孔活页制式；内容区从孔列右侧开始。
// 19 / 19 / 70 / 19 / 19 mm 分组孔距，约 5.5 mm 圆孔。
binding_holes_enabled = true;
binding_hole_count = 6;
binding_hole_pitch = 19;
binding_hole_diameter = 5.5;
binding_hole_center_x = 6.5;
binding_margin = 16;
binding_hole_pattern_enabled = true;
binding_hole_positions = [32, 51, 70, 140, 159, 178];

// 标签与滑道布局
lane_count = 13;
lane_pitch = 15;
label_width = 25;
label_height = 9;
label_clearance = 0.4;
label_recess_depth = 0.25;
label_frame_thickness = 0.8;
// 只增加压边覆盖量，不改变标签纸本身的 25 × 9 mm 尺寸。
// 实际压边宽度 = label_frame_thickness + label_lip_inset = 2.6 mm。
// 在 15 mm 行距下接近上限，仍保留标签纸的 9.8 mm 入口高度。
label_lip_inset = 1.8;
label_lip_height = 0.7;
// 左侧入口增加低斜台：标签推入时跨过，反向滑出时提供止退。
label_entry_latch_length = 1.2;
label_entry_latch_height = 0.35;
// 标签槽结束后只留 1 mm 的结构间隙，标签直接贴近对应滑道入口。
label_column_width = 26;
track_gap_after_label = 1;
right_edge_margin = 3;

// 8 mm 压纹塑料载带的初始包络；拿到实物后只需调整这些参数。
tape_width = 8;
tape_height = 1.8;
tape_side_clearance = 0.3;
top_clearance = 0.25;

// 限位结构
// 由行距和内宽自动计算：相邻滑道直接共用分隔墙，不留缝。
rail_stem_width = (lane_pitch - (tape_width + 2 * tape_side_clearance)) / 2;
// 每侧向内压住编带 1.3 mm；顶部有效开口约为 6.0 mm。
rail_cap_overlap = 1.3;
rail_cap_thickness = 0.8;
entry_stop_thickness = 1.2;
// 横挡后保留 6 mm 装入/取料窗口；T 形压边从其后立即开始。
entry_notch_length = 6.0;
entry_zone_length = entry_stop_thickness + entry_notch_length;
// 左端挡板不再高出载带包络，便于将带头压入窗口后向右推。
entry_stop_height = 1.8;
end_stop_thickness = 2.0;
entry_guide_height = 0.8;
single_hook_guide_height = 0.9;

// 运行根文件时的默认模型；测试片通过独立 wrapper 调用。
model_selector = "page";
rail_profile = "dual_t";
