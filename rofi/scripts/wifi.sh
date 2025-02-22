#!/bin/bash

# Find the Ethernet interface (if available)
eth_interface=$(nmcli device status | awk '$2 == "ethernet" {print $1; exit}')

# Get the list of saved connection names (SSIDs)
saved_connections=$(nmcli -g NAME connection)

build_wifi_menu() {
  wifi_menu_conn=""
  wifi_menu_saved=""
  wifi_menu_unsaved=""

  # Trigger a Wi-Fi rescan (discard output)
  nmcli device wifi rescan >/dev/null 2>&1

  # Process available networks (fields: IN-USE:SSID:SIGNAL:SECURITY)
  while IFS=: read -r in_use ssid signal security; do
    [ -z "$ssid" ] && continue

    # Determine if network is currently connected
    connected=0
    if [ "$in_use" = "*" ]; then
      connected=1
    fi

    # Check if SSID is saved
    saved=0
    if echo "$saved_connections" | grep -Fxq "$ssid"; then
      saved=1
    fi

    # Calculate signal strength index (0 to 4)
    idx=$((signal / 20))
    [ $idx -gt 4 ] && idx=4

    # Choose an icon set based on state:
    if [ $connected -eq 1 ]; then
      icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")
    elif [ $saved -eq 1 ]; then
      icons=("󱛏" "󱛋" "󱛌" "󱛍" "󱛎")
    else
      icons=("󰤬" "󰤡" "󰤤" "󰤧" "󰤪")
    fi
    icon="${icons[$idx]}"

    # Create a line with icon and SSID (tab-separated)
    line="${icon}\t${ssid}"
    if [ $connected -eq 1 ]; then
      wifi_menu_conn+="\t${line}\n"
    else
      if [ $saved -eq 1 ]; then
        wifi_menu_saved+="${line}\n"
      else
        wifi_menu_unsaved+="${line}\n"
      fi
    fi
  done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list)
  # Combine the lists: connected first, then saved, then unsaved
  wifi_menu="${wifi_menu_conn}${wifi_menu_saved}${wifi_menu_unsaved}"
}

# --- Main Loop ---
while true; do
  # Update Ethernet toggle if applicable.
  if [ -n "$eth_interface" ]; then
    eth_state=$(nmcli device status | awk -v iface="$eth_interface" '$1 == iface {print $3}')
    if [ "$eth_state" != "unavailable" ]; then
      if [ "$eth_state" = "connected" ]; then
        eth_toggle="Disable Ethernet"
      else
        eth_toggle="Enable Ethernet"
      fi
    fi
  fi

  # Determine current Wi-Fi state.
  wifi_status=$(nmcli radio wifi)
  if [ "$wifi_status" = "enabled" ]; then
    wifi_toggle="Disable Wi-Fi"
  else
    wifi_toggle="Enable Wi-Fi"
  fi

  # Rebuild the Wi-Fi menu list.
  build_wifi_menu

  # Combine toggles and Wi-Fi networks into the final menu.
  menu_list=""
  [ -n "$eth_toggle" ] && menu_list+="          ${eth_toggle}\n"
  menu_list+="            ${wifi_toggle}\n"
  menu_list+="${wifi_menu}"
  # Remove any empty lines.
  menu_list=$(printf "%b" "$menu_list" | sed '/^[[:space:]]*$/d')

  # Display the menu using rofi.
  chosen=$(printf "%b" "$menu_list" | rofi -theme-str 'configuration { show-icons: false; } window { location: north east; x-offset: -155; y-offset: 2; width: 225px; } listview { columns: 1; lines: 50; } inputbar { enabled: false; } mode-switcher { enabled: false; }' -dmenu -i)

  # If no selection is made, exit.
  [ -z "$chosen" ] && break

  # Process toggle selections.
  if [[ "$chosen" == "          Disable Ethernet" ]]; then
    nmcli device disconnect "$eth_interface"
    break
  elif [[ "$chosen" == "          Enable Ethernet" ]]; then
    nmcli device connect "$eth_interface"
    break
  elif [[ "$chosen" == "            Disable Wi-Fi" ]]; then
    nmcli radio wifi off
    break
  elif [[ "$chosen" == "            Enable Wi-Fi" ]]; then
    nmcli radio wifi on
    notify-send -e --app-name="Network" "Connection Refreshing" "Listing Networks" -t 5000
    sleep 5
    continue
  fi

  # Process Wi-Fi network selection.
  # Assume each network entry is "ICON<TAB>SSID"
  ssid=$(echo "$chosen" | awk -F'\t' '{print $2}')
  if echo "$saved_connections" | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" &&
      notify-send -e --app-name="Network" "Connection Established" "You are now connected to \"$ssid\"."
  else
    # If the network is secured, prompt for a password.
    sec=$(nmcli -t -f SSID,SECURITY device wifi list | grep -F "$ssid" | cut -d: -f2 | head -n1)
    if [ "$sec" != "--" ] && [ -n "$sec" ]; then
      pass=$(rofi -dmenu -theme-str 'window { location: north east; x-offset: -155; y-offset: 2; width: 225px; } listview { enabled: false; } mode-switcher { enabled: false; } element { enabled: false; }' -dmenu -mesg "Password for $ssid:" -password)
      nmcli device wifi connect "$ssid" password "$pass" &&
        notify-send -e --app-name="Network" "Connection Established" "You are now connected to \"$ssid\"."
    else
      nmcli device wifi connect "$ssid" &&
        notify-send -e --app-name="Network" "Connection Established" "You are now connected to \"$ssid\"."
    fi
  fi
  # For network selections and all other cases, exit after processing.
  break
done

exit 0
