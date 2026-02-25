#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Updating Rust and cargo packages...${NC}"

# shellcheck disable=SC1091
source "$HOME/.cargo/env" 2>/dev/null || true

if command -v rustup &> /dev/null; then
  echo "Updating Rust toolchain..."
  rustup update
else
  echo -e "${RED}rustup not found${NC}"
  exit 1
fi

if ! command -v cargo &> /dev/null; then
  echo -e "${RED}cargo not found${NC}"
  exit 1
fi

if ! command -v cargo-install-update &> /dev/null; then
  echo -e "${YELLOW}Installing cargo-update...${NC}"
  if command -v cargo-binstall &> /dev/null; then
    cargo binstall cargo-update -y
  else
    cargo install cargo-update
  fi
fi

if command -v cargo-install-update &> /dev/null; then
  echo -e "\nUpdating all cargo packages..."
  cargo install-update -a
fi

if command -v cargo-cache &> /dev/null; then
  echo -e "\nCleaning cargo cache..."
  cargo cache -a
fi

echo -e "${GREEN}Cargo update complete${NC}"
