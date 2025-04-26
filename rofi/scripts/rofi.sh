#!/usr/bin/env bash

STATEFILE="/tmp/rofi_cmd.txt"

CMD="$@"
if [ -z "$CMD" ]; then
	echo "Usage: $0 <rofi command>"
	exit 1
fi

# Check if any rofi process is running (using an exact match).
if pgrep -x rofi >/dev/null; then
	# Read the last stored command (if any).
	if [ -f "$STATEFILE" ]; then
		last_cmd=$(cat "$STATEFILE")
	else
		last_cmd=""
	fi

	# Kill all running rofi processes.
	pkill -x rofi
	# Give rofi a moment to exit.
	sleep 0.1

	if [ "$CMD" = "$last_cmd" ]; then
		# If the new command is identical to the last one, ust clear the state and exit (toggle off).
		rm -f "$STATEFILE"
		exit 0
	else
		# Otherwise, update the state file with the new command...
		echo "$CMD" >"$STATEFILE"
		# ...and launch the new command.
		eval "$CMD"
		exit 0
	fi
else
	# No rofi is running. Store the command and launch it.
	echo "$CMD" >"$STATEFILE"
	eval "$CMD"
	exit 0
fi
