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
- Use plain unified diffs for agent review: `git diff --no-ext-diff --no-color`.
- Use explicit paths when staging. Avoid `git add -A` or broad staging when unrelated user changes may exist.
- Screen staged scope for secrets, generated noise, debug output, and unrelated files.
- Preserve pre-existing staged changes. Do not unstage or rewrite another person's work unless explicitly asked.
- Final reports should say what is staged, what verification ran, and whether anything relevant remains unstaged.

## Pika (personal assistant bridge)

`pika` bridges to **Pika**, my personal AI assistant on my Mac (Telegram bot, Obsidian vault memory, calendar/email integrations, background agents, dashboard at https://me.andrew.ee).

**`send_to_pika(text, attachment_handles?)`** — synchronous: returns Pika's reply inline. SILENT to my Telegram unless Pika decides to push. Delegate freely.

Use it to: notify me on Telegram, publish reports to me.andrew.ee, log vault notes, add calendar events/reminders, or hand off research.

**Attach files:**
1. `curl -s -X POST http://100.81.62.125:7479/upload -H "Authorization: Bearer $PIKA_DELEGATION_TOKEN" -F "file=@/path"`
2. `send_to_pika(text="...", attachment_handles=["att_..."])`

## Comment Policy

### Unacceptable Comments
- Comments that repeat what code does
- Commented-out code (delete it)
- Obvious comments ("increment counter")
- Comments instead of good naming
- Section separating comments with a lot of equal signs
- Indefinite TODOs without issue links

### Acceptable Comments
- WHY something is done (when not obvious from context)
- WARNING comments for non-obvious gotchas
- TODO with issue links: `// TODO(#123): description`
- Public API documentation
- SAFETY comments for unsafe code explaining invariants
- Complex algorithm explanations (link to paper/source if applicable)

### Principle
Code should be self-documenting. If you need a comment to explain WHAT the code does, consider refactoring to make it clearer.

## Rust Development

### Cargo Commands

- Use `cargo nextest` instead of `cargo test`
- Add `--cargo-quiet` flag with `cargo nextest`
- Add `-q` flag to: cargo clippy, run, build, fmt, doc, clean ONLY
- Add `--message-format=short` to: cargo clippy, check, run, build, fmt, doc, clean ONLY

Never run cargo commands in parallel. Always run them sequentially, one at a time.
This includes `multi_tool_use.parallel`, background shells, separate terminal sessions,
and concurrent agents. Cargo can contend on file locks and interleave output.

### PR Reviews

Unless otherwise prompted, DO NOT run tests, clippy, build, fmt, etc. These are embedded in CI checks.
