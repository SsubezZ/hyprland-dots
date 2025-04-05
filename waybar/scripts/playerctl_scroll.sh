#!/usr/bin/env bash

get_metadata() {
	playerctl -i firefox -a metadata --format '{"title":"{{title}}","artist":"{{artist}}","status":"{{status}}"}'
}

check_players() {
	# Check if any players are running, excluding 'firefox'
	playerctl -l 2>/dev/null | grep -q -v firefox
}

max_length=16
scroll_speed=2
scroll_interval=0.25
front_separator=""
back_separator="  "
last_metadata=""
current_metadata=""
scroll_title=""
scroll_position=0
last_output_text=""

pad_title() {
	local title="$1"
	if [[ ${#title} -lt $max_length ]]; then
		local total_padding=$((max_length - ${#title}))
		local left_padding=$((total_padding / 2))
		local right_padding=$((total_padding - left_padding))
		printf "%${left_padding}s%s%${right_padding}s" "" "$title" ""
	else
		echo "${title:0:max_length}"
	fi
}

wrap_title() {
	local title="$1"
	if [[ ${#title} -gt $max_length ]]; then
		echo "$front_separator$title$back_separator"
	else
		echo "$title"
	fi
}

escape_markup() {
	local text="$1"
	echo "${text//&/&amp;}"
}

while true; do
	if ! check_players; then
		echo '{"text": "", "tooltip": "", "class": ""}'
		sleep $scroll_interval
		continue
	fi

	current_metadata=$(get_metadata)

	# If metadata retrieval fails (e.g., no current track), skip printing.
	if [[ -z "$current_metadata" ]]; then
		sleep $scroll_interval
		continue
	fi

	# Process metadata only if it has changed.
	if [[ "$current_metadata" != "$last_metadata" ]]; then
		last_metadata="$current_metadata"
		title=$(echo "$current_metadata" | jq -r '.title')
		artist=$(echo "$current_metadata" | jq -r '.artist')
		status=$(echo "$current_metadata" | jq -r '.status')
		scroll_title=$(wrap_title "$title")
		scroll_position=0
		last_output_text=""
	fi

	if [[ "$status" == "Paused" ]]; then
		output_text=$(pad_title "$title")

		if [[ "$output_text" != "$last_output_text" ]]; then
			last_output_text="$output_text"
			output_text=$(escape_markup "$output_text")
			echo "{\"text\": \"$output_text\", \"tooltip\": \"$artist - $title\", \"class\": \"Paused\"}"
		fi

		sleep $scroll_interval
		continue
	fi

	output_text=""

	if [[ ${#title} -gt $max_length ]]; then
		full_scroll_title="${scroll_title}${scroll_title}"
		output_text="${full_scroll_title:$scroll_position:$max_length}"
		scroll_position=$(((scroll_position + scroll_speed) % ${#scroll_title}))

		if [[ $scroll_position -eq 0 ]]; then
			scroll_position=1
		fi

		output_text="${output_text//"$front_separator"/}"

		if [[ "$output_text" != "$last_output_text" ]]; then
			last_output_text="$output_text"
			output_text="$front_separator$output_text$back_separator"
			output_text=$(pad_title "$output_text")
			output_text=$(escape_markup "$output_text")
			echo "{\"text\": \"$output_text\", \"tooltip\": \"$artist - $title\", \"class\": \"$status\"}"
		fi

	else
		output_text=$(pad_title "$title")

		if [[ "$output_text" != "$last_output_text" ]]; then
			last_output_text="$output_text"
			output_text=$(escape_markup "$output_text")
			echo "{\"text\": \"$output_text\", \"tooltip\": \"$artist - $title\", \"class\": \"$status\"}"
		fi
	fi

	sleep $scroll_interval
done
