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

git clone https://github.com/davilera/dotfiles .davilera
chmod +x install.sh
./install.sh
cd "$SRC_BF"

#############################
title "Tweaking David's basics and setup my customs"
#############################
subtitle "Creating DEV directory"
mkdir ~/DEV

subtitle "Copying wallpaper to omarchy's folder"
cp "$SRC_BF"/wallpapers/FrameworkMoon.jpg ~/.config/omarchy/themes/catppuccin/backgrounds/4-framework-moon.jpg

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
