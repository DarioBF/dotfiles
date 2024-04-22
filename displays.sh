#!/bin/bash

# Workspaces
ws1='1. Chats'
ws2='2. General'
ws3='3. DEV'
ws4='4. Design'
ws5='5. Others'

# Initialize primary and secondary monitors
primary=`xrandr | grep " connected primary" | awk '{print $1}'`
secondary=`xrandr | grep " connected [0-9]" | awk '{print $1}'`

if [ "$secondary" == "" ];
then
  secondary="$primary"
fi

# Open new workspace
if [ $# -eq 1 ];
then
  i3-msg workspace $1
fi

# Move workspaces
i3-msg workspace number $ws1 && i3-msg move workspace to output $secondary
i3-msg workspace number $ws2 && i3-msg move workspace to output $primary
i3-msg workspace number $ws3 && i3-msg move workspace to output $primary
i3-msg workspace number $ws4 && i3-msg move workspace to output $primary
i3-msg workspace number $ws5 && i3-msg move workspace to output $secondary
