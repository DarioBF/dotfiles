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

cd "$HOME"

if [ ! -d "$HOME/.davilera" ]; then
  subtitle "Cloning dotfiles repo"
  git clone https://github.com/davilera/dotfiles "$HOME/.davilera"
  cd "$HOME/.davilera"
  chmod +x install.sh
  ./install.sh
else
  subtitle "Directory ~/.davilera already exists. Skipping clone and install."
fi

cd "$SRC_BF"

#############################
title "Tweaking David's basics and setup my customs"
#############################

subtitle "Creating DEV directory"
mkdir -p ~/DEV
sudo mkdir -p /media
sudo mkdir -p /media/Almacen
sudo mkdir -p /media/HomeBackup

subtitle "Removing .gitconfig"
rm -f ~/.gitconfig

subtitle "Installing utilities"
sudo pacman -S --noconfirm cifs-utils nano
yay -S --noconfirm calcure bluetuith slack-desktop telegram-desktop

subtitle "Installing background"
NEW_BACKGROUND="$HOME/.config/omarchy/current/theme/backgrounds/4-framework-moon.jpg"
CURRENT_BACKGROUND_LINK="$HOME/.config/omarchy/current/background"

echo "Copying new background"
mkdir -p "$(dirname "$NEW_BACKGROUND")"
cp -f "$SRC_BF/wallpapers/FrameworkMoon.jpg" "$NEW_BACKGROUND"

echo "Linking background"
ln -nsf "$NEW_BACKGROUND" "$CURRENT_BACKGROUND_LINK"

echo "Restarting swaybg"
pkill -x swaybg
echo "uwsm app"
nohup uwsm app -- swaybg -i "$CURRENT_BACKGROUND_LINK" -m fill >/dev/null 2>&1 &

subtitle "Configuring my bash"
rm -f ~/.bashrc
stow shell

subtitle "Cleaning bloatware"
APP_NAMES=("Basecamp" "Discord" "GitHub" "Google Contacts" "Google Messages" "Google Photos" "HEY" "X" "YouTube")
omarchy-webapp-remove "${APP_NAMES[@]}"

sudo pacman -Rns --no-confirm 1password-beta 1password-cli typora

subtitle "Overriding hyprland and waybar settings"
rm -rf ~/.config/hypr
rm -rf ~/.config/waybar
stow desktop

gum confirm "End install and reboot" && sudo reboot

# Maybe TODO
# Para configurar nvim bien
# cd ~/.local/share
# mv nvim nvim.bkp
