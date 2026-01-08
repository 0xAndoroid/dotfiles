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

You will implement the engineering plan detailed in PLAN_TO_EXECUTE.

When you complete the work, report their final changes made in a comprehensive `RESULTS.md` file at the root of their respective workspace.

Do not commit `RESULTS.md`, `CLAUDE.md` or PLAN_TO_EXECUTE to git.

When running agents make sure they compile the code as little as possible. Make sure only specific tests are being run, not all tests.

Unless absolutely necessary, stick to pre-approved commands only, as using other commands requires manual confirmation of user.

Periodically commit your changes to git.
