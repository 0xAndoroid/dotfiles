---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

## Rust Development

### Cargo Commands

- Use `cargo nextest` instead of `cargo test`
- Add `-q` flag to: clippy, run, build, fmt, doc, clean
- Add `--cargo-quiet` flag to nextest
- Add `--message-format=short` to: clippy, check, run, build, fmt, doc, clean

### PR Reviews

Unless otherwise prompted, DO NOT run tests, clippy, build, fmt, etc. These are embedded in CI checks.
