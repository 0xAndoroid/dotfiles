---
name: orchestrating-swarms
description: Multi-agent orchestration patterns using teams and tasks. Use when coordinating parallel agents, pipelines with dependencies, or self-organizing task queues.
---

# Swarm Orchestration Patterns

## Pattern 1: Parallel Specialists (Fan-Out)

Multiple agents work independently, leader synthesizes results.

```
TeamCreate({ team_name: "review", description: "PR review" })

# Spawn specialists in parallel (single message, multiple Task calls)
Task({ team_name: "review", name: "security", subagent_type: "general-purpose",
       prompt: "Review PR for security. Send findings to team-lead.", run_in_background: true })
Task({ team_name: "review", name: "perf", subagent_type: "general-purpose",
       prompt: "Review PR for performance. Send findings to team-lead.", run_in_background: true })

# Wait for results (auto-delivered to inbox)
# Synthesize, then shutdown
SendMessage({ type: "shutdown_request", recipient: "security", content: "Done" })
SendMessage({ type: "shutdown_request", recipient: "perf", content: "Done" })
TeamDelete()
```

## Pattern 2: Pipeline (Sequential Dependencies)

Each stage blocks on the previous via task dependencies.

```
TeamCreate({ team_name: "feature" })

TaskCreate({ subject: "Research", description: "...", activeForm: "Researching..." })
TaskCreate({ subject: "Implement", description: "...", activeForm: "Implementing..." })
TaskCreate({ subject: "Test", description: "...", activeForm: "Testing..." })

TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })
TaskUpdate({ taskId: "3", addBlockedBy: ["2"] })

# Spawn workers — they claim tasks as they unblock
Task({ team_name: "feature", name: "researcher", subagent_type: "Explore",
       prompt: "Claim task #1, complete it, send findings to team-lead.", run_in_background: true })
Task({ team_name: "feature", name: "dev", subagent_type: "general-purpose",
       prompt: "Poll TaskList. When #2 unblocks, claim and implement.", run_in_background: true })
```

## Pattern 3: Self-Organizing Swarm

Workers race to claim from a shared task pool. Natural load-balancing.

```
TeamCreate({ team_name: "swarm" })

# Create independent tasks (no dependencies)
TaskCreate({ subject: "Review auth.rs", description: "...", activeForm: "Reviewing..." })
TaskCreate({ subject: "Review api.rs", description: "...", activeForm: "Reviewing..." })
TaskCreate({ subject: "Review db.rs", description: "...", activeForm: "Reviewing..." })

# Spawn N workers with identical prompt
WORKER_PROMPT = """
Loop:
1. TaskList() → find pending task with no owner
2. Claim: TaskUpdate({ taskId: X, owner: "YOUR_NAME" })
3. Work on it
4. Complete: TaskUpdate({ taskId: X, status: "completed" })
5. Send findings to team-lead
6. Repeat until no tasks remain
"""

Task({ team_name: "swarm", name: "w1", subagent_type: "general-purpose",
       prompt: WORKER_PROMPT, run_in_background: true })
Task({ team_name: "swarm", name: "w2", subagent_type: "general-purpose",
       prompt: WORKER_PROMPT, run_in_background: true })
```

## Pattern 4: Plan Approval Gate

Teammate must get plan approved before implementing.

```
Task({ team_name: "team", name: "architect", subagent_type: "general-purpose",
       prompt: "Design OAuth implementation", mode: "plan", run_in_background: true })

# You receive plan_approval_request, then:
SendMessage({ type: "plan_approval_response", recipient: "architect",
              request_id: "...", approve: true })
```

## Shutdown Choreography

Always follow: request → wait for approval → cleanup.

```
SendMessage({ type: "shutdown_request", recipient: "worker-1", content: "Done" })
# Wait for shutdown_response with approve: true
# Repeat for all teammates
TeamDelete()  # Fails if active members remain
```

## Spawn Backends

Auto-detected. Override with `CLAUDE_CODE_SPAWN_BACKEND`.

| Backend | When | Visibility | Persistence |
|---------|------|------------|-------------|
| **in-process** | Default (no tmux) | Hidden | Dies with leader |
| **tmux** | `$TMUX` set | `tmux select-pane -t N` | Survives leader |
| **iterm2** | iTerm2 + `it2` CLI | Split panes | Dies with window |

## Agent Type Selection

| Type | Tools | Use For |
|------|-------|---------|
| Explore | Read-only | Search, analysis (use `model: "haiku"` for speed) |
| Plan | Read-only | Architecture, planning |
| general-purpose | All | Implementation, multi-step work |
