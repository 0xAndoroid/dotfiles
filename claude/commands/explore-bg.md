# /explore-bg

Background exploration - keeps main context lean.

## Usage

```
/explore-bg <question or area>
```

## Process

1. **Spawn Background Agent**
   ```
   Task(
     subagent_type="Explore",
     run_in_background=true,
     prompt="<user question>. Write findings to ~/.claude/cache/agents/explore-<topic>.md"
   )
   ```

2. **Wait for Completion**
   - Monitor via system reminders
   - Or poll: `ls -la ~/.claude/cache/agents/`

3. **Read Summary Only**
   ```
   Read("~/.claude/cache/agents/explore-<topic>.md")
   ```

## Output Convention

Agent writes to: `~/.claude/cache/agents/explore-<kebab-topic>.md`

Format:
```markdown
# Exploration: <topic>

## Summary
<2-3 sentence answer>

## Key Files
- path/to/file.ts:line - description
- path/to/other.ts:line - description

## Details
<longer explanation if needed>
```

## Why Background

| Approach | Context Cost |
|----------|--------------|
| Direct exploration | All file reads + greps (~50k tokens) |
| Background + read file | Just the summary (~500 tokens) |

## Examples

```
/explore-bg how does auth work
/explore-bg where are API routes defined
/explore-bg what testing framework is used
```

## Key Rule

NEVER use TaskOutput to get results. Always read the output file.
