#!/usr/bin/env bash
# KDE Connect link handoff for Waybar.
#
#   status -> Waybar JSON; shows the icon whenever your phone is reachable.
#   send   -> LAPTOP -> PHONE. Grabs the current browser tab's URL (or the
#             actively-playing media's URL) and opens it on the phone.
#   pull   -> PHONE -> LAPTOP. Opens whatever link is in your clipboard
#             (synced from the phone) in your default browser.
#
# Why two directions instead of auto-detect: KDE Connect's media protocol
# never transmits the source URL of what's playing on the phone, so the laptop
# can't read it to pull a video automatically. Pushing is reliable; pulling is
# done via clipboard sync. Left-click = push, right-click = pull.
#
# Deps: kdeconnect-cli, playerctl, wtype, wl-clipboard, hyprctl, libnotify.

set -uo pipefail

DEVICE_NAME="${KDECONNECT_DEVICE:-}"   # set to your phone's exact name if >1 device
ICON=""                               # nf-fa-exchange  U+F0EC
BROWSER_CLASSES="firefox|zen|chrome|chromium|brave|vivaldi|librewolf|edge|mullvad"

json_escape() { local s="$1"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//$'\n'/\\n}"; s="${s//$'\t'/\\t}"
  printf '%s' "$s"; }
emit() { printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$(json_escape "$1")" "$(json_escape "$2")" "$3"; }

resolve_id() {
  if [[ -n "$DEVICE_NAME" ]]; then
    kdeconnect-cli -a 2>/dev/null | grep -F -- "$DEVICE_NAME" \
      | sed -nE 's/^- .*: ([^ ]+) \(.*/\1/p' | head -n1
  else
    kdeconnect-cli -a --id-only 2>/dev/null | awk 'NF{print $1; exit}'
  fi
}

append_ts() { local u="$1" p="$2"
  if ! [[ "$p" =~ ^[0-9]+$ ]] || [[ "$p" -le 0 ]]; then printf '%s' "$u"; return; fi
  case "$u" in
    *youtube.com/watch*|*youtu.be/*|*music.youtube.com*)
      if [[ "$u" == *\?* ]]; then printf '%s&t=%ss' "$u" "$p"; else printf '%s?t=%ss' "$u" "$p"; fi ;;
    *) printf '%s' "$u" ;;
  esac
}

# 1) a locally-playing player (not the phone) that exposes a real URL
url_from_player() {
  local p u st pos
  while read -r p; do
    [[ -z "$p" || "$p" == kdeconnect* ]] && continue
    st="$(playerctl -p "$p" status 2>/dev/null)"
    [[ "$st" != "Playing" ]] && continue
    u="$(playerctl -p "$p" metadata xesam:url 2>/dev/null)"
    [[ "$u" == http* ]] || continue
    pos="$(playerctl -p "$p" position 2>/dev/null | cut -d. -f1)"
    append_ts "$u" "${pos:-0}"; return 0
  done < <(playerctl -l 2>/dev/null)
  return 1
}

# 2) fall back to the focused browser's address bar (Ctrl+L, Ctrl+C)
url_from_addressbar() {
  command -v wtype >/dev/null 2>&1 || return 1
  local cls; cls="$(hyprctl activewindow 2>/dev/null \
    | awk -F': ' '/^[[:space:]]*class:/{print $2; exit}')"
  [[ "${cls,,}" =~ ($BROWSER_CLASSES) ]] || return 1
  local saved; saved="$(wl-paste -n 2>/dev/null)"
  wtype -M ctrl -k l -m ctrl; sleep 0.12
  wtype -M ctrl -k c -m ctrl; sleep 0.12
  wtype -k Escape
  local u; u="$(wl-paste -n 2>/dev/null)"
  printf '%s' "$saved" | wl-copy 2>/dev/null || true
  [[ "$u" == http* ]] && { printf '%s' "$u"; return 0; }
  return 1
}

case "${1:-status}" in
  status)
    id="$(resolve_id)"; [[ -z "$id" ]] && { echo '{"text":""}'; exit 0; }
    emit "$ICON" "Left-click: send this tab to your phone
Right-click: open phone's copied link here" "active"
    ;;
  send)
    id="$(resolve_id)"
    [[ -z "$id" ]] && { notify-send "Handoff" "Phone not reachable"; exit 0; }
    url="$(url_from_player)" || url="$(url_from_addressbar)" || url=""
    if [[ -z "$url" ]]; then
      notify-send "Handoff →" "Couldn't read a URL. Focus the browser tab and try again."
      exit 0
    fi
    if kdeconnect-cli -d "$id" --share "$url"; then
      notify-send "Handoff →" "Opened on your phone"
    else
      notify-send "Handoff →" "kdeconnect-cli failed"
    fi
    ;;
  pull)
    u="$(wl-paste -n 2>/dev/null)"
    if [[ "$u" == http* ]]; then
      xdg-open "$u" >/dev/null 2>&1 &
      notify-send "Handoff ←" "Opening here: ${u:0:50}"
    else
      notify-send "Handoff ←" "No link in clipboard. Copy the link on your phone first (clipboard sync must be enabled)."
    fi
    ;;
  *) echo "usage: $0 {status|send|pull}" >&2; exit 1 ;;
esac
