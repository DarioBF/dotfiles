-- Personal window rules, on top of Omarchy's ($OMARCHY_PATH/default/hypr/windows.lua
-- and apps/). See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window("org.gnome.Calculator", { float = true })

o.window({ title = "Plexamp" }, { float = true, center = true, size = { 255, 475 } })

-- Bitwarden's Firefox extension pop-out. Omarchy covers the desktop app and
-- the Chromium extension, not this one.
o.window(
  { class = "firefox", title = "Extension: \\(Bitwarden Password Manager\\).*" },
  { float = true, center = true, no_screen_share = true }
)
