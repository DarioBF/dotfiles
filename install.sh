#!/usr/bin/bash

cd "$(dirname "$0")"
SRC_BF=$(pwd)

title() {
	echo ""
	gum style --trim --border=thick --padding="1 10" "$1"
	echo ""
}

subtitle() {
	echo ""
	gum style --trim --foreground=6 "$1"
}

#############################
title "Let's clone David Aguilera's cool basic settings"
#############################
cd /home/dariobf/
git clone https://github.com/davilera/dotfiles .davilera
cd .davilera
chmod +x install.sh
./install.sh
cd "$SRC_BF"

#############################
title "Tweaking David's basics and setup my customs"
#############################
subtitle "Creating DEV directory"
mkdir ~/DEV

subtitle "Removing .gitconfig"
rm ~/.gitconfig

subtitle "Installing utilities"
sudo pacman -S cifs-utils nano

subtitle "Installing background"
NEW_BACKGROUND="$HOME/.config/omarchy/current/theme/backgrounds/4-framework-moon.jpg"
CURRENT_BACKGROUND_LINK="$HOME/.config/omarchy/current/background"
cp -f "$SRC_BF/wallpapers/FrameworkMoon.jpg" "$NEW_BACKGROUND"
ln -nsf "$NEW_BACKGROUND" "$CURRENT_BACKGROUND_LINK"
pkill -x swaybg
setsid uwsm app -- swaybg -i "$CURRENT_BACKGROUND_LINK" -m fill >/dev/null 2>&1

subtitle "Configuring my bash"
rm ~/.bashrc
stow shell

subtitle "Overriding hyprland and waybar settings"
rm -rf ~/.config/hypr
rm -rf ~/.config/waybar
stow desktop

gum confirm "Relaunch Hyprland to use new settings?" && uwsm stop

# Maybe TODO
#Para configurar nvim bien
#cd ~/.local/share
#mv nvim nvim.bkp
