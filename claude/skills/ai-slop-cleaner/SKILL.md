---
name: ai-slop-cleaner
description: 'Clean up, refactor, and simplify AI-generated or overgrown code without changing behavior. Use when the user says "AI slop", "deslop", "anti-slop", "clean up this code", "remove bloat", "simplify generated code", "delete dead code", "collapse wrappers", "reduce duplication", or asks for a reviewer-only cleanup pass. Removes dead code, duplicate logic, speculative abstractions, noisy comments, weak tests, and boundary leaks with regression checks after each focused pass.'
---

# AI Slop Cleaner

Use this skill to clean AI-generated code slop without drifting scope or changing intended behavior. This is the bounded cleanup workflow for code that works but feels bloated, repetitive, weakly tested, or over-abstracted.

## When to Use

Use this skill when:
- the user explicitly says `deslop`, `anti-slop`, or `AI slop`
- the request is to clean up or refactor code that feels noisy, repetitive, or overly abstract
- follow-up implementation left duplicate logic, dead code, wrapper layers, boundary leaks, or weak regression coverage
- the user wants a reviewer-only anti-slop pass via `--review`
- the goal is simplification and cleanup, not new feature delivery

## When Not to Use

Do not use this skill when:
- the task is mainly a new feature build or product change
- the user wants a broad redesign instead of an incremental cleanup pass
- the request is a generic refactor with no simplification or anti-slop intent
- behavior is too unclear to protect with tests or a concrete verification plan

## Execution Posture

- Preserve behavior unless the user explicitly asks for behavior changes.
- Lock behavior with focused regression tests first whenever practical.
- Write a cleanup plan before editing code.
- Prefer deletion over addition.
- Reuse existing utilities and patterns before introducing new ones.
- Avoid new dependencies unless the user explicitly requests them.
- Keep diffs small, reversible, and smell-focused.

## Scoped File-List Usage

This skill can be bounded to an explicit file list or changed-file scope when the caller already knows the safe cleanup surface.

- Good fit: `ai-slop-cleaner skills/some-skill/SKILL.md skills/ai-slop-cleaner/SKILL.md`
- Good fit: a calling workflow handing off only the files changed in that session
- Preserve the same regression-safe workflow even when the scope is a short file list
- Do not silently expand a changed-file scope into broader cleanup work unless the user explicitly asks for it

## Loop Integration

A persistence loop or driver workflow can invoke this skill as a bounded post-review cleanup pass.

- In that workflow, the cleaner runs in standard mode (not `--review`)
- The cleanup scope is the calling session's changed files only
- After the cleanup pass, the caller re-runs regression verification before completion
- `--review` remains the reviewer-only follow-up mode, not the default integration path

## Review Mode (`--review`)

`--review` is a reviewer-only pass after cleanup work is drafted. It exists to preserve explicit writer/reviewer separation for anti-slop work.

- **Writer pass**: make the cleanup changes with behavior locked by tests.
- **Reviewer pass**: inspect the cleanup plan, changed files, and verification evidence.
- The same pass must not both write and self-approve high-impact cleanup without a separate review step.
- Read `references/review-mode.md` before producing the reviewer verdict.

## Workflow

1. **Protect current behavior first**
   - Identify what must stay the same.
   - Add or run the narrowest regression tests needed before editing.
   - If tests cannot come first, record the verification plan explicitly before touching code.

2. **Write a cleanup plan before code**
   - Bound the pass to the requested files or feature area.
   - List the concrete smells to remove.
   - Order the work from safest deletion to riskier consolidation.

3. **Classify the slop before editing**
   - **Duplication** -- repeated logic, copy-paste branches, redundant helpers
   - **Dead code** -- unused code, unreachable branches, stale flags, debug leftovers
   - **Needless abstraction** -- pass-through wrappers, speculative indirection, single-use helper layers
   - **Boundary violations** -- hidden coupling, misplaced responsibilities, wrong-layer imports or side effects
   - **Missing tests** -- behavior not locked, weak regression coverage, edge-case gaps

4. **Run one smell-focused pass at a time**
   - **Pass 1: Dead code deletion**
   - **Pass 2: Duplicate removal**
   - **Pass 3: Naming and error-handling cleanup**
   - **Pass 4: Test reinforcement**
   - Re-run targeted verification after each pass.
   - Do not bundle unrelated refactors into the same edit set.

5. **Run the quality gates**
   - Keep regression tests green.
   - Run the relevant lint, typecheck, and unit/integration tests for the touched area.
   - Run existing static or security checks when available.
   - If a gate fails, fix the issue or back out the risky cleanup instead of forcing it through.

6. **Close with an evidence-dense report**
   Always report:
   - **Changed files**
   - **Simplifications**
   - **Behavior lock / verification run**
   - **Remaining risks**

## Common Transformations

Read `references/cleanup-patterns.md` when choosing what to delete, inline, merge, or move.

Inline examples of good cleanup targets:

- Delete unused functions, exports, debug branches, and stale comments.
- Inline pass-through wrappers that only rename arguments or forward calls.
- Merge duplicate branches that differ only by labels or formatting.
- Move logic back to the layer that owns the state or side effect.

```ts
// Before: generated wrapper adds no behavior.
export function getUserNameForDisplay(user: User): string {
  return formatUserNameForDisplay(user);
}

// After: callers use the existing formatter directly.
formatUserNameForDisplay(user);
```

## Report Template

```markdown
Changed files:
- <file>: <what was simplified>

Verification:
- <command>: <result>

Remaining risks:
- <risk or "none known">
```

## Usage

- `/ai-slop-cleaner <target>`
- `/ai-slop-cleaner <target> --review`
- `/ai-slop-cleaner <file-a> <file-b> <file-c>`
- From a calling loop: run the cleaner on the session's changed files only, then return to the caller for post-cleanup regression verification

## Good Fits

**Good:** `deslop this module: too many wrappers, duplicate helpers, and dead code`

**Good:** `cleanup the AI slop in src/auth and tighten boundaries without changing behavior`

**Bad:** `refactor auth to support SSO`

**Bad:** `clean up formatting`
