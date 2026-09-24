#!/usr/bin/env bash
set -euo pipefail

# Build the MakerWorld platform variants from the same v22 source.
# Units are millimetres. The 12 mm STL is the previously printed/validated
# package and is deliberately preserved; this script verifies that it exists.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENSCAD_BIN="${OPENSCAD_BIN:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"
SOURCE="$ROOT_DIR/src/0603_tape_page.scad"
OUTPUT_DIR="$ROOT_DIR/output/3d-print"
REPORT_DIR="$ROOT_DIR/output/verification"
INSPECT_STL="${INSPECT_STL:-/Users/norman/.codex/skills/openscad-stl-print/scripts/inspect_stl.py}"

if [[ ! -x "$OPENSCAD_BIN" ]]; then
    printf 'OpenSCAD executable not found: %s\n' "$OPENSCAD_BIN" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR" "$REPORT_DIR"

# 8 mm tape: retain the existing 18-lane / 11 mm pitch layout, which leaves
# room for the 25 x 9 mm label card used by this narrow variant.
"$OPENSCAD_BIN" --export-format binstl \
    -D 'tape_width=8' \
    -D 'tape_side_clearance=0.3' \
    -D 'lane_count=18' \
    -D 'lane_pitch=11.0' \
    -D 'label_height=9' \
    -o "$OUTPUT_DIR/0603_tape_page_8mm_label9_v1.stl" \
    "$SOURCE"

# 12 mm tape: this is the previously printed/validated 12 mm package.
if [[ ! -s "$OUTPUT_DIR/0603_tape_page_12mm_label12_v1.stl" ]]; then
    printf 'Missing validated 12 mm STL: %s\n' \
        "$OUTPUT_DIR/0603_tape_page_12mm_label12_v1.stl" >&2
    exit 1
fi

# 16 mm tape: compact common-wall layout. The 17.2 mm pitch is
# 16.0 + 0.2 + 0.8 + 0.2; adjacent rail stems overlap into one 0.8 mm wall.
"$OPENSCAD_BIN" --export-format binstl \
    -D 'tape_width=16' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=11' \
    -D 'lane_pitch=17.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_tape_page_16mm_label12_tight_v1.stl" \
    "$SOURCE"

# A small dual-T coupon for checking the actual 16 mm carrier tape.
"$OPENSCAD_BIN" --export-format binstl \
    -D 'model_selector="fit_dual_t"' \
    -D 'tape_width=16' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=11' \
    -D 'lane_pitch=17.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_fit_coupon_dual_t_16mm_label12_tight_v1.stl" \
    "$SOURCE"

# Wider carrier tapes use the same compact common-wall rule:
# pitch = tape width + 0.2 mm side clearance on each side + 0.8 mm shared wall.
# The larger height envelopes keep the page useful for deeper pockets/modules:
# 24/32 mm use a conservative 3.0 mm envelope; 44 mm is sized for the
# approximately 3.1 mm ESP32-WROOM-class module plus 0.5 mm pocket allowance.
# These are initial fit variants and still need confirmation against the actual
# carrier tape and component cavity before committing a full reel.
"$OPENSCAD_BIN" --export-format binstl \
    -D 'tape_width=24' \
    -D 'tape_height=3.0' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=8' \
    -D 'lane_pitch=25.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_tape_page_24mm_label12_v1.stl" \
    "$SOURCE"

"$OPENSCAD_BIN" --export-format binstl \
    -D 'model_selector="fit_dual_t"' \
    -D 'tape_width=24' \
    -D 'tape_height=3.0' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=8' \
    -D 'lane_pitch=25.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_fit_coupon_dual_t_24mm_label12_v1.stl" \
    "$SOURCE"

"$OPENSCAD_BIN" --export-format binstl \
    -D 'tape_width=32' \
    -D 'tape_height=3.0' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=6' \
    -D 'lane_pitch=33.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_tape_page_32mm_label12_v1.stl" \
    "$SOURCE"

"$OPENSCAD_BIN" --export-format binstl \
    -D 'model_selector="fit_dual_t"' \
    -D 'tape_width=32' \
    -D 'tape_height=3.0' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=6' \
    -D 'lane_pitch=33.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_fit_coupon_dual_t_32mm_label12_v1.stl" \
    "$SOURCE"

"$OPENSCAD_BIN" --export-format binstl \
    -D 'tape_width=44' \
    -D 'tape_height=3.6' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=4' \
    -D 'lane_pitch=45.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_tape_page_44mm_label12_v1.stl" \
    "$SOURCE"

"$OPENSCAD_BIN" --export-format binstl \
    -D 'model_selector="fit_dual_t"' \
    -D 'tape_width=44' \
    -D 'tape_height=3.6' \
    -D 'tape_side_clearance=0.2' \
    -D 'lane_count=4' \
    -D 'lane_pitch=45.2' \
    -D 'label_height=12' \
    -o "$OUTPUT_DIR/0603_fit_coupon_dual_t_44mm_label12_v1.stl" \
    "$SOURCE"

# B5 landscape long-track variants. The left binding edge remains the opening
# edge; page width grows to 250 mm while page height becomes 176 mm. Six holes
# keep the normal 19 mm pitch with a 70 mm gap between the two three-hole groups.
# The 250 mm edge fits the X1C's nominal 256 mm axis with about 3 mm per side;
# these pages should be placed deliberately and printed without a brim.
B5_HOLE_POSITIONS='[15,34,53,123,142,161]'

build_b5_page() {
    local tape_w="$1"
    local tape_h="$2"
    local side_clear="$3"
    local count="$4"
    local pitch="$5"
    local label_h="$6"
    local output_name="$7"

    "$OPENSCAD_BIN" --export-format binstl \
        -D 'page_width=250' \
        -D 'page_height=176' \
        -D "binding_hole_positions=$B5_HOLE_POSITIONS" \
        -D "tape_width=$tape_w" \
        -D "tape_height=$tape_h" \
        -D "tape_side_clearance=$side_clear" \
        -D "lane_count=$count" \
        -D "lane_pitch=$pitch" \
        -D "label_height=$label_h" \
        -o "$OUTPUT_DIR/$output_name" \
        "$SOURCE"
}

build_b5_page 8 1.8 0.3 15 11.0 9 \
    '0603_tape_page_b5_8mm_label9_v1.stl'
build_b5_page 12 1.8 0.2 12 13.2 12 \
    '0603_tape_page_b5_12mm_label12_v1.stl'
build_b5_page 16 1.8 0.2 9 17.2 12 \
    '0603_tape_page_b5_16mm_label12_tight_v1.stl'
build_b5_page 24 3.0 0.2 6 25.2 12 \
    '0603_tape_page_b5_24mm_label12_v1.stl'
build_b5_page 32 3.0 0.2 5 33.2 12 \
    '0603_tape_page_b5_32mm_label12_v1.stl'
build_b5_page 44 3.6 0.2 3 45.2 12 \
    '0603_tape_page_b5_44mm_label12_v1.stl'

python3 "$INSPECT_STL" "$OUTPUT_DIR/0603_tape_page_8mm_label9_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_tape_page_8mm_label9_v1_stl_report.json"
python3 "$INSPECT_STL" "$OUTPUT_DIR/0603_tape_page_12mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_tape_page_12mm_label12_v1_stl_report.json"
python3 "$INSPECT_STL" "$OUTPUT_DIR/0603_tape_page_16mm_label12_tight_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_tape_page_16mm_label12_tight_v1_stl_report.json"
python3 "$INSPECT_STL" \
    "$OUTPUT_DIR/0603_fit_coupon_dual_t_16mm_label12_tight_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_fit_coupon_dual_t_16mm_label12_tight_v1_stl_report.json"
python3 "$INSPECT_STL" "$OUTPUT_DIR/0603_tape_page_24mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_tape_page_24mm_label12_v1_stl_report.json"
python3 "$INSPECT_STL" \
    "$OUTPUT_DIR/0603_fit_coupon_dual_t_24mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_fit_coupon_dual_t_24mm_label12_v1_stl_report.json"
python3 "$INSPECT_STL" "$OUTPUT_DIR/0603_tape_page_32mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_tape_page_32mm_label12_v1_stl_report.json"
python3 "$INSPECT_STL" \
    "$OUTPUT_DIR/0603_fit_coupon_dual_t_32mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_fit_coupon_dual_t_32mm_label12_v1_stl_report.json"
python3 "$INSPECT_STL" "$OUTPUT_DIR/0603_tape_page_44mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_tape_page_44mm_label12_v1_stl_report.json"
python3 "$INSPECT_STL" \
    "$OUTPUT_DIR/0603_fit_coupon_dual_t_44mm_label12_v1.stl" \
    --require-watertight --output \
    "$REPORT_DIR/0603_fit_coupon_dual_t_44mm_label12_v1_stl_report.json"

for b5_name in \
    8mm_label9 \
    12mm_label12 \
    16mm_label12_tight \
    24mm_label12 \
    32mm_label12 \
    44mm_label12; do
    python3 "$INSPECT_STL" \
        "$OUTPUT_DIR/0603_tape_page_b5_${b5_name}_v1.stl" \
        --require-watertight --output \
        "$REPORT_DIR/0603_tape_page_b5_${b5_name}_v1_stl_report.json"
done

printf 'Platform variants built and checked.\n'
