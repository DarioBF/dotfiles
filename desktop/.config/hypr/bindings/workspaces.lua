-- Workspaces, numbered globally: each number is one workspace, wherever it
-- lives. scripts/clamshell.sh places them on monitors (see monitors.lua, which
-- also turns off Omarchy 4.5's per-monitor blocks of ten), so these use plain
-- workspace ids instead of Omarchy's o.workspaces.* helpers.

-- QWERTY row: SUPER + Q…O switches to 1–9, SUPER + SHIFT + Q…P moves the window
-- to 1–10. SUPER + P stays pseudo-tile (windows.lua), so 10 has no switch key here.
for workspace, key in ipairs({ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }) do
  if key ~= "P" then
    o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  end
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

-- Number row 1…0 (keycodes 10–19, so they work on any layout).
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end

o.bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))

o.bind("SUPER + SHIFT + ALT + LEFT", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + RIGHT", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.bind("SUPER + SHIFT + ALT + UP", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + ALT + DOWN", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))

-- Moving a window to another monitor has no block logic, so Omarchy's helper stays.
o.bind("SUPER + SHIFT + CTRL + LEFT", "Move window to left monitor", o.workspaces.move_window_to_monitor("l"))
o.bind("SUPER + SHIFT + CTRL + RIGHT", "Move window to right monitor", o.workspaces.move_window_to_monitor("r"))
o.bind("SUPER + SHIFT + CTRL + UP", "Move window to up monitor", o.workspaces.move_window_to_monitor("u"))
o.bind("SUPER + SHIFT + CTRL + DOWN", "Move window to down monitor", o.workspaces.move_window_to_monitor("d"))
