#!/bin/bash
# Two-stage notification: macOS first, then phone/watch via ntfy if no user reaction
# Usage: notify.sh <message> [claude|codex]
# Fires if: terminal not frontmost, OR zellij pane not focused
# Requires CLAUDE_NOTIF_NTFY_TOPIC in ~/.keysrc for phone escalation

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

now=$(date +%s)
cooldown_file="/tmp/claude-notify-$(printf '%s' "$cwd" | md5 -q)"
last=$(cat "$cooldown_file" 2>/dev/null || echo 0)
printf '%s' "$now" > "$cooldown_file"
(( now - last < 5 )) && exit 0

project=$(basename "$cwd")

notify() {
    osascript -e "display notification \"$message\" with title \"$tool: $project\" sound name \"Glass\"" 2>/dev/null || true

    source ~/.keysrc
    [[ -z "${CLAUDE_NOTIF_NTFY_TOPIC:-}" ]] && return

    (
        set +e
        sleep 15
        idle_secs=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
        if [[ "$idle_secs" -ge 15 ]]; then
            curl -sf "https://ntfy.sh/${CLAUDE_NOTIF_NTFY_TOPIC}" \
                -H "Title: $tool: $project" \
                -d "$message" \
                >/dev/null 2>&1
        fi
    ) &
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
