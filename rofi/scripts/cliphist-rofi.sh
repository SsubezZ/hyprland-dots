#!/usr/bin/env bash

TMP_DIR="/tmp/cliphist"
SELECTION=$(mkdir -p "$TMP_DIR" && rm -rf "${TMP_DIR:?}"/* &&
	cliphist list | awk -v tmp_dir="$TMP_DIR" '
    # Skip HTML meta entries
    /^[0-9]+\t<meta http-equiv=/ { next }

    # Handle image entries
    match($0, /^([0-9]+)\t(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
        id = grp[1]
        ext = grp[3]
        cmd = "cliphist decode " id " > " tmp_dir "/" id "." ext " 2>/dev/null"
        system(cmd)
        print id "\tImage (" ext ")\0icon\x1f" tmp_dir "/" id "." ext
        next
    }

    # Handle text entries
    {
        split($0, parts, "\t")
        print parts[1] "\t" substr($0, index($0, "\t") + 1)
    }
' | rofi -dmenu -show-icons -display-columns 2 -mesg "Clipboard" -config ~/.config/rofi/theme-mesg.rasi -theme-str 'window {width: 600px;} listview {columns: 1;}' | cut -f1)

if [ -n "$SELECTION" ]; then
	cliphist decode "$SELECTION" | wl-copy
fi
