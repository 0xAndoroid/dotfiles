# Context Isolation

Keep main context lean. Delegate exploration to disposable subagent contexts.

## The Rule

Before reading 3+ files on a topic, STOP. Use `/explore-bg` or background Task instead.

## Background Agent Pattern

```
Task(subagent_type="Explore", run_in_background=true,
     prompt="<question>. Write findings to ~/.claude/cache/agents/explore-<topic>.md")
```

Wait for completion, then:
```
Read("~/.claude/cache/agents/explore-<topic>.md")
```

## NEVER Use TaskOutput

```
WRONG: TaskOutput(task_id="...")  # dumps 70k+ tokens
RIGHT: Read("~/.claude/cache/agents/<file>.md")  # ~500 tokens
```

## Decision Matrix

| Situation | Action |
|-----------|--------|
| "Where is X?" | `/explore-bg where is X` |
| "How does Y work?" | `/explore-bg how does Y work` |
| User names specific file | `Read` directly |
| About to edit a file | `Read` directly |
| Need to grep broadly | Background agent |
| Quick single file check | `Read` directly |

## Output Directory

`~/.claude/cache/agents/`

## Why This Matters

```
Without isolation:
├─ grep results (5k tokens)
├─ file read 1 (3k tokens)
├─ file read 2 (2k tokens)
├─ ... exploration ...
└─ Total: 50k tokens before real work

With isolation:
├─ Task spawns background agent
├─ Agent explores (50k tokens, DISCARDED)
├─ Read summary file (500 tokens)
└─ Total: 500 tokens, ready to work
```
