#!/usr/bin/env bash

set -euo pipefail

###############
# Information #
###############

# Usage:
#   ./fonts.sh /path/to/font.ttf {repo}
#
# Generates bitmap fonts with fontbm
# Writes a fonts.xml file in each resource folder
# Uses a fixed preset list of common Garmin screen sizes
#

#############
# Constants #
#############

TTF=${1:?missing TTF path}
REPO=${2:-.}
FONTBM=${FONTBM:-fontbm}
BASE_SIZE=416

# Base sizes from the 416px layout
WRITING=38
TIMEZONE=32
NUMBERS=40
WATCH=112
SECONDS=36

# Common Garmin screen sizes

# Format
#   resource-folder:scale-size
#
# "resources:416" as the default fallback set
#
TARGETS=(
  "resources:416"
  "resources-176x176:176"
  "resources-205x148:205"
  "resources-round-208x208:208"
  "resources-round-218x218:218"
  "resources-round-240x240:240"
  "resources-round-260x260:260"
  "resources-round-280x280:280"
  "resources-320x300:320"
  "resources-round-360x360:360"
  "resources-round-390x390:390"
  "resources-round-454x454:454"
  "resources-round-466x466:466"
)

#########
# Check #
#########

have() {
  command -v "$1" >/dev/null 2>&1
}

if [[ ! -f "$TTF" ]]; then
  echo "TTF not found: $TTF" >&2
  exit 1
fi

if ! have "$FONTBM"; then
  echo "fontbm not found: $FONTBM" >&2
  exit 1
fi

##################
# Character sets #
##################

# Keep the glyph sets small so the atlases stay small too

UPPER=$(mktemp)
DIGITS=$(mktemp)

trap 'rm -f "$UPPER" "$DIGITS"' EXIT

printf 'ABCDEFGHIJKLMNOPQRSTUVWXYZ !' > "$UPPER"
printf '0123456789- ' > "$DIGITS"

###########
# Helpers #
###########

scale() {
  echo $(( ($1 * $2 + BASE_SIZE / 2) / BASE_SIZE ))
}

write_fonts_xml() {
  local dir=$1

  cat > "$dir/fonts.xml" <<'XML'
<fonts xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">
    <font id="FontWriting"  filename="FontWriting.fnt"  antialias="true" />
    <font id="FontTimezone" filename="FontTimezone.fnt" antialias="true" />
    <font id="FontNumbers"  filename="FontNumbers.fnt"  antialias="true" />
    <font id="FontWatch"    filename="FontWatch.fnt"    antialias="true" />
    <font id="FontSecond"   filename="FontSecond.fnt"   antialias="true" />
</fonts>
XML
}

gen_font() {
  local out=$1
  local size=$2
  local chars=$3
  local textures=$4

  "$FONTBM" \
    --font-file "$TTF" \
    --output "$out" \
    --font-size "$size" \
    --chars-file "$chars" \
    --texture-size "$textures" \
    --data-format txt \
    --background-color 0,0,0
}

generate_target() {
  local folder=$1
  local screen=$2
  local fonts_dir="$REPO/$folder/fonts"

  mkdir -p "$fonts_dir"
  write_fonts_xml "$fonts_dir"

  echo "Generating fonts for $folder (scale $screen)"

  gen_font "$fonts_dir/FontWriting"  "$(scale "$WRITING"  "$screen")" "$UPPER"        "256x256,512x512"
  gen_font "$fonts_dir/FontTimezone" "$(scale "$TIMEZONE" "$screen")" "$UPPER"        "256x256,512x512"
  gen_font "$fonts_dir/FontNumbers"  "$(scale "$NUMBERS"  "$screen")" "$DIGITS"       "256x256,512x512"
  gen_font "$fonts_dir/FontWatch"    "$(scale "$WATCH"    "$screen")" "$DIGITS"       "512x512,1024x1024"
  gen_font "$fonts_dir/FontSecond"  "$(scale "$SECONDS"  "$screen")" "$DIGITS"       "256x256,512x512"
}

########
# Main #
########

for target in "${TARGETS[@]}"; do
  folder=${target%%:*}
  screen=${target##*:}
  generate_target "$folder" "$screen"
done
