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

save_heredoc_in "$HOME/.profile" <<'HEREDOC'
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
HEREDOC

source "$HOME/.profile"


echo "All done"
