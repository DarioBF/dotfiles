---@module 'hl'

-- Basic envs

mainMod = "SUPER"
terminal = "uwsm app -- kitty"
menu = "exec noctalia msg panel-toggle launcher"
fileManager = "nautilus"
browser = "firefox"

-- Extra env variables
-- Note: You must relaunch Hyprland after changing envs (use Super+Esc, then Relaunch)
-- env = MY_GLOBAL_ENV,setting
-- Dark mode

hl.env("GTK_THEME", "Adwaita:dark")

-- Fix (Teorically) electron apps blurry fail

hl.env("ELECTRON_ENABLE_WAYLAND", 1)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- Freetype & Fontconfig

hl.env("FREETYPE_PROPERTIES", "truetype:interpreter-version=35")
hl.env("FONTCONFIG_PATH", "/etc/fonts")

-- Cursor size

hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)

-- Force all apps to use Wayland

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", 1)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc)

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

-- Use XCompose file

hl.env("XCOMPOSEFILE", "~/.XCompose")

-- Don't show update on first launch

hl.config({
	ecosystem = {
		no_update_news = true,
	},
})
