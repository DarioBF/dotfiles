alias pass="echo dummy"
source ~/.davilera/shell/.bashrc
unalias pass
unset aws

alias bat='batcat'

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

alias batteryhealth="upower -i /org/freedesktop/UPower/devices/battery_BAT1"

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

pot2pos() {
  # 1. Parámetros de entrada
  local input_pot="$1"
  local output_dir="${2%/}" # Limpia la barra final si existe

  # Verificación de parámetros básicos
  if [ -z "$input_pot" ] || [ -z "$output_dir" ]; then
    echo "Uso: pot2pos archivo.pot ruta/del/directorio/"
    return 1
  fi

  if [ ! -f "$input_pot" ]; then
    echo "Error: El archivo '$input_pot' no existe."
    return 1
  fi

  # 2. Intentar crear el directorio y validar permisos
  if ! mkdir -p "$output_dir" 2>/dev/null; then
    echo "Error: No se pudo crear el directorio '$output_dir'. Permiso denegado."
    echo "Prueba usando una ruta relativa (ej: 'po/' en lugar de '/po/')."
    return 1
  fi

  # 3. Extraer el text-domain directamente del nombre del fichero .pot
  local domain=$(basename "$input_pot" .pot)

  # 4. Lista de locales (limpia y única)
  local locales=$(echo "
        ceb_PH et haw_US is_IS ky_KG mn pa_IN sl_SI ta_IN xh_ZA 
        af cs_CZ eu he_XA it_IT la mr pl_PL sm_WS te_IN yi_US 
        am cy_GB fa_IR hi_IN ja lb_LU ms_MY pt_BR sn_ZW tg_TJ yo 
        ar da_DK fi hmn jw_ID lo mt_MT pt_XA so_SO th zh_XB 
        az de_DE fr_FR hr ka_GE lt_LT my_MM qu sq tl zh_XC 
        be_BY el fy_NL ht_HT kk lv nb_NO ro_RO sr_RS tr_TR zu_ZA 
        bg_BG ga hu_HU km mg_MG ne_NP ru_RU st_ZA uk_UA 
        bn_BD en_US gd hy kn mi_NZ nl_NL sd_PK su_ID ur_PK 
        bs_BA eo gu id_ID ko_KR mk_MK nn_NO si_LK sv_SE uz_UZ 
        ca es_ES ha ig_NG ku ml_IN ny_MW sk_SK sw_KE vi
    " | tr -s ' ' '\n' | sed 's/\..*//' | sort -u | grep -v '^$')

  echo "Generando archivos .po en '$output_dir' usando el dominio: $domain"

  # 5. Bucle de generación
  for lang in $locales; do
    # Formato estándar: directorio/dominio-locale.po
    local output_file="${output_dir}/${lang}.po"

    echo " -> Creando: ${lang}.po"

    # Generamos el archivo
    msginit --input="$input_pot" \
      --locale="${lang}.UTF-8" \
      --output="$output_file" \
      --no-translator

    # CORRECCIÓN DE CABECERA:
    # Forzamos que el campo Language sea exacto (ej. es_ES en lugar de es)
    # Esto es vital para la compatibilidad total con WordPress
    sed -i "s/\"Language: .*/\"Language: ${lang}\\\\n\"/" "$output_file"
  done

  echo "------------------------------------------"
  echo "¡Listo! Todos los archivos generados con éxito."
}

eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
