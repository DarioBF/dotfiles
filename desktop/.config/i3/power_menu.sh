#!/bin/bash

# Definir las opciones del menú
options="Cerrar Sesión\nApagar\nReiniciar"

# Mostrar el menú usando Rofi
selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Selecciona una opción:")

# Realizar acciones basadas en la opción seleccionada
case "$selected_option" in
    "Cerrar Sesión")
        cinnamon-session-quit --logout
        ;;
    "Apagar")
        systemctl poweroff
        ;;
    "Reiniciar")
        systemctl reboot
        ;;
    *)
        echo "Opción inválida"
        ;;
esac
