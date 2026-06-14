---
name: pr-review
description: 'Deep pull request review using parallel analysis agents (semantic consistency, bugs, tech debt, security). Posts validated review comments into a live Hunk review session by default; GitHub PR posting is reference-only unless the user explicitly asks for it. USE FOR: - Reviewing PRs for bugs, security issues, and code quality - Analyzing new abstractions for consistency and correctness - Identifying tech debt and architectural concerns - Preparing line comments for Hunk or optional GitHub PR review posting TRIGGERS: - "review PR", "PR review", "code review", "review changes" - "diff review", "PR feedback", "check PR" - "analyze diff", "critique code", "review code" - "pull request review", "GitHub PR review"'
---

Provide a pull request review.

Follow these steps:

1. **Eligibility Check** (Sonnet): Check if the PR (a) is closed, (b) is automated/trivial. If so, stop.

2. **PR Analysis** (Fable): View the PR and return:
   - Summary of the change and its purpose
   - List of new functions, types, enums, or abstractions introduced
   - For each new abstraction: its name, stated purpose (from comments/docs), and intended usage contract

3. **Parallel Deep Review** (4 Fable agents): Pass the PR summary and new abstractions list to each agent. Use `references/review-agents.md` for the exact prompts.

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

5. **Compose review comments** (IMMEDIATELY after step 4 -- do not pause):

   Read `references/comment-style.md` before composing comments.

   For each validated issue worth surfacing, prepare one inline review comment with:
   - `filePath`: repo-relative path
   - `newLine`: the NEW file line number, on a line modified by the PR
   - `summary`: comment text following `references/comment-style.md`
   - `rationale`: optional supporting detail when the summary needs context

   Do not ask which issues to post. Do not prompt about GitHub. Continue to step 6.

6. **Post comments to Hunk by default**:

   Apply the prepared comments to the live Hunk review session before any GitHub PR posting.
   Use `hunk session *` commands only; do not run interactive `hunk diff`, `hunk show`, or TUI commands.

   Inspect the session and visible review first:
   ```bash
   hunk session list --json
   hunk session get --repo . --json
   hunk session review --repo . --json
   ```

   Apply comments as one batch:
   ```bash
   printf '%s\n' '{"comments":[{"filePath":"relative/path/to/file.rs","newLine":42,"summary":"Comment text","rationale":"Optional detail"}]}' \
     | hunk session comment apply --repo . --stdin
   ```

   Key points:
   - Use `comment apply` for multiple agent-generated comments.
   - Target `newLine` for added/modified PR lines.
   - Only apply comments for visible files/lines in the loaded Hunk review.
   - If no active Hunk session exists, or a target line is not visible, do not block and do not ask the user to post to GitHub instead. Report that Hunk comments were not applied and include the prepared comments in the final response.
   - If no issues survive validation, do not apply comments.

7. **Report results and stop**:

   Present ALL validated issues in a single final message, formatted as a numbered list with scores.
   Include: file path, line number, one-line description, score, and 1-2 sentence rationale.

   Also report:
   - Whether comments were applied to Hunk
   - That GitHub/PR comments were not posted, by default

   Do not ask whether to post to GitHub. Stop here unless the user explicitly asked in the current request to post to GitHub/PR.

8. **GitHub posting reference only**:

   Use this section only when the user explicitly asks to post comments to GitHub/PR.
   If the exact comments have not already been applied to Hunk in this run, apply them to Hunk first via step 6.

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
- When applying or posting comments, target specific changed lines of code
- Do not post comments to GitHub unless the user explicitly asks
- Make a todo list to track progress
