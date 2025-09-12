#!/usr/bin/env bash
set -euo pipefail

: "${XDG_VIDEOS_DIR:="$HOME/Videos"}"
SAVE_DIR="${XDG_VIDEOS_DIR}/Captures"
SCREENCAST_NAME="capture_$(date '+%F_%T_%3N').mp4"
mkdir -p "$SAVE_DIR"

STATE_FILE="/tmp/screenrecorder.state"

get_state() {
  [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo "stopped"
}

set_state() {
  echo "$1" >"$STATE_FILE"
}

get_last_capture() {
  find "${SAVE_DIR}" -maxdepth 1 -type f -name 'capture_*.mp4' -printf '%T@ %p\n' 2>/dev/null |
    sort -nr | head -n 1 | cut -d' ' -f2-
}

is_recording() {
  pgrep -f "gpu-screen-recorder" >/dev/null
}

pause_recording() {
  if ! is_recording; then
    notify-send -a "Screen Recorder" "Screen Recorder" "No recording is running" -h string:x-canonical-private-synchronous:screenrecord
    return 1
  fi
  pkill -SIGUSR2 -f "gpu-screen-recorder"
  set_state "paused"
  notify-send -a "Screen Recorder" -h string:x-canonical-private-synchronous:screenrecord -u critical \
    "Screen Recorder" "Recording Paused" \
    -A "resume=Resume" -A "stop=Stop" | {
    read -r action
    case "$action" in
    resume) resume_recording ;;
    stop) stop_recording ;;
    esac
  }
}

resume_recording() {
  if ! is_recording; then
    notify-send -a "Screen Recorder" "Screen Recorder" "No recording is running" -h string:x-canonical-private-synchronous:screenrecord
    return 1
  fi
  pkill -SIGUSR2 -f "gpu-screen-recorder"
  set_state "recording"
  notify-send -a "Screen Recorder" -h string:x-canonical-private-synchronous:screenrecord \
    "Screen Recorder" "Recording Resumed" \
    -A "pause=Pause" -A "stop=Stop" | {
    read -r action
    case "$action" in
    pause) pause_recording ;;
    stop) stop_recording ;;
    esac
  }
}

stop_recording() {
  if is_recording; then
    pkill -SIGINT -f "gpu-screen-recorder"
    sleep 1
  fi
  set_state "stopped"
  local last_capture
  last_capture=$(get_last_capture)
  notify-send -a "Screen Recorder" -h string:x-canonical-private-synchronous:screenrecord \
    "Screen Recorder" "Recording Stopped" \
    -A "view=View" -A "open=Open folder" -A "delete=Delete" | {
    read -r action
    case "$action" in
    view) [ -n "$last_capture" ] && xdg-open "$last_capture" ;;
    open) xdg-open "$SAVE_DIR" ;;
    delete) [ -n "$last_capture" ] && rm -f "$last_capture" ;;
    esac
  }
}

start_recording() {
  SUFFIX="${1:-screen}"
  local output_file="${SAVE_DIR}/${SCREENCAST_NAME}"
  local monitor
  monitor=$(hyprctl monitors -j | jq -r '.[0].name') || echo eDP-1

  case "$SUFFIX" in
  area)
    # Get all fullscreen workspaces
    FULLSCREEN_WORKSPACES="$(hyprctl workspaces -j | jq -r 'map(select(.hasfullscreen) | .id)')"

    # Get all active workspaces on monitors
    WORKSPACES="$(hyprctl monitors -j | jq -r '
        [(foreach .[] as $monitor (0; 
            if $monitor.specialWorkspace.name == "" 
            then $monitor.activeWorkspace 
            else $monitor.specialWorkspace 
            end
        )).id]
    ')"

    # Get all relevant windows that are not in fullscreen workspaces or are fullscreen themselves
    WINDOWS="$(
      hyprctl clients -j | jq -r \
        --argjson workspaces "$WORKSPACES" \
        --argjson fullscreenWorkspaces "$FULLSCREEN_WORKSPACES" \
        'map(select((([.workspace.id] | inside($workspaces)) and ([.workspace.id] | inside($fullscreenWorkspaces) | not)) or .fullscreen > 0))'
    )"

    # Build the region string for gpu-screen-recorder
    region="$(
      echo "$WINDOWS" |
        jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' |
        slurp -d -f "%wx%h+%x+%y" |
        xargs
    )"

    # Check if region is empty
    if [ -z "$region" ]; then
      notify-send -a "Screen Recorder" "Error: Region selection failed."
      return 1
    fi

    # Start recording the selected region
    gpu-screen-recorder -w region \
      -region "$region" \
      -q ultra -a default_output -k h264 -ac opus -cr full -f 144 \
      -o "$output_file" &
    ;;

  screen | *)
    gpu-screen-recorder -w "$monitor" \
      -q ultra -a default_output -k h264 -ac opus -cr full -f 144 \
      -o "$output_file" &
    ;;
  esac

  sleep 1
  if ! is_recording; then
    notify-send -a "Screen Recorder" "Failed to start recording"
    exit 1
  fi

  set_state "recording"
  notify-send -a "Screen Recorder" -h string:x-canonical-private-synchronous:screenrecord \
    "Screen Recorder" "Recording Started" \
    -A "pause=Pause" -A "stop=Stop" | {
    read -r action
    case "$action" in
    pause) pause_recording ;;
    stop) stop_recording ;;
    esac
  }
}

toggle_recording_state() {
  if ! is_recording; then
    notify-send -a "Screen Recorder" "Screen Recorder" "No recording is running" -h string:x-canonical-private-synchronous:screenrecord
    return 1
  fi

  case "$(get_state)" in
  recording) pause_recording ;;
  paused) resume_recording ;;
  *) pause_recording ;;
  esac
}

toggle_recording() {
  local suffix="${1:-}"
  if ! is_recording; then
    case "$suffix" in
    toggle)
      notify-send -a "Screen Recorder" "Screen Recorder" "No recording is running" -h string:x-canonical-private-synchronous:screenrecord
      return 1
      ;;
    area | screen | "")
      start_recording "${suffix:-screen}"
      ;;
    *)
      notify-send -a "Screen Recorder" "Invalid command: $suffix"
      return 1
      ;;
    esac
    return
  fi

  case "$suffix" in
  toggle) toggle_recording_state ;;
  stop | "") stop_recording ;;
  *) notify-send -a "Screen Recorder" "Invalid command: $suffix" ;;
  esac
}

toggle_recording "${1:-}"
