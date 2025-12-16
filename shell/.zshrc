# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Faster navigation
# -----------------
eval "$(zoxide init --cmd j bash)"
alias cd="j"
alias ji="zoxide query -i"
alias za="zoxide add"
alias zq="zoxide query"
alias zr="zoxide remove"

alias kitty="LIBGL_ALWAYS_SOFTWARE=true GALLIUM_DRIVER=llvmpipe kitty"

# NVM
# ---
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh >/dev/null 2>&1
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# nvm use 20 is too slow. Use this instead (with --no-use):
export NVM_BIN="${NVM_DIR}/versions/node/v20.19.4/bin"
PATH="${NVM_BIN}:${PATH}"

function cat() {
  if [[ "$#" -eq 1 && "$TERM" = xterm-kitty && "$(file "$1" | command grep -ci "image data")" -eq 1 ]]; then
    local aux
    aux="$(mktemp)"
    magick "$1" -resize "480x320>" -gravity center "$aux"
    kitten icat --align=left "$aux"
    identify "$1"
    rm "$aux"

  elif [[ "$#" -eq 1 ]]; then
    if [[ "$1" == "readme.txt" || "$1" == *.md || "$1" == *.markdown ]]; then
      local aux
      aux="$(mktemp --suffix=.md)"
      cp "$1" "$aux"
      glow -s tokyo-night --pager "$aux"
      rm "$aux"
    else
      bat --tabs 2 "$1"
    fi

  else
    bat --tabs 2 "$@"
  fi
}

alias df="dysk"
alias ping="prettyping --nolegend"
alias tree="lsd --group-dirs=first --tree"
alias vi="nvim"
alias vim="nvim"

alias dev='cd ~/DEV'
alias hosts='sudo nano /etc/hosts'

alias lerr='lando logs --s appserver -f'
alias lerr7='lando logs --s appserver -f | grep "\[php7:"'
alias lerr8='lando logs --s appserver -f | grep "\[php8:"'

alias almacen='sshfs dariobf@192.168.1.250:/media/almacen /media/Almacen'
alias bfserver='ssh dariobf@192.168.1.250'
alias homebackup='sudo mount -t cifs //192.168.1.135/DarioBF /media/HomeBackup -o username=dariobf,uid=$(id -u),gid=$(id -g),file_mode=0664,dir_mode=0775,vers=3.0,mfsymlinks'

alias mkwp="/home/dariobf/.dariobf/mkwp"
alias cleardev="ls | xargs rm -rf"
alias cleandev="ls | xargs rm -rf"

mkpot() {
  local domain output_dir output_file

  if [ -z "$1" ]; then
    echo "Buscando automáticamente el text-domain..."
    domain=$(ag -or --no-filename "_[_x]\([^)]+\)" . |
      sed -e 's/[ \(\)]//g' |
      awk -F',' '{print $NF}' |
      sort | uniq -c | sort -nr |
      head -n1 | cut -d"'" -f2)

    if [ -z "$domain" ]; then
      echo "No se pudo detectar el text-domain automáticamente."
      echo "Uso: mkpot <text-domain>"
      return 1
    fi

    echo "Text-domain detectado: ${domain}"
  else
    domain="$1"
  fi

  output_dir="lang"
  output_file="${output_dir}/${domain}.pot"

  # Crear carpeta si no existe
  [ ! -d "$output_dir" ] && mkdir -p "$output_dir"

  echo "Generando archivo POT para el dominio '${domain}'..."
  lando wp i18n make-pot . "$output_file" --domain="$domain"
}

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# export PATH="/home/dariobf/.lando/bin:$PATH"; #landopath
export PATH="./node_modules/.bin:$BUN_INSTALL/bin:./vendor/bin:$HOME/.config/composer/vendor/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.lando/bin:$PATH:/usr/bin/vendor_perl"
