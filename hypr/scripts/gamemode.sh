#!/usr/bin/env bash

write_state() {
  local icon="$1"
  local tt="$2"
  local state_dir=$HOME/.local/state
  echo "{\"text\": \"${icon}\", \"tooltip\": \"${tt}\"}" >"${state_dir}/._state_gamemode.txt"
}

enable_gamemode() {
  hyprctl keyword misc:disable_autoreload 1
  power-daemon-mgr -q set-profile-override Performance++
  pkill hyprpaper
  hyprctl --batch "\
    #keyword animations:enabled 0;\
    keyword windowrulev2 forcergbx, class:.*;\
    keyword windowrulev2 opaque, class:.*;\
    keyword decoration:shadow:enabled 0;\
    #keyword decoration:rounding 0;\
    keyword decoration:blur:enabled 0"
  write_state "󰖺" "Gamemode ON"
  sleep 0.5
}

disable_gamemode() {
  hyprctl reload
  hyprctl dismissnotify
  power-daemon-mgr -q reset-profile-override
  hyprpaper &
  write_state "󰖻" "Gamemode OFF"
  sleep 0.5
}

HYPRGAMEMODE=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')
CURRENT_STATE="off"
[ "$HYPRGAMEMODE" = "0" ] && CURRENT_STATE="on"

ACTION="toggle"
if [ $# -ge 1 ]; then
  case "$1" in
  on | off) ACTION="$1" ;;
  *)
    echo "Usage: $0 [on|off]" >&2
    exit 1
    ;;
  esac
fi

case $ACTION in
on)
  [ "$CURRENT_STATE" = "off" ] && enable_gamemode
  ;;
off)
  [ "$CURRENT_STATE" = "on" ] && disable_gamemode
  ;;
toggle)
  if [ "$CURRENT_STATE" = "on" ]; then
    disable_gamemode
  else
    enable_gamemode
  fi
  ;;
esac

exit 0
