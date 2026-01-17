#!/bin/bash

set -e

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
else
  echo -e "${YELLOW}⚠ Brewfile not found, skipping brew bundle${NC}"
fi

# Install Neovim via bob
echo "Installing Neovim via bob..."
if command -v bob &> /dev/null; then
  bob use stable
  print_status "installed" "Neovim (stable)"
else
  echo -e "${YELLOW}⚠ bob not found, skipping Neovim installation${NC}"
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

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Powerlevel10k theme
echo "Checking for Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  print_status "installed" "Powerlevel10k"
else
  print_status "exists" "Powerlevel10k"
fi

# Install zsh plugins
install_zsh_plugin() {
  local name=$1
  local url=$2
  echo "Checking for $name..."
  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    echo "Installing $name..."
    git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name"
    print_status "installed" "$name"
  else
    print_status "exists" "$name"
  fi
}

install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_zsh_plugin "zsh-defer" "https://github.com/romkatv/zsh-defer.git"

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
install_npm_package @fsouza/prettierd
install_npm_package @nomicfoundation/solidity-language-server
install_npm_package ccusage
install_npm_package eslint
install_npm_package prettier
install_npm_package tsc
install_npm_package typescript-language-server
install_npm_package wscat
echo -e "${GREEN}✓ npm packages installed${NC}"

# Install Claude Code if not already installed
echo "Checking for Claude Code..."
if ! command -v claude &> /dev/null; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  print_status "installed" "Claude Code"
else
  print_status "exists" "Claude Code"
fi

# Install Bun if not already installed
echo "Checking for Bun..."
if ! command -v bun &> /dev/null; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  print_status "installed" "Bun"
else
  print_status "exists" "Bun"
fi

echo -e "${GREEN}All installations complete!${NC}"
