#!/usr/bin/env bash
IFS=$'\n'

source_list=$(pactl list sources)

ports_info=$(echo "$source_list" | grep "input" | grep "type" | awk '{id=$1; sub(":", "", id); print id, $2}')

active=$(echo "$source_list" | grep "Active Port:" | awk '{print $3}' | head -n 1)

active_desc=$(echo "$ports_info" | awk -v id="$active" '$1 == id {print $2}')

inactive=$(echo "$ports_info" | awk -v active="$active_desc" '$2 != active {print $2}')

if [ "$#" -gt 0 ]; then
	desc="$*"
	device=$(echo "$ports_info" | grep "$desc" | awk '{print $1}' | head -n 1 | xargs)
	pactl set-source-port 0 "$device"
else
	echo -en "\x00prompt\x1fInput Port\n"
	for port in $inactive; do
		echo "$port"
	done
	echo "$active_desc"
fi
