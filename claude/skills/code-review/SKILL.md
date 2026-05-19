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

3. **Parallel Deep Review** (4 Opus agents): Pass the PR summary and new abstractions list to each agent. Use `references/review-agents.md` for the exact prompts.

   - **Semantic Consistency Agent**: verify each new abstraction is used according to its contract.
   - **Deep Bug Analysis Agent**: read full modified-file context and trace data/control flow.
   - **Tech Debt Removal Agent**: judge whether new abstractions fit actual call sites and project patterns.
   - **Security Reviewer Agent**: focus on changed trust boundaries, protocol soundness, auth, resource limits, concurrency, and external process/file access.

4. **Validate Issues** (MANDATORY -- do not skip):

   After collecting all issues from the 4 agents, YOU (the main orchestrator) MUST validate
   every issue scored >= 50 before presenting it to the user.

   For each issue from the agents:
   - Re-read the relevant files and diff hunks yourself.
   - Prefer direct verification when possible: run the targeted test, reproduce the failing path,
     inspect generated output, or trace the relevant control/data flow.
   - For security findings, verify the trust boundary, attacker-controlled inputs, and exploitability
     from the code, not just from pattern matching.
   - Drop issues that do not survive this validation pass.

   Score each issue 0-100 AFTER validation:
   - 0: False positive, doesn't stand up to scrutiny, or pre-existing issue
   - 25: Might be real, but couldn't verify. Stylistic issues without explicit guidance.
   - 50: Verified real issue, but minor/nitpick. Not important relative to PR scope.
   - 75: Verified real issue that will impact functionality. Insufficient existing approach.
   - 100: Confirmed real issue that will happen frequently. Direct evidence confirms it.

   **CRITICAL: validation is a WAYPOINT, not a stopping point. After scoring all
   issues, IMMEDIATELY continue to step 5. Do NOT wait for user input. Do NOT treat
   validation notes as the end of the review.**

5. **List issues to user for double check** (IMMEDIATELY after step 4 -- do not pause):

   Present ALL issues in a single message, formatted as a numbered list with scores.
   Include: file path, line number, one-line description, score, and 1-2 sentence rationale.
   Then ask the user which issues to post to the PR. Wait for user response before step 6.

6. **Post comments to PR**: For each issue that is approved by user, post a review to the PR
   with comments on specific lines of code. Or if no issues, do not post comments.

   Build a JSON file and use the GitHub review API:
   ```bash
   # Write review JSON to a unique temp file (use $$ for PID to avoid collisions)
   cat > "/tmp/pr-review-${PR_NUMBER}-$$.json" << 'EOF'
   {
     "commit_id": "<HEAD_SHA>",
     "event": "COMMENT",
     "body": "Short review summary (1-2 sentences)",
     "comments": [
       {
         "path": "relative/path/to/file.rs",
         "line": 42,
         "body": "Comment text -- see tone guidelines below"
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
   - Do NOT use `--raw-field` for the comments array -- it doesn't handle nested JSON. Always use `--input` with a file.

   Read `references/comment-style.md` before composing GitHub review comments.

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
