---
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git branch:*), Bash(git diff:*), Bash(gh pr create:*), Bash(gh pr list:*), mcp__pal__chat
description: Commit, push, and open a PR
---

## Context
- Status: !`git status`
- Diff: !`git diff HEAD`
- Branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`

## Steps

1. **Check existing PRs**: Run `gh pr list --head $(git branch --show-current)`. If PR exists, ask user if they want to update it instead of creating new.

2. **Check for sensitive files**: If any staged files look like secrets (.env, credentials, keys), warn user and stop.

3. **Create branch** if on main/master: `git checkout -b <descriptive-branch-name>`

4. **Stage and commit** with conventional commit message:
   - Format: `type(scope): description`
   - Types: feat, fix, refactor, docs, test, chore, perf

5. **Push** to origin with `-u` flag.

6. **Create PR**:
   - Title: Match commit message or summarize changes
   - Body format:
     ```
     ## Summary
     <2-3 bullet points>

     ## Changes
     <list key file changes>

     ## Testing
     <how to test, or "CI covers this">

     Closes #<issue> (if applicable)
     ```
   - Use `mcp__pal__chat` if unsure about PR description
   - Add `--draft` flag if user indicates work is incomplete

Execute steps 3-7 in a single message with parallel tool calls where possible.
