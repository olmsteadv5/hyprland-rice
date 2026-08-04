#!/bin/bash

options="🔒 Lock\n🚪 Logout\n💤 Suspend\n🔄 Reboot\n⏻ Shutdown"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power" \
    --width 200 --height 200 \
    --location top_right \
    --hide-scroll)

case $chosen in
    "🔒 Lock") hyprlock ;;
    "🚪 Logout") hyprctl dispatch exit ;;
    "💤 Suspend") systemctl suspend ;;
    "🔄 Reboot") systemctl reboot ;;
    "⏻ Shutdown") systemctl poweroff ;;
esac
