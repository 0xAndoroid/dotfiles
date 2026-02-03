---
name: code-review
description: Code review a pull request with deep analysis. Use when user wants to review a PR, check for bugs, or analyze code changes.
---

# Code Review

## Workflow

1. **Eligibility Check**: Skip if PR is closed, draft, automated/trivial, or already reviewed.

2. **PR Analysis**: View PR and identify:
   - Summary of change and purpose
   - New functions, types, enums, abstractions introduced
   - For each: name, purpose, usage contract

3. **Deep Review Areas**:

   a. **Semantic Consistency**: For each new abstraction:
      - Read definition, docs, comments
      - Find ALL usages within PR
      - Verify usage matches documented intent
      - Flag misuse of error handlers, validators, enums

   b. **Bug Analysis**: Read full context (not just diff):
      - Data flow and control flow
      - Logic errors, edge cases, off-by-one
      - Resource leaks, error handling

   c. **Historical Context**:
      - Git blame and history
      - Previous PRs and reviewer comments
      - Reintroduced bugs or ignored design decisions

   d. **API Contract**: For public APIs:
      - Input validation completeness
      - Documented vs actual behavior
      - Breaking changes

4. **Score Issues** (0-100):
   - 0: False positive or pre-existing
   - 25: Uncertain, stylistic
   - 50: Real but minor/nitpick
   - 75: Will impact functionality
   - 100: Confirmed, frequent occurrence

5. **List issues to user** for approval before posting.

6. **Post comments** to PR on specific lines. THE COMMENT MUST BE POSTED TO A SPECIFIC LINES OF CODE. Use suggestion blocks for trivial fixes.

## Skip (False Positives)

- Pre-existing issues
- Lines not modified in PR
- Linter/compiler catches
- Pedantic nitpicks
- Intentional changes per PR purpose

## Notes

- Do NOT run builds/tests - CI handles that
- Use `gh` for GitHub interaction
- Full SHA in links: `https://github.com/owner/repo/blob/<sha>/path#L10-L15`
