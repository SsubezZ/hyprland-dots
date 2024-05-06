#!/bin/bash
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &
/usr/lib/xdg-desktop-portal-hyprland &
systemctl restart --user pipewire.service &
