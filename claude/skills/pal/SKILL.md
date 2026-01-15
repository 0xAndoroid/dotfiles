---
name: pal
description: Multi-model orchestration for debugging, code review, architecture decisions, planning, and deep analysis. Use for complex tasks needing external validation.
user-invocable: false
---

# PAL MCP Server

Multi-model orchestration tools. Use proactively for complex tasks.

## Tool Selection

| Task | Tool |
|------|------|
| Runtime errors, crashes | `debug` |
| Static analysis, security | `codereview` |
| Architecture decisions | `consensus` |
| Complex planning | `planner` |
| Pre-commit validation | `precommit` |
| Deep analysis | `thinkdeep` |
| Quick questions, brainstorm | `chat` |

## Critical Rules

1. **ALWAYS reuse `continuation_id`** from previous PAL calls - preserves context across resets
2. **Use `thinking_mode`**: minimal(128t) → low(2K) → medium(8K) → high(16K) → max(32K)
3. **Absolute paths** in `relevant_files`

## Tool Parameters

**debug**: `step`, `hypothesis`, `confidence` (exploring→certain), `relevant_files`, `findings`
```
step_number=1, total_steps=N, next_step_required=true/false
```

**codereview**: `review_type` (full|security|performance|quick), `relevant_files`, `issues_found`
```
review_validation_type=external (2 steps) | internal (1 step)
```

**precommit**: `path` (repo root), `compare_to` (optional ref), `include_staged/unstaged`
```
total_steps>=3 for external validation
```

**consensus**: `models` array with `model`, `stance` (for/against/neutral)
```
models: [{"model":"gemini-2.5-pro","stance":"for"}, {"model":"gpt-5.2-pro","stance":"against"}]
```

**planner**: `step`, `branch_id`, `is_branch_point`, `is_step_revision`

**thinkdeep**: Same as debug, defaults to max thinking

**chat**: `prompt`, `model`, `working_directory_absolute_path` (required)

**clink**: Bridge to external CLIs - `cli_name` (claude|codex|gemini), `role` (default|codereviewer|planner)

**apilookup**: Auto-fetch current docs - just pass `prompt` with API/SDK name

## Skip PAL When

- Simple edits, obvious fixes
- Tasks not needing external validation
