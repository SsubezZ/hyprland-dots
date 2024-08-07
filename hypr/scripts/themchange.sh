#!/usr/bin/env sh

CURRENT=$(gsettings get org.gnome.desktop.interface color-scheme | cut -d "'" -f2 | xargs)
LIGHT="Colloid-Light"
DARK="Colloid-Dark"
if [ "$CURRENT" = "prefer-dark" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-light
  gsettings set org.gnome.desktop.interface gtk-theme $LIGHT
  gsettings set org.gnome.desktop.interface icon-theme Papirus-Light
  # rm $HOME/.config/gtk-4.0
  # ln -s /home/subez/.themes/Graphite/gtk-4.0 /home/subez/.config/gtk-4.0
  sed -i "s/dark/light/" ~/.config/alacritty/alacritty.toml
  sed -i "s/$DARK/$LIGHT/" ~/.config/xsettingsd/xsettingsd.conf
  hyprctl --batch "\
    keyword windowrulev2 opacity 1 override 1 override 1 override class:(.*);\
    keyword general:col.active_border rgb(0F0F0F);\
    keyword general:col.inactive_border rgb(D0D0D0)"
  notify-send --app-name "Theme" "Theme Changed" "Switched to Light" -e -h string:x-canonical-private-synchronous:themechange
else
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme $DARK
  gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
  # rm $HOME/.config/gtk-4.0
  # ln -s /home/subez/.themes/Graphite-dark/gtk-4.0 /home/subez/.config/gtk-4.0
  sed -i "s/light/dark/" ~/.config/alacritty/alacritty.toml
  sed -i "s/$LIGHT/$DARK/" ~/.config/xsettingsd/xsettingsd.conf
  hyprctl reload
  notify-send --app-name "Theme" "Theme Changed" "Switched to Dark" -e -h string:x-canonical-private-synchronous:themechange
fi

killall -HUP xsettingsd

exit
