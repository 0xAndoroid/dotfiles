#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_section() {
  echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

echo -e "${BLUE}Starting system update...${NC}"

print_section "Homebrew"
"$SCRIPT_DIR/brew.sh"

print_section "npm"
"$SCRIPT_DIR/npm.sh"

print_section "Cargo"
"$SCRIPT_DIR/cargo.sh"

print_section "Zsh"
"$SCRIPT_DIR/zsh.sh"

print_section "Claude Plugins"
"$SCRIPT_DIR/claude.sh"

echo -e "\n${GREEN}All updates complete!${NC}"
