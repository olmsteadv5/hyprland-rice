#!/bin/bash
# explainer: Chrome --app derives the class from the URL
CLASS="chrome-discord.com__app-Default"

if hyprctl clients -j | python3 -c "
import json,sys
sys.exit(0 if any(c['class']=='$CLASS' for c in json.load(sys.stdin)) else 1)
"; then
    hyprctl dispatch togglespecialworkspace discord
else
    setsid google-chrome-stable --app=https://discord.com/app >/dev/null 2>&1 &
fi
