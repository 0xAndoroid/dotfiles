---
allowed-tools: Bash, Read, Glob, Grep, Write
---

# /handoff

Package current state for next agent/session to resume quickly.

## Output

Write handoff state to `.handoff.md` in the current directory.

## Contents

Generate a concise bullet list containing:

1. **Scope/Status**
   - What you were doing
   - What's done
   - What's pending
   - Any blockers

2. **Git State**
   - Run `git status -sb`
   - Note unpushed local commits

3. **Branch/PR**
   - Current branch name
   - PR number if applicable
   - CI status (`gh run list -L 3`)

4. **Tests/Checks**
   - Which commands were run
   - Results (pass/fail counts)
   - What still needs to run

5. **Next Steps**
   - Ordered bullets of immediate actions

6. **Risks/Gotchas**
   - Flaky tests
   - Feature flags
   - Brittle areas
   - Required credentials/env vars

## Action

Write the handoff to `.handoff.md` in the current directory.
