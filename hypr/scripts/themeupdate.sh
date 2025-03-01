#!/bin/bash

suppress_output() {
  "$@" >/dev/null 2>&1
}

echo
echo "Choose a GTK theme:"
echo "1) Colloid"
echo "2) Graphite"
read -r -p "Enter your choice (1 or 2, Default: 1): " THEME_CHOICE
[ -z "$THEME_CHOICE" ] && THEME_CHOICE=1

if [ "$THEME_CHOICE" -eq 2 ]; then
  THEME_NAME="Graphite"
  GIT_URL="https://github.com/vinceliuice/Graphite-gtk-theme.git"

  echo
  read -r -p "Specify accent variant [blue|purple|pink|red|orange|yellow|green|teal|grey] (Default: grey): " ACCENT
  [ -z "$ACCENT" ] && ACCENT="default"

  echo
  read -r -p "Specify size variant [standard|compact] (Default: compact): " SIZE
  [ -z "$SIZE" ] && SIZE="compact"

  echo
  read -r -p "Enter colorscheme [black|nord] (Default: black): " COLORSCHEME
  [ -z "$COLORSCHEME" ] && COLORSCHEME="black"

  echo
  read -r -p "Enter tweak(s) for $THEME_NAME [darker|rimless|normal|float|colorful] (Default: rimless normal): " TWEAKS
  [ -z "$TWEAKS" ] && TWEAKS="rimless normal"
else
  THEME_NAME="Colloid"
  GIT_URL="https://github.com/vinceliuice/Colloid-gtk-theme.git"

  echo
  read -r -p "Specify accent variant [blue|purple|pink|red|orange|yellow|green|teal|grey] (Default: grey): " ACCENT
  [ -z "$ACCENT" ] && ACCENT="grey"

  echo
  read -r -p "Specify size variant [standard|compact] (Default: compact): " SIZE
  [ -z "$SIZE" ] && SIZE="compact"

  echo
  read -r -p "Enter colorscheme [black|nord|dracula|gruvbox|everforest|catppuccin] (Default: black): " COLORSCHEME
  [ -z "$COLORSCHEME" ] && COLORSCHEME="black"

  echo
  read -r -p "Enter tweak(s) for $THEME_NAME [rimless|normal|float] (Default: rimless normal): " TWEAKS
  [ -z "$TWEAKS" ] && TWEAKS="rimless normal"
fi

BASE_DIR="/tmp/themeupdate/$THEME_NAME"
THEME_DIR="$HOME/.themes/"

echo
echo "Theme: $THEME_NAME"
echo "Accent: $ACCENT"
echo "Size: $SIZE"
echo "Tweaks: $TWEAKS"
echo "Colorscheme: $COLORSCHEME"

echo
echo "Making base temp directory..."
suppress_output mkdir -p $BASE_DIR

echo
echo "Cleaning up old clone directory..."
suppress_output rm -rf "$BASE_DIR"

echo
echo "Cloning the theme repository..."
if git clone "$GIT_URL" "$BASE_DIR"; then
  echo "Successfully cloned $GIT_URL"
else
  echo "Failed to clone repository. Exiting."
  exit 1
fi

echo
echo "Creating build directory..."
suppress_output mkdir -p "$BASE_DIR/build"

IFS=' ' read -r -a TWEAKS_ARRAY <<<"$TWEAKS"
echo
echo "Installing theme with selected options..."
if suppress_output "$BASE_DIR/install.sh" -d "$BASE_DIR/build" -t "$ACCENT" -s "$SIZE" --tweaks "$COLORSCHEME" --tweaks "${TWEAKS_ARRAY[@]}"; then
  echo "Installation successful."
else
  echo "Installation failed. Exiting."
  exit 1
fi

echo
echo "Renaming theme files..."
cd "$BASE_DIR/build" || exit 1
find . -depth -name "$THEME_NAME*" | while read -r path; do
  new_path=$(dirname "$path")/$(
    basename "$path" | sed -e 's/\(Blue\|Purple\|Pink\|Red\|Orange\|Yellow\|Green\|Teal\|Grey\|Compact\|compact\)-//gI' \
      -e 's/-\(Nord\|Dracula\|Gruvbox\|Everforest\|Catppuccin\|Compact\|compact\)//gI' \
      -e 's/-Dark/-dark/g' \
      -e 's/-Light/-light/g'
  )

  if [ "$path" != "$new_path" ]; then
    mkdir -p "$(dirname "$new_path")"
    suppress_output mv "$path" "$new_path"
    echo "Renamed $path to $new_path"
  fi
done

echo
echo "Cleaning up old theme directories..."
suppress_output rm -rf "${THEME_DIR:?}/${THEME_NAME:?}"*

echo
echo "Copying themes to the themes directory..."
suppress_output cp -r $THEME_NAME* "$THEME_DIR"

if [[ "$(suppress_output gsettings get org.gnome.desktop.interface color-scheme | cut -d "'" -f2 | xargs)" == "prefer-light" ]]; then
  THEME_NAME="$THEME_NAME"-light
  TEMP_THEME="Adwaita"
  THEME_COLOR="prefer-light"

else
  THEME_NAME="$THEME_NAME"-dark
  TEMP_THEME="Adwaita-dark"
  THEME_COLOR="prefer-dark"
fi

echo
echo "Temporarily switching to Adwaita theme to force theme reapplication..."
suppress_output gsettings set org.gnome.desktop.interface gtk-theme "$TEMP_THEME"
suppress_output gsettings set org.gnome.desktop.interface color-scheme "$THEME_COLOR"
sleep 1

if [ -d "$THEME_DIR/$THEME_NAME" ]; then
  echo "Theme directory exists. Proceeding to apply theme."
else
  echo "Theme directory not found. Exiting."
  exit 1
fi

echo
echo "Applying GTK theme..."
suppress_output gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"

echo "Restarting xsettingsd to apply the theme..."
suppress_output killall -q xsettingsd
suppress_output xsettingsd &
disown

echo "Theme installation complete. Exiting."
exit
