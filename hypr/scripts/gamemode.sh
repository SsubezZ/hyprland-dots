#!/usr/bin/env bash

write_state() {
	local icon="$1"
	local tt="$2"
	local state_file="$HOME/.local/state/._state_gamemode.txt"
	mkdir -p "$(dirname "$state_file")"
	[ -f "$state_file" ] || echo '{"text": "󰖻", "tooltip": "Gamemode OFF"}' >"$state_file"
	echo "{\"text\": \"${icon}\", \"tooltip\": \"${tt}\"}" >"$state_file"
}

enable_gamemode() {
	hyprctl keyword misc:disable_autoreload 1
	power-daemon-mgr -q set-profile-override Performance++
	pkill hyprpaper
	if [ "$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")" == "prefer-dark" ]; then
		hyprctl --batch "\
    #keyword animations:enabled 0;\
    #keyword windowrule forcergbx, class:.*;\
    keyword windowrule opaque override, class:.*;\
    keyword decoration:shadow:enabled 0;\
    #keyword decoration:rounding 0;\
    #keyword decoration:blur:enabled 0;\
    keyword decoration:blur:size 0;\
    keyword decoration:blur:passes 0;\
    keyword decoration:blur:brightness 0;\
    # keyword decoration:blur:contrast 0;\
    keyword decoration:blur:popups 1"
	else
		hyprctl --batch "\
    #keyword animations:enabled 0;\
    #keyword windowrule forcergbx, class:.*;\
    keyword windowrule opaque override, class:.*;\
    keyword decoration:shadow:enabled 0;\
    #keyword decoration:rounding 0;\
    #keyword decoration:blur:enabled 0;\
    keyword decoration:blur:size 0;\
    keyword decoration:blur:passes 0;\
    keyword decoration:blur:brightness 2;\
    # keyword decoration:blur:contrast 0;\
    keyword decoration:blur:popups 1"
	fi
	swayosd-client --custom-message "Gamemode Enabled" --custom-icon "input-gaming" || notify-send --app-name "Gamemode" "Gamemode Enabled" "Decorations Disabled" -e -h string:x-canonical-private-synchronous:gamemode
	write_state "󰖺" "Gamemode ON"
	sleep 0.5

}

disable_gamemode() {
	hyprctl reload
	hyprctl dismissnotify
	power-daemon-mgr -q reset-profile-override
	$HOME/.config/hypr/scripts/hyprpaper.sh
	swayosd-client --custom-message "Gamemode Disabled" --custom-icon "input-gaming" || notify-send --app-name "Gamemode" "Gamemode Disabled" "Decorations Enabled" -e -h string:x-canonical-private-synchronous:gamemode
	write_state "󰖻" "Gamemode OFF"
	sleep 0.5

}

HYPRGAMEMODE=$(hyprctl getoption decoration:blur:size | awk 'NR==1{print $2}')
CURRENT_STATE="off"
[ "$HYPRGAMEMODE" = "0" ] && CURRENT_STATE="on"

ACTION="toggle"
if [ $# -ge 1 ]; then
	case "$1" in
	on | off) ACTION="$1" ;;
	*)
		echo "Usage: $0 [on|off]" >&2
		exit 1
		;;
	esac
fi

case $ACTION in
on)
	[ "$CURRENT_STATE" = "off" ] && enable_gamemode
	;;
off)
	[ "$CURRENT_STATE" = "on" ] && disable_gamemode
	;;
toggle)
	if [ "$CURRENT_STATE" = "on" ]; then
		disable_gamemode
	else
		enable_gamemode
	fi
	;;
esac

exit 0
