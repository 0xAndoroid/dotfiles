#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_FILE="$DOTFILES_DIR/.skhdrc.space-bindings"
ACTIVE_FILE="$DOTFILES_DIR/.skhdrc.space-bindings.active"

write_active_file() {
  local source_file="$1"
  local tmp_file
  tmp_file="$(mktemp "${ACTIVE_FILE}.XXXXXX")"
  cp "$source_file" "$tmp_file"
  mv "$tmp_file" "$ACTIVE_FILE"
}

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

if csrutil status | grep -q "disabled"; then
  write_active_file "$TEMPLATE_FILE"
  state="enabled"
else
  write_active_file "/dev/null"
  state="disabled"
fi

if pgrep -qx skhd >/dev/null 2>&1; then
  skhd --reload >/dev/null 2>&1 || true
fi

echo "skhd space bindings ${state}"
