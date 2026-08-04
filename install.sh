#!/usr/bin/env bash
# install.sh — symlink this repo into place.
#
# Every target is backed up to ~/.dotfiles-backup/<timestamp>/ before being
# replaced, so running this on a machine that already has configs is safe.
# Re-running is idempotent: links we already own are left alone.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DEFAULT_THEME="gruvbox-dark"
DRY_RUN=0

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1 && echo "== dry run: nothing will be written =="

link() {
    local src="$1" dest="$2"

    # Already pointing at us — nothing to do.
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        printf '  ok    %s\n' "${dest/#$HOME/\~}"
        return
    fi

    if (( DRY_RUN )); then
        printf '  would link %s\n' "${dest/#$HOME/\~}"
        return
    fi

    # Anything else living there gets moved aside, not deleted.
    if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BACKUP/$(dirname "${dest#$HOME/}")"
        mv "$dest" "$BACKUP/${dest#$HOME/}"
        printf '  backup %s\n' "${dest/#$HOME/\~}"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    printf '  link  %s\n' "${dest/#$HOME/\~}"
}

# These directories hold files we don't own — fish's generated fish_variables,
# GTK bookmarks, micro's buffers. Linking the whole directory would displace
# them, so their contents get linked one entry at a time instead.
MERGE_DIRS=(fish micro gtk-3.0)

is_merge_dir() {
    local name="$1"
    for d in "${MERGE_DIRS[@]}"; do [[ "$d" == "$name" ]] && return 0; done
    return 1
}

echo "==> ~/.config"
for path in "$REPO"/config/*; do
    name="$(basename "$path")"
    if [[ -d "$path" ]] && is_merge_dir "$name"; then
        (( DRY_RUN )) || mkdir -p "$HOME/.config/$name"
        for inner in "$path"/*; do
            link "$inner" "$HOME/.config/$name/$(basename "$inner")"
        done
    else
        link "$path" "$HOME/.config/$name"
    fi
done

echo "==> ~/.local/bin"
for path in "$REPO"/local/bin/*; do
    (( DRY_RUN )) || chmod +x "$path"
    link "$path" "$HOME/.local/bin/$(basename "$path")"
done

# theme-switch resolves the active theme through this symlink; it is per-machine
# state rather than content, so it is created here instead of being committed.
echo "==> active theme"
if [[ -L "$HOME/.config/themes/current" ]]; then
    printf '  ok    themes/current -> %s\n' "$(basename "$(readlink -f "$HOME/.config/themes/current")")"
elif (( DRY_RUN )); then
    printf '  would set themes/current -> %s\n' "$DEFAULT_THEME"
else
    ln -sfn "$REPO/config/themes/$DEFAULT_THEME" "$HOME/.config/themes/current"
    printf '  set   themes/current -> %s\n' "$DEFAULT_THEME"
fi

echo
if (( DRY_RUN )); then
    echo "Dry run complete."
    exit 0
fi

[[ -d "$BACKUP" ]] && echo "Replaced files were backed up to $BACKUP"

cat <<'EOF'

Done. Remaining manual steps:

  1. Edit ~/.config/hypr/hyprland.conf — the monitor= lines and the
     brightnessctl device (amdgpu_bl1) are specific to my laptop.
  2. Install the dependencies listed in the README, then log into Hyprland.
  3. Apply the theme once everything is running:  theme-switch gruvbox-dark

EOF
