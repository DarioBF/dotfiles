alias pass="echo dummy"
source ~/.davilera/shell/.bashrc
unalias pass
unset aws

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
