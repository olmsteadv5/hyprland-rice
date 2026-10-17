#!/usr/bin/env bash
# explainer: status = connected / paired-but-offline / none, connect = rescan, reconnect, ping
# explainer: needs kdeconnect-cli and libnotify. Nerd Font glyphs, swap them if you see boxes

set -uo pipefail

DEVICE_NAME="${KDECONNECT_DEVICE:-}"
ICON_ON=""       # explainer: nf-fa-mobile U+F10B
ICON_OFF=""      # explainer: nf-fa-chain_broken U+F127

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"; s="${s//$'\t'/\\t}"; s="${s//$'\r'/\\r}"
  printf '%s' "$s"
}
emit() { printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$(json_escape "$1")" "$(json_escape "$2")" "$3"; }

reachable_id() {
  if [[ -n "$DEVICE_NAME" ]]; then
    kdeconnect-cli -a 2>/dev/null | grep -F -- "$DEVICE_NAME" \
      | sed -nE 's/^- .*: ([^ ]+) \(.*/\1/p' | head -n1
  else
    kdeconnect-cli -a --id-only 2>/dev/null | awk 'NF{print $1; exit}'
  fi
}
paired_id() {
  if [[ -n "$DEVICE_NAME" ]]; then
    kdeconnect-cli -l 2>/dev/null | grep -F -- "$DEVICE_NAME" \
      | sed -nE 's/^- .*: ([^ ]+) \(.*/\1/p' | head -n1
  else
    kdeconnect-cli -l --id-only 2>/dev/null | awk 'NF{print $1; exit}'
  fi
}
name_of() { kdeconnect-cli -l 2>/dev/null | sed -nE "s/^- (.*): $1 \(.*/\1/p" | head -n1; }

case "${1:-status}" in
  status)
    id="$(reachable_id)"
    if [[ -n "$id" ]]; then
      emit "$ICON_ON" "$(name_of "$id") connected ($id)" "connected"
    else
      pid="$(paired_id)"
      if [[ -n "$pid" ]]; then
        emit "$ICON_OFF" "$(name_of "$pid") paired but offline — click to reconnect" "offline"
      else
        emit "$ICON_OFF" "No paired device — click to rescan" "none"
      fi
    fi
    ;;
  connect)
    notify-send "KDE Connect" "Forcing reconnect…"
    pgrep -x kdeconnectd >/dev/null 2>&1 || { /usr/lib/kdeconnectd >/dev/null 2>&1 & sleep 1; }
    kdeconnect-cli --refresh
    sleep 2
    id="$(reachable_id)"; pid="$(paired_id)"
    if [[ -n "$id" ]]; then
      kdeconnect-cli -d "$id" --ping >/dev/null 2>&1
      notify-send "KDE Connect" "$(name_of "$id") connected"
    elif [[ -n "$pid" ]]; then
      kdeconnect-cli -d "$pid" --refresh >/dev/null 2>&1
      notify-send "KDE Connect" "Still offline — check both devices share one Wi-Fi"
    else
      kdeconnect-cli --pair >/dev/null 2>&1
      notify-send "KDE Connect" "No device found — open the app on your phone and pair"
    fi
    pkill -RTMIN+11 waybar 2>/dev/null || true
    ;;
  *) echo "usage: $0 {status|connect}" >&2; exit 1 ;;
esac
