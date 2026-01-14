# User preferences and instructions

All code must be implemented in idiomatic way, without shortcuts. You must be meticulous about code quality.
PERFORMANCE IS CRITICAL AND TOP PRIORITY.
YOU MUST NOT MAKE ANY SHORTCUTS IN YOUR IMPLEMENTATION.
DO NOT USE cargo test. Only use cargo nextest.
Run cargo clippy, run, build, fmt, doc, clean with -q flag. For cargo nextest use --cargo-quiet flag.
Run cargo clippy, check, run, build, fmt, doc, clean with --message-format=short.

You have access to RUST LSP via LSP tool. Use it extensively as it's very powerful.

When reviewing PRs, unless otherwise prompted, DO NOT run tests, clippy, build, fmt, etc. These are embeded in the CI checks.

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

---

# Claude-Mem (Memory System)

Persistent memory across sessions. Use 3-layer workflow to minimize token waste.

## 3-Layer Workflow (CRITICAL)

```
1. search(query) → Index with IDs (~50-100t total)
2. timeline(anchor=ID) → Context around results
3. get_observations([IDs]) → Full details ONLY for filtered IDs
```

**NEVER fetch all observations upfront.** Filter first → fetch selectively.

## Tool Parameters

**search**: `query`, `limit`, `project`, `type`, `obs_type`, `dateStart`, `dateEnd`
```
Types: 🔴 bugfix | 🟣 feature | 🔵 discovery | ⚖️ decision | 🔄 refactor | ✅ change
```

**timeline**: `anchor` (observation ID) OR `query`, `depth_before`, `depth_after`

**get_observations**: `ids` array (required)

## Best Practices

1. **Query 2-3 key terms** - specific, not broad
2. **Prioritize critical types** - 🔴 bugfixes, ⚖️ decisions
3. **Check token cost** in index (~155t per full observation)
4. **Fetch 2-3 observations** per session, not 50

## When to Search

- Starting session on existing project
- Debugging (check prior context)
- Before architectural decisions (past ⚖️ decisions)
- Context feels missing
