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
