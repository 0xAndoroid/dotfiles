---
name: pokernow-save-hands-and-ledger
description: "Process a PokerNow online session: extract ledger → Mega blub Google Sheet, save hand JSON to ~/dev/pokernow/hands/, update poker-cli config.toml (file list + aliases). USE FOR: PokerNow URL given → end-of-session bookkeeping. TRIGGERS: 'process pokernow session', 'save hands and ledger', 'pokernow ledger', 'update mega blub', pokernow.com/games/ URLs after session ends."
---

# pokernow-save-hands-and-ledger

> **Input:** PokerNow game URL (e.g. `https://www.pokernow.com/games/<gameId>`).
>
> **Outputs:** (1) New column in "Mega blub" sheet with player nets. (2) Hand file at `~/dev/pokernow/hands/YYYY-MM-DD.json`. (3) Updated `~/dev/pokernow/hands/config.toml` with file prepended + new aliases.

## Execution model — READ FIRST

**You are the executor.** Every step below is something YOU run yourself with your own tools in this same session.

**DO NOT:**
- Spawn a subagent, background task, or worker.
- Invoke the `Agent` / `Task` tool to hand this off.
- Re-invoke this skill (`/pokernow-save-hands-and-ledger`) or any "chrome-enabled" wrapper.
- Treat the URL as something to dispatch. The URL is input to `curl` / `python3` calls YOU make.

If you notice yourself about to call `Agent` or launch a background task to "process the pokernow session", STOP — you already are the agent that processes it. Run the steps inline.

**Tools you use directly:** `Bash` (`curl`, `python3`, `gws`), `Read` / `Write` / `Edit` (hand JSON + `config.toml`), `Grep` (alias lookup), `mcp__chrome-devtools__*` (fallback only — you already have Chrome access, use it directly, do not spawn a chrome-enabled agent).

The HTTP paths below cover ~100% of sessions without touching Chrome. Run them yourself.

## Constants

| Thing | Value |
|---|---|
| Mega blub sheet ID | `1avc3w1J9SWFsb_CplNqFV1ae0eT80JLV-eW4rBbaI-E` |
| Sheet tab name | `Sheet1` (sheetId = 0) |
| Hand file dir | `~/dev/pokernow/hands/` |
| Poker-cli config | `~/dev/pokernow/hands/config.toml` |
| Ledger CSV URL | `https://www.pokernow.com/games/<gameId>/ledger_<gameId>.csv` |
| **Bulk hands URL** | `https://www.pokernow.com/hand-replayer/game/<gameId>/download` — returns the full `{generatedAt, playerId, gameId, hands:[...]}` envelope in one request. No auth, no reCAPTCHA (the modal is a UX shim; the backend doesn't enforce). 333 hands ≈ 1.5 MB, ~4 s cold, 0.3–0.6 s warm. |
| Hand index API | `https://www.pokernow.com/api/hand-replayer/game/<gameId>` — returns `{hands:[{id,number,startedAt,cents,gameType}]}`. Useful for cheap hand-count/date checks without pulling the full payload. |
| Per-hand API | `https://www.pokernow.com/api/hand-replayer/hand/<handId>` — returns full hand JSON (same shape as one element of the bulk `hands[]`). **Fallback only** — serial loop at 1 req/s is ~5 min for a 333-hand session vs ~4 s for the bulk URL. |
| Not a git repo | `~/dev/pokernow` — skip commit step |

## HTTP-first. Chrome is fallback.

Prefer pure HTTP for both ledger + hand collection — the browser path is brittle (Chrome MCP has hung on `Network.enable` timeouts). Only fall back to Chrome when HTTP paths 429/403/return unexpected shapes.

**For hands, the bulk download URL (`/hand-replayer/game/<gameId>/download`) is the PRIMARY path** — one unauthenticated request returns the full `{generatedAt, playerId, gameId, hands:[...]}` envelope. The per-hand loop and the Chrome download button are fallbacks, not defaults. Reach for them only when bulk fails.

## Workflow

### 1. Fetch ledger via HTTP (preferred)

```bash
curl -sS "https://www.pokernow.com/games/<gameId>/ledger_<gameId>.csv" -o /tmp/pn-ledger.csv
```

CSV columns: `player_nickname, player_id, session_start_at, session_end_at, buy_in, buy_out, stack, net`. One row per buy-in/session segment; a player with rebuys or sit-outs appears multiple times. Sum `net` per `player_id` (not nickname — a player can change nickname mid-session) to get the ledger totals that the browser modal shows aggregated.

```bash
python3 - <<'PY'
import csv, collections
totals = collections.defaultdict(lambda: {"net": 0, "names": set()})
with open("/tmp/pn-ledger.csv") as f:
    for r in csv.DictReader(f):
        totals[r["player_id"]]["net"] += int(r["net"])
        totals[r["player_id"]]["names"].add(r["player_nickname"])
for pid, v in totals.items():
    print(f"{'/'.join(sorted(v['names'])):30s}  net={v['net']:+d}")
print("SUM:", sum(v["net"] for v in totals.values()))  # must be 0
PY
```

NET is already in dollars (or cents if the game is cents-denominated — check the `cents` field in any hand JSON). Sum MUST equal 0.

**Fallback to Chrome ledger scrape** if CSV 404s (unlikely — it's a static route) or the game uses a non-standard path:

```
mcp__chrome-devtools__new_page url=<game-url>
mcp__chrome-devtools__evaluate_script:
  () => {
    const btn = [...document.querySelectorAll('button')].find(b => b.textContent.trim() === 'Log / Ledger');
    btn.click();
    return 'opened log modal';
  }
mcp__chrome-devtools__evaluate_script:
  () => {
    const btn = [...document.querySelectorAll('button')].find(b => b.className.includes('ledger-button'));
    btn.click();
    return 'on ledger tab';
  }
```

Then extract ledger rows in one shot (do NOT repeatedly snapshot — pull the DOM):

```js
// evaluate_script
() => {
  const rows = [...document.querySelectorAll('.ledger-table tr, table tr')].map(tr =>
    [...tr.querySelectorAll('td, th')].map(c => c.textContent.trim())
  );
  return rows;
}
```

Browser columns: `PLAYER | BUY-IN | BUY-OUT | STACK | NET`. Again NET sums MUST equal 0.

### 2. Find latest hand date (ET)

Pull the hand index from the API and use the final `startedAt`:

```bash
curl -sS "https://www.pokernow.com/api/hand-replayer/game/<gameId>" \
  | python3 -c "import json,sys,datetime,zoneinfo; d=json.load(sys.stdin); ts=d['hands'][-1]['startedAt']/1000; print(datetime.datetime.fromtimestamp(ts, zoneinfo.ZoneInfo('America/New_York')).strftime('%Y-%m-%d'))"
```

`startedAt` is a unix-ms timestamp. Convert to America/New_York. This is the **date used for the sheet column header and the hand file name**.

Sheet column header format: `M/D` (single digits, no leading zeros, no year). Example: `4/17`.

### 3. Save hand file (bulk HTTP first)

**First check if file already exists for this date AND gameId** — same session won't need re-fetching:

```bash
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['gameId'], len(d['hands']))" \
  ~/dev/pokernow/hands/YYYY-MM-DD.json 2>/dev/null
```

If output matches `<gameId> <N>` and N matches the index length from the hand-index API, **skip fetching**. File is already complete. (Cheap length check: `curl -sS "https://www.pokernow.com/api/hand-replayer/game/<gameId>" | python3 -c "import json,sys;print(len(json.load(sys.stdin)['hands']))"`.)

**3a. Bulk download (PRIMARY path).**

One request, full envelope. No auth. Verified 2026-04-18: 333 hands, 1.5 MB, ~4 s cold.

```bash
GAME_ID="<gameId>"
DATE="YYYY-MM-DD"
OUT="$HOME/dev/pokernow/hands/${DATE}.json"
curl -sS --fail "https://www.pokernow.com/hand-replayer/game/${GAME_ID}/download" -o "$OUT"
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(f\"saved {len(d['hands'])} hands → {sys.argv[1]} (gameId={d['gameId']})\")" "$OUT"
```

Response shape:

```json
{"generatedAt": "...", "playerId": "...", "gameId": "...", "hands": [{"id":..., "number":"1", "players":[...], "events":[...]}, ...]}
```

**Collision rule:** if `YYYY-MM-DD.json` already exists with a DIFFERENT gameId (session started before midnight and overflowed), write as `YYYY-MM-DD-2.json`, `-3`, etc. Same gameId = same session, overwrite or skip.

**3b. Per-hand loop (FALLBACK — only if bulk returns 4xx/5xx or unexpected shape).**

60–100× slower (~5 min for 333 hands at 1 req/s) but resumable and doesn't rely on the bulk route. Run ONLY after confirming 3a returns a non-200 or malformed JSON.

```bash
curl -sS "https://www.pokernow.com/api/hand-replayer/game/<gameId>" -o /tmp/pn-index.json
```

```bash
python3 - <<'PY'
import json, time, urllib.request, urllib.error, pathlib, datetime
GAME_ID = "<gameId>"
DATE    = "YYYY-MM-DD"
OUT     = pathlib.Path(f"/Users/andoroid/dev/pokernow/hands/{DATE}.json")

idx = json.load(open("/tmp/pn-index.json"))["hands"]
hands, delay = [], 1.0
for i, meta in enumerate(idx):
    url = f"https://www.pokernow.com/api/hand-replayer/hand/{meta['id']}"
    while True:
        try:
            with urllib.request.urlopen(url, timeout=30) as r:
                hands.append(json.loads(r.read()))
                break
        except urllib.error.HTTPError as e:
            if e.code == 429:
                delay = min(delay * 2, 30)
                print(f"429 on {meta['id']}, backoff {delay}s", flush=True)
                time.sleep(delay)
                continue
            raise
    if i % 25 == 0:
        print(f"{i+1}/{len(idx)}", flush=True)
    time.sleep(1.0)  # 1 req/sec base pace

out = {
    "generatedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "gameId": GAME_ID,
    "hands": hands,
}
OUT.write_text(json.dumps(out))
print(f"saved {len(hands)} hands → {OUT}")
PY
```

**3c. Chrome download (LAST-RESORT fallback).**

Use only if both 3a and 3b are blocked (e.g. Cloudflare interstitial, sustained 4xx, network-level block):

1. Open `https://www.pokernow.com/games/<gameId>` in Chrome MCP.
2. Click the `Log / Ledger` button, then the `Download` button in the log modal (class `log-download-button`). Browser writes JSON to `~/Downloads/`.
3. `mv ~/Downloads/pokernow_*.json ~/dev/pokernow/hands/YYYY-MM-DD.json`.

All three paths produce the same `{generatedAt, playerId, gameId, hands:[...]}` envelope. The per-hand loop (3b) omits `playerId` because there is no clicker; downstream consumers (poker-cli) don't use that field.

### 4. Update Mega blub sheet

Layout (current):
- Col A: Player name
- Col B: `=COUNT(F<r>:DQ<r>)` — session count
- Col C: `=E<r>/B<r>` — per-session avg
- Col D: `=E<r>/-SUMIF($E$2:$E$N, "<0")` — loss-share %
- Col E: `=SUM($F<r>:DQ<r>)` — total
- Col F: blank separator
- Col G onward: session data columns, **newest first** (i.e. G is the latest session)
- Last data row + 1: totals row (`=SUM(E2:E<N-1>)`, `=SUM(G2:G<N-1>)`, ...)

**Step 4a — insert one column at G and one row just before the totals row.**

Find the totals row first (last row where col A is empty and col E is `=SUM(...)`). Assume its 0-indexed position is `totalRowIdx` (so existing range is rows `[2, totalRowIdx]` 1-indexed).

```bash
gws sheets spreadsheets batchUpdate \
  --params '{"spreadsheetId":"1avc3w1J9SWFsb_CplNqFV1ae0eT80JLV-eW4rBbaI-E"}' \
  --json '{
    "requests": [
      {"insertDimension": {"range": {"sheetId": 0, "dimension": "COLUMNS", "startIndex": 6, "endIndex": 7}, "inheritFromBefore": false}},
      {"insertDimension": {"range": {"sheetId": 0, "dimension": "ROWS",    "startIndex": <totalRowIdx - 1>, "endIndex": <totalRowIdx>}, "inheritFromBefore": true}}
    ]
  }'
```

**Gotchas:**
- `--params` holds URL params (spreadsheetId), `--json` holds the request body. Do NOT put `requestBody` inside `--params` — returns "Unknown name `requestBody`".
- COLUMN insert at index 6 = new column G (0-indexed), pushing old 4/16→H, 4/15→I, etc.
- ROW insert MUST be WITHIN the existing data range (i.e. before the totals row, not after) so existing formulas like `$E$2:$E$34` auto-extend to `$E$2:$E$35`. Inserting past the end does NOT extend formulas.
- After column insert, existing `F:DP` ranges auto-extend to `F:DQ`. Don't rewrite them.
- `inheritFromBefore:true` on the row insert copies formatting from the row above; `false` on the column insert keeps the separator column F clean.

**Step 4b — populate values. Raw numbers only (cell format renders `$1,076` etc.).**

Match session player names to existing sheet rows. Known mappings from config.toml `[unify]` (always re-check `~/dev/pokernow/hands/config.toml` for latest — groups may have grown since this was written):

| Session alias | Sheet row label |
|---|---|
| kev / kevin / kev2 | Kevin |
| steve / Steve / Steve__Nguyen | Steve |
| Steveooo / steveoooo / stevoooo / steveooooo | Steveooo (different person from "steve"!) |
| kedar / Kdr / jedar / $kdr | Kedar |
| aryan / Aryan / REN / REN2 | Aryan |
| nate | Nate |
| Pranav / pranav / pranavv / pranavp / pran / pra__nav / spicy__p / pprraannaavv | Pranav |
| Skyler / Sky | Skyler |
| OJ / OJ1 | OJ (steveooo friend) |
| Pucci / BP | Pucci |
| Bando | Bando |
| Katherine / Kath / Kbj / K a t h / Kbbbb | Katherine |
| Shreyas / Shreyas2 | Shreyas |
| Kwan / Kwan2 / kwan | Kwan |
| Shaun / Shaun__Desktop / Shaun__1am | Shaun |
| om / om__g / om g | Om |
| Ricky / Ricky__-op-onplane | Ricky |
| Andrew / andrew | Andrew (the user — rarely at these tables) |

> ⚠️ **STRONG WARNING — DO NOT CREATE A NEW ROW BLINDLY.**
>
> A new screen name is **far more likely** to be an existing player using a fresh handle than an actual new player. Seeing "Kbbbb" for the first time? Check Katherine's alias list — it is her. "Steveooo" vs "steve"? Different people. "REN"? That is Aryan.
>
> **Before creating a new sheet row OR adding a new `[unify]` group, you MUST:**
> 1. `grep -F '"<NAME>"' ~/dev/pokernow/hands/config.toml` — exact-match lookup across all alias groups. If found, map to that canonical name.
> 2. Compare the unknown alias against the full canonical player list above. Consider shared prefix, keyboard proximity, playful/spammy variants of an existing name (e.g. repeated letters: `Kbbbb` ~ `Kbj`, `pprraannaavv` ~ `pranav`).
> 3. If the mapping is **ambiguous** (short/obscure name that could plausibly be multiple known players, OR a known player's variant, OR genuinely new) — **STOP, do not write anything new, report the ambiguity to the user, and wait for confirmation.**
> 4. Only create a new row / new `[unify]` entry when you have HIGH confidence the player is genuinely new (e.g. a distinctly different name, a "friend of X" case, first-timer introduced by someone you know).
>
> Under-merging costs one line in the sheet and one grep to fix. Over-merging corrupts an existing player's stats with someone else's money. **Err on the side of asking.**

```bash
gws sheets spreadsheets values batchUpdate \
  --params '{"spreadsheetId":"1avc3w1J9SWFsb_CplNqFV1ae0eT80JLV-eW4rBbaI-E"}' \
  --json '{
    "valueInputOption": "USER_ENTERED",
    "data": [
      {"range": "Sheet1!G1",        "values": [["4/17"]]},
      {"range": "Sheet1!G<kevin>",  "values": [[1076]]},
      {"range": "Sheet1!G<steve>",  "values": [[-200]]},
      ...
    ]
  }'
```

**Step 4c — for each CONFIRMED-new player (after passing the warning checklist in 4b), fill the new row with standard formulas.**

Only reach this step if Step 4b's verification gave you high confidence the player is genuinely new. If you skipped the check, go back.

Example for a hypothetical new `Newbie` in new row 34 (replace `34`, `DQ`, and `E$35` with actual indices — `DQ` is the rightmost data column which auto-extended when you inserted the new G column, `$E$35` is the row containing the last non-totals player which auto-extended when you inserted the new player row):

```bash
gws sheets spreadsheets values batchUpdate \
  --params '{"spreadsheetId":"1avc3w1J9SWFsb_CplNqFV1ae0eT80JLV-eW4rBbaI-E"}' \
  --json '{
    "valueInputOption": "USER_ENTERED",
    "data": [
      {"range": "Sheet1!A34:E34", "values": [["Newbie",
        "=COUNT(F34:DQ34)",
        "=E34/B34",
        "=E34/-SUMIF($E$2:$E$35, \"<0\")",
        "=SUM($F34:DQ34)"]]},
      {"range": "Sheet1!G34", "values": [[224]]}
    ]
  }'
```

**Step 4d — add missing SUM to the totals row for the new column.** The insertDimension leaves the new G cell in the totals row EMPTY even though other totals cells have formulas. Fix:

```bash
gws sheets spreadsheets values update \
  --params '{"spreadsheetId":"1avc3w1J9SWFsb_CplNqFV1ae0eT80JLV-eW4rBbaI-E","range":"Sheet1!G<totalRow>","valueInputOption":"USER_ENTERED"}' \
  --json '{"values":[["=SUM(G2:G<totalRow-1>)"]]}'
```

**Step 4e — verify.** Read back `A1:H<totalRow>`, confirm column G sum = 0 (ledger is always balanced), new header shows correct `M/D`, all session player rows populated.

### 5. Update `~/dev/pokernow/hands/config.toml`

File is a TOML with two sections:
- `files = [ ... ]` — reverse-chronological. **Prepend** new hand file path.
- `[unify]` — alias groups. Format: `canonicalName = ["alias1", "alias2", ...]`.

**5a. Prepend the new file:**

```
Edit:
  old: 'files = [\n  "~/dev/pokernow/hands/2026-04-15.json",'
  new: 'files = [\n  "~/dev/pokernow/hands/2026-04-17.json",\n  "~/dev/pokernow/hands/2026-04-15.json",'
```

**5b. Detect new aliases — mirror the Step 4b warning.**

Extract unique player names from the downloaded hand JSON:
```bash
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print('\n'.join(sorted({p['name'] for h in d['hands'] for p in h['players']})))" ~/dev/pokernow/hands/YYYY-MM-DD.json
```

For each name, check if it's already in any `[unify]` group:
```bash
grep -F '"NAME"' ~/dev/pokernow/hands/config.toml
```

> ⚠️ **Same warning as Step 4b applies here.** An unrecognized screen name is *more likely* to be a new handle for an existing player than a true newcomer.
>
> - If the name is found in an existing group → already known, skip.
> - If the name is NOT found but looks like a variant of an existing player (shared prefix, repeated letters, friend-of-X hint, etc.) → **STOP and ask the user**, don't auto-create.
> - Only add a brand-new `NewAlias = ["NewAlias"]` entry when you have HIGH confidence it's a genuinely new player.
>
> When in doubt, **append the alias to the canonical player's existing group** rather than creating a singleton. Example done right:
>
> ```diff
> - Katherine = ["Katherine", "Kath", "Kbj", "K a t h"]
> + Katherine = ["Katherine", "Kath", "Kbj", "K a t h", "Kbbbb"]
> ```
>
> Example done wrong (what happened on 2026-04-17 — first skill author mistook Kbbbb for a newcomer):
>
> ```diff
> - Katherine = ["Katherine", "Kath", "Kbj", "K a t h"]
> + Katherine = ["Katherine", "Kath", "Kbj", "K a t h"]
> + Kbbbb = ["Kbbbb"]   # ← WRONG: this is Katherine, not a new player
> ```

### 6. Close Chrome tabs (only if Chrome fallback was used)

If steps 1 and 3a succeeded via HTTP, skip this entirely — no tabs were opened. Otherwise:

```
mcp__chrome-devtools__close_page pageId=<game-tab>
mcp__chrome-devtools__close_page pageId=<replayer-tab>
```

### 7. No git commit

`~/dev/pokernow` is NOT a git repo. Skip the commit/push step.

## Final report template

**You (the agent that ran this skill) MUST emit this message to the user at the end.** The `Summary` block is required — the user reads these five fields first.

```
Summary:
  Date:        YYYY-MM-DD ET
  Players:     <N>
  Hands:       <N>
  Andrew net:  ±$<amt>   (or "did not play" if Andrew wasn't at the table)
  File:        ~/dev/pokernow/hands/YYYY-MM-DD.json

Date of latest hand: YYYY-MM-DD ET (hand #<N> @ <H:MM> AM/PM ET)

Player nets:
  <name>: ±$<amt>
  ...
  (sum = $0 ✓)

Mega blub sheet: 1avc3w1J9SWFsb_CplNqFV1ae0eT80JLV-eW4rBbaI-E
  Inserted column G = <M/D>
  Updated rows: <kevin>, <steve>, ..., <bando>
  New row(s) for: <Kbbbb>
  G<totalRow> SUM formula added.

Hand file: ~/dev/pokernow/hands/YYYY-MM-DD.json  (<existing|downloaded>, <N> hands)

Aliases added to config.toml: <Kbbbb>, <nate>   (or "none")
File list prepended: YYYY-MM-DD.json

Git commit: N/A (not a git repo)
```

## Anti-patterns (things that have gone wrong in past runs)

- **[2026-04-17] Adding `Kbbbb` as a new player row instead of merging into Katherine.** Screen name was a playful variant of `Kbj` (existing Katherine alias). Fix required: moving the ledger value into Katherine's row, deleting the orphan row, shifting Katherine's session count/total/% (formulas handled it, but the row-delete still had to happen). **Rule: unknown name → grep config.toml + eyeball shared prefixes/variants FIRST. Ask if unsure.**
- **[2026-04-18] Reaching for Chrome MCP first and hitting `Network.enable timed out`, burning minutes retrying.** The PokerNow public HTTP API (`/games/<gameId>/ledger_<gameId>.csv` + `/api/hand-replayer/game/<gameId>` + `/api/hand-replayer/hand/<handId>`) is open, unauthenticated, and reliable. Try HTTP first, fall back to Chrome only on 429/403/unexpected shapes. **Do NOT claim the per-hand endpoint "doesn't exist" — it does, and it returns the same JSON as one `hands[]` element of the browser download.**
- **[2026-04-18] Looping the per-hand endpoint at 1 req/sec as the primary path — wasted 5+ min on a 333-hand session when the bulk endpoint `GET /hand-replayer/game/<gameId>/download` exists and returns the whole envelope in ~4 s.** The endpoint is unauthenticated; the reCAPTCHA modal in the UI is a UX shim, not a backend requirement. Bulk is PRIMARY; the per-hand loop is a fallback reserved for when the bulk route returns 4xx/5xx. Re-derived by grepping `handReplayer.bundle-*.js` for `"download"` — hit the string `/hand-replayer/${t.scopeType}/${t.scopeId}/download?recaptchaResponse=${e}`.
- Repeatedly calling `take_snapshot` — slow, huge tokens. Scrape via `evaluate_script` once (only relevant if you're on the Chrome fallback to begin with).
- Trying to intercept the `Download` button's generated anchor tag — it uses Blob URLs, not capturable that way. In the HTTP path you don't need it at all; in the Chrome fallback just let the browser save to `~/Downloads/` and `mv`.
- Putting request body under `requestBody` key in `--params` for `gws batchUpdate` — wrong. Use `--json` instead.
- Writing ledger nets as strings (`"$1,076"`) — the column has currency formatting, so write raw numbers and let the sheet format them.
- Inserting the new row AFTER the totals row — breaks the `=SUM(E2:E<N>)` reference. Insert BEFORE totals row.
- Forgetting to add a SUM formula to the new column in the totals row — `insertDimension` leaves it empty.
- Re-fetching a hand file that already exists for the same gameId — wasteful and burns 333+ HTTP requests. Check first.
- Summing ledger rows by `player_nickname` instead of `player_id` — nicknames can change mid-session; you'll double-count or misattribute.
