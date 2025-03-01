#!/bin/bash

declare -A GTK_THEMES=(["light"]="Colloid-light" ["dark"]="Colloid-dark")
# declare -A GTK_THEMES=(["light"]="Graphite-light" ["dark"]="Graphite-dark")
declare -A ICN_THEMES=(["light"]="Papirus-Light" ["dark"]="Papirus-Dark")
declare -A CUR_THEMES=(["light"]="Graphite-dark-cursors" ["dark"]="Graphite-light-cursors")
CUR_SIZE=24
declare -A ALACRITTY_THEMES=(["light"]="theme-light.toml" ["dark"]="theme-dark.toml")
declare -A ROFI_THEMES=(["light"]="theme-light.rasi" ["dark"]="theme-dark.rasi")
declare -A HYPR_THEMES=(["light"]="theme-light.conf" ["dark"]="theme-dark.conf")
# declare -A YAZI_THEMES=(["light"]="theme-light.toml" ["dark"]="theme-dark.toml")
declare -A SPICETIFY_THEMES=(["light"]="light" ["dark"]="dark")

pre() {
  echo "Cleaning up previous GTK 4.0 configuration..."
  rm -rf ~/.config/gtk-4.0 &>/dev/null
  echo "Killing any running Rofi instances..."
  pkill -x rofi &>/dev/null
  if pgrep -x spotify >/dev/null; then
    echo "Starting Spicetify watch..."
    spicetify watch -s &>/dev/null &
    sleep 1 && pkill -x spicetify &>/dev/null
  fi
}

set_theme() {
  local mode=$1

  echo "Setting theme to $mode mode..."
  settings set org.gnome.desktop.interface color-scheme "default" &>/dev/null
  gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode" &>/dev/null
  gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEMES[$mode]}" &>/dev/null
  gsettings set org.gnome.desktop.interface icon-theme "${ICN_THEMES[$mode]}" &>/dev/null
  gsettings set org.gnome.desktop.interface cursor-theme "${CUR_THEMES[$mode]}" &>/dev/null
  gsettings set org.gnome.desktop.interface cursor-size "$CUR_SIZE" &>/dev/null
  hyprctl setcursor "${CUR_THEMES[$mode]}" "$CUR_SIZE" &>/dev/null

  echo "Updating xsettingsd configuration..."
  sed -i -e "/^Net\/ThemeName/s/\"[^\"]*\"/\"${GTK_THEMES[$mode]}\"/" \
    -e "/^Net\/IconThemeName/s/\"[^\"]*\"/\"${ICN_THEMES[$mode]}\"/" \
    -e "/^Gtk\/CursorThemeName/s/\"[^\"]*\"/\"${CUR_THEMES[$mode]}\"/" \
    ~/.config/xsettingsd/xsettingsd.conf &>/dev/null

  echo "Applying Alacritty theme..."
  sed -i "/^import = \[/s|\(\"[^\"]*theme-[^\"]*\"\)|\"~/.config/alacritty/${ALACRITTY_THEMES[$mode]}\"|" ~/.config/alacritty/alacritty.toml &>/dev/null

  echo "Applying Rofi theme..."
  sed -i "/^@theme .*theme-.*\.rasi/s|@theme \".*\"|@theme \"${ROFI_THEMES[$mode]}\"|" ~/.config/rofi/colorscheme.rasi &>/dev/null
  echo "Applying Hyprland theme..."
  sed -i "/^source = .*theme-.*\.conf/s|source = .*|source = ./themes/${HYPR_THEMES[$mode]}|" ~/.config/hypr/hyprland.conf &>/dev/null

  echo "Applying Spicetify theme..."
  spicetify config color_scheme "${SPICETIFY_THEMES[$mode]}" &>/dev/null
  spicetify apply -n &>/dev/null

  # echo "Applying Yazi theme..."
  # cp "$HOME/.config/yazi/${YAZI_THEMES[$mode]}" ~/.config/yazi/theme.toml &>/dev/null
}

post() {
  echo "Reloading xsettingsd..."
  killall -HUP xsettingsd &>/dev/null
  echo "Reloading Hyprland..."
  hyprctl reload &>/dev/null
  # echo "Reloading Yazi..."
  # yazi --reload &>/dev/null
  hyprpm reload &>/dev/null
  hyprctl dismissnotify &>/dev/null
  if pgrep -x spotify >/dev/null; then
    echo "Restarting Spicetify watch..."
    spicetify watch -s &>/dev/null &
    sleep 1 && pkill -x spicetify &>/dev/null
  fi
}

write_state() {
  local icon="$1"
  local to="$2"
  local state_dir=$HOME/.local/state

  echo "{\"text\": \"${icon}\", \"tooltip\": \"Switch to ${to}\"}" >"${state_dir}/._state_themechange.txt"
}

# Main script logic to handle command line arguments or toggle mode by default
if [[ $# -eq 0 ]]; then
  CURRENT=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")

  if [[ "$CURRENT" == "prefer-dark" ]]; then
    MODE="light"
    write_state "" "Dark"
  elif [[ "$CURRENT" == "prefer-light" ]]; then
    MODE="dark"
    write_state "" "Light"
  else
    MODE="dark"
    write_state "" "Dark"
  fi
else
  MODE=$1

  if [[ ! ${GTK_THEMES[$MODE]} ]]; then
    echo "Invalid argument: $MODE. Please use 'light' or 'dark'."
    exit 1
  fi
fi

pre
set_theme "$MODE"
post

exit 0
