#!/usr/bin/env bash

ocr_text=$(grimblast --freeze save area - | tesseract -l eng - - 2>/dev/null)

if [[ -n "$ocr_text" ]]; then
  text_length=${#ocr_text}

  short_text=${ocr_text:0:150}

  if ((text_length > 150)); then
    short_text="${short_text} ......"
  fi

  echo -n "$ocr_text" | wl-copy

  notify-send -a "OCR" "OCR Success" "Text Copied\n\n$short_text"
else
  notify-send -a "OCR" "OCR Failed" "No text recognized or operation failed"
fi
