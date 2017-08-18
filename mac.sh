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

# System configs, inspired by: https://github.com/mathiasbynens/dotfiles/blob/master/.macos

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"





# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Desktop
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

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
echo "All done"