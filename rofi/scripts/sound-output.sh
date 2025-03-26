#!/usr/bin/env bash
IFS=$'\n'

if [ "$@" ]; then
	desc="$*"
	device=$(pactl list sinks | grep -C2 -F "Description: $desc" | grep Name | cut -d: -f2 | xargs)
	if pactl set-default-sink "$device"; then
		notify-send -a "Audio" "Audio Source" "Activated: $desc" -e
	else
		notify-send -a "Audio" "Audio Source" "Error activating $desc" -e
	fi
else
	echo -en "\x00prompt\x1fSink\n"
	for x in $(pactl list sinks | grep -ie "description:" | cut -d: -f2 | sort); do
		echo "$x" | xargs
	done
fi
