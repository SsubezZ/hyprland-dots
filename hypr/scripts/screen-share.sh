#!/bin/bash
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
xdg-desktop-portal-hyprland &
xdg-desktop-portal &
