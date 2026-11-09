-- Personal keybindings, layered over Omarchy's defaults.
-- See everything that's bound: omarchy menu keybindings --print
-- Rebinding a key Omarchy uses needs hl.unbind() first.

-- Workspaces on the QWERTY row, alongside Omarchy's SUPER + 1…0:
-- SUPER + Q…O switches to 1–9, SUPER + SHIFT + Q…P moves the window to 1–10.
-- This takes over Omarchy's close (Q and W), float (T) and pop-out (O), and the
-- Omawrite (SHIFT+W), Email (SHIFT+E), YouTube (SHIFT+Y), Obsidian (SHIFT+O)
-- and Google Photos (SHIFT+P) web-app keys. Omarchy 4.5 added Activity/btop
-- (SHIFT+T) and input language cycling (I, SHIFT+I) on these keys too; without
-- unbinding them both actions fire on the same press.
for _, key in ipairs({ "Q", "W", "T", "O", "I", "SHIFT + W", "SHIFT + E", "SHIFT + T", "SHIFT + Y", "SHIFT + I", "SHIFT + O", "SHIFT + P" }) do
  hl.unbind("SUPER + " .. key)
end

for workspace, key in ipairs({ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }) do
  -- SUPER + P stays Omarchy's pseudo-tile; only SHIFT + P is used, for 10.
  if key ~= "P" then
    o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  end
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

-- Omarchy 4.5 turned SUPER + 1…0 and the workspace keys below into per-monitor
-- blocks (o.workspaces.*). clamshell.sh numbers workspaces globally, so put back
-- the 4.0.6 bindings: each number is one workspace, wherever it lives.
-- SUPER + SHIFT + CTRL + arrows (move window to monitor) is new in 4.5 and has no
-- block logic, so it stays.
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.rebind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end

o.rebind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.rebind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.rebind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.rebind("SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.rebind("SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))

o.rebind("SUPER + SHIFT + ALT + LEFT", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.rebind("SUPER + SHIFT + ALT + RIGHT", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.rebind("SUPER + SHIFT + ALT + UP", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.rebind("SUPER + SHIFT + ALT + DOWN", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))

-- Window keys. These replace Omarchy's universal paste (SUPER + V; use CTRL + V
-- in apps instead) and swap fullscreen with the file manager. SUPER + X keeps
-- Omarchy's universal cut; closing moves to SUPER + SHIFT + X (X web app key).
hl.unbind("SUPER + SHIFT + X")
hl.unbind("SUPER + V")
hl.unbind("SUPER + F")
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + X", "Close window", hl.dsp.window.close())
o.bind("SUPER + V", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Scratchpad: SUPER + S toggles it (Omarchy default); SUPER + SHIFT + S sends
-- the window there and follows it. Replaces the Google Maps web-app key.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Clipboard history, also on Omarchy's SUPER + CTRL + V.
o.bind("SUPER + SHIFT + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end
