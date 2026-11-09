-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Fallback for any monitor not listed below. Omarchy's SUPER + SLASH scaling
-- keys persist their change here, so it only affects unlisted monitors.
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Desk layout. Positions are in logical (scaled) pixels.
--
--   ┌──────────────┐┌──────────────┐
--   │  dell_left   ││  dell_right  │
--   └──────────────┘└──────────────┘
--   ┌────────┐             ┌──┐
--   │ laptop │             │  │ mini
--   └────────┘             └──┘
--
-- Externals are matched by description so dock port renumbering doesn't matter.
local dell_left = "desc:Dell Inc. DELL U2715H GH85D74E1U4S"
local dell_right = "desc:Dell Inc. DELL U2715H GH85D7CN014S"
local mini = "desc:DRS Defense Solutions LLC TYPE-C L56051794302"
local mini_hdmi = "desc:Invalid Vendor Codename- RTK HDMI 0x01010101"

-- Keep the laptop rule on one line with literal values: Omarchy's clamshell
-- handler reads its position and scale back when the lid reopens.
-- 2256x1504 / 1.6 = 1410x940 logical.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x1440", scale = 1.6 })

hl.monitor({ output = dell_left, mode = "2560x1440@59.95", position = "0x0", scale = 1 })
hl.monitor({ output = dell_right, mode = "2560x1440@59.95", position = "2560x0", scale = 1 })
hl.monitor({ output = mini, mode = "960x640@60", position = "3840x1440", scale = 1 })
hl.monitor({ output = mini_hdmi, mode = "960x640@60", position = "3840x1440", scale = 1 })

-- Workspaces per display follow the lid and dock: scripts/clamshell.sh picks
-- the layout and writes it as rules to a state file, loaded here so config
-- reloads keep it. Omarchy's own lid binds turn the laptop panel off and on;
-- these run alongside them.
--
-- Omarchy 4.5 added its own per-monitor scheme (default/hypr/monitor-workspaces.lua:
-- a block of ten ids per monitor, 1-10, 11-20, 21-30...). On every start, config
-- reload and monitor change it reconciles workspaces into those blocks, which
-- fights the global numbering below: it renumbered 1-6 to 21+ on the laptop and
-- moved 1-10 to whichever monitor owns block 0. It can't be switched off, but its
-- event handlers look up o.workspaces.reconcile at call time, so replacing it
-- with a no-op leaves workspace placement to clamshell.sh alone, as before 4.5.
-- The 4.5 workspace keys are restored to their 4.0 form in bindings.lua.
o.workspaces.reconcile = function() end

local clamshell = os.getenv("HOME") .. "/.config/hypr/scripts/clamshell.sh"
local clamshell_workspaces = (os.getenv("XDG_STATE_HOME") or os.getenv("HOME") .. "/.local/state")
  .. "/hypr/clamshell-workspaces.lua"

local layout = io.open(clamshell_workspaces, "r")
if layout then
  layout:close()
  dofile(clamshell_workspaces)
end

-- Omarchy's own lid handlers (turn eDP-1 off/on), taken from its bindings
-- because omarchy_default_bindings is off. They live here, registered just
-- before clamshell.sh's, to keep the order they had when Omarchy loaded them.
o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
o.bind("switch:off:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })

o.bind("switch:on:Lid Switch", nil, clamshell .. " close", { locked = true })
o.bind("switch:off:Lid Switch", nil, clamshell .. " open", { locked = true })

hl.on("hyprland.start", function() hl.exec_cmd(clamshell) end)
hl.on("monitor.added", function() hl.exec_cmd(clamshell) end)
hl.on("monitor.removed", function() hl.exec_cmd(clamshell) end)
