# hyprland-rice

My Hyprland setup on CachyOS. Gruvbox Dark by default, and `SUPER + SHIFT + T` switches the whole desktop to another theme at once (Waybar, SwayNC, wofi, kitty, Hyprland borders, starship, btop, zellij, Zed). Two themes ship: `gruvbox-dark` and `macos-dark`.

## Install

```bash
git clone https://github.com/olmsteadv5/hyprland-rice.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh
```

`install.sh` symlinks `config/*` into `~/.config/` and `local/bin/*` into `~/.local/bin/` (needs to be on your `PATH`). Anything already there goes to `~/.dotfiles-backup/<timestamp>/`. Safe to re-run.

After that:

1. Fix the monitor lines at the top of `config/hypr/hyprland.conf` for your outputs (`hyprctl monitors`). Mine is a 2560x1600 laptop panel with an ultrawide to its right, and `config/hypr/monitor-handler.sh` redoes that layout on hotplug. Waybar has no output set, so it shows on every monitor.
2. The brightness keys use `brightnessctl -d amdgpu_bl1`. Check `brightnessctl -l` for yours (usually `intel_backlight` on Intel).
3. Log into Hyprland and run `theme-switch gruvbox-dark` once.

## Dependencies

```bash
sudo pacman -S hyprland waybar wofi wlogout swaync kitty fish \
               hyprpaper hypridle hyprlock hyprshot \
               xdg-desktop-portal-hyprland qt5ct qt6ct kvantum \
               network-manager-applet blueman playerctl brightnessctl \
               cliphist wl-clipboard grim slurp \
               noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols \
               starship btop zellij yazi micro \
               jq socat power-profiles-daemon
paru -S gruvbox-material-gtk-theme-git whitesur-icon-theme capitaine-cursors-gruvbox
```

You need the Nerd Font symbols, otherwise Waybar, wofi and wlogout show boxes. The configs refer to the themes by name (GTK `Gruvbox-Dark`, icons `WhiteSur-yellow`, cursor `Capitaine-Cursors-Gruvbox-White`, Kvantum `Gruvbox-Dark-Brown`), so if an AUR package is gone, any copy with that name works.

Optional: `tesseract` + `tesseract-data-eng` for OCR screenshots, `kdeconnect` for the phone handoff, `google-chrome` for the Discord window, `fw-fanctrl` for the fan module (Framework laptops), `spicetify-cli` for the Spotify theme, and your own `~/.config/hypr/hyprpaper.conf` for a wallpaper.

## Themes

A theme is a folder in `config/themes/<name>/` with color files that `local/bin/theme-switch` copies into place, then it reloads Hyprland, kitty, SwayNC and finally Waybar (restarting Waybar can kill the script when you clicked it from Waybar).

```bash
theme-switch --list
theme-switch --next
theme-switch macos-dark
```

To add one, copy `config/themes/gruvbox-dark`, change the colors, and it joins the rotation. `waybar/colors.css`, `wofi/style.css`, `kitty/theme-colors.conf`, `hypr/theme-colors.conf` and `starship.toml` get overwritten on every switch, so edit the theme folder instead.

## Keys

`SUPER` is the mod key, the full list is in `config/hypr/hyprland.conf`.

| Key | Action |
|---|---|
| `SUPER + T` | kitty |
| `SUPER + SPACE` | launcher |
| `SUPER + F` / `Z` / `S` | Dolphin / Zen / Signal |
| `SUPER + D` | Discord hover window |
| `SUPER + C` | close window |
| `SUPER + Y` / `I` | float / pin |
| `SUPER + E` / `SHIFT + E` | fullscreen on / off |
| `SUPER + J` | toggle split |
| `SUPER + 1..0` | workspace, `+ SHIFT` moves the window |
| `SUPER + V` | clipboard history |
| `SUPER + SHIFT + S` / `D` | screenshot / OCR to clipboard |
| `SUPER + SHIFT + T` | next theme |
| `SUPER + BACKSPACE` | lock |
| `SUPER + ESC` | power menu |

`SUPER + TAB` opens Claude's Quick Entry through the GlobalShortcuts portal. The id after `global,` is specific to my install, get yours from `hyprctl globalshortcuts` or delete the line.

## Waybar scripts

`config/waybar/scripts/` has the hotspot toggle, KDE Connect link handoff (left click sends this tab to the phone, right click opens the phone's link here), and Framework fan speed. The hotspot one expects a saved NetworkManager AP connection called `Hotspot` on `wlan0` and reads its password from NetworkManager at runtime, nothing is stored here:

```bash
nmcli con add type wifi ifname wlan0 con-name Hotspot autoconnect no \
      ssid <ssid> 802-11-wireless.mode ap 802-11-wireless.band bg \
      ipv4.method shared wifi-sec.key-mgmt wpa-psk wifi-sec.psk <password>
```

`config/fish/config.fish` has some of my machine setup (FreeSurfer, Ollama on a Radeon 890M, Julia). It checks before using any of it, but you'll probably want to trim it. `config/fish/functions/` has `cc-local` (Claude Code on a local Ollama model) and `cc-check` (makes sure plain `claude` is on the subscription, not an API key).

MIT, see [LICENSE](LICENSE).
