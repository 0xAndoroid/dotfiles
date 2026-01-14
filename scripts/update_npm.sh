#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Updating npm packages...${NC}"

if ! command -v npm &> /dev/null; then
  echo -e "${RED}npm not found${NC}"
  exit 1
fi

echo "Updating npm..."
npm install -g npm@latest

echo -e "\nChecking for outdated global packages..."
outdated=$(npm outdated -g --depth=0 2>/dev/null || true)

if [ -z "$outdated" ]; then
  echo -e "${YELLOW}All npm packages are up to date${NC}"
else
  echo "Outdated packages found:"
  echo "$outdated"
  echo -e "\nUpdating global packages..."
  npm update -g
fi

echo -e "${GREEN}npm update complete${NC}"
