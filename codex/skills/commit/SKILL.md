---
name: commit
description: Create a git commit with conventional commit format. Use when user wants to commit changes, stage files, or create a commit message.
---

# Commit

## Workflow

1. **Check for sensitive files**: If staged files look like secrets (.env, credentials, keys), warn and stop.

2. **Craft commit message**:
   - Format: `type(scope): description`
   - Types: feat, fix, refactor, docs, test, chore, perf
   - Match style of recent commits in repo

3. **Stage and commit** in single operation.

## Commands

```bash
git status
git diff HEAD
git branch --show-current
git log --oneline -5
```
