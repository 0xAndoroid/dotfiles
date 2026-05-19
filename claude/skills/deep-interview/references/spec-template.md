# Deep Interview Spec Template

Write the final spec to `.claude/specs/deep-interview-{slug}.md`.

```markdown
# Deep Interview Spec: {title}

## Metadata
- Interview ID: {uuid}
- Rounds: {count}
- Final Ambiguity Score: {score}%
- Type: greenfield | brownfield
- Generated: {timestamp}
- Threshold: {threshold}
- Status: PASSED | BELOW_THRESHOLD_EARLY_EXIT

## Clarity Breakdown
| Dimension | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Goal Clarity | {s} | {w} | {s*w} |
| Constraint Clarity | {s} | {w} | {s*w} |
| Success Criteria | {s} | {w} | {s*w} |
| Context Clarity | {s} | {w} | {s*w} |
| **Total Clarity** | | | **{total}** |
| **Ambiguity** | | | **{1-total}** |

## Goal
{crystal-clear goal statement derived from the interview}

## Constraints
- {constraint}

## Non-Goals
- {excluded scope}

## Acceptance Criteria
- [ ] {testable criterion}

## Assumptions Exposed And Resolved
| Assumption | Challenge | Resolution |
|------------|-----------|------------|
| {assumption} | {question/challenge} | {decision} |

## Technical Context
{brownfield: relevant repo findings}
{greenfield: technology choices and constraints}

## Ontology
Use the final round's ontology extraction.

| Entity | Type | Fields | Relationships |
|--------|------|--------|---------------|
| {entity.name} | {entity.type} | {entity.fields} | {entity.relationships} |

## Ontology Convergence
Use `state.ontology_snapshots`.

| Round | Entity Count | New | Changed | Stable | Stability Ratio |
|-------|--------------|-----|---------|--------|-----------------|
| 1 | {n} | {n} | - | - | - |
| 2 | {n} | {new} | {changed} | {stable} | {ratio}% |

## Interview Transcript
<details>
<summary>Full Q&A ({n} rounds)</summary>

### Round 1
**Q:** {question}
**A:** {answer}
**Ambiguity:** {score}% (Goal: {g}, Constraints: {c}, Criteria: {cr})

</details>
```
