#!/usr/bin/env bash

# REQUIREMENTS
# swaymsg, jq, swaylock, waybar

# ------------------------------
# SETTINGS
# ------------------------------

DEBUG="off"

LAPTOP_OUTPUT="eDP-1"
MAIN_DISPLAY="Dell Inc. DELL U2715H GH85D7CN014S"
SECONDARY_DISPLAY="Dell Inc. DELL U2715H GH85D74E1U4S"
MINI_DISPLAY="Synaptics Inc Non-PnP 0x00BC614E"

BACKGROUND_IMAGE="$HOME/.dariobf/wallpapers/FrameworkMoon.jpg"
WAYBAR_CONFIG="$HOME/.config/waybar/modules/sway/workspaces.jsonc"

log() {
  [[ "$DEBUG" != "off" ]] && echo "$1"
}

# ------------------------------
# OUTPUTS ACTIVOS
# ------------------------------

active_outputs=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active == true) | .name')
num_outputs=$(echo "$active_outputs" | wc -l)

only_laptop=0
if [ "$num_outputs" -eq 1 ] && echo "$active_outputs" | grep -q "^$LAPTOP_OUTPUT$"; then
  only_laptop=1
fi

# ------------------------------
# WAYBAR
# ------------------------------

# Devuelve el ID de un monitor dado su nombre/description
# $1 = nombre de la pantalla (por ejemplo "Dell Inc. DELL U2715H GH85D7CN014S")
# $1 = descripción del monitor, puede ser:
#   - nombre de Sway ("DP-11")
#   - combinación make+model+serial ("Dell Inc. DELL U2715H GH85D7CN014S")
get_output_id() {
  local name="$1"
  swaymsg -t get_outputs -r | jq -r --arg name "$name" '
    .[] | select(
        .name == $name or
        (.make + " " + .model + " " + .serial) == $name
    ) | .name
  ' | head -n1
}

update_waybar_config() {
  local json

  # Convertir nombres a IDs de Sway
  local MAIN_ID=$(get_output_id "$MAIN_DISPLAY")
  local SECONDARY_ID=$(get_output_id "$SECONDARY_DISPLAY")
  local MINI_ID=$(get_output_id "$MINI_DISPLAY")
  local LAPTOP_ID=$(get_output_id "$LAPTOP_OUTPUT")

  case "$1" in
  close)
    json=$(jq -n --arg main "$MAIN_ID" --arg sec "$SECONDARY_ID" --arg mini "$MINI_ID" '{
        "1": [$main],
        "2": [$main],
        "3": [$main],
        "4": [$sec],
        "5": [$sec],
        "6": [$mini]
      }')
    ;;
  open_only_laptop)
    json=$(jq -n --arg lap "$LAPTOP_ID" '{
        "1": [$lap],
        "2": [$lap],
        "3": [$lap],
        "4": [$lap],
        "5": [$lap],
        "6": [$lap]
      }')
    ;;
  open_external)
    json=$(jq -n --arg lap "$LAPTOP_ID" --arg main "$MAIN_ID" --arg sec "$SECONDARY_ID" --arg mini "$MINI_ID" '{
        "1": [$lap],
        "2": [$main],
        "3": [$main],
        "4": [$sec],
        "5": [$sec],
        "6": [$mini]
      }')
    ;;
  esac

  tmpfile=$(mktemp)
  jq ".\"sway/workspaces\".\"persistent-workspaces\" = $json" \
    "$WAYBAR_CONFIG" >"$tmpfile" && mv "$tmpfile" "$WAYBAR_CONFIG"

  pkill waybar
  waybar &
}

# ------------------------------
# WORKSPACES
# ------------------------------

assign_workspaces() {
  case "$1" in
  close)
    swaymsg "workspace 1 output \"$MAIN_DISPLAY\""
    swaymsg "workspace 2 output \"$MAIN_DISPLAY\""
    swaymsg "workspace 3 output \"$MAIN_DISPLAY\""

    swaymsg "workspace 4 output \"$SECONDARY_DISPLAY\""
    swaymsg "workspace 5 output \"$SECONDARY_DISPLAY\""

    swaymsg "workspace 6 output \"$MINI_DISPLAY\""

    swaymsg "focus output \"$MAIN_DISPLAY\"; workspace 1"

    update_waybar_config close
    ;;
  open)
    if echo "$active_outputs" | grep -vq "$LAPTOP_OUTPUT"; then
      swaymsg "workspace 1 output \"$LAPTOP_OUTPUT\""

      swaymsg "workspace 2 output \"$MAIN_DISPLAY\""
      swaymsg "workspace 3 output \"$MAIN_DISPLAY\""

      swaymsg "workspace 4 output \"$SECONDARY_DISPLAY\""
      swaymsg "workspace 5 output \"$SECONDARY_DISPLAY\""

      swaymsg "workspace 6 output \"$MINI_DISPLAY\""

      swaymsg "focus output \"$LAPTOP_OUTPUT\"; workspace 1"

      update_waybar_config open_external
    else
      for ws in {1..6}; do
        swaymsg "workspace $ws output \"$LAPTOP_OUTPUT\""
      done
      swaymsg "workspace 1"

      update_waybar_config open_only_laptop
    fi
    ;;
  esac
}

# ------------------------------
# MAIN
# ------------------------------

case "$1" in
close)
  log "Clamshell ON"
  swaymsg "output $LAPTOP_OUTPUT disable"
  assign_workspaces close

  if [ "$only_laptop" -eq 1 ]; then
    swaylock -f -i "$BACKGROUND_IMAGE"
    systemctl suspend
  fi
  ;;
open)
  log "Clamshell OFF"
  swaymsg "output $LAPTOP_OUTPUT enable"
  assign_workspaces open
  ;;
reload)
  if echo "$active_outputs" | grep -q "$LAPTOP_OUTPUT"; then
    "$0" open
  else
    "$0" close
  fi
  ;;
esac
