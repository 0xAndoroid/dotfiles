---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), mcp__pal__chat
description: Create a git commit
---

## Context
- Status: !`git status`
- Diff: !`git diff HEAD`
- Branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`

## Steps

1. **Check for sensitive files**: If any staged files look like secrets (.env, credentials, keys, tokens), warn user and stop.

2. **Craft commit message**:
   - Use conventional commits format: `type(scope): description`
   - Types: feat, fix, refactor, docs, test, chore, perf
   - Match style of recent commits in repo

3. **Stage and commit** in single message.
