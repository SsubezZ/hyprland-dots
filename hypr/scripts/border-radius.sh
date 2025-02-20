#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <border-radius-value>"
	exit 1
fi

BORDER_RADIUS=$1

# Validate that the input is a number
if ! [[ "$BORDER_RADIUS" =~ ^[0-9]+$ ]]; then
	echo "Error: Border radius must be a numeric value."
	exit 1
fi

# Define the border radius for each application
WAYBAR_RADIUS="${BORDER_RADIUS}px"
SWAYNC_RADIUS="${BORDER_RADIUS}px"
SWAYOSD_RADIUS="${BORDER_RADIUS}px"
ROFI_RADIUS="${BORDER_RADIUS}px"

change_radius() {
	# Hyprland
	sed -i "s/^\(\s*rounding\s*=\s*\).*/\1$BORDER_RADIUS/" ~/.config/hypr/hyprland.conf

	# Hyprlock
	sed -i "s/^\(\s*rounding\s*=\s*\).*/\1$BORDER_RADIUS/" ~/.config/hypr/hyprlock.conf

	# Waybar
	sed -i "s/^\(\s*border-radius:\s*\).*/\1$WAYBAR_RADIUS;/" ~/.config/waybar/style-dark.css

	# Swaync
	sed -i "s/^\(\s*border-radius:\s*\).*/\1$SWAYNC_RADIUS;/" ~/.config/swaync/style.css

	# Swayosd
	sed -i "s/^\(\s*border-radius:\s*\).*/\1$SWAYOSD_RADIUS;/" ~/.config/swayosd/style.css

	# Rofi
	sed -i "s/^\(\s*border-radius:\s*\).*/\1$ROFI_RADIUS;/" ~/.config/rofi/theme.rasi

	# MPV(uosc)
	sed -i "s/^\(\s*border_radius=\s*\).*/\1$BORDER_RADIUS/" ~/.config/mpv/script-opts/uosc.conf
}

post() {
	hyprctl reload &>/dev/null &
	disown

	swaync-client -rs &>/dev/null &
	disown

	pkill swayosd-server
	while pgrep -x "swayosd-server" >/dev/null; do
		sleep 0.1
	done
	swayosd-server -s "$HOME/.config/swayosd/style.css" &>/dev/null &
	disown

	echo "Updated border radius to $BORDER_RADIUS for all applications."
}

change_radius
post

exit
