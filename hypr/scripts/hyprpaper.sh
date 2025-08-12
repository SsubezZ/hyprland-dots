#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/hypr/wallpapers/wallpapers.conf"
LINK_DIR="$HOME/.config/hypr/wallpapers"

pgrep -x hyprpaper >/dev/null || hyprpaper &

sleep 0.25

while IFS='=' read -r monitor wallpaper; do
  monitor=$(echo "$monitor" | xargs)
  wallpaper=$(eval echo "$wallpaper")

  # Skip invalid lines
  [[ -z "$monitor" || -z "$wallpaper" ]] && continue

  hyprctl hyprpaper reload "$monitor,$wallpaper"

  # Create symlink
  link_path="$LINK_DIR/background_${monitor}"
  ln -sf "$wallpaper" "$link_path"

done <"$CONFIG_FILE"
