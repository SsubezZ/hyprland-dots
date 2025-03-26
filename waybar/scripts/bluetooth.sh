#!/usr/bin/env bash

goback="Back"

_notify() { notify-send "$@"; }

# Checks if bluetooth controller is powered on
is_bt_on() { bluetoothctl show | grep -q "Powered: yes"; }

# returns a list of all bluetooth devices in a form of 'name' ⇨ 'mac'
get_devices() {
	bluetoothctl devices | awk '{
    mac = $2
    name = substr($0, index($0,$3))
    printf "%s <span alpha=\"50%\">⇨ %s</span>\n", name, mac
  }'
}

toggle_power() {
	if is_bt_on; then
		bluetoothctl power off
	else
		rfkill list bluetooth | grep -q 'blocked: yes' &&
			rfkill unblock bluetooth && sleep 3
		bluetoothctl power on
	fi
	show_menu
}

restart_bt() {
	_notify "Restarting bluetooth"
	bluetoothctl power off
	bluetoothctl power on
	show_menu
}

# Toggles scanning state
enable_scan() {
	_notify -t 5000 -e "Scanning for pairable bluetooth devices..."

	coproc ubt { bluetoothctl; } # echo "$ubt_PID"
	_bt() { echo -e "$@" >&"${ubt[1]}"; }
	_bt agent on

	_bt scan on
	sleep 3
	_bt exit

	show_menu
}

pairable() {
	if bluetoothctl show | grep -q "Pairable: yes"; then
		echo "Pairable: on" && return 0
	else
		echo "Pairable: off" && return 1
	fi
}

toggle_pairable() {
	if pairable; then
		bluetoothctl pairable off
	else
		bluetoothctl pairable on
	fi
	show_menu
}

discoverable() {
	if bluetoothctl show | grep -q "Discoverable: yes"; then
		echo "Discoverable: on" && return 0
	else
		echo "Discoverable: off" && return 1
	fi
}

toggle_discoverable() {
	if discoverable; then
		bluetoothctl discoverable off
	else
		bluetoothctl discoverable on
	fi
	show_menu
}

is_connected() {
	mac="$1"
	if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
		echo "Connected: yes" && return 0
	else
		echo "Connected: no" && return 1
	fi
}

toggle_connection() {
	mac="$1"
	if is_connected "$mac"; then
		bluetoothctl disconnect "$mac"
	else
		bluetoothctl connect "$mac"
	fi
}

is_paired() {
	mac="$1"
	if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
		echo "Paired: yes" && return 0
	else
		echo "Paired: no" && return 1
	fi
}

toggle_paired() {
	mac="$1"
	if is_paired "$mac"; then
		bluetoothctl remove "$mac"
	else
		# connect because some devices like to disconnect after pairing
		bluetoothctl pair "$mac" && bluetoothctl connect "$mac"
	fi
}

device_trusted() {
	mac="$1"
	if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
		echo "Trusted: yes" && return 0
	else
		echo "Trusted: no" && return 1
	fi
}

toggle_trust() {
	mac="$1"
	if device_trusted "$mac"; then
		bluetoothctl untrust "$mac"
	else
		bluetoothctl trust "$mac"
	fi
}

get_mac() { expr "$1" : '.*⇨ \([0-9A-F:]*\)'; }

# checks that passed line contains mac address of a bluetooth device
is_device() { echo "$1" | grep -qP '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}'; }

# A submenu for a specific device that allows connecting, pairing, and trusting
device_menu() { # receives user chosen line as is with no changes
	local device_info="$1"
	local mac
	mac="$(get_mac "$1")"

	local -a options

	options=("$device_info")
	if is_paired "$mac"; then
		connected="$(is_connected "$mac")"
		options+=("$connected")
	fi
	paired="$(is_paired "$mac")"
	trusted=$(device_trusted "$mac")
	options+=("$paired" "$trusted" "$goback")

	option=$(printf '%s\n' "${options[@]}" | _rofi -selected-row 1)
	rofi_exit="$?"
	[ "$rofi_exit" -eq 1 ] && exit

	case "$option" in
	"") echo "No option chosen." ;;
	"$connected") toggle_connection "$mac" ;;
	"$paired") toggle_paired "$mac" ;;
	"$trusted") toggle_trust "$mac" ;;
	"$goback") show_menu ;;
	esac
}

show_menu() {
	local -a options

	if is_bt_on; then
		local power="Power: on"

		local scan="Scan for devices"
		local pairable
		pairable=$(pairable)
		local discoverable
		discoverable=$(discoverable)
		local -a devices
		options=("$power" "$scan" "$pairable" "$discoverable")

		# Human-readable names of devices, one per line
		# If scan is off, will only list paired devices
		devices=$(get_devices)

		# check needed otherwise empty newline will be appended
		[ -n "$devices" ] && options+=("$devices")
	else
		local power="Power: off"
		options=("$power")
	fi

	local option
	option=$(printf '%s\n' "${options[@]}" | _rofi)
	[ "$?" -eq 1 ] && exit

	case "$option" in
	"$power") toggle_power ;;
	"$scan") enable_scan ;;
	"$discoverable") toggle_discoverable ;;
	"$pairable") toggle_pairable ;;
	*) is_device "$option" && device_menu "$option" ;;
	esac
}

# Rofi command to pipe into, can add any options here
_rofi() { rofi -dmenu -theme-str 'configuration {show-icons: false;} window {location: north east; x-offset: -236; y-offset: 2; width: 275px;} listview {columns: 1;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} inputbar {enabled: false;} mode-switcher {enabled: false;}' -markup-rows -i "$@"; }

show_menu
