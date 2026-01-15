#!/usr/bin/env bash

# REQUIREMENTS
# swaylock

# HELPERS
export WAYLAND_DISPLAY=wayland-1 # Cambia a wayland-0 si es necesario
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Accede directamente a la variable de entorno HYPRLAND_INSTANCE_SIGNATURE
echo "HYPRLAND_INSTANCE_SIGNATURE: $HYPRLAND_INSTANCE_SIGNATURE"

if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
  echo "Error: No se pudo encontrar HYPRLAND_INSTANCE_SIGNATURE. ¿Está Hyprland corriendo?"
  exit 1
fi

# SETTINGS
DEBUG="off"
DEBUG_COMMANDS=0

LAPTOP_OUTPUT="eDP-1"
MAIN_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.description | test("DELL U2715H GH85D7CN014S")) | .name')
SECONDARY_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.description | test("DELL U2715H GH85D74E1U4S")) | .name')
MINI_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.description | test("TYPE-C L56051794302")) | .name')
BACKGROUND_IMAGE="$HOME/.dariobf/wallpapers/FrameworkMoon.jpg"
WAYBAR_CONFIG="$HOME/.config/waybar/config"

MAIN_DISPLAY=${MAIN_DISPLAY:-$LAPTOP_OUTPUT}
SECONDARY_DISPLAY=${SECONDARY_DISPLAY:-$LAPTOP_OUTPUT}
MINI_DISPLAY=${MINI_DISPLAY:-$SECONDARY_DISPLAY}

log() {
  [[ "$DEBUG" != "off" ]] && echo "$1"
}

[[ $DEBUG == "log" ]] && exec >>/tmp/clamshell.log 2>&1
[[ $DEBUG_COMMANDS -eq 1 ]] && set -x

# Detect active outputs
active_outputs=$(hyprctl monitors -j | jq -r '.[] | select(.disabled == false) | .name')
num_outputs=$(echo "$active_outputs" | wc -l)
only_laptop=0
if [ "$num_outputs" -eq 1 ] && echo "$active_outputs" | grep -q "^$LAPTOP_OUTPUT$"; then
  only_laptop=1
fi

# --- FUNCIONES ---

update_waybar_config() {
  # $1 = modo: "close", "open_external" o "open_only_laptop"
  local json
  if [ "$1" = "close" ]; then
    json=$(jq -n --arg main "$MAIN_DISPLAY" --arg sec "$SECONDARY_DISPLAY" --arg mini "$MINI_DISPLAY" '{
            ($main): [1,2,3,4],
            ($sec): [5,6,7],
            ($mini): [8]
        }')
  elif [ "$1" = "open_only_laptop" ]; then
    json=$(jq -n --arg lap "$LAPTOP_OUTPUT" '{
            ($lap): [1,2,3,4,5,6,7,8]
        }')
  elif [ "$1" = "open_external" ]; then
    json=$(jq -n --arg lap "$LAPTOP_OUTPUT" --arg main "$MAIN_DISPLAY" --arg sec "$SECONDARY_DISPLAY" --arg mini "$MINI_DISPLAY" '{
            ($lap): [1],
            ($main): [2,3,4],
            ($sec): [5,6,7],
            ($mini): [8]
        }')
  fi

  tmpfile=$(mktemp)
  jq ".\"hyprland/workspaces\".\"persistent-workspaces\" = $json" \
    "$WAYBAR_CONFIG" >"$tmpfile" && mv "$tmpfile" "$WAYBAR_CONFIG"

  pkill waybar && hyprctl dispatch exec waybar
}

assign_workspaces() {
  if [ "$1" = "close" ]; then
    # Asignar workspaces al cerrar la tapa
    hyprctl dispatch moveworkspacetomonitor 1 $MAIN_DISPLAY
    hyprctl dispatch moveworkspacetomonitor 2 $MAIN_DISPLAY
    hyprctl dispatch moveworkspacetomonitor 3 $MAIN_DISPLAY
    hyprctl dispatch moveworkspacetomonitor 4 $SECONDARY_DISPLAY
    hyprctl dispatch moveworkspacetomonitor 5 $SECONDARY_DISPLAY
    hyprctl dispatch moveworkspacetomonitor 6 $MINI_DISPLAY

    hyprctl dispatch focusmonitor "$MINI_DISPLAY"
    hyprctl dispatch workspace 6
    hyprctl dispatch focusmonitor "$SECONDARY_DISPLAY"
    hyprctl dispatch workspace 4
    hyprctl dispatch focusmonitor "$MAIN_DISPLAY"
    hyprctl dispatch workspace 1

    update_waybar_config close
    log "Workspaces assigned (close mode)."

  elif [ "$1" = "open" ]; then
    if echo "$active_outputs" | grep -vq "$LAPTOP_OUTPUT"; then
      # Monitores externos activos
      hyprctl dispatch moveworkspacetomonitor 1 $LAPTOP_OUTPUT
      hyprctl dispatch moveworkspacetomonitor 2 $MAIN_DISPLAY
      hyprctl dispatch moveworkspacetomonitor 3 $MAIN_DISPLAY
      hyprctl dispatch moveworkspacetomonitor 4 $MAIN_DISPLAY
      hyprctl dispatch moveworkspacetomonitor 5 $SECONDARY_DISPLAY
      hyprctl dispatch moveworkspacetomonitor 6 $MINI_DISPLAY

      hyprctl dispatch focusmonitor "$MINI_DISPLAY"
      hyprctl dispatch workspace 6
      hyprctl dispatch focusmonitor "$SECONDARY_DISPLAY"
      hyprctl dispatch workspace 4
      hyprctl dispatch focusmonitor "$MAIN_DISPLAY"
      hyprctl dispatch workspace 2
      hyprctl dispatch focusmonitor "$LAPTOP_OUTPUT"
      hyprctl dispatch workspace 1

      update_waybar_config open_external
    else
      # Solo laptop activo
      for ws in {1..8}; do
        hyprctl dispatch moveworkspacetomonitor "$ws" $LAPTOP_OUTPUT
      done
      hyprctl dispatch workspace "1,monitor:$LAPTOP_OUTPUT"

      update_waybar_config open_only_laptop
    fi
  fi

  hyprctl dispatch workspace 1

  # Recarga Waybar o lo inicia si no está corriendo
  # if pgrep -x waybar >/dev/null; then
  #   pkill -USR1 waybar
  # else
  #   nohup waybar >/dev/null 2>&1 &
  # fi
}

# --- EJECUCIÓN ---

log "Script invocation: $0 $*"
log "Active outputs: $active_outputs"
log "Only Laptop? $only_laptop"

if [ "$1" = "close" ]; then
  log "Clamshell mode ON: Disabling laptop output."
  hyprctl keyword monitor "$LAPTOP_OUTPUT,disable"
  assign_workspaces close

  if [ "$only_laptop" -eq 1 ]; then
    log "Only laptop output active, locking and suspending."
    # swaylock -f -i "$BACKGROUND_IMAGE" && systemctl suspend
    hyprlock
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
