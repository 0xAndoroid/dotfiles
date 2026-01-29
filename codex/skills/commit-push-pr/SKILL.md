---
name: commit-push-pr
description: Commit changes, push to remote, and open a pull request. Use when user wants to create a PR, push changes, or complete a feature branch workflow.
---

# Commit, Push, PR

## Workflow

1. **Check existing PRs**: `gh pr list --head $(git branch --show-current)`. If exists, ask to update instead.

2. **Check for sensitive files**: Warn and stop if .env, credentials, keys staged.

3. **Create branch** if on main/master: `git checkout -b <descriptive-branch-name>`

4. **Stage and commit** with conventional format:
   - `type(scope): description`
   - Types: feat, fix, refactor, docs, test, chore, perf

5. **Push** to origin with `-u` flag.

6. **Create PR**:
   - Title: Match commit or summarize
   - Body:
     ```
     ## Summary
     <2-3 bullet points>

     ## Changes
     <key file changes>

     ## Testing
     <how to test or "CI covers this">

     Closes #<issue> (if applicable)
     ```
   - Add `--draft` if work incomplete

## Commands

```bash
git status
git diff HEAD
git branch --show-current
git log --oneline -5
gh pr list --head <branch>
```
