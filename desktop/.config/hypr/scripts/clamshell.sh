#!/usr/bin/env bash

# HELPERS & ENVs
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
  echo "Error: No se pudo encontrar HYPRLAND_INSTANCE_SIGNATURE. ¿Está Hyprland corriendo?"
  exit 1
fi

# SETTINGS
DEBUG="off" # Cambia a "off" cuando todo funcione correctamente
DEBUG_COMMANDS=0

LAPTOP_OUTPUT="eDP-1"
MAIN_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.description | test("DELL U2715H GH85D7CN014S")) | .name')
SECONDARY_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.description | test("DELL U2715H GH85D74E1U4S")) | .name')
MINI_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.description | test("TYPE-C L56051794302")) | .name')

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

# --- HELPERS HYPRLAND (parser Lua, Hyprland 0.56+ con config .lua) ---
# En modo Lua, `hyprctl dispatch <arg>` se evalua como `return hl.dispatch(<arg>)`,
# por lo que ya NO valen los comandos de texto ("workspace 1", "moveworkspacetomonitor ...").
# Hay que pasar dispatchers del namespace hl.dsp.* con tablas Lua, y usar `hyprctl eval`
# con hl.monitor(...) para (des)activar salidas (el antiguo `keyword monitor` tampoco funciona).
#
# ws_assign fija un workspace a un monitor de forma PERSISTENTE mediante una regla.
# A diferencia de hl.dsp.workspace.move (que solo mueve workspaces YA existentes, falla
# con los vacíos -> "Workspace not found", y no es permanente), hl.workspace_rule
# materializa el workspace aunque esté vacío y lo mantiene fijo en ese monitor. Además
# la regla hace MERGE, así que se conserva el default_name/icono definido en monitors.lua.
ws_assign() { hyprctl eval "hl.workspace_rule({ workspace = $1, monitor = \"$2\", persistent = true })"; }
focus_mon() { hyprctl dispatch "hl.dsp.focus({ monitor = \"$1\" })"; }
focus_ws() { hyprctl dispatch "hl.dsp.focus({ workspace = $1 })"; }
mon_disable() { hyprctl eval "hl.monitor({ output = \"$1\", disabled = true })"; }
# hl.monitor hace MERGE del estado, así que tras un mon_disable (disabled=true) hay que
# poner disabled=false explícitamente; con solo mode/position/scale la salida seguiría apagada.
mon_enable() { hyprctl eval "hl.monitor({ output = \"$1\", mode = \"$2\", position = \"$3\", scale = $4, disabled = false })"; }

# --- FUNCIONES ---

assign_workspaces() {
  if [ "$1" = "close" ]; then
    ws_assign 1 "$MAIN_DISPLAY"
    ws_assign 2 "$MAIN_DISPLAY"
    ws_assign 3 "$MAIN_DISPLAY"
    ws_assign 4 "$SECONDARY_DISPLAY"
    ws_assign 5 "$SECONDARY_DISPLAY"
    ws_assign 6 "$MINI_DISPLAY"

    focus_mon "$MINI_DISPLAY"
    focus_ws 6
    focus_mon "$SECONDARY_DISPLAY"
    focus_ws 4
    focus_mon "$MAIN_DISPLAY"
    focus_ws 1

    log "Workspaces assigned (close mode)."

  elif [ "$1" = "open" ]; then
    if echo "$active_outputs" | grep -vq "$LAPTOP_OUTPUT"; then
      ws_assign 1 "$LAPTOP_OUTPUT"
      ws_assign 2 "$MAIN_DISPLAY"
      ws_assign 3 "$MAIN_DISPLAY"
      ws_assign 4 "$SECONDARY_DISPLAY"
      ws_assign 5 "$SECONDARY_DISPLAY"
      ws_assign 6 "$MINI_DISPLAY"

      focus_mon "$MINI_DISPLAY"
      focus_ws 6
      focus_mon "$SECONDARY_DISPLAY"
      focus_ws 4
      focus_mon "$MAIN_DISPLAY"
      focus_ws 2
      focus_mon "$LAPTOP_OUTPUT"
      focus_ws 1
    else
      for ws in {1..8}; do
        ws_assign "$ws" "$LAPTOP_OUTPUT"
      done
      focus_mon "$LAPTOP_OUTPUT"
      focus_ws 1
    fi
  fi

  focus_ws 1
}

# --- EJECUCIÓN ---

log "Script invocation: $0 $*"
log "Active outputs: $active_outputs"
log "Only Laptop? $only_laptop"

if [ "$1" = "close" ]; then
  log "Clamshell mode ON: Disabling laptop output."
  assign_workspaces close

  if [ "$only_laptop" -eq 1 ]; then
    log "Only laptop output active, locking and suspending."
    systemctl suspend
  else
    # En config Lua: se desactiva la salida via hl.monitor(... disabled=true)
    mon_disable "$LAPTOP_OUTPUT"
  fi

elif [ "$1" = "open" ]; then
  log "Clamshell mode OFF: Enabling laptop output."
  # En config Lua: se reactiva/configura la salida via hl.monitor(...)
  mon_enable "$LAPTOP_OUTPUT" "2256x1504@60" "0x1440" "1.33"
  assign_workspaces open

elif [ "$1" = "reload" ]; then
  log "Reload detected: Checking clamshell status."
  if echo "$active_outputs" | grep -q "$LAPTOP_OUTPUT"; then
    "$0" open
  else
    "$0" close
  fi
fi
