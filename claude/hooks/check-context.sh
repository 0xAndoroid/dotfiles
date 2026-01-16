#!/bin/bash
# Stop hook: block at 80% context to preserve working room
# Reads JSON from stdin, outputs JSON decision

set -euo pipefail

THRESHOLD=80
SYSTEM_OVERHEAD=45000

input=$(cat)

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

total=$((input_tokens + cache_read + cache_creation + SYSTEM_OVERHEAD))
pct=$((total * 100 / ctx_size))

if [ "$pct" -ge "$THRESHOLD" ]; then
    cat <<EOF
{"decision":"block","reason":"Context at ${pct}%. Write handoff to ~/.claude/handoffs/ and exit."}
EOF
fi
