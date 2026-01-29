---
name: debug
description: Debug an issue systematically with hypothesis-driven investigation. Use when user reports a bug, error, or unexpected behavior that needs root cause analysis.
---

# Debug

## Workflow

1. **Gather context**:
   - Read relevant files
   - Check recent changes: `git log -p -5 -- <file>`
   - Search for related code

2. **Form hypothesis**:
   - Theory about root cause
   - Confidence level: exploring → low → medium → high → certain
   - Relevant files involved
   - Evidence gathered

3. **Investigate**:
   - Trace code path
   - Check edge cases
   - Look for recent regression-causing changes

4. **Iterate**:
   - Update hypothesis based on findings
   - Continue until confident

5. **Fix**: Once confident (high+), implement fix.

6. **Verify**:
   - Run relevant tests
   - If fix fails, return to step 2
   - Document root cause in commit

## Escalate to User When

- Can't reproduce issue
- Fix requires architectural changes
- Multiple valid fixes with different tradeoffs
- Issue in unfamiliar code
