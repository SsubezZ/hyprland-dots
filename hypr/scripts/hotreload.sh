#!/usr/bin/env bash

pkill hyprpaper
hyprpaper &
disown && sleep 0.25
pkill waybar
waybar &
disown && sleep 0.25
swaync-client -R &
swaync-client -rs &
swaync-client -swb &
disown && sleep 0.25
pkill swayosd-server
sleep 1
swayosd-server -s /home/subez/.config/swayosd/style.css &
disown && sleep 0.25
hyprctl reload &
disown
notify-send --app-name "Hot Reload" "Hot Reload" "Refreshed!\n  Hyprpaper\n  Waybar\n  Swaync\n  Swayosd\n  Hyprctl" -e -h string:x-canonical-private-synchronous:hot_reload &
disown && sleep 0.25

exit
