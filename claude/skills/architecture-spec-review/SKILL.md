---
name: architecture-spec-review
description: 'Use when reviewing a branch, PR, or git diff range at the architecture/abstractions altitude rather than hunting line-by-line bugs. Triggers: "architecture review", "architectural spec review", "PR to spec", "diff to spec", "reconstruct the spec", "future-proofing review", "abstraction review", "are these the right abstractions", "will this design scale", "blast radius of future features". Produces a NEUTRAL architecture spec (design reconstruction + future-pressure map) as a standalone report for a human to review. It surfaces the material to judge by; it does NOT render the verdict, abstraction diagnosis, risk ranking, or recommendations — those are the human reviewer''s.'
---

# Architecture Spec Review

## Overview

Turn a code diff into a written **architecture spec**: a faithful, neutral reconstruction of the design, plus a **future-pressure map** that lays out what realistic future features would cost to build on top of it. Operate at the altitude of abstractions, module boundaries, and design decisions — NOT line-by-line correctness.

**Division of labor — read this first.** You author the *spec*; the human does the *review*. Your job is to **describe and surface**, theirs is to **judge**. The spec gives the reviewer everything they need to answer "are these the right abstractions?" — but you do NOT answer it for them. Specifically, you do **not** produce: a verdict, an abstraction diagnosis ("this is leaky/rigid/over-engineered"), a ranked risk list, or recommendations. State design decisions and their tradeoffs neutrally (lay out the alternative; don't crown a winner). Map futures to blast radius and cost as facts. Then hand off.

This is a spec-authoring/reporting skill, not a bug hunter and not a verdict-giver. For correctness/security line review, use the `pr-review` skill instead.

## Writing style — write for a reader who will NOT open the code

The reader judges the design from your words alone. Assume they never look at the source. So:

- **No code paths.** Never cite `file.rs:123`. To this reader, line references are pure noise.
- **Minimal identifiers.** Name things by plain concept ("the scheduling core," "the final-opening helper," "the matrix sizing setup"), not by type/function name. Keep a literal identifier only when it is a genuine label the reviewer will reuse (e.g. the two layout names).
- **Lead with the gist. Short sentences. One idea each.** Open with a one-sentence summary and a small primer defining the load-bearing jargon — that beats explaining terms scattered throughout.
- **Altitude:** they want to understand the design and what future changes cost, not navigate the file tree. Use plain analogies for hard concepts.

## When to Use

- Architecture review of a branch / PR / diff range (you produce the spec the reviewer works from)
- "Turn this PR into a spec" / "reconstruct the design"
- Future-proofing or abstraction review; "will this scale / absorb what's next?" — you map the pressure; the reviewer draws the conclusion

Not for: line-by-line bug hunts, style nits, security audits → use `pr-review`. Not for: rendering the verdict/recommendations yourself — that's the human reviewer's call.

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

Reverse-engineer intent from the diff. Write it so a reader understands the design WITHOUT reading the code. Keep it **neutral and descriptive** — this is the substance of your deliverable:

- **Problem & requirements** the change implies (functional + non-functional).
- **Components / abstractions** introduced or modified, and their responsibilities.
- **Data & control flow** through the new code.
- **Boundaries & seams** — where this plugs into the existing system.
- **Key decisions & tradeoffs**, including alternatives not taken (when inferable). Present each as *decision + the tension it trades off* — do not pick a winner or call it good/bad. Genuinely factual observations ("X is derived independently on both sides; no test asserts they agree") are fair game and useful; verdicts ("this is fragile") are not — leave those for the reviewer.

### 3. Future-pressure map (neutral material for the reviewer)

The reviewer's verdict hinges on how the design absorbs change, so you give them the raw evidence — futures and what each would cost — **without diagnosing or concluding**. Do it deliberately:

1. **Brainstorm plausible next features** — 5-8 changes this system will realistically need next, given its domain. Mix obvious roadmap items with adversarial "what if a requirement shifts" cases.
2. **Estimate blast radius** for each against the architecture *as it stands after this PR*: which areas / components / interfaces change, and is the change localized or cross-cutting? Describe the seams in plain concepts — **not** file:line or identifiers (see Writing style). "Touched in ~6 places across the placement code, the schedule, and the final-point logic" is the right register.
3. **Classify cost** Low / Medium / High by the *mechanical* criterion (how far the edit spreads), not by a quality judgment:
   - **Low** — absorbed by existing extension points; you add code, you don't edit it (open/closed).
   - **Medium** — touches a few known seams; mechanical but spread out.
   - **High** — ripples across many modules, breaks a public interface, or forces reworking a core abstraction.

Present as a table: Feature | Blast radius | Cost | Why. The "Why" states *what it touches and whether that's localized or cross-cutting* — a fact, not a verdict.

**Do NOT** synthesize the cost pattern into an abstraction diagnosis (leaky / missing / rigid / over-engineered), and do NOT rank risks or recommend changes. The pattern is laid bare in the table; naming it as a defect and prescribing fixes is the reviewer's job. (Surfacing a neutral *open question* — "a third layout would edit these 4 sites; is a single dispatch seam wanted?" — is fine; answering it is not.)

### 4. Emit the report

- The report is the **spec** — it ends at the future-pressure map (plus any neutral open questions). Close with a one-line handoff making explicit that the verdict, risks, and recommendations are the reader's review. Do not append an "Assessment"/"Verdict"/"Recommendations" section.
- Format: **Markdown by default.** Produce **HTML** (standalone, inline CSS, no external assets) when the user asks or when tables/diagrams benefit. Skeletons for both: `report-template.md`.
- Output path: honor the user's requested path / `--output`; else default to `./<branch-or-pr>-architecture-spec.md` at the repo root.
- Keep it **portable** — never hardcode machine paths. (On a Pika setup, reports MAY optionally be dropped in `~/.pika/web/reports/` to surface on the dashboard — optional, not the default.)
- The report is **standalone**: a reader (or an AI in discussion) needs only the report, not the diff.

## Quick Reference

| Step | Output |
|------|--------|
| Resolve input | Three-dot diff vs merge-base + full file reads |
| Reconstruct spec | Problem, components, flow, boundaries, decisions (neutral) |
| Future-pressure map | Future features × blast radius × Low/Med/High — facts only, no diagnosis |
| Emit | Markdown (default) or HTML spec at output path; handoff line, no verdict/risks/recs |

The reviewer (the human), not this skill, produces the verdict, abstraction diagnosis, ranked risks, and recommendations.

## Common Mistakes

- **Doing the review instead of the spec** → the single biggest one. No verdict, no "this is a leaky/rigid/over-engineered abstraction," no ranked risks, no recommendations. You describe and surface; the human judges. If a sentence renders judgment or prescribes a change, cut it or reframe it as a neutral fact/open question.
- **Spraying code paths and identifiers** → the reader won't open the source; `file.rs:123` and bare type/function names are noise. Describe in plain concepts and lead with a primer. (See Writing style.)
- **Wall-of-text density** → even a domain expert tires of long compound sentences full of jargon. Short sentences, one idea each, gist first.
- **Reviewing hunks, not files** → you miss the abstraction context. Read full changed files.
- **Two-dot diff** (`base..head`) → pulls in upstream drift. Use three-dot / `--merge-base`.
- **Drifting into bug-hunting** → that's `pr-review`'s job. Stay at abstraction altitude.
- **Vague futures** ("more features") → useless. Name concrete, domain-specific features with realistic requirements.
- **Listing futures without costing them** → blast radius + Low/Med/High is the material the reviewer needs. Always classify by the mechanical spread criterion + justify with the seams it touches (this is a fact, not a verdict).
- **Editorializing the cost pattern** → laying out "these 3 futures are High, all touching seam X" is the spec; concluding "therefore X is the wrong abstraction" is the review. Stop at the pattern.
- **Hardcoding output paths** → keep portable; take a path or use the repo-root default.

## Assumptions

- A git CLI is available; `gh` is used only for PR-number/URL inputs.
- "Architecture as it stands after this PR" means the merge-base tip plus the branch — review the resulting state, not the branch in isolation.
