#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config
polybar mybar &

echo "Polybar launched..."

# Obtener el monitor primario
PRIMARY_MONITOR=$(xrandr --query | grep " primary" | cut -d" " -f1)

if type "xrandr"; then
    # Obtener la lista de monitores activos
    ACTIVE_MONITORS=$(xrandr --query | grep " connected" | grep -v "disconnected" | cut -d" " -f1)

    # Lanzar Polybar en cada monitor activo, excepto en el monitor primario
    for m in $ACTIVE_MONITORS; do
        if [ "$m" != "$PRIMARY_MONITOR" ]; then
            MONITOR=$m polybar --reload mybar &
        fi
    done
else
    # Si xrandr no está disponible, lanzar Polybar en todos los monitores
    polybar --reload mybar &
fi

# Lanzar Polybar en el monitor primario si no se ha lanzado ya
if [ -n "$PRIMARY_MONITOR" ] && ! pgrep -x polybar >/dev/null; then
    MONITOR=$PRIMARY_MONITOR polybar --reload mybar &
fi

