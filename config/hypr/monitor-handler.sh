#!/bin/bash
# explainer: Hyprland moved its sockets to $XDG_RUNTIME_DIR in 0.40, /tmp kept as a fallback
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
[ -S "$SOCKET" ] || SOCKET="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        "monitorremoved>>DP-1"*|"monitorremoved>>DP-3"*)
            hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "auto", scale = 1 })'
            ;;
        "monitoradded>>DP-3"*)
            sleep 1
            hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "0x0", scale = 1 })'
            hyprctl eval 'hl.monitor({ output = "DP-3", mode = "3440x1440@60", position = "2560x0", scale = 1 })'
            ;;
        "monitoradded>>DP-1"*)
            # decision: wait for Hyprland's own hotplug setup, otherwise the keyword lands mid-modeset
            sleep 1
            hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "auto", scale = 1 })'
            hyprctl eval 'hl.monitor({ output = "DP-1", mode = "3440x1440@60", position = "auto-right", scale = 1 })'
            ;;
    esac
done
