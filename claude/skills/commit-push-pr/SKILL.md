---
name: commit-push-pr
description: 'Commit local changes, push the branch, and open or update a GitHub pull request. Use when the user asks to "open a PR", "create PR", "commit and push", "push changes", "submit for review", "send PR", or make a draft PR. Checks scope, avoids unrelated files, screens for secrets, creates a branch when needed, commits intentionally, pushes with upstream tracking, and reports the PR URL.'
---

# Commit, Push, PR

Use this skill when the user wants local changes published to GitHub as a pull request.

## Steps

1. **Inspect the worktree**
   - Run `git status --short`, `git branch --show-current`, and `git diff --stat`.
   - If there are no changes to commit, stop and report that.
   - Identify which files are in scope for the user's request. Do not stage unrelated user changes without explicit approval.

2. **Check for existing PRs**
   - Run `gh pr list --head "$(git branch --show-current)"`.
   - If a PR already exists for this branch, update it instead of creating a duplicate unless the user asked for a new branch.

3. **Choose the branch**
   - If currently on `main` or `master`, create a descriptive branch with `git checkout -b <type>/<short-topic>`.
   - If already on a topic branch, stay there unless the user requested a different branch.

4. **Screen for mistakes before staging**
   - Review `git diff` for accidental files, debug output, generated noise, and secrets.
   - Stop if `.env`, private keys, credentials, tokens, or unrelated large files appear in the staged scope.
   - Run `git diff --check` when practical to catch whitespace/conflict-marker issues.

5. **Stage and commit**
   - Stage only the intended files with explicit paths.
   - Use a concise conventional commit when it fits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, or `perf:`.
   - Include the verification performed in the final report, not necessarily in the commit body.

6. **Push**
   - Push with upstream tracking: `git push -u origin "$(git branch --show-current)"`.
   - If the branch already has upstream tracking, a normal `git push` is fine.

7. **Open or update the PR**
   - For a new PR, run `gh pr create`.
   - Title: Match commit message or summarize changes
   - Body format:
     ```
     ## Summary
     <2-3 bullet points>

     ## Changes
     <list key file changes>

     ## Testing
     <how to test, or "CI covers this">

     Closes #<issue> (if applicable)
     ```
   - Add `--draft` if the user asked for draft/work-in-progress review.
   - For an existing PR, push the new commit and report the existing PR URL.

8. **Report outcome**
   - Branch
   - Commit SHA and message
   - PR URL
   - Tests/checks run, or "not run" with a reason

## Safety Rules

- Never use `git reset --hard`, `git checkout --`, or force-push unless the user explicitly asks.
- Never include unrelated dirty worktree changes just to make the PR cleaner.
- If the user asks for a draft PR, do not mark it ready for review.
- If `gh` is unauthenticated or the remote is missing, stop with the exact blocker and leave local changes intact.
