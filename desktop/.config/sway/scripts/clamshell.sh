#!/bin/bash

# SETTINGS
DEBUG="off"
DEBUG_COMMANDS=0

LAPTOP_OUTPUT="eDP-1"
MAIN_DISPLAY="DP-5"
SECONDARY_DISPLAY="DP-4"
MINI_DISPLAY="DP-6"
BACKGROUND_IMAGE="/home/dariobf/.config/sway/wallpapers/purple_landscape.jpg"

# HELPERS
log() {
    [[ "$DEBUG" != "off" ]] && echo "$1"
}

[[ $DEBUG == "log" ]] && exec >> /tmp/clamshell.log 2>&1
[[ $DEBUG_COMMANDS -eq 1 ]] && set -x

assign_workspaces() {
    if [ "$1" = "on" ]; then
        swaymsg workspace 1 output $MAIN_DISPLAY
        swaymsg workspace 2 output $MAIN_DISPLAY
        swaymsg workspace 3 output $MAIN_DISPLAY
        swaymsg workspace 4 output $SECONDARY_DISPLAY
        swaymsg workspace 5 output $SECONDARY_DISPLAY
        swaymsg workspace 6 output $MINI_DISPLAY
        log "Workspaces assigned: 1-3 to $MAIN_DISPLAY, 4-5 to $SECONDARY_DISPLAY, 6 to $MINI_DISPLAY"
    elif [ "$1" = "off" ]; then
			if echo "$active_outputs" | grep -qv "$LAPTOP_OUTPUT"; then
					swaymsg workspace 5 output $LAPTOP_OUTPUT
					log "External monitors active. Assigned workspace 5 to $LAPTOP_OUTPUT"
			else
					for ws in {1..6}; do
							swaymsg workspace $ws output $LAPTOP_OUTPUT
					done
					log "No external monitors active. All workspaces assigned to $LAPTOP_OUTPUT"
			fi
    fi
}

# Detect active outputs
active_outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')
only_laptop=$(expr "${active_outputs}" == "${LAPTOP_OUTPUT}")

log "Script invocation: $0 $*"
log "Active outputs: $active_outputs"
log "Only Laptop?    $only_laptop"

if [ "$1" = "on" ]; then
    log "Clamshell mode ON: Disabling laptop output."
    swaymsg output "$LAPTOP_OUTPUT" disable
		assign_workspaces on
    if [ $only_laptop -eq 1 ]; then
        log "Only laptop output active, locking and suspending."
        /usr/bin/swaylock -f -i "$BACKGROUND_IMAGE" && /usr/bin/systemctl suspend
    fi
elif [ "$1" = "off" ]; then
    log "Clamshell mode OFF: Enabling laptop output."
    swaymsg output "$LAPTOP_OUTPUT" enable
		assign_workspaces off
elif [ "$1" = "reload" ]; then
    log "Reload detected: Checking clamshell status."
    if echo "$active_outputs" | grep -q "$LAPTOP_OUTPUT"; then
        "$0" off
    else
        "$0" on
    fi
fi
