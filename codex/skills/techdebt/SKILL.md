---
name: techdebt
description: Capture session learnings into CLAUDE.md and triage tech debt — fix small issues, surface big ones to user.
---

# Tech Debt

End-of-session sweep: persist learnings, fix small debt, surface big debt.

## Workflow

1. **Gather session context**:
   - Review conversation for non-obvious gotchas, surprising behavior, things that required deep searching
   - Check recent changes: `git diff HEAD~5..HEAD --stat` and `git log --oneline -10`
   - Scan modified files for structural issues

2. **Persist learnings → CLAUDE.md**:
   - Read project's `CLAUDE.md`, understand existing structure
   - Insert learnings where they naturally fit within existing sections
   - If no fitting section exists, create one matching the doc's style
   - Match existing format — terse, actionable
   - No duplicates, no obvious things

3. **Triage tech debt** in files touched this session:
   - **Small fixes** (< ~20 lines, no behavioral change): fix immediately
     - Dead imports, rename for clarity, extract constant
   - **Big changes** (architectural, multi-file, behavioral): present to user
     - What, why, suggested approach
     - Do NOT implement

## Output Format

```
## CLAUDE.md updated
- <what was added and where>

## Small fixes applied
- <file>: <what>

## Tech debt to consider
1. **<issue>** — <why>
   Suggestion: <approach>
```
