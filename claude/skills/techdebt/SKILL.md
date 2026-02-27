---
allowed-tools: Bash(*), Read, Grep, Glob, Write, Edit, mcp__pal__thinkdeep
description: Capture session learnings and address tech debt
---

# /techdebt

End-of-session sweep: persist learnings, fix small debt, surface big debt.

## Phase 1: Gather Session Context

1. Review conversation for:
   - Non-obvious gotchas discovered during this session
   - Things that required extensive searching to figure out
   - Surprising behavior, undocumented quirks, hidden constraints
   - Workarounds for framework/library/tooling issues
2. Check recent changes: `git diff HEAD~5..HEAD --stat` and `git log --oneline -10`
3. Scan modified files for structural issues

## Phase 2: Persist Learnings → CLAUDE.md

If gotchas/learnings were found:

1. Read the project's `CLAUDE.md` (repo root)
2. Understand its existing structure and sections
3. Insert learnings where they naturally fit within the existing structure
   - If there's a relevant section, add there
   - If no fitting section exists, create one that matches the doc's style
4. Format: match existing style — terse, actionable
5. Do NOT duplicate entries already present
6. Do NOT add obvious things — only genuinely non-obvious discoveries

## Phase 3: Tech Debt Triage

Scan the codebase areas touched this session for:
- Code that should be restructured for maintainability/modularity
- Repeated patterns that should be abstracted
- Missing error handling at system boundaries
- Dead code, unused dependencies, stale configs
- Naming inconsistencies, leaky abstractions

### Small fixes (< ~20 lines changed, no behavioral change)
- Fix immediately without asking
- Examples: dead import removal, rename for clarity, extract obvious constant

### Big changes (architectural, multi-file, behavioral)
- Present to user as a numbered list with:
  - What the issue is
  - Why it matters
  - Suggested approach
- Do NOT implement — let user decide

## Output Format

```
## CLAUDE.md updated
- <what was added and where>

## Small fixes applied
- <file>: <what was fixed>

## Tech debt to consider
1. **<issue title>** — <why it matters>
   Suggestion: <approach>
2. ...
```
