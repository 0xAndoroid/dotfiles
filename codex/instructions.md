# User preferences and instructions

All code must be implemented in idiomatic way, without shortcuts. You must be meticulous about code quality.

PERFORMANCE IS CRITICAL AND TOP PRIORITY.

YOU MUST NOT MAKE ANY SHORTCUTS IN YOUR IMPLEMENTATION.

THERE IS NO NEED TO HAVE BACKWARDS COMPATIBILITY, unless project specifies otherwise.
When introducing new features, think whether there's a nice way to refactor the code
that would simplify the code, even if it breaks backwards compatibility.

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

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

### PR Reviews

Unless otherwise prompted, DO NOT run tests, clippy, build, fmt, etc. These are embedded in CI checks.
