#!/usr/bin/env bash

PDM="power-daemon-mgr -q"
SET="$PDM set-profile-override"

options=(
	"Powersave++"
	"Powersave"
	"Balanced"
	"Performance"
	"Performance++"
	"Reset Override"
)

selected_option=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -mesg "Power Options Daemon" -theme-str 'configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 225px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}')

case "$selected_option" in
"Powersave++") $SET Powersave++ ;;
"Powersave") $SET Powersave ;;
"Balanced") $SET Balanced ;;
"Performance") $SET Performance ;;
"Performance++") $SET Performance++ ;;
"Reset Override") $PDM reset-profile-override ;;
*) echo "Invalid selection." ;;
esac
