#!/usr/bin/env bash
IFS=$'\n'

sink_list=$(pactl list sinks)

ports_info=$(echo "$sink_list" | grep "output" | grep "type" | awk '{id=$1; sub(":", "", id); print id, $2}')

active=$(echo "$sink_list" | grep "Active Port:" | awk '{print $3}' | head -n 1)

active_desc=$(echo "$ports_info" | awk -v id="$active" '$1 == id {print $2}')

inactive=$(echo "$ports_info" | awk -v active="$active_desc" '$2 != active {print $2}')

if [ "$#" -gt 0 ]; then
    desc="$*"
    clean_desc=$(echo "$desc" | sed 's/<[^>]*>//g')
    device=$(echo "$ports_info" | grep "$clean_desc" | awk '{print $1}' | head -n 1 | xargs)
    pactl set-sink-port 0 "$device"
else
    echo -en "\x00prompt\x1fOutput Port\n"
    echo -en "\x00markup-rows\x1ftrue\n"
    if [ -z "$active_desc" ]; then
        for port in $(echo "$ports_info" | awk '{print $2}'); do
            echo "$port"
        done
    elif [ -z "$inactive" ]; then
        echo "$active_desc"
    else
        for port in $inactive; do
            echo "$port"
        done
        echo "<b><u>$active_desc</u></b>"
    fi
fi
