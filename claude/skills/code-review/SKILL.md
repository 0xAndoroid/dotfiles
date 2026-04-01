---
name: code-review
description: 'Deep code review of a pull request using parallel analysis agents (semantic consistency, bugs, tech debt, security). USE FOR: - Reviewing PRs for bugs, security issues, and code quality - Analyzing new abstractions for consistency and correctness - Identifying tech debt and architectural concerns - Posting review comments to specific lines on GitHub TRIGGERS: - "review PR", "code review", "review changes" - "diff review", "PR feedback", "check PR" - "analyze diff", "critique code", "review code" - "pull request review", "GitHub PR review"'
---

Provide a code review for the given pull request.

Follow these steps:

1. **Eligibility Check** (Sonnet): Check if the PR (a) is closed, (b) is automated/trivial. If so, stop.

2. **PR Analysis** (Opus): View the PR and return:
   - Summary of the change and its purpose
   - List of new functions, types, enums, or abstractions introduced
   - For each new abstraction: its name, stated purpose (from comments/docs), and intended usage contract

3. **Parallel Deep Review** (4 Opus agents): Pass the PR summary and new abstractions list to each agent.

   **All agents**: When uncertain about an issue, use PAL MCP tools:
   - `mcp__pal__thinkdeep` for complex semantic analysis
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

   c. **Tech Debt Removal Agent**:
      - Understand new abstractions that are introduced, new functions/types/enums
      - Identify possible future usecases for these things and understand whether abstractions meet future requirements
      - See which paradigms of Rust (or other language) development are used and whether they apply here
      - Identify possible improvements that would benefit long term maintainability of the code
      - Be an enjoyer of abstractions: generics, traits, dyn, enums, etc.

   d. **Security Reviewer Agent**:
      - Identify whether changes to the protocol do not break soundness
      - Identify possible attack vectors that are introduced with these changes
      - Check for input validation gaps at trust boundaries (user input, network data, file I/O, IPC)
      - Verify authentication/authorization checks are not bypassed or weakened
      - Look for injection risks: SQL, command, path traversal, template injection, deserialization
      - Check cryptographic usage: hardcoded secrets, weak algorithms, nonce reuse, timing side-channels
      - Verify resource limits: unbounded allocations, missing timeouts, denial-of-service vectors
      - Check concurrency: TOCTOU races, lock ordering, shared mutable state without synchronization

4. **Validate Issues** (PAL MCP): For issues that seem significant but **uncertain**, use:
   - `mcp__pal__codereview` to get independent opinion on whether the issue is real
   - `mcp__pal__thinkdeep` for complex issues requiring deeper analysis

   Score each issue 0-100:
   - 0: False positive, doesn't stand up to scrutiny, or pre-existing issue
   - 25: Might be real, but couldn't verify. Stylistic issues without explicit guidance.
   - 50: Verified real issue, but minor/nitpick. Not important relative to PR scope.
   - 75: Verified real issue that will impact functionality. Insufficient existing approach.
   - 100: Confirmed real issue that will happen frequently. Direct evidence confirms it.

5. **List issues to user for double check**: List all the issues and their scores to user.

6. **Post comments to PR**: For each issue that is approved by user, post a review to the PR
   with comments on specific lines of code. Or if no issues, do not post comments.

   Build a JSON file and use the GitHub review API:
   ```bash
   # Write review JSON to a unique temp file (use $$ for PID to avoid collisions)
   cat > "/tmp/pr-review-${PR_NUMBER}-$$.json" << 'EOF'
   {
     "commit_id": "<HEAD_SHA>",
     "event": "COMMENT",
     "body": "Review summary text",
     "comments": [
       {
         "path": "relative/path/to/file.rs",
         "line": 42,
         "body": "**[Score N/100 — Severity]** Title.\n\nExplanation.\n\nOptional suggestion:\n```rust\n// suggested fix\n```"
       }
     ]
   }
   EOF

   # Post the review (all comments appear as a single review)
   gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input "/tmp/pr-review-${PR_NUMBER}-$$.json"
   ```

   Key points:
   - Use a heredoc with `'EOF'` (quoted) to prevent shell interpolation of `$`, backticks, etc.
   - The `line` field refers to the NEW file line number (right side of diff) for added/modified lines.
   - Get the head SHA via `gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'`.
   - Get changed files via `gh api repos/{owner}/{repo}/pulls/{number}/files`.
   - Do NOT use `--raw-field` for the comments array — it doesn't handle nested JSON. Always use `--input` with a file.

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
- When posting comments, post them to the specific lines of code
- Make a todo list to track progress
