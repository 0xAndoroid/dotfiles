# AI Slop Cleaner Patterns

Use these only after behavior is protected by tests or a written verification plan.

## Prefer

- Delete unused functions, exports, flags, debug branches, and stale comments.
- Inline pass-through wrappers that only rename arguments or forward calls.
- Merge duplicate branches that differ only by labels or formatting.
- Replace speculative "future-proof" option objects with the direct value currently needed.
- Move logic back to the layer that owns the state or side effect.
- Strengthen missing regression coverage before removing suspicious fallback code.

## Example

```ts
// Before: generated wrapper adds no behavior.
export function getUserNameForDisplay(user: User): string {
  return formatUserNameForDisplay(user);
}

// After: callers use the existing formatter directly.
formatUserNameForDisplay(user);
```
