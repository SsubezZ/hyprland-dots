#!/usr/bin/env bash

# Configuration
BROWSER=("librewolf" "--new-window")

find_places_db() {
	find "${HOME}/.librewolf" -type f -name 'places.sqlite' -printf '%T@ %p\n' 2>/dev/null |
		sort -nr -k1 |
		awk 'NR==1 {print $2}'
}

copy_to_tmp() {
	local source_file destination_file
	source_file=$(find_places_db)

	[[ -z "$source_file" ]] && {
		echo "Error: No places.sqlite file found" >&2
		return 1
	}
	[[ -r "$source_file" ]] || {
		echo "Error: No read permission" >&2
		return 1
	}

	destination_file="/tmp/places_$(date +%s).sqlite"
	cp -f "$source_file" "$destination_file" || return 1
	echo "$destination_file"
}

get_bookmarks() {
	local profile_db
	profile_db=$(copy_to_tmp) || return 1
	local cleanup=1

	trap '[[ -n $cleanup ]] && rm -f "$profile_db"' EXIT

	local query="WITH RECURSIVE menu_folders AS (
        SELECT id FROM moz_bookmarks WHERE guid = 'menu________' AND type = 2
        UNION ALL
        SELECT b.id FROM moz_bookmarks b
        JOIN menu_folders mf ON b.parent = mf.id
        WHERE b.type = 2
    )
    SELECT DISTINCT
        b.title,
        p.url
    FROM moz_bookmarks b
    JOIN moz_places p ON b.fk = p.id
    WHERE b.type = 1
    AND p.hidden = 0
    AND p.url NOT LIKE 'place:%'
    ORDER BY
        CASE WHEN b.parent IN (SELECT id FROM menu_folders) THEN 0 ELSE 1 END,
        b.lastModified DESC"

	sqlite3 -separator ' | ' "$profile_db" "$query" 2>/dev/null |
		awk -F' \\| ' 'NF == 2 && $1 != "" {print $1 " | " $2}'

	cleanup=0
}

create_entries() {
	local bookmarks
	if ! bookmarks=$(get_bookmarks); then
		echo "Error: Failed to retrieve bookmarks" >&2
		return 1
	fi
	[[ -n "$bookmarks" ]] && echo "$bookmarks"
}

main() {
	local selected url
	selected=$(create_entries | rofi -dmenu -i -mesg "Web Bookmarks" \
		-format 's' -config ~/.config/rofi/theme-mesg.rasi \
		-theme-str 'window {width: 600px;} listview {columns: 1; lines: 10;}')

	[[ -z "$selected" ]] && exit 0

	url=$(echo "$selected" | awk -F' [|] ' '{print $2}' |
		sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

	echo "Opening URL: ${url}"
	"${BROWSER[@]}" "$url" &>/dev/null &
}

main
