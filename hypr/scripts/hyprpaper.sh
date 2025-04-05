#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/wallpapers/wallpapers.conf"
VAR_FILE="$HOME/.config/wallpapers/.wallpapers"

hyprpaper &

sleep 0.25

WALLPAPER_RIGHT=""
WALLPAPER_LEFT=""

while IFS='=' read -r monitor wallpaper; do
	monitor=$(echo "$monitor" | xargs)
	wallpaper=$(eval echo "$wallpaper")

	# Skip invalid lines
	if [[ -z "$monitor" || -z "$wallpaper" ]]; then
		continue
	fi

	hyprctl hyprpaper reload "$monitor,$wallpaper"

	case "$monitor" in
	"eDP-1")
		WALLPAPER_RIGHT="$wallpaper"
		;;
	"HDMI-A-1")
		WALLPAPER_LEFT="$wallpaper"
		;;
	esac
done <"$CONFIG_FILE"

cat >"$VAR_FILE" <<EOF
export WALLPAPER_RIGHT="$WALLPAPER_RIGHT"
export WALLPAPER_LEFT="$WALLPAPER_LEFT"
EOF
