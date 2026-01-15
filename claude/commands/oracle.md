---
allowed-tools: mcp__pal__chat, mcp__pal__thinkdeep, mcp__pal__codereview, Read, Glob
description: Get second-model review for complex problems
---

# /oracle

Get a second opinion from another model using PAL MCP tools.

## Model Selection

- **Default:** `gemini-3-pro-preview` - 1M context, cost-effective
- **Hard problems only:** `gpt-5.2-pro` - Very expensive, use sparingly

Only escalate to gpt-5.2-pro when:
- gemini-3-pro-preview gave insufficient answer
- Problem is exceptionally complex (architecture, security-critical)
- Need maximum reasoning depth

## When to Use

- Stuck on a bug that needs fresh perspective
- Want design/architecture review
- Cross-validate complex logic
- Debug hypothesis validation

## Workflow

1. **Gather context** - Read relevant files using Read/Glob
2. **Choose tool based on task:**
   - `mcp__pal__chat` - Quick questions, brainstorming
   - `mcp__pal__thinkdeep` - Deep analysis, architecture decisions (works with both gemini-3-pro-preview and gpt-5.2-pro)
   - `mcp__pal__codereview` - Code quality, security, performance review

3. **Always include:**
   - `model: "gemini-3-pro-preview"` (or gpt-5.2-pro for hard problems)
   - `relevant_files` with absolute paths
   - `thinking_mode` appropriate to complexity (low/medium/high/max)

4. **Preserve context** - Reuse `continuation_id` from previous calls

## Examples

### Quick Review (chat with gemini)
```
mcp__pal__chat:
  prompt: "Review this error handling approach..."
  model: "gemini-3-pro-preview"
  relevant_files: ["/path/to/file.rs"]
  thinking_mode: "medium"
```

### Deep Analysis (thinkdeep with gemini)
```
mcp__pal__thinkdeep:
  prompt: "Analyze this architecture..."
  model: "gemini-3-pro-preview"
  relevant_files: ["/path/to/module.rs"]
  thinking_mode: "high"
  step_number: 1
  total_steps: 2
  next_step_required: true
  findings: "Initial investigation..."
```

### Very Hard Problem (escalate to gpt-5.2-pro)
```
mcp__pal__thinkdeep:
  prompt: "Analyze race condition..."
  model: "gpt-5.2-pro"
  relevant_files: ["/path/to/concurrent.rs"]
  thinking_mode: "max"
  step_number: 1
  total_steps: 2
  next_step_required: true
  findings: "Initial investigation..."
```

## Cost Awareness

- gemini-3-pro-preview: ~$0.01-0.05 per query
- gpt-5.2-pro: ~$0.50-2.00 per query (10-40x more expensive)

Always try gemini-3-pro-preview first unless you're certain the problem requires gpt-5.2-pro.
