---
name: architecture-spec-review
description: 'Use when reviewing a branch, PR, or git diff range at the architecture/abstractions altitude rather than hunting line-by-line bugs. Triggers: "architecture review", "architectural spec review", "PR to spec", "diff to spec", "reconstruct the spec", "future-proofing review", "abstraction review", "are these the right abstractions", "will this design scale", "blast radius of future features". Produces a standalone written report (Markdown or HTML) a human reads or discusses with an AI.'
---

# Architecture Spec Review

## Overview

Turn a code diff into a written **architectural spec + adversarial future-proofing review**. Operate at the altitude of abstractions, module boundaries, and design decisions — NOT line-by-line correctness.

The report answers one question: **are these the right abstractions?** Good abstractions make likely future features cheap; leaky or misplaced ones make them expensive. You reveal which by stress-testing the design against the futures it will realistically face.

This is an analysis/reporting skill, not a bug hunter. For correctness/security line review, use the `code-review` skill instead.

## When to Use

- Architecture review of a branch / PR / diff range
- "Turn this PR into a spec" / "reconstruct the design"
- Future-proofing or abstraction review; "will this scale / absorb what's next?"

Not for: line-by-line bug hunts, style nits, security audits → use `code-review`.

## Workflow

### 1. Resolve input → full branch diff

Accept any of: branch name, PR URL/number, or an explicit range (`origin/main...HEAD`).

- PR number/URL → `gh pr view <n> --json headRefName,baseRefName,title,body`, then diff those refs.
- Always diff against the **merge-base** (three-dot) so you review only what the branch adds, not upstream drift:
  ```bash
  git diff --merge-base <base> <head> --stat        # file-level overview first
  git diff --merge-base <base> <head> --name-status # spot added (A) vs modified (M) files
  git diff --merge-base <base> <head>               # full diff (== <base>...<head>)
  ```
- Read **full files**, not just hunks, for every changed/added file — abstractions live in the surrounding code, not the diff window.
- Large diff? Fan out: dispatch parallel sub-agents to summarize file clusters, then synthesize (see superpowers:dispatching-parallel-agents).

### 2. Reconstruct the architectural spec

Reverse-engineer intent from the diff. Write it so a reader understands the design WITHOUT reading the code:

- **Problem & requirements** the change implies (functional + non-functional).
- **Components / abstractions** introduced or modified, and their responsibilities.
- **Data & control flow** through the new code.
- **Boundaries & seams** — where this plugs into the existing system.
- **Key decisions & tradeoffs**, including alternatives not taken (when inferable).

### 3. Adversarial future-feature stress test (the core)

The differentiator. Do it deliberately:

1. **Brainstorm plausible next features** — 5-8 changes this system will realistically need next, given its domain. Mix obvious roadmap items with adversarial "what if a requirement shifts" cases.
2. **Estimate blast radius** for each against the architecture *as it stands after this PR*: which modules / files / interfaces change, and is the change localized or cross-cutting?
3. **Classify cost** Low / Medium / High with reasoning:
   - **Low** — absorbed by existing extension points; you add code, you don't edit it (open/closed).
   - **Medium** — touches a few known seams; mechanical but spread out.
   - **High** — ripples across many modules, breaks a public interface, or forces reworking a core abstraction.
4. **Diagnose the abstractions** from the pattern of costs. Many High-cost futures ⇒ wrong/leaky/missing abstractions; name the specific seam. Explicitly flag:
   - **Leaky abstractions** — callers must know internals.
   - **Missing extension points** — every new variant edits the same switch/if-chain.
   - **Rigid seams** — hardcoded assumptions that block a whole class of futures.
   - **Over-engineering** — indirection/abstraction that buys nothing for any plausible future. This is a defect too; recommend deleting it.

Present as a table: Feature | Blast radius | Cost | Why.

### 4. Overall architectural assessment

- **Verdict** — do the abstractions fit the reconstructed spec? One paragraph; commit to a position.
- **Top risks**, ranked.
- **Recommendations** — specific seams to add / move / remove, each tied to the future(s) that justify it.

### 5. Emit the report

- Format: **Markdown by default.** Produce **HTML** (standalone, inline CSS, no external assets) when the user asks or when tables/diagrams benefit. Skeletons for both: `report-template.md`.
- Output path: honor the user's requested path / `--output`; else default to `./<branch-or-pr>-architecture-review.md` at the repo root.
- Keep it **portable** — never hardcode machine paths. (On a Pika setup, reports MAY optionally be dropped in `~/.pika/web/reports/` to surface on the dashboard — optional, not the default.)
- The report is **standalone**: a reader (or an AI in discussion) needs only the report, not the diff.

## Quick Reference

| Step | Output |
|------|--------|
| Resolve input | Three-dot diff vs merge-base + full file reads |
| Reconstruct spec | Problem, components, flow, boundaries, decisions |
| Stress test | Future features × blast radius × Low/Med/High + abstraction diagnosis |
| Assess | Verdict + ranked risks + recommendations |
| Emit | Markdown (default) or HTML report at output path |

## Common Mistakes

- **Reviewing hunks, not files** → you miss the abstraction context. Read full changed files.
- **Two-dot diff** (`base..head`) → pulls in upstream drift. Use three-dot / `--merge-base`.
- **Drifting into bug-hunting** → that's `code-review`'s job. Stay at abstraction altitude.
- **Vague futures** ("more features") → useless. Name concrete, domain-specific features with realistic requirements.
- **Listing futures without costing them** → the cost estimate IS the signal. Always classify + justify.
- **Ignoring over-engineering** → unused abstraction is as much a defect as a missing one. Flag both.
- **Hardcoding output paths** → keep portable; take a path or use the repo-root default.

## Assumptions

- A git CLI is available; `gh` is used only for PR-number/URL inputs.
- "Architecture as it stands after this PR" means the merge-base tip plus the branch — review the resulting state, not the branch in isolation.
