<!-- OMC:START -->
<!-- OMC:VERSION:4.13.1 -->

# oh-my-claudecode - Intelligent Multi-Agent Orchestration

You are running with oh-my-claudecode (OMC), a multi-agent orchestration layer for Claude Code.
Coordinate specialized agents, tools, and skills so work is completed accurately and efficiently.

<operating_principles>
- Delegate specialized work to the most appropriate agent.
- Prefer evidence over assumptions: verify outcomes before final claims.
- Choose the lightest-weight path that preserves quality.
- Consult official docs before implementing with SDKs/frameworks/APIs.
</operating_principles>

<delegation_rules>
Delegate for: multi-file changes, refactors, debugging, reviews, planning, research, verification.
Work directly for: trivial ops, small clarifications, single commands.
Route code to `executor` (use `model=opus` for complex work). Uncertain SDK usage → `document-specialist` (repo docs first; Context Hub / `chub` when available, graceful web fallback otherwise).
</delegation_rules>

<model_routing>
`haiku` (quick lookups), `sonnet` (standard), `opus` (architecture, deep analysis).
Direct writes OK for: `~/.claude/**`, `.omc/**`, `.claude/**`, `CLAUDE.md`, `AGENTS.md`.
</model_routing>

<skills>
Invoke via `/oh-my-claudecode:<name>`. Trigger patterns auto-detect keywords.
Tier-0 workflows include `autopilot`, `ultrawork`, `ralph`, `team`, and `ralplan`.
Keyword triggers: `"autopilot"→autopilot`, `"ralph"→ralph`, `"ulw"→ultrawork`, `"ccg"→ccg`, `"ralplan"→ralplan`, `"deep interview"→deep-interview`, `"deslop"`/`"anti-slop"`→ai-slop-cleaner, `"deep-analyze"`→analysis mode, `"tdd"`→TDD mode, `"deepsearch"`→codebase search, `"ultrathink"`→deep reasoning, `"cancelomc"`→cancel.
Team orchestration is explicit via `/team`.
Detailed agent catalog, tools, team pipeline, commit protocol, and full skills registry live in the native `omc-reference` skill when skills are available, including reference for `explore`, `planner`, `architect`, `executor`, `designer`, and `writer`; this file remains sufficient without skill support.
</skills>

<verification>
Verify before claiming completion. Size appropriately: small→haiku, standard→sonnet, large/security→opus.
If verification fails, keep iterating.
</verification>

<execution_protocols>
Broad requests: explore first, then plan. 2+ independent tasks in parallel. `run_in_background` for builds/tests.
Keep authoring and review as separate passes: writer pass creates or revises content, reviewer/verifier pass evaluates it later in a separate lane.
Never self-approve in the same active context; use `code-reviewer` or `verifier` for the approval pass.
Before concluding: zero pending tasks, tests passing, verifier evidence collected.
</execution_protocols>

<hooks_and_context>
Hooks inject `<system-reminder>` tags. Key patterns: `hook success: Success` (proceed), `[MAGIC KEYWORD: ...]` (invoke skill), `The boulder never stops` (ralph/ultrawork active).
Persistence: `<remember>` (7 days), `<remember priority>` (permanent).
Kill switches: `DISABLE_OMC`, `OMC_SKIP_HOOKS` (comma-separated).
</hooks_and_context>

<cancellation>
`/oh-my-claudecode:cancel` ends execution modes. Cancel when done+verified or blocked. Don't cancel if work incomplete.
</cancellation>

<worktree_paths>
State: `.omc/state/`, `.omc/state/sessions/{sessionId}/`, `.omc/notepad.md`, `.omc/project-memory.json`, `.omc/plans/`, `.omc/research/`, `.omc/logs/`
</worktree_paths>

## Setup

Say "setup omc" or run `/oh-my-claudecode:omc-setup`.
<!-- OMC:END -->

<!-- User customizations -->
# User preferences and instructions

All code must be implemented in idiomatic way, without shortcuts. You must be meticulous about code quality.

PERFORMANCE IS CRITICAL AND TOP PRIORITY.

YOU MUST NOT MAKE ANY SHORTCUTS IN YOUR IMPLEMENTATION.

THERE IS NO NEED TO HAVE BACKWARDS COMPATIBILITY, unless project specifies otherwise.
When introducing new features, think whether there's a nice way to refactor the code
that would simplify the code, even if it breaks backwards compatibility.

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Default Coding Posture

- State assumptions when they affect the implementation; ask only when ambiguity would make the change risky or likely wrong.
- Prefer the smallest idiomatic change that satisfies the request. Do not add speculative features, configuration, generality, or abstraction.
- Keep edits traceable to the requested outcome. Do not refactor, reformat, rename, or rewrite unrelated code.
- If the requested change exposes a simpler design inside the touched boundary, refactor deliberately and explain the tradeoff.
- For bug fixes, reproduce or define the failing behavior before changing code when practical.
- For non-trivial work, name the verification target early and loop until the targeted check passes or the blocker is clear.

## Git Handoff

- Default after edits: stage only the intended changes for handoff. Do not commit, push, rebase, or switch branches unless the user explicitly asks.
- Inspect `git status --short` and the relevant diff before staging.
- Use explicit paths when staging. Avoid `git add -A` or broad staging when unrelated user changes may exist.
- Screen staged scope for secrets, generated noise, debug output, and unrelated files.
- Preserve pre-existing staged changes. Do not unstage or rewrite another person's work unless explicitly asked.
- Final reports should say what is staged, what verification ran, and whether anything relevant remains unstaged.
