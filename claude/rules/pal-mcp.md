## PAL MCP — External AI via GPT-5.4 and Codex

PAL MCP tools provide access to GPT-5.4 (1M context, extended thinking) and external AI CLIs (Codex, Gemini) as a second-opinion and deep-reasoning layer. All tools are prefixed `mcp__pal__`.

### When to Use PAL

Use PAL as an **escalation layer**, not a first resort:
- `thinkdeep` — complex multi-system bugs, architectural trade-offs, deep root-cause analysis. Use when your own investigation hits a wall or when confidence is low on a high-stakes decision.
- `codereview` — independent validation of uncertain code review findings. Use `review_type: "security"` for security-focused review. Cross-validate before reporting false positives.
- `challenge` — adversarial scrutiny of your own conclusions. Use before finalizing architectural recommendations or when you catch yourself agreeing too easily.
- `refactor` — code smell detection, decomposition analysis. Supports `style_guide_examples` for project-specific patterns.
- `chat` — brainstorming, second opinions, reasoning through edge cases. Lightweight alternative to thinkdeep for quick consultations.
- `clink` — spawn an external AI CLI (Codex, Gemini, or Claude) to work on a task. Use `cli_name: "codex"` to get a Codex agent for independent implementation, sandboxed execution, or a competing solution. Use `role: "codereviewer"` for review tasks, `role: "planner"` for planning. Supports `continuation_id` for multi-turn sessions and `absolute_file_paths` to share context.

### Key Parameters

- Pass `absolute_file_paths` instead of inlining code into `prompt` — PAL reads files directly.
- Reuse `continuation_id` across calls within the same logical task (works across different PAL tools).
- `thinkdeep`/`codereview`/`refactor` are multi-step: set `step_number`, `total_steps`, `next_step_required`, `findings`.
- `challenge` takes only a `prompt` — pass the claim/decision to scrutinize.

### Anti-Patterns

- Don't use PAL for mechanical tasks (git ops, file search, simple edits).
- Don't use PAL from latency-sensitive agents (explore, writer, executor in tight loops).
- Don't inline large code blocks in `prompt` — use `absolute_file_paths` or `relevant_files`.
