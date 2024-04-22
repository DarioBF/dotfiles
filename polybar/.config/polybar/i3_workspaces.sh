#!/bin/bash

# Obtener la lista de espacios de trabajo y su estado desde i3-msg
WORKSPACES=$(i3-msg -t get_workspaces)

# Iterar sobre cada espacio de trabajo y mostrar su nombre y estado
for row in $(echo "${WORKSPACES}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

    NAME=$(_jq '.name')
    FOCUSED=$(_jq '.focused')
    ACTIVE=$(_jq '.visible')

    if [ "${FOCUSED}" = "true" ]; then
        echo "%{F#00FF00}${NAME}%{F-}"
    elif [ "${ACTIVE}" = "true" ]; then
        echo "%{F#FFFF00}${NAME}%{F-}"
    else
        echo "${NAME}"
    fi
done
