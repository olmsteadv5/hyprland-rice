#!/bin/bash
socat - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if echo "$line" | grep -q "^monitorremoved>>DP-1"; then
        hyprctl keyword monitor "eDP-1,2560x1600@165,auto,1"
    fi
    if echo "$line" | grep -q "^monitoradded>>DP-1"; then
        hyprctl keyword monitor "eDP-1,3440x1440@60,auto,1"
        hyprctl keyword monitor "DP-1,3440x1440@60,auto,1,mirror,eDP-1"
    fi
done
