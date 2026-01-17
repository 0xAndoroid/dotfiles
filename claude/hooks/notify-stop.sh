#!/bin/bash
# Stop hook: notify when Claude completes if pane not visible
# Fires if: terminal not frontmost, OR zellij pane not focused

set -euo pipefail

# Read hook input and extract cwd
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[[ -z "$cwd" ]] && exit 0

project=$(basename "$cwd")

notify() {
    osascript -e "display notification \"Task completed\" with title \"Claude: $project\" sound name \"Glass\"" 2>/dev/null || true
}

# Check if terminal app is frontmost
frontmost=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
terminal="${TERM_PROGRAM:-Terminal}"

if [[ "$frontmost" != "$terminal" ]]; then
    notify
    exit 0
fi

# Terminal is frontmost - check zellij pane focus if in zellij
if [[ -n "${ZELLIJ:-}" ]]; then
    layout=$(zellij action dump-layout 2>/dev/null) || exit 0
    rel_cwd="${cwd#$HOME/}"

    # Check if our pane is focused
    if echo "$layout" | grep -q "cwd=\"$rel_cwd\".*focus=true"; then
        exit 0
    fi
    if echo "$layout" | grep -q "cwd=\"$cwd\".*focus=true"; then
        exit 0
    fi

    notify
fi
