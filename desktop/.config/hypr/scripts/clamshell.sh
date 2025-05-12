#!/usr/bin/env bash

# HELPERS
export WAYLAND_DISPLAY=wayland-1  # Cambia a wayland-0 si es necesario
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Accede directamente a la variable de entorno HYPRLAND_INSTANCE_SIGNATURE
echo "HYPRLAND_INSTANCE_SIGNATURE: $HYPRLAND_INSTANCE_SIGNATURE"

# Si no está definida la variable, muestra un error
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "Error: No se pudo encontrar HYPRLAND_INSTANCE_SIGNATURE. ¿Está Hyprland corriendo?"
    exit 1
fi

# SETTINGS
DEBUG="off"
DEBUG_COMMANDS=0

LAPTOP_OUTPUT="eDP-1"
MAIN_DISPLAY="DP-5"
SECONDARY_DISPLAY="DP-4"
MINI_DISPLAY="DP-6"
BACKGROUND_IMAGE="/home/dariobf/.dariobf/wallpapers/FrameworkMoon.jpg"
WAYBAR_CONFIG="$HOME/.config/waybar/config.json"

log() {
    [[ "$DEBUG" != "off" ]] && echo "$1"
}

[[ $DEBUG == "log" ]] && exec >> /tmp/clamshell.log 2>&1
[[ $DEBUG_COMMANDS -eq 1 ]] && set -x

# Detect active outputs
active_outputs=$(hyprctl monitors -j | jq -r '.[] | select(.disabled == false) | .name')
num_outputs=$(echo "$active_outputs" | wc -l)
only_laptop=0
if [ "$num_outputs" -eq 1 ] && echo "$active_outputs" | grep -q "^$LAPTOP_OUTPUT$"; then
    only_laptop=1
fi

update_waybar_config() {
    if ! jq empty "$WAYBAR_CONFIG" 2>/dev/null; then
        echo "{}" > "$WAYBAR_CONFIG"
    fi

    tmpfile=$(mktemp)
    jq "$1" "$WAYBAR_CONFIG" > "$tmpfile" && mv "$tmpfile" "$WAYBAR_CONFIG"
}

assign_workspaces() {
    if [ "$1" = "close" ]; then
        hyprctl dispatch moveworkspacetomonitor 1 $MAIN_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 2 $MAIN_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 3 $MAIN_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 4 $MAIN_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 5 $SECONDARY_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 6 $SECONDARY_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 7 $SECONDARY_DISPLAY
        hyprctl dispatch moveworkspacetomonitor 8 $MINI_DISPLAY

        hyprctl dispatch focusmonitor "$MAIN_DISPLAY"
        hyprctl dispatch workspace 1

        hyprctl dispatch focusmonitor "$SECONDARY_DISPLAY"
        hyprctl dispatch workspace 5

        hyprctl dispatch focusmonitor "$MINI_DISPLAY"
        hyprctl dispatch workspace 8

        update_waybar_config '.["hyprland/workspaces"].persistent-workspaces = {
            "DP-5": [1, 2, 3, 4],
            "DP-4": [5, 6, 7],
            "DP-6": [8]
        }'

        log "Workspaces assigned: 1–4 to $MAIN_DISPLAY, 5–7 to $SECONDARY_DISPLAY, 8 to $MINI_DISPLAY"
    elif [ "$1" = "open" ]; then
        if echo "$active_outputs" | grep -vq "$LAPTOP_OUTPUT"; then
            log "External monitors active. Assigned workspace 1 to $LAPTOP_OUTPUT"
            hyprctl dispatch moveworkspacetomonitor 1 $LAPTOP_OUTPUT
            hyprctl dispatch moveworkspacetomonitor 2 $MAIN_DISPLAY
            hyprctl dispatch moveworkspacetomonitor 3 $MAIN_DISPLAY
            hyprctl dispatch moveworkspacetomonitor 4 $MAIN_DISPLAY
            hyprctl dispatch moveworkspacetomonitor 5 $SECONDARY_DISPLAY
            hyprctl dispatch moveworkspacetomonitor 6 $SECONDARY_DISPLAY
            hyprctl dispatch moveworkspacetomonitor 7 $SECONDARY_DISPLAY
            hyprctl dispatch moveworkspacetomonitor 8 $MINI_DISPLAY

            hyprctl dispatch focusmonitor "$LAPTOP_OUTPUT"
            hyprctl dispatch workspace 1

            hyprctl dispatch focusmonitor "$MAIN_DISPLAY"
            hyprctl dispatch workspace 2

            hyprctl dispatch focusmonitor "$SECONDARY_DISPLAY"
            hyprctl dispatch workspace 5

            hyprctl dispatch focusmonitor "$MINI_DISPLAY"
            hyprctl dispatch workspace 8

            update_waybar_config '.["hyprland/workspaces"].persistent-workspaces = {
                "eDP-1": [1],
                "DP-5": [2, 3, 4],
                "DP-4": [5, 6, 7],
                "DP-6": [8]
            }'
        else
            log "No external monitors active. All workspaces assigned to $LAPTOP_OUTPUT"
            for ws in {1..8}; do
                hyprctl dispatch moveworkspacetomonitor "$ws" $LAPTOP_OUTPUT
            done
            hyprctl dispatch workspace "1,monitor:$LAPTOP_OUTPUT"

            update_waybar_config '.["hyprland/workspaces"].persistent-workspaces = {
                "eDP-1": [1, 2, 3, 4, 5, 6, 7, 8]
            }'
        fi
    fi
    hyprctl dispatch workspace 1
    killall -SIGUSR2 waybar
}

log "Script invocation: $0 $*"
log "Active outputs: $active_outputs"
log "Only Laptop?    $only_laptop"

if [ "$1" = "close" ]; then
    log "Clamshell mode ON: Disabling laptop output."
    hyprctl keyword monitor "$LAPTOP_OUTPUT,disable"
    assign_workspaces close

    if [ "$only_laptop" -eq 1 ]; then
        log "Only laptop output active, locking and suspending."
        swaylock -f -i "$BACKGROUND_IMAGE" && systemctl suspend
    fi

elif [ "$1" = "open" ]; then
    log "Clamshell mode OFF: Enabling laptop output."
    hyprctl keyword monitor "$LAPTOP_OUTPUT,2256x1504,0x1440,1.566667"
    assign_workspaces open

elif [ "$1" = "reload" ]; then
    log "Reload detected: Checking clamshell status."
    if echo "$active_outputs" | grep -q "$LAPTOP_OUTPUT"; then
        "$0" open
    else
        "$0" close
    fi
fi

