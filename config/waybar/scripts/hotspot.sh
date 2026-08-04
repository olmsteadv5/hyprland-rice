#!/usr/bin/env bash
# Waybar module for the NetworkManager "Hotspot" connection (see custom/hotspot in config.jsonc).
#   status → JSON state for waybar   toggle → start/stop the hotspot

CON="Hotspot"

active() {
    nmcli -g NAME con show --active | grep -qx "$CON"
}

case "$1" in
    status)
        if active; then
            ssid=$(nmcli -g 802-11-wireless.ssid con show "$CON")
            psk=$(nmcli --show-secrets -g 802-11-wireless-security.psk con show "$CON")
            clients=$(iw dev wlan0 station dump 2>/dev/null | grep -c '^Station')
            printf '{"text":"󰀂","class":"on","tooltip":"Hotspot ON — %s client(s)\\nSSID: %s\\nPassword: %s\\nClick to turn off"}\n' \
                "$clients" "$ssid" "$psk"
        else
            printf '{"text":"󰀃","class":"off","tooltip":"Hotspot off — click to turn on"}\n'
        fi
        ;;
    toggle)
        if active; then
            nmcli con down "$CON"
        else
            nmcli con up "$CON"
        fi
        pkill -RTMIN+11 waybar
        ;;
esac
