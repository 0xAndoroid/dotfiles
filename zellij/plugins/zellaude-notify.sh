#!/usr/bin/env bash
# zellaude v0.5.0
# zellaude-notify.sh — bell + desktop notification helper.
# Shared between zellaude-hook.sh (Claude Code) and codex-hook.sh (Codex CLI).
#
# Args:  $1 = notification title, $2 = notification body
# Env:   ZELLIJ_SESSION_NAME, ZELLIJ_PANE_ID, TERM_PROGRAM

TITLE="${1:-Zellaude}"
MESSAGE="${2:-Permission requested}"

[ -z "$ZELLIJ_PANE_ID" ] && exit 0

printf '\a' > /dev/tty 2>/dev/null || true

SETTINGS_FILE="$HOME/.config/zellij/plugins/zellaude.json"
NOTIFY_MODE="Always"
if [ -f "$SETTINGS_FILE" ] && command -v jq >/dev/null 2>&1; then
  NOTIFY_MODE=$(jq -r '.notifications // "Always"' "$SETTINGS_FILE" 2>/dev/null)
fi

SHOULD_NOTIFY=false
case "$NOTIFY_MODE" in
  Always) SHOULD_NOTIFY=true ;;
  Unfocused)
    TERM_FOCUSED=false
    case "$(uname)" in
      Darwin)
        EXPECTED="${TERM_PROGRAM:-}"
        case "$EXPECTED" in
          Apple_Terminal) EXPECTED="Terminal" ;;
          iTerm.app)     EXPECTED="iTerm2" ;;
        esac
        FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
        [ "$FRONT_APP" = "$EXPECTED" ] && TERM_FOCUSED=true
        ;;
      Linux)
        if command -v xdotool >/dev/null 2>&1; then
          ACTIVE_PID=$(xdotool getactivewindow getwindowpid 2>/dev/null)
          if [ -n "$ACTIVE_PID" ]; then
            PID=$$
            while [ "$PID" -gt 1 ] 2>/dev/null; do
              [ "$PID" = "$ACTIVE_PID" ] && { TERM_FOCUSED=true; break; }
              PID=$(ps -o ppid= -p "$PID" 2>/dev/null | tr -d ' ')
            done
          fi
        fi
        ;;
    esac
    if [ "$TERM_FOCUSED" = false ]; then
      SHOULD_NOTIFY=true
    else
      FOCUSED_PANE=$(zellij action list-clients 2>/dev/null | awk 'NR==2 {print $2}')
      [ "$FOCUSED_PANE" != "terminal_$ZELLIJ_PANE_ID" ] && SHOULD_NOTIFY=true
    fi
    ;;
esac

[ "$SHOULD_NOTIFY" != true ] && exit 0

# Rate-limit: at most one notification per pane per 10 seconds
LOCK="/tmp/zellaude-notify-${ZELLIJ_PANE_ID}"
NOW=$(date +%s)
LAST=0
[ -f "$LOCK" ] && LAST=$(cat "$LOCK" 2>/dev/null)
[ $((NOW - LAST)) -lt 10 ] && exit 0
echo "$NOW" > "$LOCK"

ZELLIJ_BIN=$(command -v zellij)
FOCUS_CMD="${ZELLIJ_BIN} -s '${ZELLIJ_SESSION_NAME}' pipe --name zellaude:focus -- ${ZELLIJ_PANE_ID}"

case "$(uname)" in
  Darwin)
    [ -n "${TERM_PROGRAM:-}" ] && FOCUS_CMD="open -a '${TERM_PROGRAM}' && ${FOCUS_CMD}"
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier \
        -title "$TITLE" \
        -message "$MESSAGE" \
        -execute "$FOCUS_CMD" &
    else
      osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" &
    fi
    ;;
  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$TITLE" "$MESSAGE" &
    fi
    ;;
esac
