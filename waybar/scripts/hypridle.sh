#!/usr/bin/env bash
set -euo pipefail

PROCESS="hypridle"

notify() {
  local msg="$1"
  swayosd-client --custom-message "$msg" --custom-icon "video-display" ||
    notify-send --app-name "Hypridle" "$msg" -e \
      -h string:x-canonical-private-synchronous:hypridle
}

is_running() {
  pgrep -x "$PROCESS" >/dev/null 2>&1
}

if [[ "${1-}" == "toggle" ]]; then
  if is_running; then
    pkill -x "$PROCESS"
    notify "Idle Inhibited"
  else
    "$PROCESS" >/dev/null 2>&1 &
    disown
    notify "Not Idle Inhibited"
  fi
  pkill -SIGRTMIN+10 waybar 2>/dev/null || true
  exit 0
fi

if is_running; then
  STATE="running"
  ICON="󰾪"
  TOOLTIP="Not Idle Inhibited"
else
  STATE="stopped"
  ICON="󰅶"
  TOOLTIP="Idle Inhibited"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$ICON" "$TOOLTIP" "$STATE"
