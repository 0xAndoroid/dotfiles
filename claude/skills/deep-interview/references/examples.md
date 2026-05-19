# Deep Interview Examples

## Weakest-Dimension Targeting

```text
Scores: Goal=0.9, Constraints=0.4, Criteria=0.7
Next question targets Constraints because support boundaries are the bottleneck.

When you say "works on mobile", does that mean responsive web, native app, or PWA?
```

## Brownfield Evidence First

```text
I found JWT middleware in src/auth/ using passport.js. Should this feature extend that existing auth path, or intentionally introduce a separate flow?
```

## Early Exit Warning

```text
Current ambiguity is 35% (threshold: 20%). Areas still unclear:
- Success Criteria: 0.5 (verification for ranking quality is undefined)
- Constraints: 0.6 (no performance target yet)

Proceeding may require rework. Continue anyway?
```

## Ontology Question

```text
Across the last rounds you described this as a workflow, an inbox, and a planner. Which one is the core thing this product is, and which are supporting metaphors or views?
```

## Anti-Patterns

- Do not ask multiple questions in one round.
- Do not ask the user for facts the codebase can reveal.
- Do not proceed to implementation while ambiguity remains above threshold unless the user explicitly accepts the risk.
