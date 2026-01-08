# Task Execution [PLAN_TO_EXECUTE_FILE]

## Variables
PLAN_TO_EXECUTE: $ARGUMENTS

## Run these commands top to bottom
READ: PLAN_TO_EXECUTE

## PAL Tools for Execution

Use PAL tools when issues arise during execution:
- `mcp__pal__debug`: Runtime errors, crashes - use `hypothesis` + `confidence` levels
- `mcp__pal__thinkdeep`: Complex blockers requiring deep analysis
- `mcp__pal__chat`: Quick questions, validation of approach mid-execution
- `mcp__pal__precommit`: Before periodic commits, validate changes

**Remember**: Reuse `continuation_id` across all PAL calls in this session.

---

## Instructions

Implement the engineering plan detailed in PLAN_TO_EXECUTE.

When complete, report final changes in a comprehensive `RESULTS.md` file at workspace root.

Do not commit `RESULTS.md`, `CLAUDE.md` or PLAN_TO_EXECUTE to git.

## Error Recovery

When execution fails:
1. **Compilation error**: Use `mcp__pal__debug` with the error. Don't retry blindly.
2. **Test failure**: Analyze with `mcp__pal__thinkdeep`. Check if test is flaky or code is wrong.
3. **Stuck >10 min on same issue**: Use `mcp__pal__chat` to brainstorm alternatives.
4. **Unclear requirement**: Ask user before proceeding with assumptions.

## Escalate to User When
- Plan requires changes to files not mentioned in plan
- Discovered architectural issue that affects plan
- >3 failed attempts at same step
- Security-sensitive changes needed
- Unsure which of multiple valid approaches to take

## Checkpointing
- Commit after completing each major section of the plan
- Use descriptive messages: `WIP: implement X from plan step N`
- Don't commit broken code - stash if needed
- Run only specific relevant tests, not full test suite

## Execution Guidelines
- Compile/build only when needed to verify changes work
- Run specific tests for changed functionality, not all tests
- Stick to pre-approved commands - other commands require user confirmation
