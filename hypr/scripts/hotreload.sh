#!/usr/bin/env bash
pkill waybar
waybar &
disown
pkill swaync-client
swaync-client -R -rs -swb &
disown
pkill swayosd-server
sleep 1
swayosd-server -s /home/subez/.config/swayosd/style.css &
disown
hyprctl reload &
disown
notify-send -e "Refreshed!" &
disown

exit
