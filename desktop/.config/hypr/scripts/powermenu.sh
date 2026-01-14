#!/usr/bin/env bash

options=" Apagar\n Reiniciar\n Suspender\n Bloquear\n Cerrar sesión"

chosen=$(echo -e "$options" | rofi -dmenu \
  -i \
  -p "Power" \
  -show-icons)

case "$chosen" in
" Shutdown")
  systemctl poweroff
  ;;
" Reboot")
  systemctl reboot
  ;;
" Suspend")
  systemctl suspend
  ;;
" Lock")
  loginctl lock-session
  ;;
" Logout")
  hyprctl dispatch exit
  ;;
esac
