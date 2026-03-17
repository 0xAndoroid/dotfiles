---
description: 'Analyze PokerNow hand histories using poker-cli. USE FOR: - Computing player stats (VPIP, PFR, 3-bet, C-bet, AF, WTSD, WWSF) - Replaying specific hands with made-hand descriptions - Searching/filtering hands by player, pot size, showdown, won/lost - Comparing player performance across sessions - Session summaries TRIGGERS: - "poker stats", "hand history", "analyze session" - "show hand", "replay hand", "what happened in hand" - "search hands", "big pots", "showdown hands" - "player stats", "VPIP", "how did X play" - "session summary", "biggest pot", "who won"'
allowed-tools:
  - Bash(./target/release/poker-cli:*)
  - Bash(cargo build:*)
---

## Context

- **Command:** `poker-cli` (assumed installed and on PATH)
- **Source:** `~/dev/poker-cli`
- **Hand files:** `~/dev/pokernow/hands/YYYY-MM-DD.json`
- **Tests:** 251 tests, ~92% line coverage. `cargo test` / `cargo llvm-cov`

## Commands

### stats — Player Statistics

```bash
poker-cli stats [files...]
poker-cli stats                              # uses config.toml files
poker-cli stats session1.json session2.json  # explicit files
poker-cli stats --player Andrew session.json # single-player compact view
```

Per-player output ranked by P&L: VPIP, PFR, 3-Bet%, Fold-to-3B%, Cold Call%, C-Bet%, Fold-to-CB%, AF, WTSD%, W$SD%, WWSF%, All-in EV, positional breakdowns (EP/MP/CO/BTN/SB/BB), net P&L in BB, BB/hand. Multi-file merges stats across sessions. `--player` flag shows a single player.

### hand — Hand Replay

```bash
poker-cli hand <id> [files...]
poker-cli hand 245 session.json              # by hand number (matches search output)
poker-cli hand geyaotgpt14p session.json     # by PokerNow hash ID
```

Street-by-street replay with:
- Header: hand number, hash ID, stakes, player count, effective stack in BB
- Visible hole cards for all shown players
- Each action with amounts and pot-relative sizing (e.g., "bets 22 (67% pot)")
- Board cards and running pot
- Made hand descriptions at each street (e.g., "flush, ace-high", "top pair, queens", "open-ended straight draw")
- Final result with winner and amount
- Per-player net P&L line (e.g., "Net: aryan +62 | pranav -30 | Andrew -30")

Hand number matches the `Hand #` column in search output. Hash ID always works across all files.

### search — Hand Search/Filter

```bash
poker-cli search [filters...] [files...]
poker-cli search --player Andrew --min-pot 100 --showdown session.json
poker-cli search --player Andrew --lost --sort pot session.json
poker-cli search --saw-flop Andrew --sort pot session.json
```

**Filters:**
- `--player <name>` — hands where player was dealt in
- `--saw-flop <name>` — player saw the flop
- `--saw-turn <name>` — player saw the turn
- `--saw-river <name>` — player saw the river
- `--min-pot <bb>` — minimum pot size in BB
- `--max-pot <bb>` — maximum pot size in BB
- `--showdown` — only showdown hands (player-aware when combined with `--player`)
- `--no-showdown` — only non-showdown hands
- `--won` — only hands where `--player` won money
- `--lost` — only hands where `--player` lost money
- `--sort pot` — sort by pot size descending (default: hand number)

Output: hand number, PokerNow hash ID, pot size (BB), showdown status, winner, amount won. When `--player` is specified, an additional "Player Net" column shows how much that player won/lost in each hand.

### summary — Session Summary

```bash
poker-cli summary [files...]
poker-cli summary session.json
```

Compact one-screen overview: hand count, stakes, player count, biggest pot, and a P&L table with VPIP/PFR/BB-per-hand for all players ranked by profit. Also shows biggest winner and biggest loser.

### gen-config — Generate Config Template

```bash
poker-cli gen-config
```

Generates a fully-commented default `config.toml` with all available options. Errors if `config.toml` already exists in the current directory.

### Global Flags

```bash
poker-cli --unify-players "pranav,pranavv;Steve,steveooooo" stats session.json
poker-cli --no-config stats session.json
poker-cli --chips stats session.json
poker-cli --format hu,short,full stats session.json
poker-cli --blind-remap "0.5/1:1/1,2/1:1/2" stats session.json
```

- `--unify-players <groups>` — merge player identities. First name = canonical. Semicolons separate groups. Overrides config.toml `[unify]`.
- `--no-config` — disable loading config.toml entirely.
- `--chips` — display values in raw chip amounts instead of BB.
- `--format <sizes>` — filter by table size: `hu` (2), `short` (3-6), `full` (7+). Comma-separated. Default: `short,full`.
- `--blind-remap <rules>` — normalize non-standard blind levels. Format: `from_sb/from_bb:to_sb/to_bb,...`. Overrides config.

## Config File

Create `config.toml` in the directory where you run `poker-cli`. Eliminates repetitive CLI args.

```toml
# Default hand history files (supports ~ expansion)
files = [
  "~/dev/pokernow/hands/2026-03-11.json",
  "~/dev/pokernow/hands/2026-03-10.json",
  "~/dev/pokernow/hands/2026-03-08.json",
  "~/dev/pokernow/hands/2026-03-07.json",
  "~/dev/pokernow/hands/2026-03-06.json",
  "~/dev/pokernow/hands/2026-02-23.json",
]

# Player unification — key is canonical name, value is list of aliases
[unify]
pranav = ["pranav", "pranavv"]

# Display values in raw chips instead of BB
# chips = false

# Table size filter (comma-separated: hu, short, full)
# format = "short,full"

# Blind remapping — normalize non-standard blind levels
# [[blind_remap]]
# from = [1.0, 0.5]
# to = [1.0, 1.0]
```

**Precedence:** CLI args override config.toml. If files given on CLI, config `files` ignored. If `--unify-players` passed, config `[unify]` ignored. `--blind-remap` on CLI overrides config. `--chips` enables chips mode regardless of config. `--format` overrides config format. When config is loaded, "Loaded N file(s) from config.toml" is printed to stderr.

## What Gets Filtered

Only standard Texas Hold'em is processed. Silently skipped:
- Omaha hands (`gameType != "th"`)
- Bomb pots (`bombPot: true`)
- Double-board games (no type 14 RIT vote event)

Run-it-twice hands are fully supported — first run's board used for stats/eval, hand replay shows both runs.

## Stat Definitions

- **VPIP** — Voluntarily put money in preflop (call or raise, excludes forced bets)
- **PFR** — Preflop raise
- **3-Bet%** — Re-raise preflop (second raise)
- **Fold-to-3B** — Folded after opening and facing a 3-bet
- **Cold Call%** — Called a raise without having previously put money in
- **C-Bet%** — Continuation bet (first flop bet by preflop aggressor)
- **Fold-to-CB** — Folded facing a c-bet
- **AF** — Aggression Factor: postflop (bets + raises) / calls
- **WTSD%** — Went to showdown / saw flop
- **W$SD%** — Won money at showdown / went to showdown
- **WWSF%** — Won When Saw Flop: won the pot / saw flop (regardless of showdown)
- **All-in EV** — Expected value in all-in situations vs observed result. Format: "ran X BB below/above EV (EV-adjusted: Y BB)"

## Workflow Patterns

**Session review:** Run `summary` for quick overview, then `stats` for detailed numbers, then `search --sort pot` to find interesting hands, then `hand <number>` to replay them.

**Leak analysis:** `search --player X --lost --sort pot` to find biggest losing hands, then replay each to identify mistakes.

**Player investigation:** `stats --player X` for a single-player stat view. Then `search --player X --showdown` for hands where they went to showdown (player-aware — only hands where X actually showed down).

**Cross-session comparison:** Pass multiple JSON files to `stats` to aggregate. Use `--unify-players` or config `[unify]` if players changed names between sessions.

**Pre-game prep:** Load all sessions with regulars to review opponent tendencies. Focus on VPIP-PFR gap, fold-to-3bet, c-bet frequency, and WWSF.

## Notes

- Pot sizes are in big blinds throughout
- Player name matching is case-sensitive
- Hand descriptions are contextual for Hold'em (overpair, top pair, flush draw, nut flush draw, etc.)
- Hand numbers match the JSON `number` field (shown in search output's `Hand #` column)
- The PokerNow hash ID is always unique across all files — use it for unambiguous hand lookup
- Multi-file stats merge across all files; hand/search operate on the combined hand list
- Effective stack = minimum stack among all players in the hand (shown in BB in hand header)
- Per-player net P&L is shown at the end of each hand replay
