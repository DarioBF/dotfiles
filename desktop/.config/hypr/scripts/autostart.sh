#!/bin/bash

# ~/.config/hypr/scripts/autostart.sh

pgrep -x waybar > /dev/null || waybar &
pgrep -x hyprpaper > /dev/null || hyprpaper &
pgrep -x firefox > /dev/null || firefox &
