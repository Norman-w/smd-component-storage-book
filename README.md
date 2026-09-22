# 0603 编带收纳活页页

当前版本是 ISO A5 纵向页面，外廓 `148 × 210 mm`，默认 18 条平行滑道。页面左侧带常见 A5 六孔圆孔列，标签卡槽底面保持完整，卡槽由底板上方增高的 T 形墙体形成。

当前源模型为 v22：标签纸仍为 `25 × 9 mm`，从右向左插入；底板不再挖浅槽，标签上下两侧与编带槽共用“下宽上窄”的 T 形卡口。入口压边的外侧边保持直线，只让朝标签内侧的边收斜，俯视轮廓为“个”字形而不是两边都收窄的 Y 形。编带内宽约 `8.6 mm`，双侧 T 形压边每侧覆盖约 `1.3 mm`，顶部有效开口约 `6.0 mm`；相邻滑道用约 `0.8 mm` 共用薄墙直接相接，页面保持 18 条滑道。

当前工作树保留连续外圈围墙：围墙高约 `3.45 mm`、平面内墙厚 `2.0 mm`，从页面最外缘向内形成加强边，既帮助装订后保持页面平整，也作为每条编带滑道的右端止挡。左侧装订区域从页面边缘到孔列内侧加强脊全部满铺到同一高度，孔洞贯穿高台，以提升装订孔抗撕裂能力。新版导出文件使用 `_v22_z_wall_t_slot` 文件名。

## 使用与商业授权

本作品默认仅供个人学习、测试、收藏和非商业打印使用。未经作者书面许可，禁止将原模型或任何基于本模型的改造、缩放、修补、重混或衍生版本用于商业用途，包括但不限于：销售打印件、按需打印或代打服务、批量生产、产品配套或赠品、手板/复模、定制服务、商业展示，以及上传或销售商业衍生模型。

如需商业使用，请在使用前联系作者（MakerWorld / GitHub：`@NormanWang`）取得书面授权，并另行约定授权费、单件费用、销售额分成或利润分成。未获授权的商业使用，作者保留要求停止使用、下架、追究侵权责任及索取相应授权费用或损害赔偿的权利。完整条款见 [`LICENSE.md`](LICENSE.md)。

## 设计假设

- FDM / PETG / 0.4 mm 喷嘴；底板为 `0.6 mm` 极薄版本，约对应 0.2 mm 层高的 3 层实体，不是单层空壳。
- T 形压边每侧内收 `1.3 mm`，压边材料厚 `1.0 mm`、上压高度 `0.9 mm`；相邻 `11.0 mm` 行距滑道共用约 `0.8 mm` 薄隔档，目标为普通 PETG、0.4 mm 喷嘴、无支撑打印。
- 页面平放打印，设计目标是不使用支撑。
- 页面最外圈增加连续圆角围墙，平面内墙厚 `2.0 mm`、高度与 T 形滑道最高点一致；编带滑道直接延伸到外墙内侧，不再额外设置右端挡块。
- 载带默认按 8 mm 压纹塑料带估算：宽度 8 mm、最大凸包高度 1.8 mm。
- 双侧 T 形限位是正式页面默认结构；单侧 7 形只用于对照测试片。
- 装订孔默认采用 A5 六孔制式，孔径 `5.5 mm`，孔中心距左边 `6.5 mm`，纵向位置为 `32 / 51 / 70 / 140 / 159 / 178 mm`；参数可在 `src/params.scad` 调整。
- 标签槽右边缘与对应滑道入口约留 `1 mm`，纸片标签从右向左插入，左端由装订孔旁加强高台止挡，标签槽挪出的空间让给编带滑道。
- 标签纸仍按 `25 × 9 mm` 使用；标签卡槽不削薄 `0.6 mm` 底板，支脚从底板顶面向上增高，标签下方有效容纳高度约 `0.7 mm`。主体上、下压边覆盖量约 `2.8 mm`，每格右侧入口前 `4.5 mm` 采用上下镜像的浅压边；外侧边保持直线，只收窄朝标签内侧的边。相邻标签共用水平隔档，主体标签窗口仍保留约 `9.8 mm` 高度。
- 滑道入口改为短装入豁口：横挡后的实际窗口约 `6 mm`，左端横挡高度降为 `1.8 mm`，T 形压边从其后立即开始，兼顾推进手感和防掉出。
- 编带槽内宽约 `8.6 mm`，顶部有效开口约 `6.0 mm`，优先加强编带防脱；槽间不留空白，直接共用约 `0.8 mm` 薄隔档，共容纳 18 条滑道。
- 所有载带包络和配合间隙集中在 `src/params.scad`。

## 导出

本机 OpenSCAD 应用程序路径：

```sh
OPENSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

"$OPENSCAD" --export-format binstl \
  -o output/3d-print/0603_tape_page_v22_z_wall_t_slot.stl \
  src/0603_tape_page.scad

"$OPENSCAD" --export-format binstl \
  -o output/3d-print/0603_fit_coupon_dual_t_v22_z_wall_t_slot.stl \
  -D 'model_selector="fit_dual_t"' src/0603_tape_page.scad

"$OPENSCAD" --export-format binstl \
  -D 'model_selector="fit_single_7"' \
  -o output/3d-print/0603_fit_coupon_single_7_v22_z_wall_t_slot.stl \
  src/0603_tape_page.scad
```

底板完整 + 标签上凸 T 形墙 + 单侧内边斜入口 + 装订边满铺加强版 v22 输出：

```text
output/3d-print/0603_tape_page_v22_z_wall_t_slot.stl
output/3d-print/0603_fit_coupon_dual_t_v22_z_wall_t_slot.stl
```

## 16 mm 编带变体

16 mm 版不改默认的 8 mm 页面参数，导出时通过命令行覆盖三个版型参数：

- 编带宽度 `16 mm`
- A5 页面 `10` 条滑道
- 行距 `19.0 mm`
- 编带外宽约 `18.2 mm`，相邻滑道保留标称约 `0.8 mm` 的共用薄墙；底部的 `0.04 mm` 合并余量只是为了避免 STL 共面接触，不是 8 mm 隔道
- 编带凸包高度仍按当前版本的 `1.8 mm`；若实物高度不同，只需调整 `tape_height`

导出 16 mm 整页和双侧 T 测试片：

```sh
"$OPENSCAD" --export-format binstl \
  -D 'tape_width=16' -D 'lane_count=10' -D 'lane_pitch=19.0' \
  -o output/3d-print/0603_tape_page_16mm_v1.stl \
  src/0603_tape_page.scad

"$OPENSCAD" --export-format binstl \
  -D 'model_selector="fit_dual_t"' \
  -D 'tape_width=16' -D 'lane_count=10' -D 'lane_pitch=19.0' \
  -o output/3d-print/0603_fit_coupon_dual_t_16mm_v1.stl \
  src/0603_tape_page.scad

"$OPENSCAD" --export-format binstl \
  -D 'model_selector="fit_single_7"' \
  -D 'tape_width=16' -D 'lane_count=10' -D 'lane_pitch=19.0' \
  -o output/3d-print/0603_fit_coupon_single_7_16mm_v1.stl \
  src/0603_tape_page.scad
```

对应的 16 mm STL 均已在 `output/3d-print/`，整页包围盒为 `148 × 210 × 3.45 mm`，并通过封闭流形检查。

### 16 mm 编带 + 12 mm 标签变体

针对 16 mm 编带，另提供标签横向宽度为 `12 mm` 的版本；标签沿插入方向的长度仍为 `25 mm`。这只覆盖 `label_height=12`，不会改变默认 8 mm 页面或普通 16 mm 页面。

```sh
"$OPENSCAD" --export-format binstl \
  -D 'tape_width=16' -D 'lane_count=10' -D 'lane_pitch=19.0' \
  -D 'label_height=12' \
  -o output/3d-print/0603_tape_page_16mm_label12_v1.stl \
  src/0603_tape_page.scad

"$OPENSCAD" --export-format binstl \
  -D 'model_selector="fit_dual_t"' \
  -D 'tape_width=16' -D 'lane_count=10' -D 'lane_pitch=19.0' \
  -D 'label_height=12' \
  -o output/3d-print/0603_fit_coupon_dual_t_16mm_label12_v1.stl \
  src/0603_tape_page.scad
```

整页 12 mm 标签变体同样为 `148 × 210 × 3.45 mm`，并已通过封闭流形检查。

### X1C 直接打印工程

为避免 Bambu Studio 导入 STL 后把页面放进左下角校准避让区，另提供同一几何体的 X1C 安全坐标包装版：页面位于 `x=54..202 mm`、`y=23..233 mm`，几何包围盒仍为 `148 × 210 × 3.45 mm`。

```text
output/3d-print/0603_tape_page_16mm_label12_x1c_safe_v1.stl
output/3d-print/0603_tape_page_16mm_label12_x1c_petg_v1.3mf
```

3MF 已按 Bambu Lab X1 Carbon、0.4 mm 喷嘴、0.20 mm Standard、Bambu PETG Basic、纹理 PEI 板切片；发送到打印机时，在 AMS 中把普通 PETG 映射到第 3 或第 4 槽。

## 打印前检查

先打印测试片，用实际 0603 编带验证插入、竖直防脱、镊子取料和 `25 × 9 mm` 标签插入。确认后再打印整页。PETG 大面积平板建议使用干燥耗材、纹理 PEI，并按切片结果决定是否加小幅 brim。

STL 导出后还需要检查包围盒、流形性、底面连续性和 T 形压边是否能无支撑成形。STL 导出成功本身不等于实际配合已经验证。

## X1C 局域网打印工程

已准备好可直接在 Bambu Studio 打开的切片工程：

```text
output/3d-print/0603_tape_page_v1_x1c_petg_standard.3mf
```

工程使用 Bambu Lab X1 Carbon、0.4 mm 喷嘴、PETG Basic 和纹理 PEI 板，并在工程内明确写入 `256 × 256 × 256 mm` 打印区及左下角 `18 × 28 mm` 校准避让区。当前 v4 页面通过 `src/0603_tape_page_x1c_safe.scad` 以 `54 / 23 mm` 放置，实际页面约为 `148 × 210 × 3.45 mm`，不会占用左下校准区。

质量优先参数：

- 层高 `0.20 mm`，首层 `0.20 mm`；2 圈外墙，底部 3 层，顶部 4 层，填充 `0%`。
- PETG 喷嘴 `255°C`，纹理 PEI 热床首层及其余层 `80°C`。
- 首层 `20 mm/s`，外墙 `45 mm/s`，内墙 `60 mm/s`，顶面 `60 mm/s`。
- 默认/外墙加速度 `500 mm/s²`，首层 `300 mm/s²`，风扇范围 `10–40%`，最大体积流量 `8 mm³/s`。
- 关闭 skirt，外裙边改为 `1 mm`；A5 页面在 X1C 床面上有充足边缘余量，可按首层观察结果决定是否加 brim。

该 `.3mf` 是上一版 B5 工程，不能代表当前 A5 v22 几何；正式打印前应在 Bambu Studio 中导入新的 v22 STL，确认 X1C 当前装的是干燥 PETG、纹理 PEI 板已清洁，并先用双 T 测试片确认实际编带和右侧标签配合。
