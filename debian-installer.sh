#!/usr/bin/zsh
############################
# install.sh
############################

## Script prepared for debian

cd "`dirname $0`"
SRC_DIR=`pwd`

echo "Updating apt packages…"
sudo apt-get -qq update
sudo apt-get -qq upgrade
sudo apt-get -qq install curl zsh

echo ""
echo "======"
echo "SYSTEM"
echo "======"

echo "Installing dev packages…"
sudo apt-get -qq -y install stow fasd tree meld jq vim ruby subversion composer php-xml  curl g++ build-essential kitty openjdk-17-jdk openjdk-17-jre python3-pip golang cargo luarocks markdown
sudo update-alternatives --set editor /usr/bin/vim.basic

echo "Installing utilities…"
sudo apt-get -qq -y install btop fastfetch htop imagemagick libimage-exiftool-perl poedit myspell-es aspell-es silversearcher-ag ripgrep

echo "Installing nvm, node.js, and npm…"
rm -rf ~/.nvm >/dev/null 2>&1
mkdir ~/.nvm
version=`wget -qO- "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r .tag_name`
wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" | bash >/dev/null 2>&1
\. ~/.nvm/nvm.sh
nvm install node 2>/dev/null

echo "Installing neovim LSP servers…"
npm install -g eslint_d >/dev/null 2>&1
npm install -g prettier@npm:wp-prettier@latest 2>&1
npm install -g typescript typescript-language-server >/dev/null 2>&1
npm install -g @elm-tooling/elm-language-server >/dev/null 2>&1
npm install -g emmet-ls >/dev/null 2>&1
npm install -g intelephense >/dev/null 2>&1
npm install -g vscode-langservers-extracted >/dev/null 2>&1

cd $SRC_DIR 2>/dev/null
stow --no-folding composer >/dev/null 2>&1
composer global install >/dev/null 2>&1
cd - 2>/dev/null

echo ""
echo -n "Do you want to install Docker and Lando? (y/N) "
read answer
if [ "$answer" = "y" ];
then
	echo "Removing any old Docker versions…"
	sudo apt remove docker docker-engine docker.io containerd runc

	echo "Setting up the apt repository…"
	sudo apt-get install ca-certificates curl gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo \
  	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  	  $(. /etc/os-release && echo "bookworm") stable" | \
  	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	  sudo apt-get update

	echo "Installing docker…"
	sudo apt-get -qq -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	echo "Configuring docker…"
	sudo groupadd docker >/dev/null 2>&1
	sudo usermod -aG docker $USER
	sudo newgrp docker
	echo "Docker installed"

	echo "Installing Lando..."
	/bin/bash -c "$(curl -fsSL https://get.lando.dev/setup-lando.sh)"
fi

echo ""
echo "Updating apt packages…"
sudo apt-get -qq update

echo "Upgrading system…"
sudo apt-get -qq upgrade

echo "Cleaning unnecessary packages…"
sudo apt-get -qq autoremove >/dev/null 2>&1
sudo apt-get -qq autoclean >/dev/null 2>&1

echo ""
echo "====================="
echo "DEVELOPMENT UTILITIES"
echo "====================="

echo "Creating development directory…"
mkdir -p ~/DEV 2>/dev/null

echo "Copying mkwp script to development directory…"
cp mkwp ~/DEV
chmod +x ~/DEV/mkwp

echo "Installing oh-my-zsh…"
rm -rf ~/.oh-my-zsh 2>&1 >/dev/null
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm -f ~/.zshrc ~/.zshrc.pre-oh-my-zsh

echo "Adding zsh plugins…"
sudo apt install zsh-syntax-highlighting

echo "Installing neovim…"
sudo apt -qq -y install libfuse2
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

echo "Installing lunarvim…"
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

echo "Configuring things with stow"
mkdir -p ~/.local/bin 2>/dev/null
cd $SRC_DIR 2>/dev/null
rm -rf ~/.zshrc ~/.bashrc ~/.config/lvim/config.lua 2>/dev/null

stow kitty
stow lvim
stow shell

echo ""
echo "DONETE"
