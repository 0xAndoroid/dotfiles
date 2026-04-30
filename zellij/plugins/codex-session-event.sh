#!/usr/bin/env bash
# zellaude v0.5.0
# codex-session-event.sh — synthesize a Codex lifecycle event for the
# zellaude plugin. Codex's own hooks emit Start/Stop per turn but have
# no SessionEnd analogue, so the marker would otherwise linger in the
# tab bar after the user exits codex. A `cdx` shell function calls this
# helper before and after invoking the binary:
#
#   cdx() {
#     "$HOME/.config/zellij/plugins/codex-session-event.sh" SessionStart
#     caffeinate -i command codex --dangerously-bypass-approvals-and-sandbox "$@"
#     local rc=$?
#     "$HOME/.config/zellij/plugins/codex-session-event.sh" SessionEnd
#     return $rc
#   }
#
# Usage: codex-session-event.sh <hook_event_name>

EVENT="${1:-}"
[ -z "$EVENT" ] && exit 1
[ -z "$ZELLIJ_SESSION_NAME" ] && exit 0
[ -z "$ZELLIJ_PANE_ID" ] && exit 0
command -v zellij >/dev/null 2>&1 || exit 0

if command -v jq >/dev/null 2>&1; then
  TS_MS=$(jq -nc 'now * 1000 | floor')
  PAYLOAD=$(jq -nc \
    --arg pane_id "$ZELLIJ_PANE_ID" \
    --arg event "$EVENT" \
    --arg ts_ms "$TS_MS" \
    '{
      pane_id: ($pane_id | tonumber),
      hook_event: $event,
      ts_ms: ($ts_ms | tonumber)
    }')
else
  TS_MS=$(($(date +%s) * 1000))
  PAYLOAD="{\"pane_id\":${ZELLIJ_PANE_ID},\"hook_event\":\"${EVENT}\",\"ts_ms\":${TS_MS}}"
fi

zellij pipe --name "zellaude" -- "$PAYLOAD" 2>/dev/null || true

