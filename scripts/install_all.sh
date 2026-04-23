#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

print_status() {
  local status=$1
  local message=$2

  if [ "$status" == "installed" ]; then
    echo -e "${GREEN}✓ ${message} - successfully installed${NC}"
  elif [ "$status" == "exists" ]; then
    echo -e "${YELLOW}⚠ ${message} - already installed${NC}"
  fi
}

echo "Checking for Rust..."
if ! command -v rustc &> /dev/null; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  print_status "installed" "Rust"
else
  print_status "exists" "Rust"
fi
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_status "installed" "Homebrew"
else
  print_status "exists" "Homebrew"
fi

echo "Installing packages from Brewfile..."
if [ -f "$HOME/.dotfiles/Brewfile" ]; then
  brew bundle --file="$HOME/.dotfiles/Brewfile"
  echo -e "${GREEN}✓ Brewfile packages installed${NC}"
else
  echo -e "${YELLOW}⚠ Brewfile not found, skipping brew bundle${NC}"
fi

echo "Installing Neovim via bob..."
bob use stable
print_status "installed" "Neovim (stable)"

ZSH_PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

install_zsh_plugin() {
  local name=$1
  local url=$2
  echo "Checking for $name..."
  if [ ! -d "$ZSH_PLUGINS_DIR/$name" ]; then
    echo "Installing $name..."
    git clone --depth=1 "$url" "$ZSH_PLUGINS_DIR/$name"
    print_status "installed" "$name"
  else
    print_status "exists" "$name"
  fi
}

install_zsh_plugin "zsh-defer" "https://github.com/romkatv/zsh-defer.git"
install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

install_npm_package() {
  local package=$1
  echo "Checking for $package..."
  if npm list -g --depth=0 "$package" &> /dev/null; then
    print_status "exists" "$package"
  else
    echo "Installing $package..."
    npm install -g "$package"
    print_status "installed" "$package"
  fi
}

echo "Installing npm global packages..."
install_npm_package ccusage
install_npm_package oh-my-claude-sisyphus
install_npm_package prettier
install_npm_package tsc
install_npm_package wscat
echo -e "${GREEN}✓ npm packages installed${NC}"

echo "Checking for Claude Code..."
if ! command -v claude &> /dev/null; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  print_status "installed" "Claude Code"
else
  print_status "exists" "Claude Code"
fi

echo "Checking for Bun..."
if ! command -v bun &> /dev/null; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  print_status "installed" "Bun"
else
  print_status "exists" "Bun"
fi

echo -e "${GREEN}All installations complete!${NC}"
