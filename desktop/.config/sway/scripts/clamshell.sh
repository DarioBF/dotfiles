#!/bin/bash

# SETTINGS
# ============

# Values: off | on | log
DEBUG="off"
DEBUG_COMMANDS=0

LAPTOP_OUTPUT="eDP-1"
BACKGROUND_IMAGE="/home/dariobf/.config/sway/wallpapers/purple_landscape.jpg"

# HELPERS
# ============

log() {
    [[ "$DEBUG" != "off" ]] && echo $1
}

[[ $DEBUG == "log" ]] && exec >> /tmp/clamshell.log 2>&1
[[ $DEBUG_COMMANDS -eq 1 ]] && set -x

# START
# ============

log "Script invocation: $0 $*"

active_outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')
only_laptop=$(expr "${active_outputs}" == "${LAPTOP_OUTPUT}")

log "Active outputs: $active_outputs"
log "Only Laptop?    $only_laptop"

if [ "$1" = "on" ]; then
    swaymsg output "$LAPTOP_OUTPUT" disable
    if [ $only_laptop -eq 1 ]; then
        /usr/bin/swaylock -f -i "$BACKGROUND_IMAGE" && /usr/bin/systemctl suspend
    fi
elif [ "$1" = "off" ]; then
    swaymsg output "$LAPTOP_OUTPUT" enable
fi
