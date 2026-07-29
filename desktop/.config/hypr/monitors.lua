---@module 'hl'

-- See https://wiki.hyprland.org/Configuring/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors
-- Format: monitor = [port], resolution, position, scale
-- You must relaunch Hyprland after changing any envs (use Super+Esc, then Relaunch)
-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.

hl.env("GDK_SCALE", 1)

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

-- Good compromise for 27" or 32" 4K monitors (but fractional!)
-- env = GDK_SCALE,1.75
-- monitor=,preferred,auto,1.666667
-- Straight 1x setup for low-resolution displays like 1080p or 1440p
-- env = GDK_SCALE,1
-- monitor=,preferred,auto,1
-- Example for Framework 13 w/ 6K XDR Apple display
-- monitor = DP-5, 6016x3384@60, auto, 2
-- monitor = eDP-1, 2880x1920@120, auto, 2
-- MY CUSTOMS
--monitor=,preferred,auto,auto

hl.monitor({
	output = "eDP-1",
	mode = "2256x1504@60",
	position = "0x1440",
	scale = 1.33,
})

hl.monitor({
	output = "desc:Dell Inc. DELL U2715H GH85D74E1U4S",
	mode = "2560x1440@60",
	position = "0x0",
	scale = 1.0,
})

hl.monitor({
	output = "desc:Dell Inc. DELL U2715H GH85D7CN014S",
	mode = "2560x1440@60",
	position = "2560x0",
	scale = 1.0,
})

hl.monitor({
	output = "desc:DRS Defense Solutions LLC TYPE-C L56051794302",
	mode = "960x640@60",
	position = "3840x1440",
	scale = 1.0,
})

hl.monitor({
	output = "desc:Invalid Vendor Codename- RTK HDMI 0x01010101",
	mode = "960x640@60",
	position = "3840x1440",
	scale = 1.0,
})

-- Clamshell mode

local script = os.getenv("HOME") .. "/.config/hypr/scripts/clamshell.sh"

-- Pasamos el dispatcher directamente. Al ser asíncrono, Hyprland no se bloqueará.
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(script .. " open"), { locked = true })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(script .. " close"), { locked = true })

-- Workspace bindings and rules:

hl.workspace_rule({
	workspace = 1,
	default_name = "",
	monitor = "eDP-1",
	persistent = true,
})

hl.workspace_rule({
	workspace = 2,
	default_name = "",
	monitor = "eDP-1",
	persistent = true,
})

hl.workspace_rule({
	workspace = 3,
	default_name = "󰏘",
	monitor = "eDP-1",
	persistent = true,
})

hl.workspace_rule({
	workspace = 4,
	default_name = "󰭹",
	monitor = "eDP-1",
	persistent = true,
})

hl.workspace_rule({
	workspace = 5,
	default_name = "󰭹",
	monitor = "eDP-1",
	persistent = true,
})

hl.workspace_rule({
	workspace = 6,
	default_name = "󱣛",
	monitor = "eDP-1",
	persistent = true,
})
