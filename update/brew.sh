#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Updating Homebrew...${NC}"

if ! command -v brew &> /dev/null; then
  echo -e "${RED}Homebrew not found${NC}"
  exit 1
fi

echo "Updating formulae..."
brew update

echo -e "\nUpgrading packages..."
brew upgrade

echo -e "\nCleaning up old versions..."
brew cleanup -s

echo -e "\nRunning brew doctor..."
brew doctor || echo -e "${YELLOW}Some issues found - check output above${NC}"

echo -e "${GREEN}Homebrew update complete${NC}"
