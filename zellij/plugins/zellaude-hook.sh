#!/usr/bin/env bash
# zellaude v0.5.0
# zellaude-hook.sh — Claude Code hook → zellij pipe bridge
# Forwards hook events to the zellaude Zellij plugin via pipe.
#
# Usage in ~/.claude/settings.json hooks:
#   "command": "/path/to/zellaude-hook.sh"

# Exit silently if not running inside Zellij
[ -z "$ZELLIJ_SESSION_NAME" ] && exit 0
[ -z "$ZELLIJ_PANE_ID" ] && exit 0

# Capture send-time immediately so the plugin can order events
# that race through parallel hook subprocesses.
TS_MS=$(jq -nc 'now * 1000 | floor')

# Read hook JSON from stdin
INPUT=$(cat)

# Extract fields with jq (required dependency)
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$HOOK_EVENT" ] && exit 0

# Build compact JSON payload
PAYLOAD=$(jq -nc \
  --arg pane_id "$ZELLIJ_PANE_ID" \
  --arg session_id "$SESSION_ID" \
  --arg hook_event "$HOOK_EVENT" \
  --arg tool_name "$TOOL_NAME" \
  --arg cwd "$CWD" \
  --arg zellij_session "$ZELLIJ_SESSION_NAME" \
  --arg term_program "${TERM_PROGRAM:-}" \
  --arg ts_ms "$TS_MS" \
  '{
    pane_id: ($pane_id | tonumber),
    session_id: $session_id,
    hook_event: $hook_event,
    tool_name: (if $tool_name == "" then null else $tool_name end),
    cwd: (if $cwd == "" then null else $cwd end),
    zellij_session: $zellij_session,
    term_program: (if $term_program == "" then null else $term_program end),
    ts_ms: ($ts_ms | tonumber)
  }')

# Permission request: bell + desktop notification (delegated to shared helper)
if [ "$HOOK_EVENT" = "PermissionRequest" ]; then
  TOOL_SUFFIX=""
  [ -n "$TOOL_NAME" ] && TOOL_SUFFIX=" — $TOOL_NAME"
  "$HOME/.config/zellij/plugins/zellaude-notify.sh" \
    "⚠ Claude Code" \
    "Permission requested${TOOL_SUFFIX}"
fi

if [ "$HOOK_EVENT" = "Stop" ]; then
  TAB_NAME=$(zellij action list-panes --json --tab 2>/dev/null \
    | jq -r --arg pane_id "$ZELLIJ_PANE_ID" '.[] | select(.is_plugin == false and (.id | tostring) == $pane_id) | .tab_name // empty' \
    | head -n 1)
  PROJECT=$(basename "${CWD:-.}")
  TITLE="Claude Code"
  [ -n "$TAB_NAME" ] && TITLE="Claude Code tab: $TAB_NAME"
  "$HOME/.config/zellij/plugins/zellaude-notify.sh" \
    "$TITLE" \
    "Agent turn completed in the $PROJECT folder"
fi

# Send to plugin (hook is already async, no need to background)
zellij pipe --name "zellaude" -- "$PAYLOAD"
