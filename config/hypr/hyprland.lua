-- explainer: Hyprland 0.57 dropped hyprland.conf, this is a straight port of it

local home = os.getenv("HOME")

hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "3440x1440@60", position = "auto-right", scale = 1 })
-- explainer: the ultrawide shows up as DP-3 here, not DP-1. both kept, rules for unplugged ports are ignored
hl.monitor({ output = "DP-3", mode = "3440x1440@60", position = "2560x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "3440x1440@60", position = "2560x0", scale = 1 })
-- explainer: the ultrawide hops between DP-1/2/3, desc rules beat port rules so this always wins
hl.monitor({ output = "desc:Dell Inc. DELL U3419W 32KR5T2", mode = "3440x1440@60", position = "2560x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL U3419W HHS66T2", mode = "3440x1440@60", position = "2560x0", scale = 1 })
-- explainer: Newline classroom board is 4K, the DP-1 ultrawide rule above would force a mode it doesn't have
hl.monitor({ output = "desc:Newline Interactive Inc. TT-XXNT 0x00000001", mode = "3840x2160@60", position = "auto-right", scale = 1.5 })


local terminal = "kitty"
local fileManager = "dolphin"


hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd(home .. "/.config/hypr/monitor-handler.sh")
    hl.exec_cmd("/usr/lib/kf6/baloo_file") -- explainer: file indexer for Dolphin search
end)


hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Capitaine-Cursors-Gruvbox-White")
hl.env("BROWSER", "zen-twilight")
hl.env("XDG_DATA_DIRS", "/var/lib/flatpak/exports/share:" .. home .. "/.local/share/flatpak/exports/share:/usr/local/share:/usr/share")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_PLUGIN_PATH", "/usr/lib/qt6/plugins")
hl.env("HYPRSHOT_DIR", home .. "/Pictures/Screenshots")


hl.config({
    general = {
        gaps_in = 7,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(ebdbb2ee)", "rgba(ebdbb2ee)" }, angle = 45 },
            inactive_border = "rgba(504945aa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 16,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            vibrancy = 0.18,
            new_optimizations = true,
            xray = false,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },
    master = { new_status = "master" },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        background_color = 0x000000,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1, -- focus follows the mouse on hover
        natural_scroll = false,
        scroll_factor = 1.0,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },

    debug = { disable_scale_checks = true },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "scroll_mouse", sensitivity = -0.5 })


local mainMod = "SUPER"
local function bind(keys, dsp, opts) hl.bind(keys, dsp, opts) end

bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
bind(mainMod .. " + BACKSPACE", hl.dsp.exec_cmd("hyprlock"))
bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("setsid -f ~/.local/bin/theme-switch --next"))
bind(mainMod .. " + C", hl.dsp.window.close())
bind(mainMod .. " + L", hl.dsp.exit())
bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
bind(mainMod .. " + Y", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("wofi"))
bind(mainMod .. " + P", hl.dsp.window.pseudo())
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
bind(mainMod .. " + Z", hl.dsp.exec_cmd("zen-twilight"))
bind(mainMod .. " + S", hl.dsp.exec_cmd("signal-desktop"))
bind(mainMod .. " + I", hl.dsp.window.pin())

-- explainer: Claude Quick Entry comes through the GlobalShortcuts portal, so bind it by hand. id from hyprctl globalshortcuts, recheck after updates
bind(mainMod .. " + TAB", hl.dsp.global("com.anthropic.Claude:022536B537371E6228CC42E031525CDD-Ctrl+Alt+Space"))

bind(mainMod .. " + E", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind(mainMod .. " + SHIFT + E", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

bind(mainMod .. " + Semicolon", hl.dsp.layout("-0.05"))
bind(mainMod .. " + Apostrophe", hl.dsp.layout("0.05"))

bind(mainMod .. " + left", hl.dsp.window.move({ direction = "left" }))
bind(mainMod .. " + right", hl.dsp.window.move({ direction = "right" }))
bind(mainMod .. " + up", hl.dsp.window.move({ direction = "up" }))
bind(mainMod .. " + down", hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -s"))
bind("SUPER + SHIFT + D", hl.dsp.exec_cmd([[grim -g "$(slurp)" /tmp/ocr_shot.png && tesseract /tmp/ocr_shot.png stdout -l eng 2>/dev/null | wl-copy && notify-send "OCR" "Text copied to clipboard"]]))
bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | wofi -dmenu | cliphist decode | wl-copy"))
bind("SUPER + Escape", hl.dsp.exec_cmd("wlogout --layout ~/.config/wlogout/layout --css ~/.config/wlogout/style.css --buttons-per-row 1 --margin-top 5 --margin-right 5"))

bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local held = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), held)
bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), held)
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%+"), held)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%-"), held)

bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })


hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true, keep_aspect_ratio = true, pin = true,
})

-- decision: ignore_alpha keeps wofi's rounded corners crisp instead of blurring the edges
hl.layer_rule({ match = { namespace = "wofi" }, blur = true, ignore_alpha = 0.4 })

-- explainer: Discord as a floating toggle window, Chrome --app derives the class from the URL
hl.window_rule({
    match = { class = "chrome-discord.com__app-Default" },
    float = true, size = { 1100, 950 }, workspace = "special:discord",
})
bind(mainMod .. " + D", hl.dsp.exec_cmd(home .. "/.config/hypr/discord-toggle.sh"))

-- explainer: written by theme-switch, loaded last so its border colors win
local theme = home .. "/.config/hypr/theme-colors.lua"
if io.open(theme) then dofile(theme) end
