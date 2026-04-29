#!/usr/bin/env bash
# zellaude v0.5.0
# codex-hook.sh — Codex CLI lifecycle hook → zellij pipe bridge.
# Normalizes Codex's stdin JSON payload into the canonical zellaude
# HookPayload format and forwards it to the plugin.
#
# Wired in ~/.codex/config.toml under [[hooks.<event>.hooks]] entries.

# Exit silently if not running inside Zellij — pane routing relies on
# inheriting ZELLIJ_PANE_ID from the codex parent process.
[ -z "$ZELLIJ_SESSION_NAME" ] && exit 0
[ -z "$ZELLIJ_PANE_ID" ] && exit 0

TS_MS=$(jq -nc 'now * 1000 | floor')

INPUT=$(cat)

HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
# Codex uses session_id for session-scope events and turn_id for turn-scope.
# Either uniquely identifies the conversation thread; thread_id is an alias
# used by the legacy notify payload.
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // .thread_id // .turn_id // empty')
# Tool name is exposed in event-specific tables. Try the documented direct
# field first, then the nested object form, then the call form.
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .tool.name // .tool_call.name // empty')
# Codex doesn't put cwd in the payload — the hook process inherits it from
# the codex session, so $PWD is the session cwd.
CWD="$PWD"

[ -z "$HOOK_EVENT" ] && exit 0

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

if [ "$HOOK_EVENT" = "PermissionRequest" ]; then
  TOOL_SUFFIX=""
  [ -n "$TOOL_NAME" ] && TOOL_SUFFIX=" — $TOOL_NAME"
  "$HOME/.config/zellij/plugins/zellaude-notify.sh" \
    "⚠ Codex" \
    "Permission requested${TOOL_SUFFIX}"
fi

zellij pipe --name "zellaude" -- "$PAYLOAD"
