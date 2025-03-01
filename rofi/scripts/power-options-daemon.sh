#!/bin/bash

# Define the path to your script as a variable
PDM="power-daemon-mgr -q"
SET="$PDM set-profile-override"

# Define the options for the Rofi menu
options=(
  "Powersave++"
  "Powersave"
  "Balanced"
  "Performance"
  "Performance++"
  "Reset Override"
)

# Display the menu using Rofi
selected_option=$(printf '%s\n' "${options[@]}" | rofi -dmenu -mesg "Power Options Daemon" -theme-str 'configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 225px;} inputbar {enabled: false;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher {enabled: false;}')

# Handle the selected option
case "$selected_option" in
"Powersave++") $SET Powersave++ ;;
"Powersave") $SET Powersave ;;
"Balanced") $SET Balanced ;;
"Performance") $SET Performance ;;
"Performance++") $SET Performance++ ;;
"Reset Override") $PDM reset-profile-override ;;
*) echo "Invalid selection." ;;
esac
