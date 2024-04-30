#!/bin/bash
# Need to create a udev rule in /etc/udev/rules.d/99-monitor-hotplug.rules
# which contains this line:
# KERNEL=="card0", SUBSYSTEM=="drm", ACTION=="change", ENV{DISPLAY}=":0", RUN+="/home/dariobf/.config/i3/scripts/displays.sh"

exec > /tmp/udev_script.log 2>&1
export DISPLAY=:0
export XAUTHORITY=/home/dariobf/.Xauthority

connected_screens=$(/usr/bin/xrandr | grep " connected" | awk '{print $1}')

# Laptop is connected to devstation
if echo "$connected_screens" | grep -q "DisplayPort-3" && echo "$connected_screens" | grep -q "DisplayPort-4"; then
	/usr/bin/xrandr --output eDP --off --output DisplayPort-3 --mode 2560x1440 --pos 0x0 --scale 1.25x1.25 --rotate normal --output DisplayPort-4 --primary --mode 2560x1440 --pos 3200x0 --scale 1.25x1.25 --rotate normal
	i3-msg restart
fi

# Laptop is disconnected from devstation
if echo "$connected_screens" | grep -q "^eDP$" && ! echo "$connected_screens" | grep -q "DisplayPort"; then
	/usr/bin/xrandr --output eDP --primary --mode 2256x1504 --scale 1x1 --rotate normal --output DisplayPort-0 --off --output DisplayPort-1 --off --output DisplayPort-2 --off --output DisplayPort-3 --off --output DisplayPort-4 --off --output DisplayPort-5 --off --output DisplayPort-6 --off --output DisplayPort-7 --off
	i3-msg restart
fi

# Workspaces
ws1='1. Chats'
ws2='2. General'
ws3='3. DEV'
ws4='4. Design'
ws5='5. Others'

# Inizialice primary and secondaru displays
primary=$(/usr/bin/xrandr | grep " connected primary" | awk '{print $1}')
secondary=$(/usr/bin/xrandr | grep " connected [0-9]" | awk '{print $1}')

if [ -z "$secondary" ]; then
	secondary="$primary"
fi

# Open new workspace
if [ $# -eq 1 ]; then
    /usr/bin/i3-msg workspace "$1"
fi

# Order workspaces
/usr/bin/i3-msg workspace number "$ws1" && /usr/bin/i3-msg move workspace to output "$secondary"
/usr/bin/i3-msg workspace number "$ws2" && /usr/bin/i3-msg move workspace to output "$primary"
/usr/bin/i3-msg workspace number "$ws3" && /usr/bin/i3-msg move workspace to output "$primary"
/usr/bin/i3-msg workspace number "$ws4" && /usr/bin/i3-msg move workspace to output "$primary"
/usr/bin/i3-msg workspace number "$ws5" && /usr/bin/i3-msg move workspace to output "$secondary"
