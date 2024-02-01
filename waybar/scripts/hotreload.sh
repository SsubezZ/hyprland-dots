#!/usr/bin/env bash
exec watchexec --clear -- 'pkill waybar || true; waybar &'
