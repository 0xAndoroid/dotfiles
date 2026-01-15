---
allowed-tools: Bash, Read, Glob, Grep
---

# /pickup

Rehydrate context when starting or resuming work.

## Steps

1. **Read Handoff**
   - Read `.handoff.md` if present in current directory
   - Summarize prior state

2. **Repo State**
   - Run `git status -sb`
   - Check for local commits: `git log @{u}..HEAD --oneline`
   - Confirm current branch

3. **CI/PR Status**
   - If on a feature branch: `gh pr view --json state,statusCheckRollup`
   - Check failing checks: `gh run list -L 5`

4. **Plan Actions**
   - Based on handoff next steps and current state
   - List next 2-3 concrete actions
   - Execute in order
