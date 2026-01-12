#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
  local status=$1
  local message=$2

  if [ "$status" == "installed" ]; then
    echo -e "${GREEN}✓ ${message} - successfully installed${NC}"
  elif [ "$status" == "exists" ]; then
    echo -e "${YELLOW}⚠ ${message} - already installed${NC}"
  elif [ "$status" == "error" ]; then
    echo -e "${RED}✗ ${message}${NC}"
  fi
}

# Install yabai window manager
echo "Checking for yabai..."
if ! command -v yabai &> /dev/null; then
  echo "Checking for yabai-cert certificate..."

  if ! security find-certificate -c "yabai-cert" &> /dev/null; then
    echo -e "${YELLOW}⚠ yabai-cert certificate not found in keychain${NC}"
    echo -e "${YELLOW}⚠ Skipping yabai installation - please create yabai-cert certificate first${NC}"
    echo -e "${YELLOW}⚠ See: https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition${NC}"
  else
    echo "Installing yabai from source..."

    YABAI_TEMP_DIR=$(mktemp -d)
    cd "$YABAI_TEMP_DIR"
    git clone https://github.com/0xAndoroid/yabai.git
    cd yabai
    git checkout fix-arc-fs-new

    echo "Building yabai (optimized)..."
    make install

    echo "Signing yabai binary..."
    make sign

    echo "Installing yabai to /usr/local/bin (requires sudo)..."
    sudo mv ./bin/yabai /usr/local/bin/

    cd "$HOME"
    rm -rf "$YABAI_TEMP_DIR"

    print_status "installed" "yabai"
  fi
else
  print_status "exists" "yabai"
fi

# Install skhd hotkey daemon (forked version with title filtering)
echo "Checking for skhd..."
if ! command -v skhd &> /dev/null; then
  echo "Installing skhd from source (with title filtering support)..."

  SKHD_TEMP_DIR=$(mktemp -d)
  cd "$SKHD_TEMP_DIR"
  git clone https://github.com/0xAndoroid/skhd.git
  cd skhd
  git checkout feat/title-filter

  echo "Building skhd..."
  make install
  
  echo "Signing skhd binary..."
  make sign

  echo "Installing skhd to /usr/local/bin (requires sudo)..."
  sudo mv ./bin/skhd /usr/local/bin/

  cd "$HOME"
  rm -rf "$SKHD_TEMP_DIR"

  print_status "installed" "skhd"
else
  print_status "exists" "skhd"
fi

echo -e "${GREEN}Done!${NC}"
