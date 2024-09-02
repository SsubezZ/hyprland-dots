#!/usr/bin/env sh

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if [ "$HYPRGAMEMODE" = 1 ]; then
  pkill hyprpaper
  hyprctl --batch "\
    keyword animations:enabled 0;\
    keyword decoration:drop_shadow 0;\
    keyword decoration:blur:enabled 0;\
    # keyword general:gaps_in 0;\
    # keyword general:gaps_out 0;\
    # keyword general:border_size 1;\
    # keyword decoration:rounding 0"
  notify-send --app-name "Gamemode" "Gamemode Enabled" "Decorations Diasabled" -e -h string:x-canonical-private-synchronous:gamemode
else
  hyprpaper &
  hyprctl reload
  notify-send --app-name "Gamemode" "Gamemode Disabled" "Decorations Enabled" -e -h string:x-canonical-private-synchronous:gamemode
fi

exit
