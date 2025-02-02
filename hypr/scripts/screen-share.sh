#!/bin/bash

killall -e xdg-desktop-portal-hyprland &
killall -e xdg-desktop-portal-gtk &
killall xdg-desktop-portal &

sleep 1

/usr/lib/xdg-desktop-portal-hyprland &
systemctl restart --user pipewire.service &
systemctl restart --user xdg-desktop-portal-hyprland &

sleep 1

wpctl set-volume @DEFAULT_SOURCE@ 25%
wpctl set-mute @DEFAULT_SOURCE@ 1
