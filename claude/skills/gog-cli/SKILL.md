# gog CLI — Google CLI (v0.11.0)

Complete reference for `gog` (Google CLI) at `/opt/homebrew/bin/gog`.
Authenticated account: `andriytretyakov@gmail.com`.

## Global Flags (apply to ALL commands)

| Flag | Short | Description |
|------|-------|-------------|
| `--json` | `-j` | Output JSON to stdout (best for scripting) |
| `--plain` | `-p` | Output stable TSV text (no colors) |
| `--results-only` | | JSON mode: emit only primary result (drops nextPageToken envelope) |
| `--select=FIELDS` | | JSON mode: select comma-separated fields (supports dot paths) |
| `--account=EMAIL` | `-a` | Use specific account (for multi-account setups) |
| `--client=NAME` | | OAuth client name |
| `--dry-run` | `-n` | Print intended actions without making changes |
| `--force` | `-y` | Skip confirmations for destructive commands |
| `--no-input` | | Never prompt; fail instead (CI mode) |
| `--verbose` | `-v` | Enable verbose logging |
| `--color=MODE` | | Color output: `auto\|always\|never` |

## Output Modes

```bash
# JSON (structured, for parsing)
gog drive ls --json --max 5

# JSON with field selection
gog drive ls --json --select='id,name,mimeType'

# JSON results only (drops pagination envelope)
gog drive ls --json --results-only

# Plain/TSV (tab-separated, stable columns)
gog drive ls --plain --max 5
# Output: ID<TAB>NAME<TAB>TYPE<TAB>SIZE<TAB>MODIFIED

# Default: human-readable colored table
gog drive ls --max 5
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | `ok` — success |
| 1 | `error` — general error |
| 2 | `usage` — invalid usage |
| 3 | `empty_results` — no results (use `--fail-empty`) |
| 4 | `auth_required` — not authenticated |
| 5 | `not_found` — resource not found |
| 6 | `permission_denied` — API access denied or API not enabled |
| 7 | `rate_limited` — rate limit hit |
| 8 | `retryable` — transient error |
| 10 | `config` — configuration error |
| 130 | `cancelled` — user cancelled |

## API Enablement Status

**Working APIs:** Gmail, Calendar, Drive, Sheets, Docs, Slides, Forms, Chat, Groups
**Disabled APIs (need enabling in Google Cloud Console):**
- People API (`contacts list/search`, `people me`) — exit code 6
- Tasks API (`tasks lists`, `tasks list/add`) — exit code 6

To enable: visit the URL in the error message at `console.developers.google.com`.

---

## Gmail (`gog gmail` / `gog mail` / `gog email`)

### Search Threads

```bash
# Search using Gmail query syntax (returns threads)
gog gmail search "from:user@example.com" --json
gog gmail search "subject:invoice newer_than:7d" --max 20 --json
gog gmail search "has:attachment filename:pdf" --json
gog gmail search "in:inbox is:unread" --max 50 --json
gog gmail search "label:IMPORTANT" --all --json    # fetch ALL pages

# Search messages (individual, not grouped by thread)
gog gmail messages search "from:amazon" --max 5 --json
gog gmail messages search "from:amazon" --include-body --json  # includes decoded body
```

**Flags:** `--max=10`, `--page=TOKEN`, `--all` (all pages), `--fail-empty` (exit 3 if empty), `--oldest` (show first message date), `--timezone=IANA`

**Gmail Query Operators:**
- `from:`, `to:`, `cc:`, `bcc:`, `subject:`
- `is:unread`, `is:starred`, `is:important`, `is:read`
- `in:inbox`, `in:sent`, `in:trash`, `in:spam`, `in:anywhere`
- `has:attachment`, `filename:pdf`, `filename:xlsx`
- `newer_than:1d`, `older_than:7d`, `after:2024/01/01`, `before:2024/12/31`
- `label:LabelName`, `category:promotions`
- `larger:5M`, `smaller:1M`
- Combine with `OR`, `AND`, `-` (NOT), `()` for grouping

### Get Message

```bash
gog gmail get <messageId> --json
gog gmail get <messageId> --format=metadata --headers="From,To,Subject,Date" --json
gog gmail get <messageId> --format=raw --json     # raw RFC2822
```

**Formats:** `full` (default), `metadata` (headers only), `raw` (RFC2822)

### Get Thread

```bash
gog gmail thread get <threadId> --json
gog gmail thread get <threadId> --full --json       # include full message bodies
gog gmail thread get <threadId> --download --out-dir=./attachments  # download attachments
```

### List Thread Attachments

```bash
gog gmail thread attachments <threadId> --json
gog gmail thread attachments <threadId> --download --out-dir=./files
```

### Download Attachment

```bash
gog gmail attachment <messageId> <attachmentId> --out=./myfile.pdf --name="report.pdf"
```

### Send Email

```bash
gog gmail send --to="user@example.com" --subject="Hello" --body="Message body"
gog gmail send --to="a@x.com,b@x.com" --cc="c@x.com" --bcc="d@x.com" \
    --subject="Report" --body="See attached" --attach=report.pdf --attach=data.csv

# Send from stdin
echo "Body text" | gog gmail send --to="user@x.com" --subject="Test" --body-file=-

# HTML body
gog gmail send --to="user@x.com" --subject="HTML" --body-html="<h1>Hello</h1>"

# Reply to a message
gog gmail send --reply-to-message-id=<msgId> --body="Thanks!"
gog gmail send --thread-id=<threadId> --reply-all --body="Noted" --quote

# With open tracking (requires setup)
gog gmail send --to="user@x.com" --subject="Tracked" --body="test" --track
```

**Flags:** `--to`, `--cc`, `--bcc`, `--subject`, `--body`, `--body-file` (or `-` for stdin), `--body-html`, `--reply-to-message-id`, `--thread-id`, `--reply-all`, `--reply-to`, `--attach=FILE,...`, `--from=ALIAS`, `--track`, `--track-split`, `--quote`

Top-level alias: `gog send` is equivalent to `gog gmail send`.

### Labels

```bash
gog gmail labels list --json
gog gmail labels get "INBOX" --json              # includes message counts
gog gmail labels create "My Label"
gog gmail labels delete "Label_18"

# Modify labels on threads
gog gmail labels modify <threadId1> <threadId2> --add="STARRED,Later" --remove="INBOX"
```

### Drafts

```bash
gog gmail drafts list --json
gog gmail drafts get <draftId> --json
gog gmail drafts create --to="user@x.com" --subject="Draft" --body="WIP" --json
gog gmail drafts update <draftId> --subject="Updated draft" --body="New body"
gog gmail drafts send <draftId>                  # send existing draft
gog gmail drafts delete <draftId>
```

**Draft create/update flags:** `--to`, `--cc`, `--bcc`, `--subject`, `--body`, `--body-file`, `--body-html`, `--reply-to-message-id`, `--reply-to`, `--attach=FILE,...`, `--from=ALIAS`

### Batch Operations

```bash
gog gmail batch modify <msgId1> <msgId2> ... --add="STARRED" --remove="UNREAD"
gog gmail batch delete <msgId1> <msgId2> ...     # PERMANENT delete
```

### Thread Modify

```bash
gog gmail thread modify <threadId> --add="Later" --remove="INBOX"
```

### History

```bash
gog gmail history --since=<historyId> --json --max=100
```

### URL

```bash
gog gmail url <threadId>                         # prints Gmail web URL
```

### Settings

```bash
gog gmail settings filters list --json
gog gmail settings delegates list --json
gog gmail settings forwarding list --json
gog gmail settings sendas list --json
gog gmail settings vacation get --json
```

### Tracking

```bash
gog gmail track setup                            # deploy Cloudflare Worker
gog gmail track status                           # show tracking config
gog gmail track opens                            # list all opens
gog gmail track opens <tracking-id>              # opens for specific email
```

---

## Google Calendar (`gog calendar` / `gog cal`)

### List Calendars

```bash
gog calendar calendars --json
# Returns: id, summary, accessRole, backgroundColor, timeZone
# Primary calendar ID is the email address: andriytretyakov@gmail.com
```

### List Events

```bash
gog cal events --json                            # default: primary, next 10
gog cal events --today --json                    # today only
gog cal events --tomorrow --json
gog cal events --week --json                     # this week (Mon-Sun default)
gog cal events --days=7 --json                   # next 7 days
gog cal events --from=today --to=friday --json   # relative dates
gog cal events --from=2024-03-01 --to=2024-03-31 --json
gog cal events --all --json                      # events from ALL calendars
gog cal events <calendarId> --json               # specific calendar

# Pagination
gog cal events --max=50 --all-pages --json       # fetch all pages
gog cal events --max=10 --page=<token> --json

# Search within events
gog cal events --query="standup" --json

# Filter by extended properties
gog cal events --private-prop-filter="key=value" --json

# Include weekday columns
gog cal events --weekday --json

# Custom fields
gog cal events --fields="summary,start,end,location" --json
```

**Flags:** `--from`, `--to`, `--today`, `--tomorrow`, `--week`, `--days=N`, `--week-start=sun|mon`, `--max=10`, `--page`, `--all-pages`, `--fail-empty`, `--query`, `--all` (all calendars), `--fields`, `--weekday`

### Get Event

```bash
gog cal event <calendarId> <eventId> --json
```

### Search Events

```bash
gog cal search "meeting" --json
gog cal search "standup" --from=today --to=friday --json
gog cal search "lunch" --calendar="primary" --max=10 --json
```

### Create Event

```bash
# Basic event
gog cal create primary --summary="Team Meeting" \
    --from="2024-03-15T10:00:00-05:00" --to="2024-03-15T11:00:00-05:00" --json

# With details
gog cal create primary --summary="Lunch" --location="Restaurant" \
    --description="Team lunch" --from="2024-03-15T12:00:00" --to="2024-03-15T13:00:00" \
    --attendees="alice@x.com,bob@x.com" --send-updates=all --json

# All-day event
gog cal create primary --summary="Vacation" --all-day \
    --from="2024-03-20" --to="2024-03-22" --json

# With Google Meet
gog cal create primary --summary="Video Call" \
    --from="2024-03-15T14:00:00" --to="2024-03-15T15:00:00" --with-meet --json

# Recurring event
gog cal create primary --summary="Standup" \
    --from="2024-03-15T09:00:00" --to="2024-03-15T09:15:00" \
    --rrule="RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR" --json

# With reminders and color
gog cal create primary --summary="Deadline" \
    --from="2024-03-20T17:00:00" --to="2024-03-20T18:00:00" \
    --reminder=popup:30m --reminder=email:1d --event-color=11 --json

# Visibility and transparency
gog cal create primary --summary="Block" \
    --from="..." --to="..." --visibility=private --transparency=free --json
```

**Create flags:** `--summary`, `--from`, `--to`, `--description`, `--location`, `--attendees=EMAILS`, `--all-day`, `--rrule`, `--reminder=METHOD:DURATION,...`, `--event-color=1-11`, `--visibility=default|public|private|confidential`, `--transparency=busy|free`, `--send-updates=all|externalOnly|none`, `--guests-can-invite`, `--guests-can-modify`, `--guests-can-see-others`, `--with-meet`, `--source-url`, `--source-title`, `--attachment=URL,...`, `--private-prop=K=V,...`, `--shared-prop=K=V,...`

### Update Event

```bash
gog cal update primary <eventId> --summary="New Title" --json
gog cal update primary <eventId> --from="2024-03-15T11:00:00" --to="2024-03-15T12:00:00" --json
gog cal update primary <eventId> --add-attendee="new@x.com" --send-updates=all --json

# Recurring event scope
gog cal update primary <eventId> --scope=single --original-start="2024-03-15T09:00:00" --summary="Changed" --json
gog cal update primary <eventId> --scope=future --original-start="2024-03-15T09:00:00" --summary="Future" --json
```

**Update flags:** Same as create plus `--add-attendee`, `--scope=single|future|all`, `--original-start`

### Delete Event

```bash
gog cal delete primary <eventId> -y               # skip confirmation
gog cal delete primary <eventId> --scope=single --original-start="..." -y
gog cal delete primary <eventId> --send-updates=all -y
```

### RSVP / Respond

```bash
gog cal respond primary <eventId> --status=accepted
gog cal respond primary <eventId> --status=declined --comment="Can't make it"
gog cal respond primary <eventId> --status=tentative
```

### Free/Busy

```bash
gog cal freebusy "primary,alice@x.com" --from="2024-03-15T00:00:00Z" --to="2024-03-16T00:00:00Z" --json
```

### Conflicts

```bash
gog cal conflicts --today --json
gog cal conflicts --week --json
gog cal conflicts --from=today --to=friday --calendars="primary,work-cal-id" --json
```

### Focus Time / OOO / Working Location

```bash
gog cal focus-time --from="2024-03-15T09:00:00" --to="2024-03-15T12:00:00" --summary="Deep work" \
    --auto-decline=all --chat-status=doNotDisturb

gog cal out-of-office --from="2024-03-20" --to="2024-03-22"

gog cal working-location --from="2024-03-15" --to="2024-03-15" --type=home
gog cal working-location --from="2024-03-16" --to="2024-03-16" --type=office --working-office-label="HQ"
```

### Other

```bash
gog cal colors                                   # show available color IDs
gog cal time                                     # server time
gog cal propose-time primary <eventId>           # generates browser URL
gog cal users                                    # Workspace users
gog cal team <group-email>                       # events for group members
```

---

## Google Drive (`gog drive` / `gog drv`)

### List Files

```bash
gog drive ls --json                              # root folder, default 20
gog drive ls --parent=<folderId> --json          # specific folder
gog drive ls --max=50 --json
gog drive ls --no-all-drives --json              # My Drive only (excludes shared)
gog drive ls --query="mimeType='application/vnd.google-apps.spreadsheet'" --json
```

Top-level alias: `gog ls`

### Search Files

```bash
gog drive search "portfolio" --json              # full-text search
gog drive search "budget 2024" --max=10 --json
gog drive search "type:spreadsheet" --json       # smart type filter

# Raw Drive query language
gog drive search "mimeType='application/pdf' and modifiedTime > '2024-01-01'" --raw-query --json
```

Top-level alias: `gog search "query"`

**Drive Query Operators (for `--raw-query`):**
- `name contains 'text'`, `name = 'exact'`
- `mimeType = 'application/vnd.google-apps.spreadsheet'`
- `modifiedTime > '2024-01-01T00:00:00'`
- `'folderId' in parents`
- `trashed = false`
- `sharedWithMe`

### Get File Metadata

```bash
gog drive get <fileId> --json
```

### Download

```bash
gog drive download <fileId>                      # default: config dir
gog drive download <fileId> --out=./report.pdf
gog drive download <fileId> --format=csv         # export Google Sheets as CSV
gog drive download <fileId> --format=pdf         # export as PDF
gog drive download <fileId> --format=docx        # export Google Doc as docx
```

Top-level alias: `gog download <fileId>` / `gog dl <fileId>`

**Export formats:** `pdf`, `csv`, `xlsx`, `pptx`, `txt`, `png`, `docx`

### Upload

```bash
gog drive upload ./report.pdf --json
gog drive upload ./data.csv --name="Q1 Report" --parent=<folderId> --json
gog drive upload ./report.pdf --replace=<existingFileId> --json  # preserves link/perms

# Convert to Google format
gog drive upload ./data.csv --convert --json                     # auto-detect
gog drive upload ./data.csv --convert-to=sheet --json            # force Sheets
gog drive upload ./doc.docx --convert-to=doc --json              # force Docs

# Override MIME type
gog drive upload ./data.txt --mime-type="text/csv" --json
```

Top-level alias: `gog upload ./file` / `gog up ./file`

**Upload flags:** `--name`, `--parent=FOLDER_ID`, `--replace=FILE_ID`, `--mime-type`, `--keep-revision-forever`, `--convert`, `--convert-to=doc|sheet|slides`

### Create Folder

```bash
gog drive mkdir "New Folder" --json
gog drive mkdir "Subfolder" --parent=<folderId> --json
```

### Copy, Move, Rename

```bash
gog drive copy <fileId> "Copy of File" --parent=<folderId> --json
gog drive move <fileId> --parent=<newFolderId> --json
gog drive rename <fileId> "New Name" --json
```

### Delete

```bash
gog drive delete <fileId> -y                     # move to trash
gog drive delete <fileId> --permanent -y         # permanent delete
```

### Share / Permissions

```bash
gog drive share <fileId> --to=anyone --role=reader           # public link
gog drive share <fileId> --to=user --email=user@x.com --role=writer
gog drive share <fileId> --to=domain --domain=example.com --role=reader --discoverable

gog drive permissions <fileId> --json            # list permissions
gog drive unshare <fileId> <permissionId>        # remove permission
```

### Comments

```bash
gog drive comments list <fileId> --json
gog drive comments get <fileId> <commentId> --json
gog drive comments create <fileId> "Great work!" --json
gog drive comments reply <fileId> <commentId> "Thanks!" --json
gog drive comments update <fileId> <commentId> "Updated comment" --json
gog drive comments delete <fileId> <commentId>
```

### URL / Shared Drives

```bash
gog drive url <fileId>                           # print web URL
gog drive drives --json                          # list shared/team drives
```

---

## Google Sheets (`gog sheets` / `gog sheet`)

### Key Concepts

- **Spreadsheet ID**: The long string in the URL (`/d/<ID>/edit`)
- **Range notation**: `SheetName!A1:Z100` — the tab name followed by cell range
- **Tab names are the actual sheet tab names**, NOT "Sheet1". Check metadata first!
- **Values format**: Rows are comma-separated, cells within a row are pipe-separated: `"A|B|C" "D|E|F"` (two rows)
- **JSON 2D array alternative**: `--values-json='[["A","B"],["C","D"]]'`

### Get Spreadsheet Metadata

```bash
# Full metadata (sheets, conditional formats, named ranges, etc.)
gog sheets metadata <spreadsheetId> --json

# Just tab names (parse with jq or --select)
gog sheets metadata <spreadsheetId> --json | jq '.sheets[].properties.title'
```

### Read Values (GET)

```bash
# Read a range
gog sheets get <spreadsheetId> 'Overview!A1:E10' --json

# Read entire column
gog sheets get <spreadsheetId> 'Crypto!A:F' --json

# Read specific cell
gog sheets get <spreadsheetId> 'Overview!C3' --json

# Read with formulas visible
gog sheets get <spreadsheetId> 'Overview!A1:E5' --json --render=FORMULA

# Read raw unformatted numeric values (no currency symbols, no % formatting)
gog sheets get <spreadsheetId> 'Overview!A1:E5' --json --render=UNFORMATTED_VALUE

# Read formatted values (default — $104,461.09 format)
gog sheets get <spreadsheetId> 'Overview!A1:E5' --json --render=FORMATTED_VALUE

# Read by columns instead of rows
gog sheets get <spreadsheetId> 'Overview!A1:E5' --json --dimension=COLUMNS

# TSV output
gog sheets get <spreadsheetId> 'Overview!A1:E5' --plain
```

**Render options:** `FORMATTED_VALUE` (default, human-readable), `UNFORMATTED_VALUE` (raw numbers), `FORMULA` (show formulas)
**Dimension:** `ROWS` (default), `COLUMNS`

**JSON output format:**
```json
{
  "range": "Overview!A1:E5",
  "values": [
    ["", "", "All", "", "All Crypto"],
    [],
    ["Current value", "", "$104,461.09", "", "$104,461.09"]
  ]
}
```

### Write/Update Values

```bash
# Update a single cell
gog sheets update <spreadsheetId> 'Crypto!A10' "BTC"

# Update a range (pipe = cell separator, space = row separator)
gog sheets update <spreadsheetId> 'Crypto!A10:C10' "BTC|50%|1000"

# Multiple rows
gog sheets update <spreadsheetId> 'Crypto!A10:C11' "BTC|50%|1000" "ETH|30%|500"

# Using JSON 2D array (safer for complex data)
gog sheets update <spreadsheetId> 'Crypto!A10:C11' --values-json='[["BTC","50%","1000"],["ETH","30%","500"]]'

# Write formulas (USER_ENTERED interprets formulas, which is the default)
gog sheets update <spreadsheetId> 'Overview!C3' "=SUM(G3,I3,K3)"

# Write raw text (RAW mode — formulas treated as plain text)
gog sheets update <spreadsheetId> 'Crypto!A10' --input=RAW "=not a formula"

# Copy data validation from existing cells
gog sheets update <spreadsheetId> 'Crypto!A10:D10' "BTC|50|1000|yes" \
    --copy-validation-from='Crypto!A2:D2'

# Dry run (see what would happen)
gog sheets update <spreadsheetId> 'Crypto!A10' "TEST" --dry-run
```

**Input modes:** `USER_ENTERED` (default — interprets formulas/dates), `RAW` (literal text)

### Append Values

```bash
# Append a row to the bottom of existing data
gog sheets append <spreadsheetId> 'Crypto!A:F' "DOGE|5%|100||50|50"

# Append multiple rows
gog sheets append <spreadsheetId> 'History!A:D' "2024-03-15|BUY|BTC|1000" "2024-03-15|BUY|ETH|500"

# Using JSON
gog sheets append <spreadsheetId> 'History!A:D' --values-json='[["2024-03-15","BUY","BTC","1000"]]'

# Insert rows instead of overwriting
gog sheets append <spreadsheetId> 'History!A:D' --insert=INSERT_ROWS "2024-03-15|BUY|SOL|200"
```

**Insert modes:** `OVERWRITE` (default), `INSERT_ROWS` (push existing data down)

### Clear Values

```bash
gog sheets clear <spreadsheetId> 'Crypto!A10:F10'
```

### Cell Formatting

```bash
# Bold a range
gog sheets format <spreadsheetId> 'Overview!A1:E1' \
    --format-json='{"textFormat":{"bold":true}}' \
    --format-fields='textFormat.bold'

# Background color
gog sheets format <spreadsheetId> 'Crypto!A1:F1' \
    --format-json='{"backgroundColor":{"red":0.2,"green":0.6,"blue":0.9}}' \
    --format-fields='backgroundColor'

# Number format (currency)
gog sheets format <spreadsheetId> 'Crypto!C2:C100' \
    --format-json='{"numberFormat":{"type":"CURRENCY","pattern":"$#,##0.00"}}' \
    --format-fields='numberFormat'
```

### Cell Notes

```bash
gog sheets notes <spreadsheetId> 'Overview!A1:E5' --json
```

### Create Spreadsheet

```bash
gog sheets create "My New Sheet" --json
gog sheets create "Portfolio Tracker" --sheets="Overview,Crypto,Stocks" --json
```

### Copy Spreadsheet

```bash
gog sheets copy <spreadsheetId> "Portfolio Backup" --json
gog sheets copy <spreadsheetId> "Portfolio Copy" --parent=<folderId> --json
```

### Export Spreadsheet

```bash
gog sheets export <spreadsheetId> --format=xlsx --out=./portfolio.xlsx
gog sheets export <spreadsheetId> --format=csv --out=./portfolio.csv
gog sheets export <spreadsheetId> --format=pdf --out=./portfolio.pdf
```

---

## Google Docs (`gog docs` / `gog doc`)

### Read Document

```bash
gog docs cat <docId>                             # print as plain text
gog docs cat <docId> --json                      # JSON with text content
gog docs cat <docId> --tab="Introduction"        # specific tab
gog docs cat <docId> --all-tabs                  # all tabs with headers
gog docs cat <docId> --max-bytes=5000            # limit output size
```

### Get Metadata

```bash
gog docs info <docId> --json
gog docs list-tabs <docId>                       # list all tabs
```

### Write Content

```bash
# Append text
gog docs write <docId> "New paragraph text"

# Replace all content
gog docs write <docId> "Completely new content" --replace

# From file
gog docs write <docId> --file=./content.txt --replace

# From stdin
echo "New content" | gog docs write <docId> --file=- --replace

# Markdown to Google Docs formatting
gog docs write <docId> --file=./README.md --replace --markdown
```

### Insert Text

```bash
gog docs insert <docId> "Inserted at beginning" --index=1
gog docs insert <docId> --file=./snippet.txt --index=50
```

### Update Content

```bash
# Replace all content (plain text)
gog docs update <docId> --content="New document text"

# Append
gog docs update <docId> --content="Appended text" --append

# From markdown file
gog docs update <docId> --content-file=./doc.md --format=markdown
```

### Find and Replace

```bash
gog docs find-replace <docId> "old text" "new text"
gog docs find-replace <docId> "DRAFT" "FINAL" --match-case
```

### Delete Text Range

```bash
gog docs delete <docId> --start=10 --end=50
```

### Export

```bash
gog docs export <docId> --format=pdf --out=./doc.pdf
gog docs export <docId> --format=docx --out=./doc.docx
gog docs export <docId> --format=txt --out=./doc.txt
```

### Create / Copy

```bash
gog docs create "New Document" --json
gog docs copy <docId> "Document Copy" --json
```

### Comments

```bash
gog docs comments list <docId> --json
gog docs comments create <docId> "Review this section" --json
```

---

## Google Slides (`gog slides` / `gog slide`)

```bash
# Info / metadata
gog slides info <presentationId> --json
gog slides list-slides <presentationId>          # list slide IDs

# Create
gog slides create "My Presentation" --json
gog slides create-from-markdown "Deck Title" --content-file=./slides.md --json

# Export
gog slides export <presentationId> --format=pdf --out=./deck.pdf
gog slides export <presentationId> --format=pptx --out=./deck.pptx

# Copy
gog slides copy <presentationId> "Deck Copy" --json

# Manage slides
gog slides add-slide <presentationId> ./image.png --json
gog slides read-slide <presentationId> <slideId>
gog slides update-notes <presentationId> <slideId> --notes="Speaker notes here"
gog slides replace-slide <presentationId> <slideId> ./new-image.png
gog slides delete-slide <presentationId> <slideId>
```

---

## Google Contacts (`gog contacts` / `gog contact`)

**NOTE: Requires People API to be enabled** (currently disabled, exit code 6).

```bash
gog contacts list --json --max=100
gog contacts search "John" --json
gog contacts get <resourceName> --json           # e.g. people/c1234567890
gog contacts create --given="John" --family="Doe" --email="john@x.com" --phone="+1234567890"
gog contacts update <resourceName> --given="Jonathan"
gog contacts delete <resourceName>

# Directory contacts (Workspace)
gog contacts directory list --json
gog contacts directory search "Jane" --json

# Other contacts (auto-saved from Gmail)
gog contacts other list --json
gog contacts other search "someone" --json
```

---

## Google Tasks (`gog tasks` / `gog task`)

**NOTE: Requires Tasks API to be enabled** (currently disabled, exit code 6).

```bash
# List task lists
gog tasks lists list --json

# List tasks in a task list
gog tasks list <tasklistId> --json --max=50
gog tasks list <tasklistId> --show-completed --show-hidden --json
gog tasks list <tasklistId> --due-min="2024-03-01" --due-max="2024-03-31" --json

# Create task
gog tasks add <tasklistId> --title="Buy groceries" --json
gog tasks add <tasklistId> --title="Review PR" --notes="Check the auth module" --due="2024-03-15" --json
gog tasks add <tasklistId> --title="Subtask" --parent=<parentTaskId> --json

# Repeating tasks
gog tasks add <tasklistId> --title="Weekly review" --repeat=weekly --repeat-count=10
gog tasks add <tasklistId> --title="Daily standup" --repeat=daily --repeat-until="2024-12-31"

# Update task
gog tasks update <tasklistId> <taskId> --title="Updated title" --notes="New notes"
gog tasks update <tasklistId> <taskId> --due="2024-03-20"
gog tasks update <tasklistId> <taskId> --status=completed

# Complete / incomplete
gog tasks done <tasklistId> <taskId>
gog tasks undo <tasklistId> <taskId>

# Delete
gog tasks delete <tasklistId> <taskId>

# Clear completed
gog tasks clear <tasklistId>

# Create task list
gog tasks lists create "My Projects"
```

---

## Google Chat (`gog chat`)

```bash
# Spaces
gog chat spaces list --json
gog chat spaces find "General" --json
gog chat spaces create "New Space" --json

# Messages
gog chat messages list <space> --json            # space = "spaces/AAAA..."
gog chat messages send <space> --text="Hello team!"
gog chat messages send <space> --text="Reply" --thread="spaces/.../threads/..."

# Direct messages
gog chat dm send user@example.com --text="Hi there!"
gog chat dm space user@example.com               # find/create DM space

# Threads
gog chat threads list <space> --json
```

---

## Google Forms (`gog forms` / `gog form`)

```bash
gog forms get <formId> --json                    # form structure + questions
gog forms create --title="Survey" --description="Please fill out" --json
gog forms responses list <formId> --json         # all responses
gog forms responses get <formId> <responseId> --json
```

---

## Google Keep (`gog keep`) — Workspace Only

```bash
gog keep list --json
gog keep get <noteId> --json
gog keep search "shopping" --json
gog keep attachment <attachmentName>
```

Requires service account with `--service-account` and `--impersonate` flags.

---

## Google Groups (`gog groups` / `gog group`)

```bash
gog groups list --json                           # groups you belong to
gog groups members <groupEmail> --json           # members of a group
```

---

## Google Classroom (`gog classroom` / `gog class`)

```bash
gog classroom courses list --json
gog classroom roster <courseId> --json
gog classroom coursework list <courseId> --json
gog classroom submissions list <courseId> <courseworkId> --json
gog classroom announcements list <courseId> --json
```

---

## Google Apps Script (`gog appscript` / `gog script`)

```bash
gog appscript get <scriptId> --json              # project metadata
gog appscript content <scriptId> --json          # project source code
gog appscript create --title="My Script" --json
gog appscript run <scriptId> <functionName> --json
gog appscript run <scriptId> myFunc --params='["arg1", 42]' --json
gog appscript run <scriptId> myFunc --dev-mode --json
```

---

## Google People (`gog people` / `gog person`)

**NOTE: Requires People API to be enabled** (currently disabled).

```bash
gog people me --json                             # your profile
gog people get <userId> --json                   # user profile by ID
gog people search "John" --json                  # Workspace directory search
gog people relations --json                      # your relations
gog people relations <userId> --json
```

---

## Utility Commands

### Open (URL Generator)

```bash
gog open <fileId>                                # auto-detect type
gog open <fileId> --type=sheets                  # force type hint
gog open <threadId> --type=gmail-thread
# Types: auto, drive, folder, docs, sheets, slides, gmail-thread
```

### Auth / Status

```bash
gog status                                       # show auth config
gog auth list                                    # list stored accounts
gog auth services                                # list supported services/scopes
```

### Config

```bash
gog config list                                  # all config values
gog config keys                                  # available config keys
gog config get <key>
gog config set <key> <value>
gog config unset <key>
gog config path                                  # print config file path
```

Config file: `~/Library/Application Support/gogcli/config.json`

---

## Multi-Account Usage

```bash
# Use specific account for any command
gog -a work@company.com gmail search "from:boss" --json
gog -a personal@gmail.com drive ls --json

# The -a flag works with all API commands
gog sheets get <id> 'Sheet1!A1:B5' -a other@gmail.com --json
```

---

## Gotchas & Edge Cases

1. **Tab names matter for Sheets**: The range must use the actual tab name (e.g., `Overview!A1:B5`), NOT `Sheet1`. If the tab name has spaces, it still works without quoting inside the range: `'Crypto - Sold!A1:B5'` — but quote the whole argument for the shell.

2. **Sheets value encoding**: Pipe (`|`) separates cells, spaces separate rows. For data containing pipes or complex characters, use `--values-json` instead.

3. **Default input mode is USER_ENTERED**: Sheets `update`/`append` interpret formulas and dates by default. Use `--input=RAW` to write literal text.

4. **API not enabled errors (exit code 6)**: People API and Tasks API are currently disabled. The error message includes the exact URL to enable them.

5. **Pagination**: Most list commands return max 10-20 results by default. Use `--max=N` to increase, `--all` or `--all-pages` to fetch everything. The JSON response includes `nextPageToken` for manual pagination with `--page=TOKEN`.

6. **Dry run**: Use `-n` / `--dry-run` on any write operation to preview changes without executing.

7. **Force mode**: Use `-y` / `--force` to skip confirmation prompts on destructive operations.

8. **Gmail search returns threads by default**: Use `gog gmail messages search` if you need individual messages. Thread search groups messages into conversations.

9. **Calendar ID**: Primary calendar uses the email address as ID. Use `gog cal calendars` to discover all calendar IDs (e.g., the Gym calendar has a long hash ID).

10. **Drive shared drives**: Shared drive files are included by default. Use `--no-all-drives` to restrict to My Drive only.

11. **Sheets formulas in JSON**: When using `--render=FORMULA`, formulas appear as strings like `=SUM(A1:A10)`. With `UNFORMATTED_VALUE`, you get raw numbers (e.g., `104461.08818605001` instead of `$104,461.09`). `FORMATTED_VALUE` (default) returns the display string.

12. **Gmail body from stdin**: Use `--body-file=-` to pipe body content from stdin.

13. **Calendar relative dates**: `--from` and `--to` accept relative values: `today`, `tomorrow`, `monday`, `friday`, or RFC3339/date strings.

14. **Empty rows in sheets**: Empty rows come back as `[]` in the values array. Your code should handle sparse arrays.

15. **Gmail send always requires explicit `--to`** unless using `--reply-all` with `--reply-to-message-id` or `--thread-id`.

16. **Calendar recurring events**: When updating/deleting, use `--scope=single|future|all` with `--original-start` for targeting specific instances.

17. **`--select` is best-effort**: Field selection in JSON mode may not always work perfectly. Use `jq` for precise extraction from `--json` output.
