#!/usr/bin/env bash

suppress_output() {
  "$@" >/dev/null 2>&1
}

check_updates() {
  echo -e "\nChecking for updates..."

  if [ ! -d "${BASE_DIR}" ]; then
    echo "No existing repository found. Proceeding with installation."
    return 0
  fi

  if [ ! -d "${BASE_DIR}/.git" ]; then
    echo "Existing directory is not a git repository. Re-cloning."
    return 0
  fi

  if ! suppress_output git -C "${BASE_DIR}" diff-index --quiet HEAD --; then
    echo "Local modifications detected. Re-cloning to ensure clean state."
    return 0
  fi

  suppress_output git -C "${BASE_DIR}" fetch
  LOCAL=$(git -C "${BASE_DIR}" rev-parse @)
  REMOTE=$(git -C "${BASE_DIR}" rev-parse @{u})
  BASE=$(git -C "${BASE_DIR}" merge-base @ @{u})

  if [ "$LOCAL" = "$REMOTE" ]; then
    echo "${THEME_NAME} is up to date."
    return 1
  elif [ "$LOCAL" = "$BASE" ]; then
    echo "${THEME_NAME} has updates."
    return 0
  else
    echo "Repository state diverged from remote. Re-cloning."
    return 0
  fi
}

get_theme_options() {
  echo
  read -r -p "Specify accent variant [blue|purple|pink|red|orange|yellow|green|teal|grey] (Default: grey): " ACCENT
  [ -z "$ACCENT" ] && ACCENT="grey"

  echo
  read -r -p "Specify size variant [standard|compact] (Default: compact): " SIZE
  [ -z "$SIZE" ] && SIZE="compact"

  echo
  read -r -p "Enter colorscheme [${COLORSCHEME_OPTIONS}] (Default: black): " COLORSCHEME
  [ -z "$COLORSCHEME" ] && COLORSCHEME="black"

  echo
  read -r -p "Enter tweak(s) for $THEME_NAME [${TWEAKS_OPTIONS}] (Default: rimless normal): " TWEAKS
  [ -z "$TWEAKS" ] && TWEAKS="rimless normal"
}

install_theme() {
  echo -e "\nMaking base theme directory..."
  mkdir -p "$BASE_DIR"

  echo -e "\nCleaning up old clone directory..."
  rm -rf "$BASE_DIR"

  echo -e "\nCloning theme repository..."
  if ! git clone "$GIT_URL" "$BASE_DIR"; then
    echo "Failed to clone repository. Exiting."
    exit 1
  fi

  echo -e "\nCreating build directory..."
  mkdir -p "${BASE_DIR}/build"

  IFS=' ' read -r -a TWEAKS_ARRAY <<<"$TWEAKS"
  echo -e "\nInstalling theme with selected options..."
  if ! suppress_output "$BASE_DIR/install.sh" -d "${BASE_DIR}/build" -t "$ACCENT" -s "$SIZE" --tweaks "$COLORSCHEME" --tweaks "${TWEAKS_ARRAY[@]}"; then
    echo "Installation failed. Exiting."
    exit 1
  fi

  echo -e "\nRenaming theme files..."
  cd "${BASE_DIR}/build" || exit 1
  find . -depth -name "${THEME_NAME}*" | while read -r path; do
    new_path=$(dirname "$path")/$(basename "$path" | sed \
      -e 's/\(Blue\|Purple\|Pink\|Red\|Orange\|Yellow\|Green\|Teal\|Grey\|Compact\|compact\)-//gI' \
      -e 's/-\(Nord\|Dracula\|Gruvbox\|Everforest\|Catppuccin\|Compact\|compact\)//gI' \
      -e 's/-Dark/-dark/g' \
      -e 's/-Light/-light/g')

    [ "$path" != "$new_path" ] && mv "$path" "$new_path"
  done

  echo -e "\nCleaning up old theme directories..."
  rm -rf "${THEME_DIR:?}/${THEME_NAME:?}"*

  echo -e "\nCopying themes to themes directory..."
  cp -r ${THEME_NAME}* "$THEME_DIR"
}

apply_theme() {
  CURRENT_COLOR=$(gsettings get org.gnome.desktop.interface color-scheme | cut -d "'" -f2 | xargs)

  if [[ "$CURRENT_COLOR" == "prefer-light" ]]; then
    NEW_THEME="${THEME_NAME}-light"
    TEMP_THEME="Adwaita"
    TEMP_COLOR="prefer-light"
  else
    NEW_THEME="${THEME_NAME}-dark"
    TEMP_THEME="Adwaita-dark"
    TEMP_COLOR="prefer-dark"
  fi

  if [ ! -d "${THEME_DIR}/${NEW_THEME}" ]; then
    echo "Theme directory not found: ${THEME_DIR}/${NEW_THEME}"
    exit 1
  fi

  echo -e "\nTemporarily switching to Adwaita theme to force theme reapplication..."
  suppress_output gsettings set org.gnome.desktop.interface gtk-theme "$TEMP_THEME"
  suppress_output gsettings set org.gnome.desktop.interface color-scheme "$TEMP_COLOR"
  sleep 1

  echo -e "\nApplying GTK theme: $NEW_THEME"
  suppress_output gsettings set org.gnome.desktop.interface gtk-theme "$NEW_THEME"
  suppress_output gsettings set org.gnome.desktop.interface color-scheme "$CURRENT_COLOR"

  echo -e "\nRestarting xsettingsd to apply theme..."
  suppress_output killall -q xsettingsd
  suppress_output xsettingsd &
  disown
}

THEME_DIR="${HOME}/.themes"

echo -e "\nChoose a GTK theme:"
echo "1) Colloid"
echo "2) Graphite"
read -r -p "Enter choice (1 or 2, Default: 1): " THEME_CHOICE
[ -z "$THEME_CHOICE" ] && THEME_CHOICE=1

if [ "$THEME_CHOICE" -eq 1 ]; then
  THEME_NAME="Colloid"
  GIT_URL="https://github.com/vinceliuice/Colloid-gtk-theme.git"
  COLORSCHEME_OPTIONS="black|nord|dracula|gruvbox|everforest|catppuccin"
  TWEAKS_OPTIONS="rimless|normal|float"
else
  THEME_NAME="Graphite"
  GIT_URL="https://github.com/vinceliuice/Graphite-gtk-theme.git"
  COLORSCHEME_OPTIONS="black|nord"
  TWEAKS_OPTIONS="darker|rimless|normal|float|colorful"
fi

BASE_DIR="${HOME}/Programs/themeupdate/${THEME_NAME}"

if check_updates; then
  get_theme_options

  echo -e "\nTheme: $THEME_NAME"
  echo "Accent: $ACCENT"
  echo "Size: $SIZE"
  echo "Tweaks: $TWEAKS"
  echo "Colorscheme: $COLORSCHEME"

  install_theme
fi

apply_theme
echo -e "\nTheme installation complete."
exit 0
