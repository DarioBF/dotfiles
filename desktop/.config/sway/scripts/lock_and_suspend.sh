#!/bin/bash
exec > /tmp/lock_and_suspend.log 2>&1
set -x

LAPTOP_OUTPUT="eDP-1"

# Función para comprobar si solo eDP-1 está activo
is_only_laptop_output_active() {
    # Obtener el número de salidas activas
    active_outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')
    count_active_outputs=$(echo "$active_outputs" | wc -l)
    
    # Comprobar si solo hay una salida activa y si es eDP-1
    if [ "$count_active_outputs" -eq 1 ] && [ "$active_outputs" == "$LAPTOP_OUTPUT" ]; then
        return 0  # True
    else
        return 1  # False
    fi
}

# Comprobar si solo está activo eDP-1 y ejecutar swaylock y systemctl suspend si es así
if is_only_laptop_output_active; then
    /usr/bin/swaylock -f -i "/home/dariobf/.config/sway/wallpapers/purple_landscape.jpg" -c 000000 && /usr/bin/systemctl suspend
fi
