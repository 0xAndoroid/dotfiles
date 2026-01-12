#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Updating Oh My Zsh and plugins...${NC}"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${RED}Oh My Zsh not found${NC}"
  exit 1
fi

echo "Updating Oh My Zsh..."
(cd "$HOME/.oh-my-zsh" && git pull)

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo -e "\nUpdating Powerlevel10k..."
  (cd "$ZSH_CUSTOM/themes/powerlevel10k" && git pull)
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-defer; do
  plugin_dir="$ZSH_CUSTOM/plugins/$plugin"
  if [ -d "$plugin_dir" ]; then
    echo -e "\nUpdating $plugin..."
    (cd "$plugin_dir" && git pull)
  fi
done

echo -e "${GREEN}Oh My Zsh update complete${NC}"
