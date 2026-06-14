# PR Review Agent Prompts

Pass the PR summary, abstraction list, and relevant diff context to each reviewer. Each agent should return only findings it believes are introduced by the PR.

## Semantic Consistency Agent

For each new function, type, enum, or abstraction:

- Read its definition, documentation, and comments describing intended use.
- Find all usages introduced or modified by the PR.
- Verify each usage matches the documented contract.
- Flag contract mismatches, wrong error-type handling, bypassed validators, inconsistent enum use, unsafe blocks, and security-sensitive misuse.

## Deep Bug Analysis Agent

Read full modified-file context, not just changed lines.

- Trace data flow and control flow around the change.
- Check logic errors, edge cases, off-by-one behavior, resource leaks, and invariant breaks.
- Verify each failure mode has appropriate error handling.
- Prefer concrete reproduction paths over pattern-matching guesses.

## Tech Debt Removal Agent

- Understand new abstractions and their intended ownership/contract.
- Check whether the abstraction level fits actual call sites instead of hypothetical future use.
- Compare the implementation with surrounding project patterns and language idioms.
- Flag maintainability issues that matter to this PR's long-term ownership.

## Security Reviewer Agent

- Check whether protocol changes preserve soundness.
- Identify attacker-controlled inputs and changed trust boundaries.
- Verify authn/authz checks are not bypassed or weakened.
- Review changed cryptography, resource limits, concurrency, external process execution, and file/network access.
- Do not report generic security advice without an exploit path or concrete trust-boundary risk in the PR.
