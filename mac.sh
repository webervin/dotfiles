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

if [ -f danger_mac ];then
  # Use to update defaults from third party, must review before use:
  # curl -v https://raw.githubusercontent.com/mathiasbynens/dotfiles/master/.macos | sed -e '/sudo/ s/^#*/# /'> danger_mac
  source danger_mac
fi

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
# screen saver delay is in seconds, must be 1, 2, 5, 10, 20, 30, or 60 minutes
# or it will reset to 20 minutes next time you open preferences
defaults -currentHost write com.apple.screensaver idleTime -int 120
osascript -e 'tell application "System Events" to set delay interval of screen saver preferences to 120'

# dock on left
defaults write com.apple.dock orientation -string left
# always show dock
defaults write com.apple.Dock autohide -bool FALSE
killall Dock

save_heredoc_in "$HOME/.aliases" <<'HEREDOC'
alias brewup='time (brew update && brew upgrade --all; brew cleanup; brew cask cleanup; brew doctor)'
alias gd='git diff --color-words'
alias gdc='git diff --cached --color-words'
alias gds='git diff --cached --color-words | sort | uniq -c | less -R'
alias rawsql='psql -P t -P format=unaligned --no-psqlrc'
HEREDOC
save_heredoc_in "$HOME/.profile" <<'HEREDOC'
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Aliases.
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

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

# work profile
if [ -f "$HOME/.work_profile" ]; then
  source "$HOME/.work_profile"
fi

# git prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  OLD_GITPROMPT=''
  PS1=''
  GIT_PROMPT_OLD_DIR_WAS_GIT=''
  PROMPT_COMMAND=''
  __GIT_PROMPT_DIR="$(brew --prefix)/opt/bash-git-prompt/share"
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

# Z
if [ -f "$(brew --prefix)/etc/profile.d/z.sh" ]; then
  _Z_NO_RESOLVE_SYMLINKS=''
  _Z_NO_PROMPT_COMMAND=''
  source "$(brew --prefix)/etc/profile.d/z.sh"
fi

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
1password
google-backup-and-sync
hex-fiend
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

save_heredoc_in "$HOME/.gemrc" <<HEREDOC
gem: --no-doc --verbose
HEREDOC

# Git
brew install python --without-sqlite --without-gdbm
pip2 install --upgrade pip setuptools
pip2 install git-sweep
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
POSTGRESQL_TARGET_VERSION='9.6'
brew tap petere/postgresql
brew install postgresql-${POSTGRESQL_TARGET_VERSION}
brew install --HEAD postgresql-common
if [ ! -d "$(brew --prefix)/var/lib/postgresql/${POSTGRESQL_TARGET_VERSION}/main" ]; then
  pg_createcluster -e UTF-8 --locale=en_US.UTF-8 ${POSTGRESQL_TARGET_VERSION} main  -- --data-checksums
fi

save_heredoc_in "$(brew --prefix)/etc/postgresql/${POSTGRESQL_TARGET_VERSION}/main/pg_hba.conf" <<CONF
local   all             $(whoami)                             peer

# No security for development
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
CONF
pg_ctlcluster ${POSTGRESQL_TARGET_VERSION} main start || pg_ctlcluster ${POSTGRESQL_TARGET_VERSION} main restart

# Misc tools and utilities:
brew install ncdu jq textql ack z

# update index for glocate
gupdatedb --localpaths="$HOME"

pg_96_version_number="$(brew info postgresql@9.6 | grep -F 'postgresql: stable' | grep --only-matching -e '\d\.\d\.\d')"
save_heredoc_in "$HOME/.bundle/config" <<HEREDOC
---
BUNDLE_DISABLE_SHARED_GEMS: '1'
BUNDLE_BIN: vendor/binstubs
BUNDLE_PATH: vendor/bundle
BUNDLE_JOBS: '$(expr $(/usr/sbin/sysctl -n hw.ncpu) - 1)'
BUNDLE_BUILD__PG: "--with-pg-config=$(brew --prefix)/Cellar/postgresql@9.6/${pg_96_version_number}/bin/pg_config"
HEREDOC

echo "All done"
