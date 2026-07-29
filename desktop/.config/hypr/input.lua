---@module 'hl'

-- Control your input devices

-- See https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "altgr-intl",
		kb_options = "compose:caps",
		repeat_rate = 40,
		repeat_delay = 600,
		touchpad = {
			scroll_factor = 0.4,
		},
	},
})

-- Scroll faster in the terminal

hl.window_rule({
	name = "windowrule-1",
	match = {
		tag = "terminal",
	},
	scroll_touchpad = 1.5,
})
