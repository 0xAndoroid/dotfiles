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

# Install packages from Brewfile
echo "Installing packages from Brewfile..."
if [ -f "$HOME/.dotfiles/Brewfile" ]; then
  brew bundle --file="$HOME/.dotfiles/Brewfile"
  echo -e "${GREEN}✓ Brewfile packages installed${NC}"
elif [ -f "$(pwd)/Brewfile" ]; then
  brew bundle --file="$(pwd)/Brewfile"
  echo -e "${GREEN}✓ Brewfile packages installed${NC}"
else
  echo -e "${YELLOW}⚠ Brewfile not found, skipping brew bundle${NC}"
fi

# Install Oh My Zsh if not already installed
echo "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  # Backup existing .zshrc if it exists
  if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
  fi

  # Install Oh My Zsh without overriding .zshrc
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Restore the original .zshrc if it was backed up
  if [ -f "$HOME/.zshrc.backup" ]; then
    mv "$HOME/.zshrc.backup" "$HOME/.zshrc"
    echo -e "${GREEN}✓ Original .zshrc restored${NC}"
  fi

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

# Install zsh-defer plugin
echo "Checking for zsh-defer..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-defer" ]; then
  echo "Installing zsh-defer plugin..."
  git clone https://github.com/romkatv/zsh-defer.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-defer"
  print_status "installed" "zsh-defer"
else
  print_status "exists" "zsh-defer"
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
install_cargo_tool cargo-llvm-cov
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
install_cargo_tool zellij

# Install yabai window manager
echo "Checking for yabai..."
if ! command -v yabai &> /dev/null; then
  echo "Checking for yabai-cert certificate..."

  # Check if yabai-cert certificate exists in the keychain
  if ! security find-certificate -c "yabai-cert" &> /dev/null; then
    echo -e "${YELLOW}⚠ yabai-cert certificate not found in keychain${NC}"
    echo -e "${YELLOW}⚠ Skipping yabai installation - please create yabai-cert certificate first${NC}"
    echo -e "${YELLOW}⚠ See: https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition${NC}"
  else
    echo "Installing yabai from source..."

    # Clone the repository
    YABAI_TEMP_DIR=$(mktemp -d)
    cd "$YABAI_TEMP_DIR"
    git clone https://github.com/0xAndoroid/yabai.git
    cd yabai

    # Checkout the fix-arc-fs-new branch
    git checkout fix-arc-fs-new

    # Build yabai
    echo "Building yabai..."
    make

    # Sign the binary
    echo "Signing yabai binary..."
    make sign

    # Move to /usr/local/bin (requires sudo)
    echo "Installing yabai to /usr/local/bin (requires sudo)..."
    sudo mv ./bin/yabai /usr/local/bin/

    # Clean up temp directory
    cd "$HOME"
    rm -rf "$YABAI_TEMP_DIR"

    print_status "installed" "yabai"
  fi
else
  print_status "exists" "yabai"
fi

# Configure npm global directory
echo "Configuring npm global directory..."
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo -e "${GREEN}✓ npm global directory configured${NC}"

# Function to install npm packages
install_npm_package() {
  local package=$1
  echo "Checking for $package..."
  
  # Check if package is already installed globally
  if npm list -g --depth=0 "$package" &> /dev/null; then
    print_status "exists" "$package"
  else
    echo "Installing $package..."
    npm install -g "$package"
    print_status "installed" "$package"
  fi
}

# Install npm packages
echo "Installing npm global packages..."
install_npm_package @anthropic-ai/claude-code
install_npm_package @fsouza/prettierd
install_npm_package @nomicfoundation/solidity-language-server
install_npm_package ccusage
install_npm_package eslint
install_npm_package prettier
# install_npm_package snarkjs
install_npm_package tsc
install_npm_package typescript-language-server
install_npm_package wscat
echo -e "${GREEN}✓ npm packages installed${NC}"

echo -e "${GREEN}All installations complete!${NC}"
