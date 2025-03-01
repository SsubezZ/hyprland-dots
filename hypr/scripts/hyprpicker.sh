#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [hex|rgb|hsv]"
  exit 1
fi

format="${1,,}"
temp_img="/tmp/color.png"

# Get color directly from hyprpicker output
color=$(hyprpicker -n -a -f "$format")
exit_status=$?

# Check for cancellation/empty output
if [ $exit_status -ne 0 ] || [ -z "$color" ]; then
  exit 1
fi

# Format specification
case "$format" in
hex) color_spec="$color" ;;
*) color_spec="$format($color)" ;;
esac

# Generate preview and notify
magick -size 96x96 xc:"$color_spec" "$temp_img"
notify-send "${format^^}" "$color_spec" -i "$temp_img" -a "Hyprpicker"
rm -f "$temp_img"

exit 0
