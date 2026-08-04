# dotfiles

Hyprland rice on CachyOS (Arch) — Gruvbox Dark by default, with a one-keystroke
theme switcher that recolors the whole desktop at once.

```
Hyprland  ·  Waybar  ·  wofi  ·  wlogout  ·  SwayNC  ·  kitty  ·  fish + starship
```

**`SUPER + SHIFT + T`** cycles the theme. Everything below repaints together:
Waybar, SwayNC, wofi, kitty, Hyprland borders, starship, btop, zellij and Zed.

Two themes ship here: `gruvbox-dark` (default) and `macos-dark`.

---

## Install

```bash
git clone https://github.com/olmsteadv5/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # see what it would do
./install.sh
```

`install.sh` symlinks `config/*` into `~/.config/` and `local/bin/*` into
`~/.local/bin/`. Anything already at those paths is moved to
`~/.dotfiles-backup/<timestamp>/` rather than overwritten, and re-running is
safe. Make sure `~/.local/bin` is on your `PATH`.

### Then do these three things

1. **Fix the monitors.** `config/hypr/hyprland.conf` starts with my laptop's
   panel (`eDP-1`, 2560x1600) and an external mirrored on `DP-1`. Yours will
   differ — check `hyprctl monitors`. The second Waybar in
   `config/waybar/config.jsonc` targets `HDMI-A-1`; change it to your external
   output or delete that block for a single-monitor setup.
2. **Fix the backlight device.** The brightness keys call
   `brightnessctl -d amdgpu_bl1`; run `brightnessctl -l` and substitute yours.
   (`intel_backlight` on most Intel laptops.)
3. **Apply the theme once** after logging into Hyprland: `theme-switch gruvbox-dark`.

---

## Dependencies

Nothing here vendors its own binaries, so install these first or you'll get a
half-painted desktop.

### Core

```bash
sudo pacman -S hyprland waybar wofi wlogout swaync kitty fish \
               hyprpaper hypridle hyprlock hyprshot \
               xdg-desktop-portal-hyprland qt5ct qt6ct kvantum \
               network-manager-applet blueman playerctl brightnessctl \
               cliphist wl-clipboard grim slurp \
               noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols \
               starship btop zellij yazi micro
```

The Nerd Font symbols package is not optional — Waybar, wofi and wlogout are
full of glyph icons that render as boxes without it. Interface font throughout
is **Noto Sans / Noto Sans Mono**.

### Themes, icons and cursors (AUR)

```bash
paru -S gruvbox-material-gtk-theme-git \
        whitesur-icon-theme \
        capitaine-cursors-gruvbox
```

These are referenced by name in `config/gtk-3.0/settings.ini`,
`config/qt6ct/qt6ct.conf` and the `XCURSOR_THEME` line in `hyprland.conf`:

| Setting     | Value                              |
|-------------|------------------------------------|
| GTK theme   | `Gruvbox-Dark`                     |
| Icon theme  | `WhiteSur-yellow`                  |
| Cursor      | `Capitaine-Cursors-Gruvbox-White`  |
| Qt style    | Kvantum → `Gruvbox-Dark-Brown` (included in `config/Kvantum/`) |

AUR package names drift; if one 404s, search for the theme by the name in the
table and drop it in `~/.local/share/themes` or `~/.local/share/icons`. The
names in the config files are what has to match, not the package.

### Optional

- **OCR screenshot** (`SUPER+SHIFT+D`) needs `tesseract` + `tesseract-data-eng`.
- **KDE Connect modules** in Waybar need `kdeconnect`; without it those two
  modules just stay empty.
- **Spotify theming** needs `spicetify-cli`; the Gruvbox theme is in
  `config/spicetify/Themes/Gruvbox/`.
- **Wallpaper**: `hyprpaper` is autostarted but ships no config here — add your
  own `~/.config/hypr/hyprpaper.conf`.

---

## How the theme system works

`local/bin/theme-switch` is the whole mechanism. A theme is just a directory of
color fragments in `config/themes/<name>/`:

```
config/themes/gruvbox-dark/
├── theme.env          # names of themes for apps that have their own (btop, zellij, zed)
├── gtk-colors.css     # copied to waybar/colors.css and swaync/colors.css
├── wofi-style.css     # copied to wofi/style.css
├── kitty-colors.conf  # copied to kitty/theme-colors.conf
├── hypr-colors.conf   # copied to hypr/theme-colors.conf (border colors)
└── starship.toml      # copied to starship.toml
```

Switching does two passes: it writes every file first, then reloads the running
apps — `hyprctl reload`, `SIGUSR1` to kitty, `swaync-client -rs`, and Waybar
dead last, because restarting Waybar kills the script's own parent process when
it was launched from a Waybar click.

```bash
theme-switch --list      # show themes, * marks active
theme-switch --current
theme-switch --next      # what SUPER+SHIFT+T and the Waybar palette icon call
theme-switch macos-dark
```

**Adding a theme:** copy `config/themes/gruvbox-dark` to a new directory, edit
the colors, done — it joins the `--next` rotation automatically (alphabetical).

A `themes/current` symlink tracks the active theme. It is machine state, so it
isn't committed; `install.sh` creates it.

> Files like `waybar/colors.css`, `wofi/style.css`, `kitty/theme-colors.conf`,
> `hypr/theme-colors.conf` and `starship.toml` are **generated** — they're
> committed so the repo works out of the box, but editing them directly gets
> your changes overwritten on the next switch. Edit `config/themes/<name>/`
> instead.

---

## Keybindings

`SUPER` is the mod key. Full list in `config/hypr/hyprland.conf`.

| Key | Action |
|---|---|
| `SUPER + T` | kitty |
| `SUPER + SPACE` | wofi launcher |
| `SUPER + F` | Dolphin |
| `SUPER + Z` / `SUPER + S` | Zen browser / Signal |
| `SUPER + C` | close window |
| `SUPER + Y` / `SUPER + I` | float / pin |
| `SUPER + E` / `SUPER + SHIFT + E` | fullscreen on / off |
| `SUPER + J` | toggle split |
| `SUPER + ; / '` | shrink / grow split |
| `SUPER + 1..0` | workspace (`+SHIFT` moves window) |
| `SUPER + arrows` | move window |
| `SUPER + drag L/R` | move / resize |
| `SUPER + V` | clipboard history (cliphist) |
| `SUPER + SHIFT + S` | region screenshot |
| `SUPER + SHIFT + D` | region OCR → clipboard |
| `SUPER + SHIFT + T` | **next theme** |
| `SUPER + BACKSPACE` | lock (hyprlock) |
| `SUPER + ESC` | wlogout |
| `SUPER + L` | exit Hyprland |

`SUPER + TAB` is bound to Claude Desktop's Quick Entry through the
GlobalShortcuts portal. The ID after `global,` is specific to that install —
run `hyprctl globalshortcuts` to get yours, or delete the line.

---

## Waybar

Two bars (laptop + external), each: workspaces · CPU · memory · temperature ·
network on the left, window title · MPRIS · KDE Connect media in the center,
backlight · volume · hotspot · tray · notifications · theme · clock · battery
on the right.

Three custom scripts in `config/waybar/scripts/`:

- **`hotspot.sh`** — toggles the NetworkManager connection named `Hotspot` and
  shows SSID, password and client count in the tooltip. It reads the password
  from NetworkManager at runtime (`nmcli --show-secrets`); nothing is stored in
  this repo. You need a saved AP-mode connection named exactly `Hotspot`:
  ```bash
  nmcli con add type wifi ifname wlan0 con-name Hotspot autoconnect no \
        ssid <your-ssid> 802-11-wireless.mode ap 802-11-wireless.band bg \
        ipv4.method shared wifi-sec.key-mgmt wpa-psk wifi-sec.psk <your-password>
  ```
  It also assumes the interface is `wlan0` for the client count.
- **`kdeconnect-status.sh`** / **`kdeconnect-handoff.sh`** — phone battery and
  media handoff.

---

## What's in here

| Path | |
|---|---|
| `config/hypr/` | Hyprland, hypridle, hyprlock, monitor hotplug handler |
| `config/waybar/` | bars, styles, custom scripts |
| `config/wofi/`, `config/wlogout/` | launcher, power menu |
| `config/swaync/` | notification center |
| `config/kitty/` | terminal |
| `config/themes/` | **theme definitions** |
| `config/gtk-3.0`, `gtk-4.0`, `qt5ct`, `qt6ct`, `Kvantum` | toolkit theming |
| `config/fish/`, `config/starship.toml` | shell + prompt |
| `config/btop`, `zellij`, `yazi`, `micro` | TUI tools |
| `config/spicetify/` | Spotify theme |
| `local/bin/theme-switch` | the theme switcher |

`config/fish/config.fish` carries some of my machine-specific setup (FreeSurfer,
ROCm/Ollama for a Radeon 890M, Julia) — it's guarded by existence checks, so it
won't break anything, but it isn't of much use to you. Trim it.

---

## License

MIT — see [LICENSE](LICENSE). Take whatever's useful.
