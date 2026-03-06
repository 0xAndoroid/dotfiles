---
name: x-cli
description: Comprehensive reference for x-cli, a CLI tool for the X/Twitter API v2
---

# x-cli — X/Twitter CLI Reference

CLI for X (Twitter) API v2. Post tweets, search, read timelines, manage bookmarks, view profiles, and interact with tweets from the terminal.

Built with Python (Click framework), installed via `uv`. Uses OAuth 1.0a for write operations and Bearer token for read operations.

---

## Installation & Setup

### Install location

- Binary: `~/.local/bin/x-cli`
- Python package: installed via `uv tool install` from source
- Package name: `x-cli` (import as `x_cli`)

### Authentication

x-cli requires 5 environment variables (X/Twitter API v2 credentials):

| Variable | Description |
|---|---|
| `X_API_KEY` | OAuth 1.0a consumer API key |
| `X_API_SECRET` | OAuth 1.0a consumer API secret |
| `X_ACCESS_TOKEN` | OAuth 1.0a access token |
| `X_ACCESS_TOKEN_SECRET` | OAuth 1.0a access token secret |
| `X_BEARER_TOKEN` | App-only Bearer token (for read endpoints) |

### Config file

Credentials are loaded from a `.env` file. Lookup order:

1. `~/.config/x-cli/.env` (primary — checked first)
2. `.env` in the current working directory (fallback)
3. Environment variables already set in the shell

The `.env` file format is standard dotenv:

```
X_API_KEY=your_api_key
X_API_SECRET=your_api_secret
X_ACCESS_TOKEN=your_access_token
X_ACCESS_TOKEN_SECRET=your_access_token_secret
X_BEARER_TOKEN=your_bearer_token
```

If any variable is missing, x-cli exits with an error listing all required vars.

### Auth model

- **Bearer token** (app-only): used for read-only operations — `tweet get`, `tweet search`, `user get`, `user timeline`, `user followers`, `user following`
- **OAuth 1.0a** (user context): used for write operations and user-specific reads — `tweet post`, `tweet delete`, `tweet reply`, `tweet quote`, `like`, `retweet`, `me mentions`, `me bookmarks`, `me bookmark`, `me unbookmark`, `tweet metrics` (non-public metrics)

---

## Global Options

Global options go **before** the command:

```
x-cli [OPTIONS] COMMAND [ARGS]...
```

| Flag | Description |
|---|---|
| `-j`, `--json` | JSON output (raw API data for `data` key; use `-v` for full response with `includes`/`meta`) |
| `-p`, `--plain` | TSV output for piping to other tools |
| `-md`, `--markdown` | Markdown-formatted output |
| `-v`, `--verbose` | Verbose output — adds timestamps, engagement metrics, metadata, join dates, locations |
| (default) | Rich colored panels (human-readable, rendered to stderr/stdout via `rich`) |

Output format flags are mutually exclusive (last one wins). They apply to all commands.

### Output format details

- **Human (default)**: Rich panels with colored borders. Tweets get blue borders, users get green borders. User lists render as tables.
- **JSON (`-j`)**: By default strips `includes`/`meta` and only prints the `data` key. With `-v`, prints the full API response.
- **Plain/TSV (`-p`)**: Tab-separated values. Single items print `key\tvalue` pairs. Lists print a header row then data rows. Compact mode omits `public_metrics`, `entities`, `attachments`, etc. unless `-v` is used.
- **Markdown (`-md`)**: Headings, bold usernames, metric tables. User lists render as markdown tables.

---

## Tweet ID Input

All commands that accept a tweet identifier accept **both formats**:

- Numeric ID: `2026338814424477737`
- Full URL: `https://x.com/elonmusk/status/2026338814424477737`
- Old-style URL: `https://twitter.com/user/status/1234567890`

The parser extracts the numeric ID from URLs automatically.

### Username input

User commands accept usernames **with or without** the `@` prefix:

- `x-cli user get elonmusk`
- `x-cli user get @elonmusk`

Both work identically — the leading `@` is stripped.

---

## Commands Reference

### tweet post — Post a tweet

```
x-cli tweet post [OPTIONS] TEXT
```

| Option | Description |
|---|---|
| `--poll TEXT` | Comma-separated poll options (e.g., `"Yes,No,Maybe"`) |
| `--poll-duration INTEGER` | Poll duration in minutes (default: 1440 = 24 hours) |

**Examples:**

```bash
# Simple tweet
x-cli tweet post "Hello world"

# Tweet with a poll
x-cli tweet post "What do you think?" --poll "Great,Good,Meh" --poll-duration 60

# Multi-line tweet (use shell quoting)
x-cli tweet post "Line one
Line two
Line three"

# Tweet with special characters (use single quotes to avoid shell expansion)
x-cli tweet post 'Check out this $100 deal! #sale'
```

### tweet get — Fetch a tweet

```
x-cli tweet get ID_OR_URL
```

Fetches a single tweet with author info, referenced tweets, media, entities, and metrics.

**Examples:**

```bash
x-cli tweet get 2026338814424477737
x-cli tweet get https://x.com/elonmusk/status/2026338814424477737
x-cli -v tweet get 2026338814424477737   # includes timestamp and engagement metrics
x-cli -j tweet get 2026338814424477737   # raw JSON
```

### tweet delete — Delete a tweet

```
x-cli tweet delete ID_OR_URL
```

Deletes a tweet you own. Requires OAuth 1.0a (write access).

```bash
x-cli tweet delete 2026338814424477737
```

### tweet reply — Reply to a tweet

```
x-cli tweet reply ID_OR_URL TEXT
```

Posts a reply to the specified tweet. The reply is linked in the conversation thread.

```bash
x-cli tweet reply 2026338814424477737 "Great point!"
x-cli tweet reply https://x.com/user/status/123456 "I agree"
```

### tweet quote — Quote tweet

```
x-cli tweet quote ID_OR_URL TEXT
```

Posts a quote tweet referencing the specified tweet.

```bash
x-cli tweet quote 2026338814424477737 "This is important"
```

### tweet search — Search recent tweets

```
x-cli tweet search [OPTIONS] QUERY
```

Searches recent tweets (last 7 days) using the Twitter API v2 search endpoint.

| Option | Description |
|---|---|
| `--max INTEGER` | Max results, range 10-100 (default: 10). Values below 10 are clamped to 10. |

**Examples:**

```bash
# Basic keyword search
x-cli tweet search "artificial intelligence"

# Search by user
x-cli tweet search "from:elonmusk"

# Search with hashtag
x-cli tweet search "#opensource"

# Search with multiple operators
x-cli tweet search "from:openai -is:retweet lang:en"

# Get more results
x-cli tweet search "machine learning" --max 50

# Verbose output with metrics
x-cli -v tweet search "from:elonmusk" --max 20

# JSON output for scripting
x-cli -j tweet search "breaking news" --max 100
```

**Search query operators** (Twitter API v2 query syntax):

- `from:username` — tweets from a specific user
- `to:username` — tweets replying to a user
- `@username` — tweets mentioning a user
- `#hashtag` — tweets with a hashtag
- `"exact phrase"` — exact phrase match
- `-keyword` — exclude keyword
- `is:retweet` / `-is:retweet` — include/exclude retweets
- `is:reply` / `-is:reply` — include/exclude replies
- `has:media` — tweets with media
- `has:links` — tweets with links
- `has:images` — tweets with images
- `lang:en` — filter by language
- `url:example.com` — tweets containing a URL
- Combine with spaces (AND) or `OR`

### tweet metrics — Get engagement metrics

```
x-cli tweet metrics ID_OR_URL
```

Fetches public, non-public, and organic metrics for a tweet. Requires OAuth 1.0a because it requests non-public metrics.

```bash
x-cli tweet metrics 2026338814424477737
x-cli -j tweet metrics 2026338814424477737
```

Metrics include: retweet count, reply count, like count, quote count, bookmark count, impression count, and (if authorized) non-public/organic metrics.

---

### user get — Look up a user profile

```
x-cli user get USERNAME
```

Returns profile info: name, username, bio/description, follower/following/tweet counts, verified status, profile image URL, location, pinned tweet ID, account creation date.

```bash
x-cli user get elonmusk
x-cli user get @openai
x-cli -v user get elonmusk    # adds join date and location
x-cli -j user get elonmusk    # raw JSON
x-cli -p user get elonmusk    # TSV key-value pairs
x-cli -md user get elonmusk   # markdown formatted
```

### user timeline — Fetch a user's recent tweets

```
x-cli user timeline [OPTIONS] USERNAME
```

| Option | Description |
|---|---|
| `--max INTEGER` | Max results, range 5-100 (default: 10) |

Fetches the user's recent tweets (their own posts, retweets, and replies).

```bash
x-cli user timeline elonmusk --max 20
x-cli -v user timeline openai --max 5
x-cli -j user timeline @google
```

Note: This first resolves the username to a user ID, then fetches the timeline. This makes two API calls.

### user followers — List a user's followers

```
x-cli user followers [OPTIONS] USERNAME
```

| Option | Description |
|---|---|
| `--max INTEGER` | Max results, range 1-1000 (default: 100) |

Returns a table of followers with username, name, and follower count. With `-v`, also shows description.

```bash
x-cli user followers openai --max 50
x-cli -v user followers elonmusk --max 10
x-cli -j user followers @google --max 200
```

Note: Resolves username to user ID first (two API calls).

### user following — List who a user follows

```
x-cli user following [OPTIONS] USERNAME
```

| Option | Description |
|---|---|
| `--max INTEGER` | Max results, range 1-1000 (default: 100) |

```bash
x-cli user following openai --max 50
x-cli -p user following elonmusk --max 1000
```

Note: Resolves username to user ID first (two API calls).

---

### me mentions — Fetch your recent mentions

```
x-cli me mentions [OPTIONS]
```

| Option | Description |
|---|---|
| `--max INTEGER` | Max results, range 5-100 (default: 10) |

Fetches tweets that mention the authenticated user. Uses OAuth 1.0a.

```bash
x-cli me mentions
x-cli me mentions --max 50
x-cli -v me mentions
```

**Note:** Requires proper OAuth 1.0a write/read access. May return 401 Unauthorized if tokens lack the required scopes or the API plan doesn't support user-context mentions.

### me bookmarks — Fetch your bookmarks

```
x-cli me bookmarks [OPTIONS]
```

| Option | Description |
|---|---|
| `--max INTEGER` | Max results, range 1-100 (default: 10) |

```bash
x-cli me bookmarks
x-cli me bookmarks --max 50
x-cli -j me bookmarks
```

**Note:** Bookmarks endpoints require Pro or higher API tier. Basic tier will return 401 Unauthorized.

### me bookmark — Bookmark a tweet

```
x-cli me bookmark ID_OR_URL
```

```bash
x-cli me bookmark 2026338814424477737
x-cli me bookmark https://x.com/user/status/123456
```

### me unbookmark — Remove a bookmark

```
x-cli me unbookmark ID_OR_URL
```

```bash
x-cli me unbookmark 2026338814424477737
```

---

### like — Like a tweet

```
x-cli like ID_OR_URL
```

Top-level command (not under a subgroup).

```bash
x-cli like 2026338814424477737
x-cli like https://x.com/elonmusk/status/2026338814424477737
```

### retweet — Retweet a tweet

```
x-cli retweet ID_OR_URL
```

Top-level command (not under a subgroup).

```bash
x-cli retweet 2026338814424477737
x-cli retweet https://x.com/user/status/123456
```

---

## Common Workflows

### Post a thread

x-cli does not have a built-in thread command. Post threads manually by replying to each previous tweet:

```bash
# Post the first tweet and capture the ID
x-cli -j tweet post "Thread: Here's what I learned about X API v2 (1/3)" | jq -r '.id'
# Suppose it returns: 111111111111

# Reply to create the thread
x-cli -j tweet reply 111111111111 "First, the authentication is much simpler than v1.1 (2/3)" | jq -r '.id'
# Suppose it returns: 222222222222

# Continue the thread
x-cli tweet reply 222222222222 "Second, the rate limits are more generous for app-only auth (3/3)"
```

For scripting threads:

```bash
#!/bin/bash
tweets=(
  "1/ Thread about something interesting"
  "2/ Here's the first point"
  "3/ And here's the conclusion"
)

prev_id=""
for text in "${tweets[@]}"; do
  if [ -z "$prev_id" ]; then
    prev_id=$(x-cli -j tweet post "$text" | jq -r '.id')
  else
    prev_id=$(x-cli -j tweet reply "$prev_id" "$text" | jq -r '.id')
  fi
  echo "Posted: $prev_id"
  sleep 1  # avoid rate limits
done
```

### Search and analyze

```bash
# Find recent tweets about a topic with engagement data
x-cli -v tweet search "from:openai" --max 20

# Export search results as JSON for processing
x-cli -j tweet search "#ai lang:en -is:retweet" --max 100 > results.json

# Pipe TSV to other tools
x-cli -p tweet search "from:elonmusk" --max 50 | cut -f3  # extract text column
```

### Monitor mentions and respond

```bash
# Check mentions
x-cli -v me mentions --max 20

# Get details on a specific mention
x-cli -v tweet get <tweet_id>

# Reply to it
x-cli tweet reply <tweet_id> "Thanks for the mention!"
```

### Profile research

```bash
# Look up a profile
x-cli -v user get username

# See their recent activity
x-cli -v user timeline username --max 20

# Check who they follow
x-cli user following username --max 100

# Check their followers
x-cli user followers username --max 100
```

---

## Gotchas and Edge Cases

### Character limits

- Standard tweets: 280 characters
- X Premium subscribers: 4,000 characters (long tweets appear in `note_tweet.text` in the API response; x-cli displays these correctly)
- Poll options: each option has a 25-character limit
- Polls: 2-4 options maximum

### Rate limits

- x-cli detects HTTP 429 responses and reports the reset time from the `x-rate-limit-reset` header
- App-only (Bearer) endpoints: typically 300 requests per 15-minute window for search, 900 for tweet lookup
- User-context (OAuth) endpoints: typically 200 tweets/day for posting (Free tier), higher for Pro
- When rate limited, wait for the reset window — there is no built-in retry logic

### API tier limitations

- **Free tier**: Can post tweets, like, retweet. Limited to ~1,500 tweets read/month, 50 tweets post/month. No access to `me mentions` or `me bookmarks` endpoints.
- **Basic tier ($100/mo)**: Higher limits. Mentions work. Bookmarks may still be restricted.
- **Pro tier ($5,000/mo)**: Full access to all endpoints including bookmarks, full-archive search.

### Search limitations

- `tweet search` only searches **recent tweets** (last 7 days) unless on Pro tier with full-archive access
- Minimum `--max` for search is 10 (values below 10 are clamped to 10)
- Query length is limited by the API (max 512 characters for standard, 1024 for Pro)

### Two-API-call commands

These commands resolve a username to a user ID first, so they make **two API calls**:

- `user timeline`
- `user followers`
- `user following`

This counts against rate limits for both the user lookup and the target endpoint.

### OAuth scope issues

- If you get 401 Unauthorized on write operations, your tokens may not have write permissions enabled
- Regenerate tokens in the X Developer Portal after enabling "Read and Write" (or "Read, Write, and Direct Messages") permissions
- Token changes in the Developer Portal require regenerating both the access token and access token secret

### Media

x-cli does **not** support media upload (images, videos, GIFs). It is text-only for posting. Fetched tweets will show `https://t.co/...` links for attached media.

### Lists, DMs, Spaces, Analytics

x-cli does **not** support these features:

- List management (create, view, add members)
- Direct messages
- Spaces
- Detailed analytics beyond `tweet metrics`
- Following/unfollowing users
- Blocking/muting users

### Shell quoting

- Use double quotes for most tweet text: `x-cli tweet post "Hello world"`
- Use single quotes if text contains `$`, `!`, or backticks: `x-cli tweet post 'Price is $99!'`
- For both, use `$'...'` syntax: `x-cli tweet post $'It\'s $99!'`
- Newlines work inside quotes for multi-line tweets

### Error handling

- Missing env vars: exits immediately with a message listing all 5 required variables
- Invalid tweet ID/URL: raises `ValueError` with the invalid input shown
- API errors: prints HTTP status code and the error detail from the API response
- Rate limits: prints the reset timestamp from response headers

---

## Quick Reference Table

| Action | Command |
|---|---|
| Post a tweet | `x-cli tweet post "text"` |
| Post with poll | `x-cli tweet post "question?" --poll "A,B,C" --poll-duration 60` |
| Reply | `x-cli tweet reply <id_or_url> "text"` |
| Quote tweet | `x-cli tweet quote <id_or_url> "text"` |
| Delete tweet | `x-cli tweet delete <id_or_url>` |
| View a tweet | `x-cli tweet get <id_or_url>` |
| Search tweets | `x-cli tweet search "query" --max 50` |
| Tweet metrics | `x-cli tweet metrics <id_or_url>` |
| Like | `x-cli like <id_or_url>` |
| Retweet | `x-cli retweet <id_or_url>` |
| User profile | `x-cli user get <username>` |
| User timeline | `x-cli user timeline <username> --max 20` |
| User followers | `x-cli user followers <username> --max 100` |
| User following | `x-cli user following <username> --max 100` |
| My mentions | `x-cli me mentions --max 20` |
| My bookmarks | `x-cli me bookmarks --max 20` |
| Bookmark tweet | `x-cli me bookmark <id_or_url>` |
| Remove bookmark | `x-cli me unbookmark <id_or_url>` |

### Output format cheat sheet

```bash
x-cli tweet get <id>           # rich colored panels (default)
x-cli -j tweet get <id>        # JSON (data key only)
x-cli -j -v tweet get <id>     # JSON (full response with includes/meta)
x-cli -p tweet get <id>        # TSV for piping
x-cli -md tweet get <id>       # markdown
x-cli -v tweet get <id>        # verbose (timestamps, metrics in any format)
```
