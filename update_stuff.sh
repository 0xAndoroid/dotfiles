#!/bin/bash

# Define color codes for output messages
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function to print section headers
print_section() {
  echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

# Helper function to print status messages
print_status() {
  local status=$1
  local message=$2
  
  if [ "$status" == "success" ]; then
    echo -e "${GREEN}✓ ${message}${NC}"
  elif [ "$status" == "error" ]; then
    echo -e "${RED}✗ ${message}${NC}"
  elif [ "$status" == "info" ]; then
    echo -e "${YELLOW}ℹ ${message}${NC}"
  fi
}

echo -e "${BLUE}Starting system update...${NC}"

# Update Homebrew
print_section "Updating Homebrew"
if command -v brew &> /dev/null; then
  echo "Updating Homebrew formulae..."
  brew update
  
  echo -e "\nUpgrading Homebrew packages..."
  brew upgrade
  
  echo -e "\nCleaning up old versions..."
  brew cleanup -s
  
  echo -e "\nRunning brew doctor..."
  brew doctor || print_status "info" "Some issues found - check output above"
  
  print_status "success" "Homebrew update complete"
else
  print_status "error" "Homebrew not found"
fi

# Update npm packages
print_section "Updating npm packages"
if command -v npm &> /dev/null; then
  echo "Checking for npm updates..."
  
  # Update npm itself first
  echo -e "\nUpdating npm..."
  npm install -g npm@latest
  
  # List outdated global packages
  echo -e "\nChecking for outdated global packages..."
  outdated=$(npm outdated -g --depth=0 2>/dev/null)
  
  if [ -z "$outdated" ]; then
    print_status "info" "All npm packages are up to date"
  else
    echo "Outdated packages found:"
    echo "$outdated"
    
    # Update all global packages
    echo -e "\nUpdating global packages..."
    npm update -g
  fi
  
  print_status "success" "npm update complete"
else
  print_status "error" "npm not found"
fi

# Update Rust and cargo packages
print_section "Updating Rust and cargo packages"

# Ensure cargo is in PATH
source "$HOME/.cargo/env" 2>/dev/null || true

if command -v rustup &> /dev/null; then
  echo "Updating Rust toolchain..."
  rustup update
  
  print_status "success" "Rust toolchain updated"
else
  print_status "error" "rustup not found"
fi

if command -v cargo &> /dev/null; then
  # Update cargo-update if installed, or install it
  if ! command -v cargo-install-update &> /dev/null; then
    print_status "info" "Installing cargo-update for efficient updates..."
    if command -v cargo-binstall &> /dev/null; then
      cargo binstall cargo-update -y
    else
      cargo install cargo-update
    fi
  fi
  
  # Update all cargo-installed packages
  if command -v cargo-install-update &> /dev/null; then
    echo -e "\nUpdating all cargo packages..."
    cargo install-update -a
    print_status "success" "Cargo packages updated"
  else
    print_status "info" "cargo-update not available, skipping bulk update"
  fi
  
  # Clean cargo cache
  if command -v cargo-cache &> /dev/null; then
    echo -e "\nCleaning cargo cache..."
    cargo cache -a
    print_status "success" "Cargo cache cleaned"
  fi
else
  print_status "error" "cargo not found"
fi

# Update Oh My Zsh
print_section "Updating Oh My Zsh and plugins"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Updating Oh My Zsh..."
  (cd "$HOME/.oh-my-zsh" && git pull)
  
  # Update Powerlevel10k
  if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo -e "\nUpdating Powerlevel10k..."
    (cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" && git pull)
  fi
  
  # Update zsh plugins
  for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode; do
    plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
    if [ -d "$plugin_dir" ]; then
      echo -e "\nUpdating $plugin..."
      (cd "$plugin_dir" && git pull)
    fi
  done
  
  print_status "success" "Oh My Zsh and plugins updated"
else
  print_status "error" "Oh My Zsh not found"
fi

echo -e "\n${GREEN}All updates complete!${NC}"