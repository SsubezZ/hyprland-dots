#!/bin/bash

# Define the path to your script as a variable
SCRIPT_PATH="$HOME/.config/hypr/scripts/nitrosense"

# Define the options for the Rofi menu
options=(
  "Power Management"
  "Fan Control"
  "Read EC Data"
  "Energy Data from Intel RAPL"
  "Restart NVIDIA Power Daemon"
)

# Display the menu using Rofi
selected_option=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Select an option:")

# Handle the selected option
case "$selected_option" in
"Power Management")
  power_options=("Quiet" "Default" "Performance")
  selected_power=$(printf '%s\n' "${power_options[@]}" | rofi -dmenu -p "Select power mode:")
  case "$selected_power" in
  "Quiet") sudo $SCRIPT_PATH q ;;
  "Default") sudo $SCRIPT_PATH d ;;
  "Performance") sudo $SCRIPT_PATH p ;;
  *) echo "Invalid selection." ;;
  esac
  ;;
"Fan Control")
  fan_options=("Auto" "Custom" "Max")
  selected_fan=$(printf '%s\n' "${fan_options[@]}" | rofi -dmenu -p "Select fan mode:")
  case "$selected_fan" in
  "Auto") sudo $SCRIPT_PATH a ;;
  "Custom")
    rofi -mesg "Please enter a fan percentage (0-100):" -dmenu -p "" >/dev/null
    fan_percentage=$(rofi -dmenu -p "Enter fan percentage (0-100):")
    if [[ "$fan_percentage" =~ ^[0-9]+$ ]] && [ "$fan_percentage" -ge 0 ] && [ "$fan_percentage" -le 100 ]; then
      sudo $SCRIPT_PATH c "$fan_percentage"
    else
      rofi -e "Invalid percentage. Please enter a number between 0 and 100."
    fi
    ;;
  "Max") sudo $SCRIPT_PATH m ;;
  *) echo "Invalid selection." ;;
  esac
  ;;
"Read EC Data")
  sudo $SCRIPT_PATH r
  ;;
"Energy Data from Intel RAPL")
  sudo $SCRIPT_PATH e
  ;;
"Restart NVIDIA Power Daemon")
  sudo $SCRIPT_PATH n
  ;;
*)
  echo "Invalid selection."
  ;;
esac
