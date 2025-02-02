#!/usr/bin/env sh

HYPRGAMEMODE=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ]; then
	hyprctl keyword misc:disable_autoreload 1
	pkill hyprpaper
	hyprctl --batch "\
    # keyword animations:enabled 0;\
    keyword windowrulev2 forcergbx, class:.*;\
    keyword windowrulev2 opaque, class:.*;\
    keyword decoration:shadow:enabled 0;\
    # keyword decoration:rounding 0;\
    keyword decoration:blur:enabled 0"
	swayosd-client --custom-message " Gamemode Enabled " || notify-send --app-name "Gamemode" "Gamemode Enabled" "Decorations Disabled" -e -h string:x-canonical-private-synchronous:gamemode
	# hyprpm enable csgo-vulkan-fix
	exit
fi

hyprpaper &
hyprctl reload
swayosd-client --custom-message " Gamemode Disabled " || notify-send --app-name "Gamemode" "Gamemode Disabled" "Decorations Enabled" -e -h string:x-canonical-private-synchronous:gamemode
# hyprpm disable csgo-vulkan-fix
hyprctl dismissnotify
sleep 0.5
exit
