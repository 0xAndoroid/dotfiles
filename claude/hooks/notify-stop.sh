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

# Terminal is frontmost - check if THIS pane is focused
[[ -z "$ZELLIJ_PANE_ID" ]] && exit 0

focused_pane=$(zellij action list-clients 2>/dev/null | awk 'NR==2 {print $2}')
[[ "$focused_pane" == "terminal_$ZELLIJ_PANE_ID" ]] && exit 0

notify
