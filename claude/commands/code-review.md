---
allowed-tools: Bash(gh issue view:*), Bash(gh search:*), Bash(gh issue list:*), Bash(gh pr comment:*), Bash(gh pr diff:*), Bash(gh pr view:*), Bash(gh pr list:*), mcp__pal__codereview, mcp__pal__consensus
description: Code review a pull request
disable-model-invocation: false
---

Provide a code review for the given pull request.

Follow these steps:

1. **Eligibility Check** (Haiku): Check if the PR (a) is closed, (b) is a draft, (c) is automated/trivial, or (d) already has your review. If so, stop.

2. **PR Analysis** (Sonnet): View the PR and return:
   - Summary of the change and its purpose
   - List of new functions, types, enums, or abstractions introduced
   - For each new abstraction: its name, stated purpose (from comments/docs), and intended usage contract

3. **Parallel Deep Review** (4 Opus agents): Pass the PR summary and new abstractions list to each agent.

   **All agents**: When uncertain about an issue, use PAL MCP tools:
   - `mcp__pal__thinkdeep` for complex semantic analysis
   - `mcp__pal__debug` to trace through suspicious code paths
   - `mcp__pal__chat` to reason through edge cases

   a. **Semantic Consistency Agent**: For each new function/type/enum introduced:
      - Read its definition, documentation, and any comments describing when/how it should be used
      - Find ALL usages of that abstraction within the PR
      - Verify each usage matches the documented intent
      - Flag misuse: e.g., error-handling functions called for wrong error types, validation functions bypassed, enums used inconsistently
      - Pay special attention to: panic/error functions (when should they trigger?), unsafe blocks, security-sensitive operations

   b. **Deep Bug Analysis Agent**: Read the full context of modified files (not just diff lines).
      - Understand the data flow and control flow around changes
      - Check for logic errors, edge cases, off-by-one errors, resource leaks
      - Verify error handling is appropriate for each failure mode
      - Check that invariants are maintained across the changes

   c. **Historical Context Agent**:
      - Read git blame and history of modified code
      - Check previous PRs that touched these files for relevant reviewer comments
      - Identify if the PR reintroduces previously fixed bugs or ignores historical design decisions

   d. **API Contract Agent**: For modified or new public APIs:
      - Verify input validation is complete and correct
      - Check that documented behavior matches implementation
      - Verify error conditions are handled and documented
      - Check for breaking changes to existing callers

4. **Validate Issues** (PAL MCP): For issues that seem significant but uncertain, use:
   - `mcp__pal__consensus` with multiple models to get independent opinions on whether the issue is real
   - `mcp__pal__thinkdeep` for complex issues requiring deeper analysis
   - If still unsure after using these tools, ask the user directly before posting

   Score each issue 0-100:
   - 0: False positive, doesn't stand up to scrutiny, or pre-existing issue
   - 25: Might be real, but couldn't verify. Stylistic issues without explicit guidance.
   - 50: Verified real issue, but minor/nitpick. Not important relative to PR scope.
   - 75: Verified real issue that will impact functionality. Insufficient existing approach.
   - 100: Confirmed real issue that will happen frequently. Direct evidence confirms it.

5. **Filter**: Keep only issues scoring 75+. If none, stop.

6. **Post Comment**: Use `gh pr comment` with this format:

```
### Code review

Found N issues:

1. <description> (<reason: e.g., "misuse of X function", "breaks invariant Y">)

<github link to file#L-L with full SHA>

...

Generated with [Claude Code](https://claude.ai/code)

<sub>If useful, react with thumbs up. Otherwise, thumbs down.</sub>
```

Or if no issues:
```
### Code review

No issues found.

Generated with [Claude Code](https://claude.ai/code)
```

## False Positives (skip these)

- Pre-existing issues not introduced by this PR
- Issues on lines not modified in the PR
- Things linters/compilers catch (imports, types, formatting)
- Pedantic nitpicks a senior engineer wouldn't flag
- Intentional functionality changes related to PR purpose
- General quality concerns (test coverage, docs) unless explicitly required

## Notes

- Do NOT run builds/tests - CI handles that
- Use `gh` for all GitHub interaction
- Links must use full SHA: `https://github.com/owner/repo/blob/<full-sha>/path/file.rs#L10-L15`
- Make a todo list to track progress
