#!/bin/bash

set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo "Setting macOS defaults..."

# Dock: quickly disappear and appear
defaults write com.apple.dock autohide-delay -int 0
defaults write com.apple.dock autohide-time-modifier -float 0
killall Dock

# Global macOS preferences
echo "Configuring global macOS preferences..."
defaults write NSGlobalDomain AppleICUForce24HourTime -int 1
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -int 0
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -int 0
defaults write NSGlobalDomain ApplePressAndHoldEnabled -int 0
defaults write NSGlobalDomain AppleShowAllExtensions -int 1
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -int 0
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -int 0
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -int 0
defaults write NSGlobalDomain "com.apple.mouse.scaling" -string "0.5"
defaults write NSGlobalDomain "com.apple.scrollwheel.scaling" -string "0.125"
defaults write NSGlobalDomain "com.apple.sound.beep.flash" -int 0
defaults write NSGlobalDomain "com.apple.springing.delay" -string "0.5"
defaults write NSGlobalDomain "com.apple.springing.enabled" -int 1
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -int 1
defaults write NSGlobalDomain "com.apple.trackpad.forceClick" -int 1
defaults write NSGlobalDomain "_HIHideMenuBar" -int 0
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -int 0

echo -e "${GREEN}macOS preferences configured${NC}"
