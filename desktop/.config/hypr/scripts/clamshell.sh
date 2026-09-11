#!/usr/bin/env bash

# Redistribute workspaces across displays for the current lid/dock state.
#
# Omarchy owns the laptop panel itself: closing the lid with a monitor attached
# turns eDP-1 off, opening it turns it back on, and closing it with nothing
# attached locks and suspends. This script only decides which workspaces live
# on which display, and runs alongside those Omarchy handlers:
#
#   lid closed, docked   1 2 3 → main     4 5 → secondary   6 → mini
#   lid open, docked     1 → laptop   2 3 → main   4 5 → secondary   6 → mini
#   laptop only          1–6 → laptop
#
# A missing display falls back: mini → secondary → main → laptop.
#
# The layout is written to a Lua file that monitors.lua loads, so the config
# reload Omarchy does on every lid change keeps it instead of resetting it.
#
# Usage: clamshell.sh [open|close] [--dry-run]
#   open|close  lid state, passed by the lid switch binds; otherwise read from ACPI
#   --dry-run   print the layout without applying it

set -euo pipefail

LAPTOP="eDP-1"
MAIN="desc:Dell Inc. DELL U2715H GH85D7CN014S"
SECONDARY="desc:Dell Inc. DELL U2715H GH85D74E1U4S"
MINI="desc:DRS Defense Solutions LLC TYPE-C L56051794302"
MINI_HDMI="desc:Invalid Vendor Codename- RTK HDMI 0x01010101"

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/clamshell-workspaces.lua"
OMARCHY_TOGGLES="$HOME/.local/state/omarchy/toggles/hypr"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOG="$RUNTIME_DIR/hypr-clamshell.log"

lid=""
dry_run=0
for arg in "$@"; do
  case $arg in
    open | close) lid=$arg ;;
    --dry-run) dry_run=1 ;;
    *)
      echo "Usage: $(basename "$0") [open|close] [--dry-run]" >&2
      exit 1
      ;;
  esac
done

log() {
  printf '%s %s\n' "$(date +%T)" "$*" >>"$LOG"
}

# Lid events, monitor hotplug and login can all fire together; take turns.
exec 9>"$RUNTIME_DIR/hypr-clamshell.lock"
flock -w 10 9

if [[ -z $lid ]]; then
  if omarchy-hw-laptop-closed; then lid=close; else lid=open; fi
fi

monitors=$(hyprctl monitors all -j)

connected() {
  jq -e --arg desc "${1#desc:}" 'any(.[]; .description | startswith($desc))' <<<"$monitors" >/dev/null
}

# Any external counts as docked, including ones not listed above (a projector).
# Its connector name ends up in generated Lua, so only a plain name may pass.
other_external=$(jq -r '[.[] | select(.name | test("^(eDP|LVDS|DSI)-") | not) | .name][0] // empty' <<<"$monitors")
[[ -z $other_external || $other_external =~ ^[A-Za-z0-9._-]+$ ]] || other_external=""

laptop_on=1
if [[ -n $other_external ]]; then
  [[ $lid == close ]] && laptop_on=0
  # Omarchy's manual "toggle laptop display" and mirroring also take it away.
  [[ -f $OMARCHY_TOGGLES/internal-monitor-disable.lua ]] && laptop_on=0
  [[ -f $OMARCHY_TOGGLES/internal-monitor-mirror.lua ]] && laptop_on=0
fi

main=$LAPTOP
if connected "$MAIN"; then
  main=$MAIN
elif ((!laptop_on)); then
  main=$other_external
fi

secondary=$main
connected "$SECONDARY" && secondary=$SECONDARY

mini=$secondary
if connected "$MINI"; then
  mini=$MINI
elif connected "$MINI_HDMI"; then
  mini=$MINI_HDMI
fi

first=$main
((laptop_on)) && first=$LAPTOP

targets=([1]="$first" [2]="$main" [3]="$main" [4]="$secondary" [5]="$secondary" [6]="$mini")

# Each display's lowest workspace is its home: the one it shows at login, and
# the one it switches to after a change. Homes are focused highest first so
# workspace 1 ends up focused.
declare -A has_home=()
homes=()
rules=""
for ws in 1 2 3 4 5 6; do
  display=${targets[$ws]}
  default=false
  if [[ -z ${has_home[$display]:-} ]]; then
    has_home[$display]=1
    homes=("$ws" "${homes[@]}")
    default=true
  fi
  rules+="hl.workspace_rule({ workspace = \"$ws\", monitor = \"$display\", persistent = true, default = $default })"$'\n'
done

summary="lid $lid, laptop $( ((laptop_on)) && echo on || echo off)"

if ((dry_run)); then
  echo "$summary"
  printf '%s' "$rules"
  exit 0
fi

content="-- Written by ~/.config/hypr/scripts/clamshell.sh for: $summary"$'\n'"$rules"

if [[ -f $STATE_FILE && $(<"$STATE_FILE")$'\n' == "$content" ]]; then
  log "$summary: layout unchanged"
  exit 0
fi

mkdir -p "$(dirname "$STATE_FILE")"
tmp=$(mktemp "$STATE_FILE.XXXXXX")
printf '%s' "$content" >"$tmp"
mv "$tmp" "$STATE_FILE"

hyprctl eval "$rules" >/dev/null
log "$summary: applied"

# Opening the lid: Omarchy turns the panel back on around now. Workspaces can
# only move onto it once it's up, so wait for it and apply the rules again.
if ((laptop_on)) && [[ -n $other_external ]]; then
  for _ in {1..25}; do
    hyprctl monitors -j | jq -e --arg name "$LAPTOP" 'any(.[]; .name == $name)' >/dev/null && break
    sleep 0.2
  done
  hyprctl eval "$rules" >/dev/null
fi

for ws in "${homes[@]}"; do
  hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })" >/dev/null || true
done
