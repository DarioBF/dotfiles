---@module 'hl'

-- Floating windows

hl.window_rule({
	name = "windowrule-1",
	match = {
		tag = "floating-window",
	},
	float = true,
	center = true,
	size = { 875, 600 },
})

hl.window_rule({
	name = "windowrule-2",
	match = {
		class = "(tui-calcure|tui-bluetuith|tui-impala|tui-fastfetch|tui-wiremix|TUI.float|imv|mpv)",
	},
	tag = "+floating-window",
})

hl.window_rule({
	name = "windowrule-3",
	match = {
		title = "Bitwarden Password Manager",
	},
	tag = "+floating-window",
	center = true,
})

hl.window_rule({
	name = "windowrule-4",
	match = {
		class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)",
		title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
	},
	tag = "+floating-window",
})

hl.window_rule({
	name = "windowrule-5",
	match = {
		class = "org.gnome.Calculator",
	},
	float = true,
})

-- No transparency on media windows

hl.window_rule({
	name = "windowrule-6",
	match = {
		class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
	},
	opacity = 1,
	1,
})

-- Popped window rounding

hl.window_rule({
	name = "windowrule-7",
	match = {
		tag = "pop",
	},
	rounding = 8,
})

hl.window_rule({
	name = "windowrule-8",
	match = {
		title = "Plexamp",
	},
	float = true,
	center = true,
	size = { 255, 475 },
})

hl.window_rule({
	name = "windowrule-9",
	match = {
		class = "firefox",
		title = "Extension:\\(Bitwarden Password Manager\\)",
	},
	float = true,
	center = true,
})
