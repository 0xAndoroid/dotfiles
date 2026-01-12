#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Updating Claude plugins...${NC}"

MARKETPLACES_DIR="$HOME/.claude/plugins/marketplaces"

if [ ! -d "$MARKETPLACES_DIR" ]; then
  echo -e "${YELLOW}No marketplaces directory found${NC}"
  exit 0
fi

for marketplace in "$MARKETPLACES_DIR"/*/; do
  if [ -d "$marketplace/.git" ]; then
    name=$(basename "$marketplace")
    echo -e "\nUpdating $name..."
    (cd "$marketplace" && git pull)
  fi
done

echo -e "${GREEN}Claude plugins update complete${NC}"
