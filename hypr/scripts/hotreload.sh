#!/usr/bin/env bash

reload_process() {
	local process_name=$1
	local start_command=$2

	pkill "$process_name"

	while pgrep -x "$process_name" >/dev/null; do
		sleep 0.1
	done

	$start_command &
	disown
}

reload_process "hyprpaper" "hyprpaper" &
reload_process "waybar" "waybar" &
wait

swaync-client -R &
swaync-client -rs &
swaync-client -swb &
disown

pkill swayosd-server
while pgrep -x "swayosd-server" >/dev/null; do
	sleep 0.1
done
swayosd-server
disown

hyprctl reload &
disown

restarted="Hyprpaper\nWaybar\nSwaync\nSwayOSD\nHyprctl"

if ! pgrep -x "hyprpaper" >/dev/null; then
	restarted="${restarted/Hyprpaper/}"
fi

if ! pgrep -x "waybar" >/dev/null; then
	restarted="${restarted/Waybar/}"
fi

if ! pgrep -x "swaync-client" >/dev/null; then
	restarted="${restarted/Swaync/}"
fi

if ! pgrep -x "swayosd-server" >/dev/null; then
	restarted="${restarted/SwayOSD/}"
fi

notify-send --app-name "Hot Reload" "Hot Reload" "Refreshed!\n$restarted" -e -h string:x-canonical-private-synchronous:hot_reload &
disown

exit
