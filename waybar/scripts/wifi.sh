#!/usr/bin/env bash

# Find the Ethernet interface (if available)
eth_interface=$(nmcli device status | awk '$2 == "ethernet" {print $1; exit}')

build_wifi_menu() {
	wifi_menu_conn=""
	wifi_menu_saved=""
	wifi_menu_unsaved=""

	nmcli device wifi rescan >/dev/null 2>&1

	# Get fresh list of saved connections
	saved_connections=$(nmcli -g NAME connection)

	# Process available networks
	while IFS=: read -r in_use ssid signal security; do
		[ -z "$ssid" ] && continue

		connected=0
		[ "$in_use" = "*" ] && connected=1

		saved=0
		echo "$saved_connections" | grep -Fxq "$ssid" && saved=1

		idx=$((signal / 20))
		[ $idx -gt 4 ] && idx=4

		if [ $connected -eq 1 ]; then
			icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")
		elif [ $saved -eq 1 ]; then
			icons=("󱛏" "󱛋" "󱛌" "󱛍" "󱛎")
		else
			icons=("󰤬" "󰤡" "󰤤" "󰤧" "󰤪")
		fi

		line="${icons[$idx]}\t${ssid}"
		if [ $connected -eq 1 ]; then
			wifi_menu_conn+="\t${line}\n"
		else
			[ $saved -eq 1 ] && wifi_menu_saved+="${line}\n" || wifi_menu_unsaved+="${line}\n"
		fi
	done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list)

	wifi_menu="${wifi_menu_conn}${wifi_menu_saved}${wifi_menu_unsaved}"
}

# --- Main Loop ---
while true; do
	[ -n "$eth_interface" ] && eth_state=$(nmcli device status | awk -v iface="$eth_interface" '$1 == iface {print $3}')
	wifi_status=$(nmcli radio wifi)

	# Build menu
	build_wifi_menu
	menu_list=""
	[ -n "$eth_interface" ] && [ "$eth_state" != "unavailable" ] && {
		[ "$eth_state" = "connected" ] && menu_list+="          Disable Ethernet\n" || menu_list+="          Enable Ethernet\n"
	}
	menu_list+="            $([ "$wifi_status" = "enabled" ] && echo "Disable Wi-Fi" || echo "Enable Wi-Fi")\n"
	menu_list+="${wifi_menu}"
	menu_list=$(printf "%b" "$menu_list" | sed '/^[[:space:]]*$/d')

	# Show ROFI menu
	chosen=$(printf "%b" "$menu_list" | rofi -theme-str 'configuration { show-icons: false; } window { location: north east; x-offset: -155; y-offset: 2; width: 225px; } listview { columns: 1; lines: 25; } inputbar { enabled: false; } mode-switcher { enabled: false; }' -dmenu -i)
	[ -z "$chosen" ] && break

	# Handle toggle selections
	case "$chosen" in
	"          Disable Ethernet")
		nmcli device disconnect "$eth_interface"
		break
		;;
	"          Enable Ethernet")
		nmcli device connect "$eth_interface"
		break
		;;
	"            Disable Wi-Fi")
		nmcli radio wifi off
		break
		;;
	"            Enable Wi-Fi")
		nmcli radio wifi on
		notify-send -e --app-name="Network" "Connection Refreshing" "Listing Networks" -t 5000
		sleep 5
		continue
		;;
	*)
		# Extract SSID based on connection status
		if [[ "$chosen" == *""* ]]; then
			ssid=$(echo "$chosen" | awk -F'\t' '{print $3}')
		else
			ssid=$(echo "$chosen" | awk -F'\t' '{print $2}')
		fi

		saved_connections=$(nmcli -g NAME connection)

		if echo "$saved_connections" | grep -Fxq "$ssid"; then
			nmcli connection up id "$ssid" && notify-send -e --app-name="Network" "Connection Established" "Connected to \"$ssid\"." && break
			notify-send -e --app-name="Network" "Connectio Failed" "Failed to connect to \"$ssid\"."
			break
		else
			sec=$(nmcli -t -f SSID,SECURITY device wifi list | grep -F "$ssid" | cut -d: -f2 | head -n1)
			if [ "$sec" != "--" ] && [ -n "$sec" ]; then
				while :; do
					pass=$(rofi -dmenu -theme-str 'window { location: north east; x-offset: -155; y-offset: 2; width: 225px; } listview { enabled: false; } mode-switcher { enabled: false; } element { enabled: false; }' -dmenu -mesg "Password for $ssid:" -password)
					[ -z "$pass" ] && break # User pressed escape

					if nmcli device wifi connect "$ssid" password "$pass"; then
						notify-send -e --app-name="Network" "Connection Established" "Connected to \"$ssid\"."
						exit 0
					else
						notify-send -e --app-name="Network" "Connection Failed" "Incorrect password for \"$ssid\"."
						nmcli connection delete "$ssid" >/dev/null 2>&1
					fi
				done
			else
				if nmcli device wifi connect "$ssid"; then
					notify-send -e --app-name="Network" "Connection Established" "Connected to \"$ssid\"."
					exit 0
				else
					notify-send -e --app-name="Network" "Connection Failed" "Failed to connect to \"$ssid\"."
					nmcli connection delete "$ssid" >/dev/null 2>&1
					exit 0
				fi
			fi
		fi
		;;
	esac
done

exit 0
