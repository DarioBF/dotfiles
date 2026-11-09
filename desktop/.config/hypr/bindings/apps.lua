-- Application launchers.
-- Omarchy's preinstalled app/web-app keys (Calculator, Signal, YouTube...) are
-- not here: they were already off on this machine (~/.local/state/omarchy/
-- preinstalls-removed), and several of their keys are workspace keys now.

o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

-- SUPER + F is the file manager; Omarchy had it on SUPER + SHIFT + F, which is
-- full screen here (see windows.lua).
o.bind("SUPER + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { omarchy = "nautilus-cwd" })
