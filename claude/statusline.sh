#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms')
WORKDIR=$(echo "$input" | jq -r '.workspace.current_dir')

CURRENT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage | .input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')

AUTO_COMPACT=$(jq -r '.autoCompactEnabled // true' ~/.claude.json 2>/dev/null)
if [ "$AUTO_COMPACT" = "true" ]; then
  BUFFER=45000
else
  BUFFER=33000
fi
EFFECTIVE_CAPACITY=$((CONTEXT_SIZE - BUFFER))
FREE_TOKENS=$((EFFECTIVE_CAPACITY - CURRENT_TOKENS))
PERCENT_FREE=$((FREE_TOKENS * 100 / EFFECTIVE_CAPACITY))

DIRNAME=$(basename "$WORKDIR")
BRANCH=$(git -C "$WORKDIR" rev-parse --abbrev-ref HEAD 2>/dev/null)

DURATION_SEC=$((DURATION_MS / 1000))
HOURS=$((DURATION_SEC / 3600))
MINUTES=$(((DURATION_SEC % 3600) / 60))
SECS=$((DURATION_SEC % 60))

if [ $HOURS -gt 0 ]; then
  DURATION="${HOURS}h${MINUTES}m"
elif [ $MINUTES -gt 0 ]; then
  DURATION="${MINUTES}m${SECS}s"
else
  DURATION="${SECS}s"
fi

CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
MAGENTA='\033[35m'
BLUE='\033[34m'
DIM='\033[2m'
RESET='\033[0m'

GIT_ICON=$''
FOLDER_ICON=$''
MODEL_ICON=$'󰚩'
CLOCK_ICON=$''
CTX_ICON=$''

if [ $PERCENT_FREE -gt 40 ]; then
  CTX_COLOR=$GREEN
elif [ $PERCENT_FREE -gt 15 ]; then
  CTX_COLOR=$YELLOW
else
  CTX_COLOR='\033[31m'
fi

if [ "$AUTO_COMPACT" = "true" ]; then
  AC_INFO="${GREEN}AC on${RESET}"
else
  AC_INFO="${DIM}AC off${RESET}"
fi
GIT_INFO=""
if [ -n "$BRANCH" ]; then
  GIT_INFO="${GREEN}${GIT_ICON} git(${BRANCH})${RESET} "
fi


echo -e "${BLUE}${FOLDER_ICON} ${DIRNAME} ${RESET}${GIT_INFO}${CYAN}${MODEL_ICON} ${MODEL}${RESET} ${MAGENTA}${CLOCK_ICON} ${DURATION}${RESET} ${CTX_COLOR}${CTX_ICON} ${PERCENT_FREE}% free${RESET} ${AC_INFO}${RESET}"
