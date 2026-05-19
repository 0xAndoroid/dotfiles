---
name: skillify
description: 'Turn a repeatable workflow from the current session into a reusable skill draft. Use when the user asks to "save this as a skill", "create a skill", "make this reusable", "turn this workflow into SKILL.md", or capture a repeatable process as a Claude/Codex skill. Extracts triggers, inputs, ordered steps, success criteria, constraints, and validation, then writes or proposes a valid SKILL.md.'
---

# Skillify

Use this skill when the current session uncovered a repeatable workflow worth encoding as a reusable skill.

## Workflow

1. Identify the repeatable task the session accomplished.
2. Extract:
   - inputs
   - ordered steps
   - success criteria
   - constraints / pitfalls
   - validation commands or checks
   - natural trigger phrases the user would say
   - best target location for the skill
3. Decide whether the workflow belongs as:
   - a repo built-in skill
   - a user/project learned skill
   - documentation only
4. Draft a complete skill file that starts with Tessl-compatible YAML frontmatter.
   - Never emit plain markdown-only skill files.
   - Minimum frontmatter:
     ```yaml
     ---
     name: <skill-name>
     description: <what the skill does, when to use it, and natural trigger phrases>
     ---
     ```
   - Put trigger guidance in `description`, not a custom `triggers` frontmatter key.
   - Use `references/template.md` as the fill-in template when drafting a full skill.
   - Write learned/user/project skills to:
     - `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/<skill-name>/SKILL.md`
     - `.claude/skills/<skill-name>/SKILL.md`
5. Draft the body with:
   - when to use / when not to use
   - required context to gather
   - ordered workflow
   - validation and completion criteria
   - edge cases that should stop or ask the user
6. Validate the draft:
   - Confirm the frontmatter has `name` and `description`.
   - Ensure no unknown frontmatter keys are needed; move extra metadata into the body.
   - Run `tessl skill review <path-to-skill-folder>` when the CLI is available, then revise clear issues.
7. Point out anything still too fuzzy to encode safely.

## Rules

- Only capture workflows that are actually repeatable.
- Keep the skill practical and scoped.
- Prefer explicit success criteria over vague prose.
- If the workflow still has unresolved branching decisions, note them before drafting.
- Keep `SKILL.md` concise. Move long templates, examples, prompts, or references into bundled files and link them from the body.

## Minimal Template

```markdown
---
name: <kebab-case-skill-name>
description: '<what the skill does>. Use when the user asks to "<natural trigger>" or <situation>. <Concrete actions the skill performs>.'
---

# <Skill Title>

Use this skill when <specific situation>. Do not use it when <nearby but wrong situation>.

## Workflow
1. <first action>
2. <validation checkpoint>
3. <completion or handoff>

## Output
- <artifact or final report shape>
- <verification evidence>
```

## Worked Example

Session signal: the user repeatedly asked for dependency risk checks after lockfile changes.

Draft shape:

```markdown
---
name: dependency-audit
description: 'Audit dependency changes before merge. Use when the user asks to review package updates, dependency diffs, lockfile changes, supply-chain risk, or "check these deps". Inspects manifests and lockfiles, checks release notes for risky updates, verifies tests, and reports merge risk.'
---

# Dependency Audit

Use this skill for dependency-only or dependency-heavy changes.

## Workflow
1. Inspect manifests and lockfiles.
2. Identify direct vs transitive updates.
3. Check release notes for major or security-sensitive packages.
4. Run the repo's relevant tests or explain why they were not run.
5. Report risks, required follow-ups, and safe-to-merge status.
```

## Output

- Proposed skill name
- Target location
- Draft workflow structure
- Validation performed
- Open questions, if any
