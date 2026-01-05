# User preferences and instructions

Do not write a lot of comments. Comments should be rare only on complex parts of the code and on public APIs.
All code must be implemented in idiomatic way, without shortcuts. You must be meticulous about code quality.
PERFORMANCE IS CRITICAL AND TOP PRIORITY.
YOU MUST NOT MAKE ANY SHORTCUTS IN YOUR IMPLEMENTATION.
DO NOT USE cargo test. Only use cargo nextest.
Run cargo nextest, clippy, run, build, fmt, doc, clean with -q flag.
Run cargo clippy, check, run, build, fmt, doc, clean with --message-format=short.

When reviewing PRs, unless otherwise prompted, DO NOT run tests, clippy, build, fmt, etc. These are embeded in the CI checks.
