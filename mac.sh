#!/usr/bin/env bash

set -o pipefail
set -o errtrace
set -o nounset
set -o errexit
set -x
save_heredoc_in(){
  local target_file=${1}

  mkdir -vp "$(dirname ${target_file})"
  cat - > "${target_file}"
}


(xcode-select --install &&  read -p "Press [Enter] key when xcode finished install") || /usr/bin/true

save_heredoc_in "$HOME/.profile" <<'HEREDOC'
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Brew:
export PATH="$HOME/tools/brew/bin:$PATH"
export HOMEBREW_NO_ANALYTICS=1
# Brew GNU utilities:
export PATH="$HOME/tools/brew/opt/coreutils/libexec/gnubin:$PATH"
# Brew casks:
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"
HEREDOC

source "$HOME/.profile"

if [ ! -d "$HOME/tools/brew" ]; then
  mkdir -vp "$HOME/tools"
  git clone https://github.com/Homebrew/homebrew "$HOME/tools/brew"
fi

brew update
brew analytics off

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

brew install bash bash-git-prompt

# app store stuff: https://github.com/mas-cli/mas
brew install mas
cut -d' ' -f1 <<'HEREAPP' | xargs -I '{}' mas install '{}'
715768417 Microsoft Remote Desktop
638161122 YubiKey Personalization Tool
1024640650 CotEditor
957734279 Toggl Desktop
803453959 Slack
425424353 The Unarchiver
1014850245 MONIT
414030210 LimeChat
HEREAPP
mas upgrade

# casks:
grep -v '#' <<'HERECASK' | xargs -I '{}' brew cask install --verbose --force '{}'
caffeine
dropbox
iterm2
keepassx
libreoffice
pgadmin3
skype
spotify
spotify-notifications
sql-tabs
vlc
firefox
sequential
android-file-transfer
chromecast
jetbrains-toolbox
disk-inventory-x
firefox
google-chrome
HERECASK

# cask upgrade, until brew cask upgrade not implemented:
# https://github.com/buo/homebrew-cask-upgrade
https://github.com/buo/homebrew-cask-upgrade
brew cu

echo "All done"