#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

MARKETPLACE_NAMES=(
  "claude-code-plugins"
  "worktrunk"
)

MARKETPLACE_SOURCES=(
  "git@github.com:anthropics/claude-code.git"
  "max-sixty/worktrunk"
)

PLUGINS=(
  "ralph-wiggum@claude-code-plugins"
  "worktrunk@worktrunk"
)

get_installed_marketplaces() {
  claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo ""
}

get_installed_plugins() {
  claude plugin list --json 2>/dev/null | jq -r '.[].id' 2>/dev/null || echo ""
}

get_enabled_plugins() {
  claude plugin list --json 2>/dev/null | jq -r '.[] | select(.enabled == true) | .id' 2>/dev/null || echo ""
}

main() {
  echo -e "${GREEN}Setting up Claude plugins...${NC}"

  local installed_marketplaces
  installed_marketplaces=$(get_installed_marketplaces)

  local i=0
  while [ $i -lt ${#MARKETPLACE_NAMES[@]} ]; do
    local name="${MARKETPLACE_NAMES[$i]}"
    local source="${MARKETPLACE_SOURCES[$i]}"
    if echo "$installed_marketplaces" | grep -q "^${name}$"; then
      echo -e "${YELLOW}Marketplace exists: $name${NC}"
    else
      echo -e "${YELLOW}Adding marketplace: $name${NC}"
      claude plugin marketplace add "$source" || echo -e "${RED}Failed: $name${NC}"
    fi
    i=$((i + 1))
  done

  local installed_plugins
  installed_plugins=$(get_installed_plugins)

  for plugin in "${PLUGINS[@]}"; do
    if echo "$installed_plugins" | grep -q "^${plugin}$"; then
      echo -e "${YELLOW}Plugin exists: $plugin${NC}"
    else
      echo -e "${YELLOW}Installing: $plugin${NC}"
      claude plugin install "$plugin" || echo -e "${RED}Failed: $plugin${NC}"
    fi
  done

  echo -e "${GREEN}Updating enabled plugins...${NC}"

  local enabled_plugins
  enabled_plugins=$(get_enabled_plugins)

  for plugin in $enabled_plugins; do
    echo -e "${YELLOW}Updating: $plugin${NC}"
    claude plugin update "$plugin" 2>/dev/null || echo -e "${YELLOW}Up to date: $plugin${NC}"
  done

  echo -e "${GREEN}Done${NC}"
}

main "$@"
