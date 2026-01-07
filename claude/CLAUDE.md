# User preferences and instructions

All code must be implemented in idiomatic way, without shortcuts. You must be meticulous about code quality.
PERFORMANCE IS CRITICAL AND TOP PRIORITY.
YOU MUST NOT MAKE ANY SHORTCUTS IN YOUR IMPLEMENTATION.
DO NOT USE cargo test. Only use cargo nextest.
Run cargo nextest, clippy, run, build, fmt, doc, clean with -q flag.
Run cargo clippy, check, run, build, fmt, doc, clean with --message-format=short.

You have access to RUST LSP via LSP tool. Use it extensively as it's very powerful.

When reviewing PRs, unless otherwise prompted, DO NOT run tests, clippy, build, fmt, etc. These are embeded in the CI checks.

## Comment Policy

### Unacceptable Comments
- Comments that repeat what code does
- Obvious comments ("increment counter")
- Comments instead of good naming

### Principle
Code should be self-documenting. If you need a comment to explain WHAT the code does, consider refactoring to make it clearer.
