#!/bin/bash
exec 2>/dev/null

input=$(cat)
[[ -z "$input" ]] && exit 0

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
WORKDIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
CURRENT_TOKENS=$(echo "$input" | jq -r '(.context_window.current_usage | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) // 0')
AUTO_COMPACT=$(jq -r '.autoCompactEnabled // true' ~/.claude.json 2>/dev/null || echo "true")

[[ "$CONTEXT_SIZE" == "null" || -z "$CONTEXT_SIZE" ]] && CONTEXT_SIZE=200000
[[ "$DURATION_MS" == "null" || -z "$DURATION_MS" ]] && DURATION_MS=0
[[ "$CURRENT_TOKENS" == "null" || -z "$CURRENT_TOKENS" ]] && CURRENT_TOKENS=0

BUFFER=$([[ "$AUTO_COMPACT" == "true" ]] && echo 45000 || echo 33000)
EFFECTIVE_CAPACITY=$((CONTEXT_SIZE - BUFFER))
((EFFECTIVE_CAPACITY <= 0)) && EFFECTIVE_CAPACITY=1
FREE_TOKENS=$((EFFECTIVE_CAPACITY - CURRENT_TOKENS))
PERCENT_FREE=$((FREE_TOKENS * 100 / EFFECTIVE_CAPACITY))

DIRNAME=$(basename "$WORKDIR" 2>/dev/null || echo ".")
BRANCH=$(git -C "$WORKDIR" rev-parse --abbrev-ref HEAD 2>/dev/null)

DURATION_SEC=$((DURATION_MS / 1000))
HOURS=$((DURATION_SEC / 3600))
MINUTES=$(((DURATION_SEC % 3600) / 60))
SECS=$((DURATION_SEC % 60))

if ((HOURS > 0)); then
  DURATION="${HOURS}h${MINUTES}m"
elif ((MINUTES > 0)); then
  DURATION="${MINUTES}m${SECS}s"
else
  DURATION="${SECS}s"
fi

GIT_ICON=$''
FOLDER_ICON=$''
MODEL_ICON=$'󰚩'
CLOCK_ICON=$''
CTX_ICON=$''

C=$'\x1b[36m'  # cyan
G=$'\x1b[32m'  # green
M=$'\x1b[35m'  # magenta
B=$'\x1b[34m'  # blue

if ((PERCENT_FREE > 40)); then
  PC=$G
elif ((PERCENT_FREE > 15)); then
  PC=$'\x1b[33m'
else
  PC=$'\x1b[31m'
fi

GIT_PART=$([[ -n "$BRANCH" ]] && echo "${G}${GIT_ICON} git(${BRANCH}) " || echo "")
AC_PART=$([[ "$AUTO_COMPACT" == "true" ]] && echo "${G}AC on" || echo "AC off")

printf '%s\n' "${B}${FOLDER_ICON} ${DIRNAME} ${GIT_PART}${C}${MODEL_ICON} ${MODEL} ${M}${CLOCK_ICON} ${DURATION} ${PC}${CTX_ICON} ${PERCENT_FREE}% free ${AC_PART}"
