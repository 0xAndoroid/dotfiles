#!/bin/bash
# Notify when AI tool needs attention and pane is not visible
# Usage: notify.sh <message> [claude|codex]
# Fires if: terminal not frontmost, OR zellij pane not focused

set -euo pipefail

message="${1:-Needs attention}"

case "${2:-claude}" in
    claude) tool="Claude" ;;
    codex)  tool="Codex" ;;
    *)      tool="${2}" ;;
esac

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[[ -z "$cwd" ]] && exit 0

project=$(basename "$cwd")

notify() {
    osascript -e "display notification \"$message\" with title \"$tool: $project\" sound name \"Glass\"" 2>/dev/null || true
}

frontmost=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
terminal="${TERM_PROGRAM:-Terminal}"

if [[ "$frontmost" != "$terminal" ]]; then
    notify
    exit 0
fi

[[ -z "${ZELLIJ_PANE_ID:-}" ]] && exit 0

focused_pane=$(zellij action list-clients 2>/dev/null | awk 'NR==2 {print $2}')
[[ "$focused_pane" == "terminal_$ZELLIJ_PANE_ID" ]] && exit 0

notify
