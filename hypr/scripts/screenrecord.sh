#!/usr/bin/env bash

set -euo pipefail

: "${XDG_VIDEOS_DIR:="$HOME/Videos"}"
SAVE_DIR="${XDG_VIDEOS_DIR}/Captures"
SCREENCAST_NAME="$(date '+%F_%T_%3N').mp4"

get_last_capture() {
  find "${SAVE_DIR}" -maxdepth 1 -type f -name '*.mp4' -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -n 1 |
    cut -d' ' -f2-
}

toggle_recording() {
  if pgrep -f "gpu-screen-recorder" >/dev/null; then
    stop_recording
  else
    start_recording
  fi
}

start_recording() {
  local output_file="${SAVE_DIR}/${SCREENCAST_NAME}"

  gpu-screen-recorder -w portal -q ultra -a default_output \
    -k hevc -ac opus -cr full -f 144 -o "${output_file}" &
  RECORDER_PID=$!

  sleep 0.5
  if ! kill -0 "${RECORDER_PID}" 2>/dev/null; then
    notify-send -a "Screen Recorder" "Failed to start recording"
    exit 1
  fi

  local action=$(notify-send -a "Screen Recorder" "Screen Recorder" "Recording Started" \
    -A "stop=Stop")

  case "${action}" in
  "stop")
    stop_recording
    return 1
    ;;
  esac
}

stop_recording() {
  pkill -SIGINT -f "gpu-screen-recorder"
  sleep 1

  local last_capture=$(get_last_capture)
  handle_user_action "${last_capture}"
}

handle_user_action() {
  local last_capture="$1"
  local action=$(notify-send -a "Screen Recorder" "Screen Recorder" "Recording Stopped" \
    -A "view=View" -A "open=Open folder" -A "delete=Delete")

  case "${action}" in
  "view")
    [ -n "${last_capture}" ] && xdg-open "${last_capture}"
    ;;
  "open")
    xdg-open "${SAVE_DIR}"
    ;;
  "delete")
    [ -n "${last_capture}" ] && rm -f "${last_capture}"
    ;;
  esac
}

toggle_recording
