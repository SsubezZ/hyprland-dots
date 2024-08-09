#!/usr/bin/env sh

CURRENT=$(gsettings get org.gnome.desktop.interface color-scheme | cut -d "'" -f2 | xargs)
GTK_LIGHT="Colloid-Light"
GTK_DARK="Colloid-Dark"
# GTK_LIGHT="Graphite-Light"
# GTK_DARK="Graphite-Dark"

pkill rofi

if [ "$CURRENT" = "prefer-dark" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-light
  gsettings set org.gnome.desktop.interface gtk-theme $GTK_LIGHT
  gsettings set org.gnome.desktop.interface icon-theme Papirus-Light
  sed -i "s/dark/light/" ~/.config/alacritty/alacritty.toml
  sed -i "1s/[^ ]*[^ ]/\"$GTK_LIGHT\"/2" ~/.config/xsettingsd/xsettingsd.conf
  sed -i "s/dark/light/" ~/.config/rofi/theme.rasi ~/.config/rofi/scripts/rofi-polkit-agent.rasi
  hyprctl --batch "\
    keyword windowrulev2 opacity 1 override 1 override 1 override class:(.*);\
    keyword general:col.active_border rgb(0F0F0F);\
    keyword general:col.inactive_border rgb(D0D0D0)"
  notify-send --app-name "Theme" "Theme Changed" "Switched to Light" -e -h string:x-canonical-private-synchronous:themechange
else
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme $GTK_DARK
  gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
  sed -i "s/light/dark/" ~/.config/alacritty/alacritty.toml
  sed -i "1s/[^ ]*[^ ]/\"$GTK_DARK\"/2" ~/.config/xsettingsd/xsettingsd.conf
  sed -i "s/light/dark/" ~/.config/rofi/theme.rasi ~/.config/rofi/scripts/rofi-polkit-agent.rasi
  hyprctl reload
  notify-send --app-name "Theme" "Theme Changed" "Switched to Dark" -e -h string:x-canonical-private-synchronous:themechange
fi

killall -HUP xsettingsd

exit
