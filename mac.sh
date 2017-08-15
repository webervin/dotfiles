#!/usr/bin/env bash

set -o pipefail
set -o errtrace
set -o nounset
set -o errexit

save_heredoc_in(){
  local target_file=${1}

  mkdir -vp "$(dirname ${target_file})"
  cat - > "${target_file}"
}


(xcode-select --install &&  read -p "Press [Enter] key when xcode finished install") || /usr/bin/true

