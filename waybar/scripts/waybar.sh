#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style-dark.css"

restart_waybar() {
  killall waybar
  # hyprctl keyword monitor eDP-1,addreserved,32,0,0,0
  sleep 0.01
  waybar &
  # sleep 0.2
  # hyprctl keyword monitor eDP-1,addreserved,0,0,0,0
}

set_layer() {
  local target_layer="$1"

  local temp_file
  temp_file="$(mktemp)"

  awk -v tl="$target_layer" '
    /"id": *1/,/}/ {
        if (/"layer":/) { gsub(/"layer": *".*"/, "\"layer\": \"" tl "\"") }
    }
    { print }
    ' "$CONFIG" >"$temp_file"

  mv -f "$temp_file" "$CONFIG"
  sleep 0.25
  restart_waybar
}
cleanup() {
  set_layer "top"
  sleep 0.5
  sed -i '1i@import url("./launch_animation.css");' "$STYLE"

}
toggle_interface() {
  trap cleanup EXIT

  if ! grep -q '"layer": *"overlay"' "$CONFIG"; then
    set_layer "overlay"
  fi

  sleep 0.5
  swaync-client -t
  while hyprctl layers | grep -q swaync-control-center; do
    sleep 0.01
  done
}

sleep 0.01
if ! pgrep -x waybar >/dev/null ||
  hyprctl layers | grep -q swaync-control-center ||
  ! hyprctl activewindow | grep -q 'monitor: 0' ||
  ! hyprctl activewindow | grep -q 'fullscreen: 2' ||
  (hyprctl activewindow | grep -q 'workspace.*special' && ! hyprctl activewindow | grep -q 'fullscreen: 2'); then
  swaync-client -t
  exit 0
fi

sed -i '/@import url(".\/launch_animation.css");/d' "$STYLE"
toggle_interface
