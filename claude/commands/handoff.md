# /handoff

Package current state for next agent/session to resume quickly.

## Output

Write to both:
- `.handoff.yaml` in current directory (structured)
- `~/.claude/handoffs/<timestamp>_<topic>.yaml` (persistent)

## YAML Format

```yaml
---
date: YYYY-MM-DD
status: complete|partial|blocked
branch: <git branch>
---

goal: <what this session accomplished>
now: <what next session should do first>

done:
  - <completed task 1>
  - <completed task 2>

pending:
  - <unfinished task>

blockers:
  - <blocking issue if any>

git:
  branch: <branch name>
  uncommitted: <true/false>
  unpushed: <count>

tests:
  ran: <command>
  passed: <count>
  failed: <count>

next:
  - <immediate action 1>
  - <immediate action 2>

files:
  modified:
    - <file1.ts>
    - <file2.ts>

risks:
  - <gotcha or risk>
```

## Process

1. Run `git status -sb` and `git log @{u}..HEAD --oneline`
2. Summarize session work
3. Write YAML to both locations
4. Report: "Handoff saved to .handoff.yaml"

## Keep It Concise

Target ~400 tokens. No prose - just structured data.
