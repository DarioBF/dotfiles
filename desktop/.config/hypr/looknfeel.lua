---@module 'hl'

-- Variables

local activeBorderColor = "rgba(FAB387FF) rgba(FAB387FF) 45deg;"

local inactiveBorderColor = "rgba(595959aa)"

-- https://wiki.hyprland.org/Configuring/Variables/#general

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 6,
		border_size = 2,
		-- https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
		-- Set to true enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,
		-- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
		allow_tearing = false,
		layout = "dwindle",
		col = {
			active_border = "rgba(FAB387FF)",
			inactive_border = "rgba(595959aa)",
		},
	},
})

-- https://wiki.hyprland.org/Configuring/Variables/#decoration

hl.config({
	decoration = {
		rounding = 8,
		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		-- https://wiki.hyprland.org/Configuring/Variables/#blur
		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			special = true,
			brightness = 0.60,
			contrast = 0.75,
		},
	},
})

-- https://wiki.hypr.land/Configuring/Variables/#group

hl.config({
	group = {
		groupbar = {
			font_size = 12,
			font_family = "monospace",
			font_weight_active = "ultraheavy",
			font_weight_inactive = "normal",
			indicator_height = 0,
			indicator_gap = 5,
			height = 22,
			gaps_in = 5,
			gaps_out = 0,
			text_color = "rgba(ffffff00)",
			text_color_inactive = "rgba(ffffff90)",
			gradients = true,
			gradient_rounding = 0,
			gradient_round_only_edges = false,
		},
		col = {
			border_active = "rgba(FAB387FF)",
			border_inactive = "rgba(595959aa)",
			border_locked_active = "rgba(FAB387FF)",
			border_locked_inactive = "rgba(595959aa)",
		},
	},
})

-- https://wiki.hyprland.org/Configuring/Variables/#animations

hl.config({
	animations = {
		enabled = false,
		-- Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
	},
})

-- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more

hl.config({
	dwindle = {
		preserve_split = true,
		-- You probably want this
		force_split = 2,
		-- Always split on the right
	},
})

-- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more

hl.config({
	master = {
		new_status = "master",
	},
})

-- https://wiki.hyprland.org/Configuring/Variables/#misc

hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		anr_missed_pings = 3,
		on_focus_under_fullscreen = 1,
	},
})

-- https://wiki.hypr.land/Configuring/Variables/#cursor

hl.config({
	cursor = {
		hide_on_key_press = true,
	},
})

-- Style Gum confirm to match terminal theme

hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", 6)

-- Cyan

hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", 0)

-- Black

hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", 2)

-- Green

hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", 0)

-- Black

hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", 8)

-- Dark grey

--para apps libadwaita gtk4 podés usar este comando:

-- para apps GTK4

--para apps gtk3 necesitás instalar el tema adw-gtk3 (en arch linux sudo pacman -S adw-gtk-theme)

-- para apps GTK3

--para apps kde necesitás instalar: sudo pacman -S qt5ct qt6ct kvantum kvantum breeze-icons

--vas a tener que configurar el tema oscuro para apps qt desde kde, es más complicado que con gnome :D:

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- para apps Qt # Tema

-- Exec (run every reload)
hl.on("config.reloaded", function()
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3")
end)
