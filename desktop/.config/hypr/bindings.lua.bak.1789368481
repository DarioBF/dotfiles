-- Personal keybindings, layered over Omarchy's defaults.
-- See everything that's bound: omarchy menu keybindings --print
-- Rebinding a key Omarchy uses needs hl.unbind() first.

-- Workspaces on the QWERTY row, alongside Omarchy's SUPER + 1…0:
-- SUPER + Q…O switches to 1–9, SUPER + SHIFT + Q…P moves the window to 1–10.
-- This takes over Omarchy's close (W), float (T) and pop-out (O), and the
-- Omawrite (SHIFT+W), Email (SHIFT+E), YouTube (SHIFT+Y), Obsidian (SHIFT+O)
-- and Google Photos (SHIFT+P) web-app keys.
for _, key in ipairs({ "W", "T", "O", "SHIFT + W", "SHIFT + E", "SHIFT + Y", "SHIFT + O", "SHIFT + P" }) do
  hl.unbind("SUPER + " .. key)
end

for workspace, key in ipairs({ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }) do
  -- SUPER + P stays Omarchy's pseudo-tile; only SHIFT + P is used, for 10.
  if key ~= "P" then
    o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  end
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

-- Window keys. These replace Omarchy's universal cut/paste (SUPER + X/V; use
-- CTRL + X/V in apps instead) and swap fullscreen with the file manager.
hl.unbind("SUPER + X")
hl.unbind("SUPER + V")
hl.unbind("SUPER + F")
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + X", "Close window", hl.dsp.window.close())
o.bind("SUPER + V", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Scratchpad: SUPER + S toggles it (Omarchy default); SUPER + SHIFT + S sends
-- the window there and follows it. Replaces the Google Maps web-app key.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Clipboard history, also on Omarchy's SUPER + CTRL + V.
o.bind("SUPER + SHIFT + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")
