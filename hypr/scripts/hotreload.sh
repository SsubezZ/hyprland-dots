#!/usr/bin/env bash
pkill hyprpaper
hyprpaper &
disown
pkill waybar
waybar &
disown
swaync-client -R &
swaync-client -rs &
swaync-client -swb &
disown
pkill swayosd-server
sleep 1
swayosd-server -s /home/subez/.config/swayosd/style.css &
disown
hyprctl reload &
disown
notify-send "Refreshed!" -e -h string:x-canonical-private-synchronous:hot_reload &
disown

exit
