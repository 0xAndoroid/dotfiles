# Deep Interview Scoring

Use a high-capability model or your strongest available reasoning path for scoring. Keep temperature low when the runtime supports it. Respond with structured JSON before summarizing to the user.

## Dimensions

Greenfield:

- Goal clarity, weight 0.40
- Constraint clarity, weight 0.30
- Success criteria clarity, weight 0.30

Brownfield:

- Goal clarity, weight 0.35
- Constraint clarity, weight 0.25
- Success criteria clarity, weight 0.25
- Context clarity, weight 0.15

Ambiguity formula:

```text
ambiguity = 1 - weighted_clarity
```

## Scoring Prompt

```text
Given this interview transcript for a {greenfield|brownfield} project, score each clarity dimension from 0.0 to 1.0.

Original idea:
{idea}

Transcript:
{rounds}

Score:
1. Goal clarity: Is the objective unambiguous? Can the key entities and relationships be stated without qualifiers?
2. Constraint clarity: Are boundaries, limitations, and non-goals clear?
3. Success criteria clarity: Could tests or concrete acceptance criteria verify success?
4. Context clarity: For brownfield only, do we understand the existing system well enough to modify it safely?

For each dimension return:
- score
- one-sentence justification
- gap if score < 0.9

Also return:
- weakest_dimension
- weakest_dimension_rationale
- ontology.entities, where each entity has name, type, fields, relationships

If previous ontology entities exist, reuse names for the same concept. Only introduce new names for genuinely new concepts.
```

## Ontology Stability

Round 1 has no stability comparison. If a round produces zero entities, mark stability as N/A.

For round 2+:

- `stable_entities`: same entity name appears in previous and current round.
- `changed_entities`: different name, same type, and more than 50% field overlap. Count these as renamed stable concepts.
- `new_entities`: current entities not matched by name or fuzzy match.
- `removed_entities`: previous entities not matched by name or fuzzy match.
- `stability_ratio = (stable + changed) / total_current_entities`

Before reporting stability, briefly list the matched, renamed, new, and removed entities so the user can sanity-check the classification.

## Progress Report

After every answer, show:

```markdown
Round {n} complete.

| Dimension | Score | Weight | Weighted | Gap |
|-----------|-------|--------|----------|-----|
| Goal | {s} | {w} | {s*w} | {gap or "Clear"} |
| Constraints | {s} | {w} | {s*w} | {gap or "Clear"} |
| Success Criteria | {s} | {w} | {s*w} | {gap or "Clear"} |
| Context | {s} | {w} | {s*w} | {gap or "Clear"} |
| **Ambiguity** | | | **{score}%** | |

Ontology: {entity_count} entities | Stability: {stability_ratio} | New: {new} | Changed: {changed} | Stable: {stable}

Next target: {weakest_dimension} - {weakest_dimension_rationale}
```

Omit the Context row for greenfield projects.
