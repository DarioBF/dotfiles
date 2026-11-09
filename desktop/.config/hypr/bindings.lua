-- Personal keybindings. Omarchy's defaults are off (omarchy_default_bindings =
-- false in hyprland.lua), so these files are the whole map: a key not bound here
-- does nothing. Started on 2026-11-09 as a port of Omarchy 4.5.0-3's defaults
-- (/usr/share/omarchy/default/hypr/bindings/) with the personal changes folded
-- in; new keys from Omarchy updates are not picked up, compare that directory
-- after an update to find them.
-- See everything that's bound: omarchy menu keybindings --print

require("hypr.bindings.apps")
require("hypr.bindings.windows")
require("hypr.bindings.workspaces")
require("hypr.bindings.clipboard")
require("hypr.bindings.utilities")
require("hypr.bindings.media")
require("hypr.bindings.dictation")
