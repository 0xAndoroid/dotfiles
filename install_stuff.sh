#!/bin/bash

# Define color codes for output messages
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Helper function to print status messages
print_status() {
  local status=$1
  local message=$2
  
  if [ "$status" == "installed" ]; then
    echo -e "${GREEN}✓ ${message} - successfully installed${NC}"
  elif [ "$status" == "exists" ]; then
    echo -e "${YELLOW}⚠ ${message} - already installed${NC}"
  fi
}

echo "Setting macOS defaults..."
# make dock quickly disappear and appear
defaults write com.apple.dock autohide-delay -int 0
defaults write com.apple.dock autohide-time-modifier -float 0
killall Dock

# Set Global macOS preferences
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
echo -e "${GREEN}✓ macOS preferences configured${NC}"

# Install Homebrew if not already installed
echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_status "installed" "Homebrew"
else
  print_status "exists" "Homebrew"
fi

# Install Oh My Zsh if not already installed
echo "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  print_status "installed" "Oh My Zsh"
else
  print_status "exists" "Oh My Zsh"
fi

# Install Powerlevel10k theme
echo "Checking for Powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  print_status "installed" "Powerlevel10k"
else
  print_status "exists" "Powerlevel10k"
fi

# Install zsh-autosuggestions plugin
echo "Checking for zsh-autosuggestions..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  print_status "installed" "zsh-autosuggestions"
else
  print_status "exists" "zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting plugin
echo "Checking for zsh-syntax-highlighting..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting plugin..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  print_status "installed" "zsh-syntax-highlighting"
else
  print_status "exists" "zsh-syntax-highlighting"
fi

# Install zsh-vi-mode plugin
echo "Checking for zsh-vi-mode..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode" ]; then
  echo "Installing zsh-vi-mode plugin..."
  git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
  print_status "installed" "zsh-vi-mode"
else
  print_status "exists" "zsh-vi-mode"
fi

# Install Rust if not already installed
echo "Checking for Rust..."
if ! command -v rustc &> /dev/null; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  print_status "installed" "Rust"
else
  print_status "exists" "Rust"
fi

# Ensure we have cargo in PATH
source "$HOME/.cargo/env" 2>/dev/null || true

# Install cargo-binstall if not already installed
echo "Checking for cargo-binstall..."
if ! command -v cargo-binstall &> /dev/null; then
  echo "Installing cargo-binstall..."
  cargo install cargo-binstall
  print_status "installed" "cargo-binstall"
else
  print_status "exists" "cargo-binstall"
fi

# Function to install Rust tools with cargo-binstall
install_cargo_tool() {
  local tool=$1
  echo "Checking for $tool..."
  if ! command -v "$tool" &> /dev/null && ! cargo install --list | grep -q "$tool"; then
    echo "Installing $tool..."
    cargo binstall "$tool" -y
    print_status "installed" "$tool"
  else
    print_status "exists" "$tool"
  fi
}

# Install Rust tools
install_cargo_tool cargo-audit
install_cargo_tool bob-nvim
install_cargo_tool cargo-cache
install_cargo_tool cargo-edit
install_cargo_tool cargo-nextest
install_cargo_tool cargo-update
install_cargo_tool cargo-watch
# Commented out tools
# install_cargo_tool circom
# install_cargo_tool circom-lsp
install_cargo_tool du-dust
install_cargo_tool just
install_cargo_tool loc
install_cargo_tool mdbook
install_cargo_tool svm-rs
install_cargo_tool tree-sitter-cli
install_cargo_tool trunk
install_cargo_tool typstyle
install_cargo_tool wasm-bindgen-cli
install_cargo_tool typos-cli
install_cargo_tool tomlq

echo -e "${GREEN}All installations complete!${NC}"
