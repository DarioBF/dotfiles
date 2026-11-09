-- Universal clipboard (from Omarchy's bindings/clipboard.lua) and clipboard
-- history. SUPER + V is floating here (windows.lua), so there is no universal
-- paste: use CTRL + V in apps.

-- Send with explicit mods to the focused surface by omitting the window target,
-- so the shortcuts reach both normal windows and focused layer-shell surfaces
-- such as Omarchy panels. The down/up split works around Hyprland send_shortcut
-- sometimes leaving synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

-- Terminals copy with CTRL + SHIFT + C. Uses the terminal tag from Omarchy's
-- default/hypr/apps/terminals.lua; dynamic tags carry a trailing "*".
local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

o.bind("SUPER + A", "Select all", send_shortcut_once("CTRL", "A"))
o.bind("SUPER + C", "Universal copy", function()
  if active_window_is_terminal() then
    send_shortcut_once("CTRL SHIFT", "C")()
  else
    send_shortcut_once("CTRL", "C")()
  end
end)
o.bind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", "X"))

o.bind("SUPER + CTRL + V", "Clipboard manager", { panel = "omarchy.clipboard" })
o.bind("SUPER + SHIFT + V", "Clipboard manager", { panel = "omarchy.clipboard" })

-- Pass the tmux/Herdr prefix through and return to direct input, so the next
-- key reaches the multiplexer instead of the input method's composition.
-- (Omarchy's SUPER + I / SHIFT + I language keys are workspace keys here.)
o.bind("CTRL + SPACE", "Direct input for the terminal prefix", function()
  if active_window_is_terminal() then
    -- Wait for the local controller reply before dispatching the next key.
    o.shell_succeeds("timeout 0.3 fcitx5-remote --check -c")
  end
end, { non_consuming = true })
