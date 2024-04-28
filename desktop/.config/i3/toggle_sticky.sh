##!/bin/bash

# Get the ID of the currently focused window
focused_window_id=$(xdotool getactivewindow)

# Toggle the sticky state of the focused window
i3-msg "[id=$focused_window_id]" sticky toggle
