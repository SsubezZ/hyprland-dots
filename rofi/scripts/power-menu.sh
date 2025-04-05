#!/usr/bin/env bash

set -euo pipefail
uptime="$(uptime -p | sed -e 's/up //g')"

declare -A actions=(
  [Shutdown]="systemctl poweroff"
  [Reboot]="systemctl reboot"
  [Suspend]="systemctl suspend"
  [Log Out]="loginctl terminate-user $USER"
)

options=("Shutdown" "Reboot" "Suspend" "Log Out")

theme_keybinds='configuration {show-icons: false;} window {width: 300px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

theme_waybar='configuration {show-icons: false;} window {location: north west; x-offset: 4; y-offset: 2; width: 250px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}'

if [[ "${1:-}" == "waybar" ]]; then
    theme="$theme_waybar"
else
    theme="$theme_keybinds"
fi

chosen=$(printf "%s\n" "${options[@]}" | rofi -dmenu \
                                              -i \
                                              -mesg "Uptime: $uptime" \
                                              -theme-str "$theme")

if [[ -n "$chosen" && "${actions[$chosen]+isset}" ]]; then
  ${actions[$chosen]}
fi
