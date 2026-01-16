#!/bin/bash
# PreCompact hook: save context state before auto-compact
# Extracts key info from transcript and saves to handoff file

set -euo pipefail

HANDOFF_DIR="$HOME/.claude/handoffs"
mkdir -p "$HANDOFF_DIR"

input=$(cat)

session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
trigger=$(echo "$input" | jq -r '.trigger // "unknown"')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
timestamp=$(date +%Y-%m-%d_%H-%M)

handoff_file="$HANDOFF_DIR/${timestamp}_auto-compact.yaml"

# Extract context usage
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
pct=$((input_tokens * 100 / ctx_size))

# Get working directory
cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
project=$(basename "$cwd")

cat > "$handoff_file" <<EOF
---
session: ${session_id}
date: $(date +%Y-%m-%d)
trigger: ${trigger}
context_pct: ${pct}
---

project: ${project}
cwd: ${cwd}

# Auto-generated on ${trigger} compact at ${pct}% context
# Transcript: ${transcript_path}

goal: [extracted from session - check transcript]
now: [continue from where compact interrupted]

next:
  - Review transcript at ${transcript_path}
  - Continue interrupted work

files:
  transcript: ${transcript_path}
EOF

echo "Handoff saved: $handoff_file" >&2
