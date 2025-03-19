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

# Get search query first
query=$(
	rofi -dmenu -mesg "Enter Search Query" -theme-str 'window {width: 400px;} listview {columns: 1;} listview {enabled: false;} mode-switcher {enabled: false;}'
)
[ -z "$query" ] && exit # Exit if no query entered

# Check if query looks like a domain
domain_regex='^(https?://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$'
domain_flag=0
if [[ "$query" =~ $domain_regex ]]; then
	domain_flag=1
	# Option for going directly to the domain.
	domain_option="Go to ${query}"
fi

# Build search engine menu list
engines_list=""
if [ $domain_flag -eq 1 ]; then
	engines_list+="${domain_option}\n"
fi
for engine in "${ENGINE_ORDER[@]}"; do
	engines_list+="${engine}\n"
done
# Remove trailing newline
engines_list=$(echo -e "$engines_list" | sed '/^$/d')

# Select search engine
selected_option=$(
	echo -e "$engines_list" | rofi -dmenu -mesg "Search With" -theme-str 'window {width: 400px;} element-text {vertical-align: 0.50; horizontal-align: 0.50;} mode-switcher { enabled: false; }'
)
[ -z "$selected_option" ] && exit

# If "Go to" option, open the domain directly
if [ "$domain_flag" -eq 1 ] && [ "$selected_option" == "$domain_option" ]; then
	# Prepend https:// if missing
	if [[ ! "$query" =~ ^https?:// ]]; then
		query="https://$query"
	fi
	$BROWSER "$query"
	exit
fi

# If selection is not a valid search engine, default to Google
if [ -z "${SEARCH_ENGINES[$selected_option]}" ]; then
	selected_option="Google"
fi

# URL-encode query function
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

encoded_query=$(urlencode "$query")

# Construct the URL using the chosen search engine
url="${SEARCH_ENGINES[$selected_option]//<QUERY>/$encoded_query}"

# Open the URL in the browser
$BROWSER "$url"
