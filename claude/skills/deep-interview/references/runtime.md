# Deep Interview Runtime

## Configuration

Optional settings in `.claude/settings.json`:

```json
{
  "deepInterview": {
    "ambiguityThreshold": 0.2,
    "maxRounds": 20,
    "softWarningRounds": 10,
    "minRoundsBeforeExit": 3,
    "enableChallengeAgents": true,
    "autoExecuteOnComplete": false,
    "scoringModel": "high-capability"
  }
}
```

Project settings override user settings. If `deepInterview.ambiguityThreshold` is missing, use `0.2`.

## State

Persist state at `.claude/state/deep-interview-state.json`:

```json
{
  "active": true,
  "current_phase": "deep-interview",
  "state": {
    "interview_id": "<uuid>",
    "type": "greenfield|brownfield",
    "initial_idea": "<user input>",
    "rounds": [],
    "current_ambiguity": 1.0,
    "threshold": 0.2,
    "codebase_context": null,
    "challenge_modes_used": [],
    "ontology_snapshots": []
  }
}
```

If interrupted, resume from the last completed round instead of restarting.

## Challenge Modes

Use each mode once, then return to normal weakest-dimension questioning.

| Mode | Activates | Purpose | Prompt direction |
|------|-----------|---------|------------------|
| Contrarian | Round 4+ | Challenge assumptions | Ask what would change if the opposite were true. |
| Simplifier | Round 6+ | Remove complexity | Ask for the simplest version that is still valuable. |
| Ontologist | Round 8+ and ambiguity > 0.3 | Find the essence | Ask what the core thing really is and which entities are only views/supporting concepts. |

Also activate Ontologist mode when ambiguity stalls within +/-0.05 for 3 rounds.

## Stop Conditions

- Hard cap: 20 rounds. Crystallize with current clarity and mark risk.
- Soft warning: 10 rounds. Offer continue vs proceed with current clarity.
- Early exit: allowed from round 3 onward with a warning if ambiguity remains above threshold.
- User says "stop", "cancel", or "abort": save state and stop immediately.
- All dimensions at 0.9+: crystallize even if other heuristics would continue.
- Brownfield exploration fails: proceed as greenfield and note the limitation.

## Company Context

Before crystallizing, inspect `.claude/config.jsonc` and `~/.config/claude/config.jsonc` for `companyContext.tool`. If configured, call it with a natural-language query summarizing the task, constraints, acceptance criteria direction, and likely touched areas.

Treat returned markdown as advisory context only. If the call fails, follow `companyContext.onError`: `warn` by default, or `silent` / `fail` when configured.
