 !/bin/sh

DEVICE=$(pactl get-default-sink)
ACTIVE_SINK=$(pactl list sinks | grep 'Active Port' | awk '{print $3}')

if [ "$ACTIVE_SINK" = "analog-output-headphones" ]; then
	echo "[*] Enabling speakers on $DEVICE."
  pactl set-sink-port 0 analog-output-speaker > /dev/null
else
	echo "[*] Enabling headphones on $DEVICE."
  pactl set-sink-port 0 analog-output-headphones > /dev/null
fi

exit 0
