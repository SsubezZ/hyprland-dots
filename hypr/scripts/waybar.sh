#!/usr/bin/env bash

CONFIG=~/.config/waybar/config.jsonc
STYLE=~/.config/waybar/style-dark.css

# Define a cleanup function to re-add the CSS import line on exit
cleanup() {
  if ! grep -q '@import url("./launch_animation.css");' "$STYLE"; then
    # Prepend the CSS import line to the file
    sed -i '1i @import url("./launch_animation.css");' "$STYLE"
  fi
}
trap cleanup EXIT

swaync-client -t
if ! hyprctl layers | grep -q swaync-control-center; then
  exit
fi

# Ensure waybar is running
if ! pgrep -x waybar >/dev/null; then
  exit
fi

# Ensure if activewindow is not fullscreenstate 2
if ! hyprctl activewindow | grep -q 'fullscreenClient: 2'; then
  exit
fi

if ! hyprctl activewindow | grep 'monitor: 0'; then
  exit
fi

# Remove the launch animation CSS import line from the style file
sed -i '/@import url(".\/launch_animation.css");/d' "$STYLE"

# Find the line number for "output": "eDP-1"
output_line=$(grep -n '"output": "eDP-1"' "$CONFIG" | cut -d: -f1)
if [ -z "$output_line" ]; then
  exit 1
fi

# Assuming the "layer" line is always 2 lines above "output"
layer_line=$((output_line - 2))

# Check if the "layer" is "top" then change it to "overlay"
if sed -n "${layer_line}p" "$CONFIG" | grep -q '"layer": "top"'; then
  sed -i "${layer_line}s/\"layer\": \"top\"/\"layer\": \"overlay\"/" "$CONFIG"
  pkill -SIGUSR2 waybar
fi

# Set the bar layer to overlay in the config and force waybar to reload it.
if [ "$(grep -w -B2 -A2 "output\": \"eDP-1\"" $CONFIG | grep -w "layer" | awk '{printf $2}' | cut -d ',' -f1 | cut -d '"' -f2 | xargs)" == "top" ]; then
  sed -i 's/^\(\s*"layer"\s*:\s*\).*/\1"overlay",/' "$CONFIG"
  pkill -SIGUSR2 waybar
fi

# Ham hyprctl layers until swaync-control-center no longer appears.
while hyprctl layers | grep -q swaync-control-center; do
  sleep 0.1
done

# Change the layer back to "top" on swaync-control-center closing
sed -i "${layer_line}s/\"layer\": \"overlay\"/\"layer\": \"top\"/" "$CONFIG"
pkill -SIGUSR2 waybar

sleep 1
