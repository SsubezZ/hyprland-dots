#!/usr/bin/env bash
IFS=$'\n'

if [ "$@" ]; then
	desc="$*"
	device=$(pactl list sources | grep -C2 -F "Description: $desc" | grep Name | cut -d: -f2 | xargs)
	if pactl set-default-source "$device"; then
		notify-send -a "Audio" "Audio Sink" "Activated: $desc" -e
	else
		notify-send -a "Audio" "Audio Sink" "Error activating $desc" -e
	fi
else
	echo -en "\x00prompt\x1fSource\n"
	for x in $(pactl list sources | grep -ie "description:" | cut -d: -f2 | sort); do
		echo "$x" | xargs
	done
fi
