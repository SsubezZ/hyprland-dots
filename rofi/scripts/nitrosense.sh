#!/usr/bin/env bash

SCRIPT_PATH="$HOME/.config/hypr/scripts/nitrosense"
THEME_KEYBIND='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
THEME_WAYBAR='configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 250px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
THEME_KEYBIND_PER='configuration {show-icons: false;} window {width: 300px;} listview {enabled: false;} mode-switcher {enabled: false;} element {enabled: false;}'
THEME_WAYBAR_PER='configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 300px;} listview {enabled: false;} mode-switcher {enabled: false;} element {enabled: false;}'

if [[ "${1:-}" == "waybar" ]]; then
	THEME="$THEME_WAYBAR"
	THEME_PER="$THEME_WAYBAR_PER"
else
	THEME="$THEME_KEYBIND"
	THEME_PER="$THEME_KEYBIND_PER"
fi

options=(
	"Power Management"
	"Fan Control"
	"Default Auto"
	"Restart NVIDIA Power Daemon"
)

selected_option=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -theme-str "$THEME" -mesg "NitroSense")

case "$selected_option" in
"Power Management")
	power_options=("Quiet" "Default" "Performance")
	selected_power=$(printf '%s\n' "${power_options[@]}" | rofi -dmenu -i -theme-str "$THEME" -mesg "Select power mode:")
	case "$selected_power" in
	"Quiet")
		pkexec "$SCRIPT_PATH" q
		wait
		notify-send -e --app-name="Nitrosense" "Nitrosense" "Quiet Power-Mode"
		;;
	"Default")
		pkexec "$SCRIPT_PATH" d
		wait
		notify-send -e --app-name="Nitrosense" "Nitrosense" "Default Power-Mode"
		;;
	"Performance")
		pkexec "$SCRIPT_PATH" p
		wait
		notify-send -e --app-name="Nitrosense" "Nitrosense" "Performance Power-Mode"
		;;
	*) echo "Invalid selection." ;;
	esac
	;;
"Fan Control")
	fan_options=("Auto" "Custom" "Max")
	selected_fan=$(printf '%s\n' "${fan_options[@]}" | rofi -dmenu -i -theme-str "$THEME" -mesg "Select fan mode:")
	case "$selected_fan" in
	"Auto")
		pkexec "$SCRIPT_PATH" a
		wait
		notify-send -e --app-name="Nitrosense" "Nitrosense" "Auto Fan-Mode"
		;;
	"Custom")
		while true; do
			fan_percentage=$(rofi -dmenu -theme-str "$THEME_PER" -mesg "Enter a fan percentage (0-100):")
			rofi_exit_code=$?
			if [[ $rofi_exit_code -ne 0 ]]; then
				break
			elif [[ "$fan_percentage" =~ ^[0-9]+$ ]] && [ "$fan_percentage" -ge 0 ] && [ "$fan_percentage" -le 100 ]; then
				pkexec "$SCRIPT_PATH" c "$fan_percentage"
				wait
				notify-send -e "Nitrosense" --appname="Nitrosense" "Fan speed set to $fan_percentage%"
				break
			else
				rofi -theme-str "$THEME_PER" -e "Invalid percentage. Enter a number between 0 and 100."
			fi
		done
		;;
	"Max")
		pkexec "$SCRIPT_PATH" m
		wait
		notify-send -e --app-name="Nitrosense" "Nitrosense" "Fan mode set to Max"
		;;
	*) echo "Invalid selection." ;;
	esac
	;;
"Restart NVIDIA Power Daemon")
	pkexec "$SCRIPT_PATH" n
	wait
	notify-send -e --app-name="Nitrosense" "Nitrosense" "NVIDIA Power Daemon restarted"
	;;
"Default Auto")
	pkexec "$SCRIPT_PATH" d
	wait
	notify-send -e --app-name="Nitrosense" "Nitrosense" "Power mode set to Default"
	pkexec "$SCRIPT_PATH" a
	wait
	notify-send -e --app-name="Nitrosense" "Nitrosense" "Fan mode set to Auto"
	;;
*)
	echo "Invalid selection."
	;;
esac
