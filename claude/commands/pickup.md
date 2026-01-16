# /pickup

Rehydrate context when starting or resuming work.

## Steps

1. **Read Handoff**
   - Check `.handoff.yaml` in current directory
   - If not found, check `~/.claude/handoffs/` for latest
   - Parse `goal:` and `now:` fields

2. **Repo State**
   - Run `git status -sb`
   - Check for local commits: `git log @{u}..HEAD --oneline`
   - Confirm current branch matches handoff

3. **CI/PR Status**
   - If on a feature branch: `gh pr view --json state,statusCheckRollup`
   - Check failing checks: `gh run list -L 5`

4. **Summarize**
   ```
   Resuming: <goal from handoff>
   Next: <now from handoff>
   Git: <branch> (<uncommitted/clean>)
   ```

5. **Execute**
   - Start with `now:` field action
   - Then work through `next:` list
