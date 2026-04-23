#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ZSH_PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugins"

if [ ! -d "$ZSH_PLUGINS_DIR" ]; then
  echo -e "${RED}Zsh plugin dir not found at $ZSH_PLUGINS_DIR${NC}"
  exit 1
fi

echo -e "${GREEN}Updating zsh plugins...${NC}"

for plugin in zsh-defer zsh-autosuggestions zsh-syntax-highlighting; do
  plugin_dir="$ZSH_PLUGINS_DIR/$plugin"
  if [ -d "$plugin_dir" ]; then
    echo -e "\nUpdating $plugin..."
    (cd "$plugin_dir" && git pull)
  fi
done

echo -e "${GREEN}Zsh plugin update complete${NC}"
