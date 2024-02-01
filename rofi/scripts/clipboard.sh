#!/bin/bash

# Get the current clipboard contents
clip="$(xclip -o -sel clip)"

# Show the contents in Rofi
chosen="$(echo -e "$clip" | rofi -dmenu -p "Clipboard: ")"

# If something was selected, put it back in the clipboard
[[ -n $chosen ]] && echo -n "$chosen" | xclip -i -sel clip
