# 0603 编带收纳活页页

当前版本是 ISO A5 纵向页面，外廓 `148 × 210 mm`，默认 13 条平行滑道。页面左侧带常见 A5 六孔圆孔列，标签槽为浅凹槽，底面保持完整。

当前源模型已进入编带防脱 v3：标签纸仍为 `25 × 9 mm`，上、下压边覆盖量增至约 `2.6 mm`，标签凹槽深度增至 `0.25 mm`，不依赖胶粘。编带内宽收窄到约 `8.6 mm`，双侧 T 形压边每侧覆盖约 `1.3 mm`，顶部有效开口约 `6.0 mm`；相邻滑道直接共用分隔墙。新版 STL 使用 `_v3` 文件名，先打印测试片确认实际插入和防脱手感。

## 设计假设

- FDM / PETG / 0.4 mm 喷嘴；底板为 `0.6 mm` 极薄版本，约对应 0.2 mm 层高的 3 层实体，不是单层空壳。
- T 形压边每侧内收 `1.3 mm`，压边厚 `0.8 mm`；相邻 15 mm 行距滑道共用 `3.2 mm` 分隔墙，目标为普通 PETG、0.4 mm 喷嘴、无支撑打印。
- 页面平放打印，设计目标是不使用支撑。
- 载带默认按 8 mm 压纹塑料带估算：宽度 8 mm、最大凸包高度 1.8 mm。
- 双侧 T 形限位是正式页面默认结构；单侧 7 形只用于对照测试片。
- 装订孔默认采用 A5 六孔制式，孔径 `5.5 mm`，孔中心距左边 `6.5 mm`，纵向位置为 `32 / 51 / 70 / 140 / 159 / 178 mm`；参数可在 `src/params.scad` 调整。
- 标签槽右边缘与对应滑道入口约留 `1 mm`，纸片标签插入后紧邻编带，不再留出较宽空白区。
- 标签纸仍按 `25 × 9 mm` 使用；标签槽不放大纸片尺寸，改为加宽上、下压边覆盖量（约 `2.6 mm`），凹槽深度 `0.25 mm`，入口另有 `0.35 mm` 低斜台止退，标签不需要胶粘。
- 滑道入口改为短装入豁口：横挡后的实际窗口约 `6 mm`，左端横挡高度降为 `1.8 mm`，T 形压边从其后立即开始，兼顾推进手感和防掉出。
- 编带槽内宽约 `8.6 mm`，顶部有效开口约 `6.0 mm`，优先加强编带防脱；槽间不留空白，直接共用分隔墙。
- 所有载带包络和配合间隙集中在 `src/params.scad`。

## 导出

本机 OpenSCAD 应用程序路径：

```sh
OPENSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

"$OPENSCAD" --export-format binstl \
  -o output/3d-print/0603_tape_page_v3.stl \
  src/0603_tape_page.scad

"$OPENSCAD" --export-format binstl \
  -o output/3d-print/0603_fit_coupon_dual_t_v3.stl \
  src/0603_fit_coupon_dual_t.scad

"$OPENSCAD" --export-format binstl \
  -o output/3d-print/0603_fit_coupon_single_7_v3.stl \
  src/0603_fit_coupon_single_7.scad
```

编带防脱加强版 v3 输出：

```text
output/3d-print/0603_tape_page_v3.stl
output/3d-print/0603_tape_page_v3_x1c_safe.stl
output/3d-print/0603_fit_coupon_dual_t_v3.stl
output/3d-print/0603_fit_coupon_single_7_v3.stl
```

## 打印前检查

先打印测试片，用实际 0603 编带验证插入、竖直防脱、镊子取料和 `25 × 9 mm` 标签插入。确认后再打印整页。PETG 大面积平板建议使用干燥耗材、纹理 PEI，并按切片结果决定是否加小幅 brim。

STL 导出后还需要检查包围盒、流形性、底面连续性和 T 形压边是否能无支撑成形。STL 导出成功本身不等于实际配合已经验证。

## X1C 局域网打印工程

已准备好可直接在 Bambu Studio 打开的切片工程：

```text
output/3d-print/0603_tape_page_v1_x1c_petg_standard.3mf
```

工程使用 Bambu Lab X1 Carbon、0.4 mm 喷嘴、PETG Basic 和纹理 PEI 板，并在工程内明确写入 `256 × 256 × 256 mm` 打印区及左下角 `18 × 28 mm` 校准避让区。当前 v3 页面通过 `src/0603_tape_page_x1c_safe.scad` 以 `54 / 23 mm` 居中放置，实际页面约为 `148 × 210 × 3.45 mm`，不会占用左下校准区。

质量优先参数：

- 层高 `0.20 mm`，首层 `0.20 mm`；2 圈外墙，底部 3 层，顶部 4 层，填充 `0%`。
- PETG 喷嘴 `255°C`，纹理 PEI 热床首层及其余层 `80°C`。
- 首层 `20 mm/s`，外墙 `45 mm/s`，内墙 `60 mm/s`，顶面 `60 mm/s`。
- 默认/外墙加速度 `500 mm/s²`，首层 `300 mm/s²`，风扇范围 `10–40%`，最大体积流量 `8 mm³/s`。
- 关闭 skirt，外裙边改为 `1 mm`；A5 页面在 X1C 床面上有充足边缘余量，可按首层观察结果决定是否加 brim。

该 `.3mf` 是上一版 B5 工程，不能代表当前 A5 v3 几何；正式打印前应在 Bambu Studio 中导入新的 v3 STL，确认 X1C 当前装的是干燥 PETG、纹理 PEI 板已清洁，并先用双 T 测试片确认实际编带配合。
