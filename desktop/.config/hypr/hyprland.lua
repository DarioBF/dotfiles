-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Personal overrides, loaded after Omarchy's defaults so package updates can
-- improve the defaults without rewriting these files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.windows")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- gcr-ssh-agent (gnome-keyring): key passphrases are kept in the login keyring,
-- so apps launched from the session (terminals, Claude Code's ssh-manager MCP) can use them.
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/gcr/ssh")
