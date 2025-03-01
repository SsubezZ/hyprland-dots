#!/usr/bin/env bash

sleep 0.25

if [ -z "$XDG_PICTURES_DIR" ]; then
  XDG_PICTURES_DIR="$HOME/Pictures"
fi

save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date '+%F_%T_%3N')
full_path="$save_dir/$save_file"
mkdir -p "$save_dir"

function print_error {
  cat <<"EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        area     : snip selected area
        active   : snip active window
        screen   : snip current screen
        screens  : snip all screens
EOF
}

case "${1,,}" in
area) grimblast --freeze copysave area "$full_path" ;;
active) grimblast --freeze copysave active "$full_path" ;;
screen) grimblast copysave output "$full_path" ;;
screens) grimblast copysave screen "$full_path" ;;
*)
  print_error
  exit 1
  ;;
esac

if [ -f "$full_path" ]; then
  editor="${SCREENSHOT_EDITOR:-swappy}"
  ACTION=$(notify-send -a "Screenshot" -i "$full_path" "Screenshot saved" "$full_path" \
    -A "view=View" -A "edit=Edit" -A "open=Open Folder" -A "delete=Delete")

  case "$ACTION" in
  view) xdg-open "$full_path" ;;
  edit) "$editor" -f "$full_path" ;;
  open) xdg-open "$save_dir" ;;
  delete) rm "$full_path" ;;
  esac
else
  exit 1
fi
