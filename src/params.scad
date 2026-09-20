// 0603 编带收纳页 v1 参数
// 单位：mm；默认按 B5 纵向页面、PETG、0.4 mm 喷嘴、平放无支撑打印。

// 页面：ISO B5 纵向比例
page_width = 176;
page_height = 250;
// 极薄底板：按 0.2 mm 层高约 3 层设计；优先减薄，必须先做翘曲实测。
base_thickness = 0.6;
corner_radius = 4;

// B5 常见 26 孔活页制式；内容区从孔列右侧开始。
// 26 孔、9.5 mm 孔距、约 5.5 mm 圆孔，孔中心距左边约 6.5 mm。
binding_holes_enabled = true;
binding_hole_count = 26;
binding_hole_pitch = 9.5;
binding_hole_diameter = 5.5;
binding_hole_center_x = 6.5;
binding_margin = 18;

// 标签与滑道布局
lane_count = 15;
lane_pitch = 15;
label_width = 25;
label_height = 9;
label_clearance = 0.5;
label_recess_depth = 0.15;
label_frame_thickness = 0.8;
label_lip_inset = 0.75;
label_lip_height = 0.7;
// 标签槽结束后只留 1 mm 的结构间隙，标签直接贴近对应滑道入口。
label_column_width = 26;
track_gap_after_label = 1;
right_edge_margin = 5;

// 8 mm 压纹塑料载带的初始包络；拿到实物后只需调整这些参数。
tape_width = 8;
tape_height = 1.8;
tape_side_clearance = 0.6;
top_clearance = 0.35;

// 限位结构
rail_stem_width = 1.0;
// 每侧向内压住编带 1.0 mm；顶部有效开口约为 7.2 mm。
rail_cap_overlap = 1.0;
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
