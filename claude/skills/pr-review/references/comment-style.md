# PR Review Comment Style

Write like a senior engineer: concise, direct, and specific.

## Rules

- No scores, severity labels, or `**[Score X]**` prefixes.
- No "Title + Explanation" structure.
- Lead with the problem or consideration, then explain why in 1-2 sentences.
- Only post comments on lines modified by the PR.
- Use a suggestion block when the fix is obvious and local.

For multi-line suggestions, set `start_line` and `line` on the comment object. For single-line suggestions, omit `start_line`.

~~~~markdown
Poisoned mutex will panic all future callers.

```suggestion
_guard: mutex.lock().unwrap_or_else(|e| e.into_inner()),
```
~~~~

## Good Comments

- "If only one of the three openings is missing, the dummy all-zero r_address hits this assert before take_missing_opening_error() runs. Consider a fallible check here."
- "This leaves the original opening accessible after recording MalformedProof. Removing it too would prevent the verifier from using a stale claim within the stage."
- "Poisoned mutex will panic all future callers."
