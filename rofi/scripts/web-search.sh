#!/usr/bin/env bash

BROWSER="librewolf --new-window"
declare -A SEARCH_ENGINES=(
	["Google"]="https://www.google.com/search?q=<QUERY>"
	["Perplexity"]="https://www.perplexity.com/search?q=<QUERY>"
	["ChatGPT"]="https://chatgpt.com/?q=<QUERY>"
	["YouTube"]="https://www.youtube.com/results?search_query=<QUERY>"
	["DuckDuckGo"]="https://duckduckgo.com/?q=<QUERY>"
	["GitHub"]="https://github.com/search?q=<QUERY>"
	["Arch Wiki"]="https://wiki.archlinux.org/index.php?search=<QUERY>"
	["Twitch"]="https://www.twitch.tv/<QUERY>"
	["Twitter"]="https://www.twitter.com/<QUERY>"
)

ENGINE_ORDER=("Google" "Perplexity" "ChatGPT" "YouTube" "DuckDuckGo" "GitHub" "Arch Wiki" "Twitch" "Twitter")

# Generate engine list
engines_list=""
for index in "${!ENGINE_ORDER[@]}"; do
	engine="${ENGINE_ORDER[$index]}"
	[ $index -ne 0 ] && engines_list+="\n"
	engines_list+="$engine"
done

# Get search query first
query=$(
	rofi -dmenu -mesg "Enter Search Query" -theme-str 'window {width: 400px;} listview {columns: 1;} listview {enabled: false;} mode-switcher {enabled: false;}'
)
[ -z "$query" ] && exit # Exit if no query entered

# Select search engine
selected_engine=$(
	echo -e "$engines_list" | rofi -dmenu -mesg "Search With" -theme-str 'window {width: 400px;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher { enabled: false; }'
)
[ -z "${SEARCH_ENGINES[$selected_engine]}" ] && exit

# Default to Google if invalid selection
if [ -z "$selected_engine" ]; then
	selected_engine="Google"
fi

# URL-encode query
urlencode() {
	local length="${#1}"
	local encoded=""
	for ((i = 0; i < length; i++)); do
		local c="${1:i:1}"
		case "$c" in
		[a-zA-Z0-9.~_-]) encoded+="$c" ;;
		*) encoded+=$(printf '%%%02X' "'$c") ;;
		esac
	done
	echo "$encoded"
}

# Encode query
encoded_query=$(urlencode "$query")

# Construct URL
url="${SEARCH_ENGINES[$selected_engine]//<QUERY>/$encoded_query}"

# Open in browser
$BROWSER "$url"
