# AI Slop Cleaner Review Mode

Use this file only for `/ai-slop-cleaner <target> --review`.

## Reviewer Workflow

1. Do not start by editing files.
2. Review the cleanup plan, changed files, and regression evidence.
3. Check specifically for:
   - leftover dead code or unused exports
   - duplicate logic that should have been consolidated
   - needless wrappers or abstractions that still blur boundaries
   - missing tests or weak verification for preserved behavior
   - cleanup that appears to have changed behavior without intent
4. Produce a reviewer verdict with required follow-ups.
5. Hand needed changes back to a separate writer pass instead of fixing and approving in one step.

## Verdict Shape

```markdown
Verdict: approve | needs changes

Blocking cleanup issues:
- <issue, file, why it matters>

Verification gaps:
- <missing or weak behavior lock>

Suggested next pass:
- <smallest targeted follow-up>
```
