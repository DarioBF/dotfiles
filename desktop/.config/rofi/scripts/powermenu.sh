#!/usr/bin/env bash

DIR="$HOME/.config/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme $DIR/powermenu.rasi"

# Options
lock=" Lock"
suspend=" Suspend"
logout="󰍃 Logout"
reboot="󰜉 Reboot"
shutdown="󰐥 Shutdown"

# Confirmation prompt
confirm_exit() {
    echo -e "yes\nno" | rofi -dmenu \
        -no-config \
        -i \
        -p "Are you sure?" \
        -theme "$DIR/confirm.rasi"
}

# Error message
msg() {
    rofi -no-config -theme "$DIR/message.rasi" -e "Available options: yes / y / no / n"
}

# Main options
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"
chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"

case "$chosen" in
    "$shutdown")
        ans=$(confirm_exit)
        [[ "$ans" =~ ^(yes|y|YES|Y)$ ]] && systemctl poweroff || ([[ "$ans" =~ ^(no|n|NO|N)$ ]] || msg)
        ;;
    "$reboot")
        ans=$(confirm_exit)
        [[ "$ans" =~ ^(yes|y|YES|Y)$ ]] && systemctl reboot || ([[ "$ans" =~ ^(no|n|NO|N)$ ]] || msg)
        ;;
		"$lock")
			if command -v swaylock &>/dev/null; then
					swaylock
			elif command -v i3lock &>/dev/null; then
					i3lock
			elif command -v betterlockscreen &>/dev/null; then
					betterlockscreen -l
			else
					rofi -no-config -theme "$DIR/message.rasi" -e "No lock tool found (swaylock, i3lock, betterlockscreen)"
			fi
			;;
		"$suspend")
			ans=$(confirm_exit)
			if [[ "$ans" == "yes" || "$ans" == "YES" || "$ans" == "y" || "$ans" == "Y" ]]; then
					mpc -q pause &>/dev/null
					amixer set Master mute &>/dev/null

					if command -v swaylock &>/dev/null; then
							swaylock & sleep 1 && systemctl suspend
					elif command -v i3lock &>/dev/null; then
							i3lock && systemctl suspend
					elif command -v betterlockscreen &>/dev/null; then
							betterlockscreen -l && systemctl suspend
					else
							rofi -no-config -theme "$DIR/message.rasi" -e "No lock tool found (swaylock, i3lock, betterlockscreen)"
					fi
			elif [[ "$ans" == "no" || "$ans" == "NO" || "$ans" == "n" || "$ans" == "N" ]]; then
					exit 0
			else
					msg
			fi
			;;
    "$logout")
        ans=$(confirm_exit)
        if [[ "$ans" =~ ^(yes|y|YES|Y)$ ]]; then
            case "$DESKTOP_SESSION" in
                sway) swaymsg exit ;;
                Hyprland|hyprland) hyprctl dispatch exit || hyprctl dispatch stop ;;
                Openbox) openbox --exit ;;
                bspwm) bspc quit ;;
                i3) i3-msg exit ;;
                *) msg ;;
            esac
        elif [[ ! "$ans" =~ ^(no|n|NO|N)$ ]]; then
            msg
        fi
        ;;
esac
