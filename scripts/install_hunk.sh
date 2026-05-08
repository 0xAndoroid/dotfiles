#!/bin/bash
set -euo pipefail

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

REPO_URL="https://github.com/0xAndoroid/hunk.git"
REPO_DIR="$HOME/dev/hunk"
BRANCH="sonokai-andromeda"

echo "Checking for Bun..."
if ! command -v bun &> /dev/null; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
  export PATH="$BUN_INSTALL/bin:$PATH"
  print_status "installed" "Bun"
else
  print_status "exists" "Bun"
fi

echo "Checking for hunk source..."
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "Cloning hunk..."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
  print_status "installed" "hunk source"
else
  print_status "exists" "hunk source"
fi

cd "$REPO_DIR"

git remote set-url origin "$REPO_URL"
git fetch origin "$BRANCH"

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH" "origin/$BRANCH"
fi

git pull --ff-only origin "$BRANCH"

echo "Installing hunk dependencies..."
bun install

echo "Building hunk..."
bun run build:npm

echo "Linking hunk globally..."
bun link

BUN_BIN_DIR="${BUN_INSTALL:-$HOME/.bun}/bin"
if ! command -v hunk &> /dev/null && [ -x "$BUN_BIN_DIR/hunk" ]; then
  export PATH="$BUN_BIN_DIR:$PATH"
fi

command -v hunk
hunk --version

print_status "installed" "hunk"
