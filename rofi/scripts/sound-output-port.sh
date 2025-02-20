#!/usr/bin/env bash
IFS=$'\n'

if [ "$@" ]; then
	desc="$*"
	device=$(pactl list sinks | grep "$desc" | grep "output" | grep "type" | awk '{print $1}' | cut -d ":" -f1 | xargs)
	pactl set-sink-port 0 "$device"
else
	echo -en "\x00prompt\x1fOutput Port\n"
	for x in $(pactl list sinks | grep "output" | grep "type" | awk '{print $2}'); do
		echo "$x" | xargs
	done
fi
