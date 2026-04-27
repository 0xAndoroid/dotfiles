---
name: portfolio-news-weekly
description: "Generate the weekly crypto portfolio news summary: per-project bullets (protocol upgrades, governance, exploits, listings, partnerships, milestones), top-5 actionable signals, source citations. Markdown → HTML → message_parent. USE FOR: weekly Sunday 9am portfolio news trigger; ad-hoc 'portfolio news this week' / 'what happened to my holdings'. TRIGGERS: 'weekly portfolio news', 'portfolio news summary', 'crypto holdings news', 'what's new with my portfolio', 'sunday news summary'."
---

# portfolio-news-weekly

> **Inputs:** today's date (resolve to absolute Mon-Sun-ish 7-day window), holdings list (read from `~/.pika/vault/memory/crypto.md`).
>
> **Outputs:** (1) Markdown report at `~/.pika/vault/notes/portfolio-news-YYYY-MM-DD.md`. (2) HTML at `/tmp/portfolio-news-YYYY-MM-DD.html`. (3) `message_parent` to main session with HTML attachment + 5-bullet summary.

## Execution model — READ FIRST

**You are the executor.** Every step below is something YOU run yourself with your own tools in this same session.

**DO NOT:**
- Spawn a subagent, background task, or worker.
- Invoke the `Agent` / `Task` tool to hand this off.
- Re-invoke this skill or any wrapper.
- Use Nansen MCP — user finds Nansen-based weekly reviews useless. This is news-only.

**Tools you use directly:** `mcp__perplexity__perplexity_search`, `mcp__perplexity__perplexity_research` (fallback for thin coverage), `Write` (markdown report), `Bash` (markdown-to-html), `mcp__pika__message_parent`.

## Constants

| Thing | Value |
|---|---|
| Holdings source | `~/.pika/vault/memory/crypto.md` (line: `**Keep:** ...`, plus `Bought` line for HYPE/Lighter/COW) |
| Markdown output | `~/.pika/vault/notes/portfolio-news-YYYY-MM-DD.md` |
| HTML output | `/tmp/portfolio-news-YYYY-MM-DD.html` |
| HTML render cmd | `markdown-to-html -s <md> -o <html>` |
| Parent dispatch | `mcp__pika__message_parent` w/ `file_attachments=[<html>]` |
| Budget | <$1 total. ~10 perplexity_search calls (~$0.10). Research calls $0.10 each (use sparingly). |

## Ticker disambiguation (CRITICAL)

User's holdings have multiple ambiguous tickers. ALWAYS disambiguate in search queries:

| User holds | Project | Disambiguator in query |
|---|---|---|
| ZK | **StarkNet ZK token** (governance for StarkNet) | `"StarkNet ZK token"` or `"StarkNet governance"` — NEVER zkSync |
| LIT / Lighter | **Lighter Finance** (perp DEX, US C-corp, $68M raise Founders Fund + Ribbit) | `"Lighter Finance perp DEX"` |
| COW | **CoW Protocol / CoW Swap** (DEX aggregator, MEV-protected batch auctions) | `"CoW Protocol CoW Swap"` |
| HYPE | **Hyperliquid** (perp DEX L1, Jeff Yan + Iliensinc) | `"Hyperliquid HYPE perp DEX"` |
| VIRTUAL | **Virtuals Protocol** (AI agent launchpad on Base) | `"Virtuals Protocol AI agents"` |
| ATOM | **Cosmos Hub** | `"Cosmos Hub ATOM"` |
| ARB | **Arbitrum** | `"Arbitrum ARB"` |
| EIGEN | **EigenLayer** | `"EigenLayer EIGEN restaking"` |

If a project's news search returns a clearly-different ticker (e.g. zkSync ZK, LIT instead of Lighter), redo the query with stronger disambiguators.

## Filter rules

**EXCLUDE from report body:**
- Price action commentary ("X up Y%", "broke resistance", chart analysis)
- Generic market analysis ("crypto market sentiment", "altcoins rally")
- Nansen on-chain flows (user explicitly excluded — see `memory/crypto.md`)
- Speculation ("could 10x", "moon target", price predictions)

**INCLUDE in report body:**
- Protocol upgrades / mainnet releases / hard forks
- Governance proposals (passed, failed, pending) with proposal IDs
- Partnerships / integrations (only material — not vague "ecosystem expansion")
- Exploits, hacks, security incidents (with $ figures and dates)
- Exchange listings (new, delisted, roadmap additions)
- Team changes / fundraising
- Ecosystem milestones (TVL crossings, user counts, major dApp launches)
- ETF / institutional product news

## Workflow

### 1. Resolve date window

```bash
# today = system clock; window = today minus 7 days through today
# Compute absolute dates (e.g. "Apr 19-26"). NEVER use "this week" / "last week".
```

### 2. Read holdings

Read `~/.pika/vault/memory/crypto.md` to confirm current holdings. The list can change week-to-week (sells, new buys). Don't hardcode.

As of Apr 26, 2026 the list was: **ETH, SOL, ZK (StarkNet), COW, ARB, ATOM, VIRTUAL, EIGEN, HYPE, Lighter** — 10 projects. Verify before each run.

### 3. Parallel news search

Single message with N parallel `mcp__perplexity__perplexity_search` calls (one per project). Keep `max_results: 8` per call. Do NOT use `search_recency_filter: "week"` reflexively — Perplexity often returns better-quality results without the filter and you can date-gate locally. If the unfiltered call is noisy, redo with `search_recency_filter: "week"`.

Example query template:
```
"<Project full name> <Ticker> <category keywords> April 2026"
```
e.g. `"Hyperliquid HYPE perp DEX protocol news April 2026"`.

### 4. Optional research escalation

If a project returned thin or off-topic coverage, run ONE `mcp__perplexity__perplexity_research` call for that project (slow ~30s, deeper). Don't blanket-research — most projects yield enough from `perplexity_search` alone.

### 5. Synthesize

Per project, extract 3-7 bullets matching the INCLUDE filter. If no material news, write `"Quiet week — no major news in the Apr X-Y window."` and move on. Don't pad.

For each bullet:
- Lead with the date or the action verb
- Include $ figures, proposal IDs, version numbers, names where present
- Trailing source ref `[N]` matching the Sources section

### 6. Top-5 ranking

Rank top-5 actionable signals across ALL projects by significance to the user. Significance = (a) material change to investment thesis, (b) governance/security action that requires user attention, (c) listing or institutional adoption that affects liquidity. NOT price-driven.

### 7. Write markdown report

Path: `~/.pika/vault/notes/portfolio-news-YYYY-MM-DD.md`

Structure (strict):
```markdown
# Portfolio News — <Month Day>, <Year> (week of Apr X-Y)

## Top 5 actionable signals
- 5 bullets, ranked, each with project tag in **bold** prefix and source [N]

---

## ETH
- Bullets [N]
- ...

## SOL
- ...

[repeat for each project; "Quiet week" entries OK]

---

## Sources
1. <Outlet> — "<Title>" (YYYY-MM-DD): <URL>
2. ...
```

### 8. Convert to HTML

```bash
markdown-to-html -s ~/.pika/vault/notes/portfolio-news-YYYY-MM-DD.md -o /tmp/portfolio-news-YYYY-MM-DD.html
```

### 9. Dispatch to main

```
mcp__pika__message_parent(
  text="**Portfolio news — week of Apr X-Y, YYYY**\n\nTop 5 signals (full report attached):\n\n- ...\n- ...\n[5 bullets matching the report's top-5 section verbatim]\n\nMarkdown source: `~/.pika/vault/notes/portfolio-news-YYYY-MM-DD.md`",
  file_attachments=["/tmp/portfolio-news-YYYY-MM-DD.html"]
)
```

## Success criteria

- All N holdings covered (or "Quiet week" entry per project)
- Top-5 section non-empty (always at least 5, even on slow weeks)
- Every body bullet has a source citation `[N]`
- Sources section is numbered with URL + outlet + date
- Markdown file written at the canonical vault path
- HTML rendered to `/tmp/`
- `message_parent` returned `ok: true` and `dispatched_to_main: true`
- Total spend under $1 (typically $0.10–$0.30)

## Pitfalls

- **Day-of-week labels:** Compute weekday from the date. Don't trust Pika's hint.
- **Date references:** ABSOLUTE dates only. No "last week" / "this week".
- **Nansen:** User explicitly excluded for the recurring weekly. Do not use even if perplexity returns Nansen-flavored articles.
- **Price commentary creep:** Easy to drift into "X surged Y%" — strip it. The user reads charts elsewhere.
- **EIGEN / quiet projects:** It's OK to have multiple "Quiet week" entries. Don't fabricate news.
- **Ambiguous-ticker contamination:** If `ZK` results pull in zkSync news, redo the search. Never mix.
- **Source rot:** Many crypto news sites are LLM-generated SEO churn (BYDFi, AInvest, MEXC News). Their facts are usually OK but cross-reference with the project's own forum/blog when claiming a specific governance vote or upgrade activation.
- **Trigger context:** This skill runs from a Pika trigger session by default. `message_parent` is the right dispatch path (NOT `send_message` — that's for main session direct→user).
