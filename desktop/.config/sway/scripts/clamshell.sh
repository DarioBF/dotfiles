#!/bin/bash

# SETTINGS
# ============

# Debugging options: off | on | log
DEBUG="on"
DEBUG_COMMANDS=0

LAPTOP_OUTPUT="eDP-1"
BACKGROUND_IMAGE="/home/dariobf/.config/sway/wallpapers/purple_landscape.jpg"

# Monitor outputs
DOCKED_OUTPUTS=("DP-4" "DP-5" "DP-6") # Define aquí los nombres de las salidas del dock
WORKSPACE_ASSIGNMENTS=(
    "1:DP-5"
    "2:DP-5"
    "3:DP-5"
    "4:DP-4"
		"5:DP-4"
    "6:DP-6"
)

# HELPERS
# ============

log() {
    [[ "$DEBUG" != "off" ]] && echo "$1"
}

[[ $DEBUG == "log" ]] && exec >> /tmp/clamshell.log 2>&1
[[ $DEBUG_COMMANDS -eq 1 ]] && set -x

# START
# ============

log "Script invocation: $0 $*"

# Detect active outputs
active_outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')
only_laptop=$(expr "${active_outputs}" == "${LAPTOP_OUTPUT}")

log "Active outputs: $active_outputs"
log "Only Laptop?    $only_laptop"

if [ "$1" = "on" ]; then
    log "Clamshell mode ON: Disabling laptop output."
    swaymsg output "$LAPTOP_OUTPUT" disable

    # If only the laptop was active, lock and suspend
    if [ $only_laptop -eq 1 ]; then
        log "Only laptop output active, locking and suspending."
        /usr/bin/swaylock -f -i "$BACKGROUND_IMAGE" && /usr/bin/systemctl suspend
    else
        log "Docked mode detected. Configuring workspaces for docked outputs."
        for output in "${DOCKED_OUTPUTS[@]}"; do
            if ! echo "$active_outputs" | grep -q "$output"; then
                log "Warning: Expected output $output not found among active outputs."
            fi
        done

        # Assign workspaces to active outputs
        for assignment in "${WORKSPACE_ASSIGNMENTS[@]}"; do
            workspace="${assignment%%:*}" # Extract workspace number
            output="${assignment##*:}"   # Extract output name
            if echo "$active_outputs" | grep -q "$output"; then
                log "Assigning workspace $workspace to output $output."
                swaymsg "workspace $workspace output $output"
            else
                log "Skipping workspace $workspace: Output $output not active."
            fi
        done
    fi

elif [ "$1" = "off" ]; then
    log "Clamshell mode OFF: Enabling laptop output."
    swaymsg output "$LAPTOP_OUTPUT" enable

    # Optional: Reset workspace assignments if needed
    for output in "${DOCKED_OUTPUTS[@]}"; do
        if echo "$active_outputs" | grep -q "$output"; then
            log "Resetting workspace assignment for output $output."
            swaymsg "workspace 1 output $output" # Example: Reset to workspace 1
        fi
    done
fi
