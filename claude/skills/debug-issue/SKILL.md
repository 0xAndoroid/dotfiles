---
name: debug-issue
description: Systematically debug issues by gathering context, forming hypotheses, and iterating toward a fix. USE FOR: - Investigating bugs and unexpected behavior - Tracing root causes of errors and crashes - Fixing regressions from recent changes - Diagnosing complex multi-system issues TRIGGERS: - "debug", "troubleshoot", "investigate bug" - "fix error", "find bug", "why is this broken" - "error investigation", "crash analysis", "fix issue" - "not working", "broken", "failing"
---

## Context
- Issue/error: $ARGUMENTS

## Steps

1. **Gather context**:
   - Read relevant files
   - Check recent changes: `git log -p -5 -- <file>`
   - Search for related code: use Grep/Glob

2. **Form hypothesis**:
   - `hypothesis`: Your theory about root cause
   - `confidence`: exploring → low → medium → high → very_high → certain
   - `relevant_files`: Absolute paths to files involved
   - `findings`: Evidence gathered so far

3. **Investigate**:
   - Trace the code path
   - Check edge cases
   - Look for recent changes that might have caused regression

4. **Iterate**:
   - Update hypothesis based on findings
   - Use `mcp__pal__thinkdeep` for complex multi-system issues
   - Use `mcp__pal__chat` to brainstorm when stuck

5. **Fix**: Once confident (high+), implement the fix.

6. **Verify**:
   - Run relevant tests
   - If fix doesn't work, return to step 2 with new findings
   - Document root cause in commit message

## When to Escalate to User
- Can't reproduce the issue
- Fix requires architectural changes
- Multiple valid fixes with different tradeoffs
- Issue is in code you don't have context for
