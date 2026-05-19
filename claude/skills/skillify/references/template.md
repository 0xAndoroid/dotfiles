# Skillify Template

Fill this template when drafting a full `SKILL.md`.

```markdown
---
name: <kebab-case-skill-name>
description: '<what the skill does>. Use when the user asks to "<natural trigger>", "<natural trigger>", or <situation>. <Concrete actions the skill performs>.'
---

# <Skill Title>

Use this skill when <specific situation>. Do not use it when <nearby but wrong situation>.

## Required Context

- <file, command, tool output, or user input needed before acting>

## Workflow

1. <first action>
2. <next action>
3. <validation checkpoint>
4. <completion or handoff>

## Stop Conditions

- <condition that should pause or ask the user>
- <condition that means the skill does not apply>

## Output

- <artifact or final report shape>
- <verification evidence>
```

Keep the generated skill concise. Move long prompts, examples, schemas, or templates into `references/` and link them from the body.
