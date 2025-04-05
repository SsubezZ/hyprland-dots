#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style-dark.css"

reset_waybar_layer_top() {
	start_line=$(grep -n '"id": *1,' "$CONFIG" | head -n1 | cut -d: -f1 || true)
	if [ -z "$start_line" ]; then
		return 1
	fi
	layer_line=$(sed -n "${start_line},$((start_line + 20))p" "$CONFIG" | grep -n '"layer": "overlay"' | head -n1 | cut -d: -f1)
	if [ -z "$layer_line" ]; then
		return 1
	fi
	layer_line=$((layer_line + start_line - 1))
	tmpfile=$(mktemp)
	sed "${layer_line}s/\"layer\": \"overlay\"/\"layer\": \"top\"/" "$CONFIG" >"$tmpfile"
	mv "$tmpfile" "$CONFIG"
	pkill -SIGUSR2 waybar
}

set_waybar_layer_overlay() {
	start_line=$(grep -n '"id": *1,' "$CONFIG" | head -n1 | cut -d: -f1)
	if [ -z "$start_line" ]; then
		exit 1
	fi
	layer_line=$(sed -n "${start_line},$((start_line + 20))p" "$CONFIG" | grep -n '"layer": "top"' | head -n1 | cut -d: -f1)
	if [ -z "$layer_line" ]; then
		exit 1
	fi
	layer_line=$((layer_line + start_line - 1))
	tmpfile=$(mktemp)
	sed "${layer_line}s/\"layer\": \"top\"/\"layer\": \"overlay\"/" "$CONFIG" >"$tmpfile"
	mv "$tmpfile" "$CONFIG"
	pkill -SIGUSR2 waybar
}

remove_animation_import() {
	tmpfile=$(mktemp)
	sed '/@import url(".\/launch_animation.css");/d' "$STYLE" >"$tmpfile"
	mv "$tmpfile" "$STYLE"
}

wait_for_swaync_cc() {
	while hyprctl layers | grep -q swaync-control-center; do
		sleep 0.1
	done
}

cleanup() {
	reset_waybar_layer_top
	if ! grep -q '@import url("./launch_animation.css");' "$STYLE"; then
		tmpfile=$(mktemp)
		echo '@import url("./launch_animation.css");' >"$tmpfile"
		cat "$STYLE" >>"$tmpfile"
		mv "$tmpfile" "$STYLE"
	fi
}
trap cleanup EXIT

# Main execution
swaync-client -t

if ! hyprctl layers | grep -q swaync-control-center; then
	exit
fi

if ! pgrep -x waybar >/dev/null; then
	exit
fi

# if ! hyprctl activewindow | grep -q 'fullscreenClient: 2'; then
# 	exit
# fi

if ! hyprctl activewindow | grep -q 'fullscreen: 2'; then
	exit
fi

if ! hyprctl activewindow | grep -q 'monitor: 0'; then
	exit
fi

remove_animation_import
set_waybar_layer_overlay
wait_for_swaync_cc
reset_waybar_layer_top

sleep 0.5
