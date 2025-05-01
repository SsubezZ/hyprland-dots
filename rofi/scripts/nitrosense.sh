#!/usr/bin/env bash

SCRIPT_PATH="$HOME/.config/hypr/scripts/nitrosense"
THEME_KEYBIND='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
THEME_WAYBAR='configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 250px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'
THEME_KEYBIND_PER='configuration {show-icons: false;} window {width: 300px;} listview {enabled: false;} mode-switcher {enabled: false;} element {enabled: false;}'
THEME_WAYBAR_PER='configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 300px;} listview {enabled: false;} mode-switcher {enabled: false;} element {enabled: false;}'

runpk() {
	pkexec "$SCRIPT_PATH" "$@"
	return $?
}

notify() {
	notify-send -e --app-name="Nitrosense" -i nitroshare "Nitrosense" "$1"
}

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
		if runpk q; then
			notify "Quiet Power-Mode"
		fi
		;;
	"Default")
		if runpk d; then
			notify "Default Power-Mode"
		fi
		;;
	"Performance")
		if runpk p; then
			notify "Performance Power-Mode"
		fi
		;;
	esac
	;;
"Fan Control")
	fan_options=("Auto" "Custom" "Max")
	selected_fan=$(printf '%s\n' "${fan_options[@]}" | rofi -dmenu -i -theme-str "$THEME" -mesg "Select fan mode:")
	case "$selected_fan" in
	"Auto")
		if runpk a; then
			notify "Auto Fan-Mode"
		fi
		;;
	"Custom")
		while true; do
			fan_percentage=$(rofi -dmenu -theme-str "$THEME_PER" -mesg "Enter a fan percentage (0-100):")
			rofi_exit_code=$?
			if [[ $rofi_exit_code -ne 0 ]]; then
				break
			elif [[ "$fan_percentage" =~ ^[0-9]+$ ]] && [ "$fan_percentage" -ge 0 ] && [ "$fan_percentage" -le 100 ]; then
				if runpk c "$fan_percentage"; then
					notify "Fan speed set to $fan_percentage%"
				fi
				break
			else
				rofi -theme-str "$THEME_PER" -e "Invalid percentage. Enter a number between 0 and 100."
			fi
		done
		;;
	"Max")
		if runpk m; then
			notify "Fan mode set to Max"
		fi
		;;
	esac
	;;
"Restart NVIDIA Power Daemon")
	if runpk n; then
		notify "NVIDIA Power Daemon restarted"
	fi
	;;
"Default Auto")
	if runpk d; then
		notify "Power mode set to Default"
	fi
	if runpk a; then
		notify "Fan mode set to Auto"
	fi
	;;
esac
