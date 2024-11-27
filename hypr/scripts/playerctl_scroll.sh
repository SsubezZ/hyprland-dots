#!/bin/bash

get_metadata() {
  playerctl -i firefox -a metadata --format '{"title":"{{title}}","artist":"{{artist}}","status":"{{status}}"}'
}

max_length=17
scroll_speed=2
scroll_interval=0.25
front_separator=""
back_separator="  "
update_interval=0.5
last_metadata=""
current_metadata=""
scroll_title=""
scroll_position=0

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

while true; do
  current_metadata=$(get_metadata)
  if [[ -z "$current_metadata" ]]; then
    echo '{"text": "", "tooltip": "", "class": ""}'
    sleep $update_interval
    continue
  fi

  if [[ "$current_metadata" != "$last_metadata" ]]; then
    last_metadata="$current_metadata"
    title=$(echo "$current_metadata" | jq -r '.title')
    artist=$(echo "$current_metadata" | jq -r '.artist')
    status=$(echo "$current_metadata" | jq -r '.status')
    scroll_title=$(wrap_title "$title")
    scroll_position=0
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
  else
    output_text=$(pad_title "$title")
  fi

  if [[ "$status" != "Playing" ]]; then
    output_text=$(pad_title "$title")
  fi

  first_word_title=$(echo "$title" | awk '{print $1}')
  first_word_output=$(echo "$output_text" | awk '{print $1}')

  if [[ "$first_word_title" == "$first_word_output" ]]; then
    output_text="${output_text//"$front_separator"/}"
  fi

  if [[ ${#title} -gt $max_length ]]; then
    output_text="$front_separator$output_text$back_separator"
  fi

  output_text=$(pad_title "$output_text")

  echo "{\"text\": \"$output_text\", \"tooltip\": \"$artist - $title\", \"class\": \"$status\"}"

  sleep $scroll_interval
done
