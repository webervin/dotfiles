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

# ruby
eval "$(rbenv init -)"
export PATH="vendor/binstubs:$PATH"
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

brew install grep

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
HEREAPP
mas upgrade

# allow previous versions of apps:
brew tap caskroom/versions
# casks: '--force will reinstall things if needed'
grep -v '#' <<'HERECASK' | xargs -I '{}' brew cask install --verbose '{}'
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
jetbrains-toolbox
disk-inventory-x
firefox
google-chrome
HERECASK

# cask upgrade, until brew cask upgrade not implemented:
# https://github.com/buo/homebrew-cask-upgrade
brew tap buo/cask-upgrade
brew cu

# ruby:
brew install rbenv
eval "$(rbenv init -)"
brew install --HEAD ruby-build || brew upgrade --fetch-HEAD ruby-build || true
brew install rbenv-default-gems
echo "bundler" > "$(rbenv root)/default-gems"

GREP_CMD='grep'
if which ggrep; then
  GREP_CMD='ggrep'
fi
LATEST_RUBY="$(curl --silent --fail  'https://www.ruby-lang.org/en/downloads/' | ${GREP_CMD} -oP '(?<=The current stable version is )\d\.\d\.\d(?=\.)')"
rbenv install --keep --skip-existing --verbose "${LATEST_RUBY}"

save_heredoc_in "$HOME/.bundle/config" <<HEREDOC
---
BUNDLE_DISABLE_SHARED_GEMS: '1'
BUNDLE_BIN: vendor/binstubs
BUNDLE_PATH: vendor/bundle
BUNDLE_JOBS: '$(expr $(/usr/sbin/sysctl -n hw.ncpu) - 1)'
HEREDOC

save_heredoc_in "$HOME/.gemrc" <<HEREDOC
gem: --no-doc --verbose
HEREDOC

# Git
brew install git tig

save_heredoc_in "$HOME/.gitignore" <<HEREDOC
.DS_Store
vendor/bundle
vendor/binstubs
.bundle
.idea
HEREDOC

git config --global core.excludesfile ~/.gitignore
git config --global color.ui auto
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout
git config --global push.default current
git config --global branch.autosetuprebase always

# postgresql:
brew tap petere/postgresql
brew install postgresql-9.6
brew install --HEAD postgresql-common

echo "All done"