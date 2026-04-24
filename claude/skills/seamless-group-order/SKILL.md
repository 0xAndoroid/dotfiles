---
name: seamless-group-order
description: 'Fill out and submit a Seamless group lunch order via Chrome DevTools MCP. USE FOR: - Joining a Seamless group order from an invite URL - Adding specified menu items to the bag - Submitting order to host (host pays, no payment entered) TRIGGERS: - "seamless-group-order", "/seamless-group-order [url] [items]" - "order lunch from seamless", "submit group order", "seamless group order" - "fill out seamless order", "join seamless group order" - any seamless.com/menu/.../grouporder/... URL combined with a list of items'
---

## Inputs

- **URL** — Seamless group order link (e.g. `https://www.seamless.com/menu/soho-sushi-231-sullivan-st-new-york/74715/grouporder/<token>?blockModal=true`)
- **Items** — list of menu item names (e.g. `["Tekka Don Lunch", "Sushi Deluxe Lunch"]`). Fuzzy matching OK; prefer exact names.
- **Email hint** (optional) — Gmail message ID **OR** a sender/subject search query (e.g. `from:zapiermail.com Pika Lunch`) identifying the originating lunch-invite email. If provided AND the order submits successfully, step 10 trashes it. If omitted or the order fails, step 10 is skipped and noted in the report.

## Standard Defaults

- **First name:** Andrew
- **Last name:** Tretyakov
- **Email:** atretyakov@a16z.com
- **Side modifier default (sushi restaurants):** Soup
- **Generic required-modifier default:** first option, or cheapest if tied; flag in final report if ambiguous

## Workflow (shortest path)

### 1. Open URL

```
mcp__chrome-devtools__new_page(url=<URL>)
```

The join-group dialog auto-opens (because of `?blockModal=true` or default flow). A snapshot shows it as the first `dialog` element with heading `"Join <Host>'s group order"`.

### 2. Handle join prompt

The dialog has three textboxes (labels: `First name`, `Last name`, `Email`) and a `Join group order` button. Fill all three with `fill_form` in ONE call, then click the button.

```
mcp__chrome-devtools__fill_form(elements=[
  {uid: <first_name_uid>, value: "Andrew"},
  {uid: <last_name_uid>, value: "Tretyakov"},
  {uid: <email_uid>, value: "atretyakov@a16z.com"},
])
mcp__chrome-devtools__click(uid=<join_button_uid>)
```

After success the page shows a status text `"You're good to go. Start adding items to <Host>'s group order."` and a cart sidebar appears with the host + participants.

### 3. Find each item

**Use the menu search box** (label `Search Soho Sushi` or `Search <Restaurant>`) — fastest path. Do NOT scroll the menu.

For each item:
1. `fill` the search box with a distinctive substring (e.g. `"Tekka Don"`, `"Sushi Deluxe"`).
2. React-backed search does NOT always re-filter on `fill` alone. If the results don't update: `press_key` `Space` then `Backspace` on the focused search box to force a re-render.
3. Snapshot → locate the matching `button "<Item Name> ... $<price>"`.

Watch for near-duplicates (e.g. `Tekka Don Lunch $26.25` in Sushi Bar Lunch vs `Tekka Don $31.50` in Sushi Bar Entrees). Prefer the one matching the user's exact requested name; if ambiguous, pick the cheaper "Lunch" variant during lunch hours and flag.

### 4. Click item → handle required modifiers

Clicking the item button opens a modal `dialog` with the item name as heading, a quantity spinbutton (default 1), and `tab` elements for each modifier group.

**Identifying required modifiers:** the submit button reads `"Make required choice (N) : $price"`. When all required choices are resolved it flips to `"Add to bag : $price"`.

For each required `tab` (e.g. `"Choose a side Choose one (Required)"`):
1. Click the tab to expand. This reveals a `region` containing `generic` elements for each option (e.g. `Soup`, `Salad`).
2. Click the default option:
   - **Sushi / Japanese lunch restaurants** → pick `Soup`.
   - **Other restaurants** → pick the first option; if the first is strictly more expensive than another, pick the cheapest.
   - If truly ambiguous / non-obvious → pick cheapest/first and add to the "ambiguous choices" section of the final report.
3. Skip optional tabs (labeled `(Optional)`) unless the user specified preferences.

After the button text flips to `"Add to bag : $price"`, click it.

**Gotcha:** clicking an option AND the Add-to-bag button back-to-back can race — the state update from the option click may not register before the Add-to-bag click fires. If the modal doesn't close, take a fresh snapshot and re-click Add-to-bag. If Add-to-bag's uid no longer exists, the item was added successfully and the dialog closed.

### 5. Verify bag

After adding each item, the cart sidebar (`complementary` region on the right) updates with `Your items`:
- Item name
- Modifier choice (e.g. `Soup`)
- Price
- Quantity spinner

Verify each item + chosen modifier appears. Subtotal below the list should equal the sum.

### 6. Submit

In the cart sidebar, click the `Submit to group order` button.

The button switches to a `Spinner icon` (busy) state. Wait for navigation.

```
mcp__chrome-devtools__wait_for(text=["Thanks", "submitted", "Your order"], timeout=15000)
```

### 7. Confirm success

On success the URL becomes `.../grouporder/<token>/thank-you` and the page shows:
- Heading `"Thanks for submitting your order"`
- Text `"We'll let you know once <Host> checks out."`
- The list of items + modifiers + subtotal
- `"Subtotal (paid by <Host>)"`

### 8. Do NOT pay

Group orders charge the **host**. If you ever see a card-entry field, a "Place order" button asking for payment method, or a Seamless+ upsell blocking submission → **STOP**. Do not enter anything. Report the exact blocker in the final report.

### 9. Screenshot + close

```
mcp__chrome-devtools__take_screenshot(
  filePath="/tmp/lunch-order-confirmation-<YYYY-MM-DD>.png",
  fullPage=true,
)
mcp__chrome-devtools__list_pages()
mcp__chrome-devtools__close_page(pageId=<thank-you page id>)
```

Use today's date (ET) in the filename.

### 10. Clean up Gmail (only after successful submission)

**Preconditions — ALL must be true before running this step:**
- Step 7 reached the confirmation page (URL contains `/thank-you`, heading `"Thanks for submitting your order"`).
- Step 8 did NOT trigger the "payment prompt appeared → STOP" branch.
- The user supplied an email hint (raw message ID OR sender/subject query).

If ANY precondition fails → **SKIP this step entirely** and log the reason in the final report. Never trash the email if the order didn't go through — the user will want to retry from the original invite.

**10a. Resolve the message ID.** If the user passed a raw Gmail message ID, use it directly in 10b. Otherwise search:

```bash
gws gmail users messages list \
  --params '{"userId":"me","q":"<sender/subject hint>","maxResults":1}'
```

Typical hint: `from:zapiermail.com Pika Lunch` or `subject:"Lunch order"`. Extract `messages[0].id`. If the response has zero matches → log `"email hint matched zero messages"` in the report and skip 10b (don't trash anything).

**10b. Trash the message.**

```bash
gws gmail users messages trash \
  --params '{"userId":"me","id":"<messageId>"}'
```

`trash` moves the message to the Trash label (reversible for 30 days). **Never use `gws gmail users messages delete`** — that is permanent. Verify `TRASH` appears in the returned `labelIds` to confirm success.

## Final Report Template

```
**Seamless group order — <Restaurant name>**

- **Host:** <Host name>
- **Joined as:** Andrew Tretyakov / atretyakov@a16z.com
- **Items added:**
  - <Item 1> ($<price>) — <modifier choice>
  - <Item 2> ($<price>) — <modifier choice>
- **Subtotal:** $<total>
- **Confirmation reached:** Yes / No
- **Payment:** Not prompted (host pays) / STOPPED — payment prompt appeared
- **Ambiguous modifier choices flagged:** <item + choice + why> | None
- **Errors / prompts I couldn't resolve:** <text> | None
- **Screenshot:** /tmp/lunch-order-confirmation-<date>.png
- **Chrome tab:** Closed
- **Originating email:** Trashed (id: `<messageId>`) | Kept — order did not submit | Kept — no email hint provided | Kept — hint matched zero messages
```

## Anti-patterns (DON'T do)

- **Don't try to pay.** Group orders are host-pay. No card, no address, no Seamless+ signup. If blocked by payment UI → stop and report.
- **Don't scroll the menu looking for items.** Use the search box — it filters the full menu in one pass.
- **Don't re-snapshot after every click.** `click` with `includeSnapshot: true` returns the post-click state in one call. Re-snapshot only when state might be stale (e.g. after a modal closes, after a `wait_for`).
- **Don't use `evaluate_script` to "find" the search box** — just fill by uid from the snapshot. `evaluate_script` is a fallback, not the default.
- **Don't click the "+" plus icon on the item card** — it can behave inconsistently for items with required modifiers. Click the item button itself to open the modal every time.
- **Don't rely on `fill` alone to trigger React-backed search filters** — follow with `Space`+`Backspace` press_key if results don't update.
- **Don't assume tab order in modifiers.** Parse the tab labels for `(Required)` vs `(Optional)` — only Required tabs block the submit button.
- **Don't click an option and Add-to-bag in the same turn without a state check.** Race condition. Either wait for the snapshot to show the button flipped to `"Add to bag"`, or be prepared for the first Add-to-bag to no-op and re-click.
- **Don't pick Salad by default for sushi shops.** User preference: Soup. Cross-check the restaurant type before defaulting; flag if non-Japanese and Soup isn't obviously right.
- **Don't send `.md` output** — the skill writes results to Telegram text; follow vault rules if converting to attachment.
- **Don't leave the tab open.** Close it after the screenshot.
- **Don't trash the originating email unless the order actually submitted.** If the thank-you page wasn't reached or a payment prompt fired, keep the email so the user can retry.
- **Don't use `gws gmail users messages delete`.** That is permanent. Always use `trash` (reversible for 30 days).

## Selector cheatsheet (Seamless / Grubhub DOM, April 2026)

- Join dialog textboxes: labels `First name` / `Last name` / `Email` (all `required`).
- Join button: `Join group order`.
- Menu search box: `searchbox` with label `Search <Restaurant name>`.
- Item modal: `dialog` with `heading level=1` matching item name, submit button at the bottom with dynamic label.
- Required modifier tab label format: `"<Group name> Choose one (Required)"` or `"<Group name> Choose as many as you'd like (Required)"`.
- Optional modifier tab label ends with `(Optional)` — ignore unless user asked.
- Cart sidebar: `complementary` region, contains `Your items`, participants, `Submit to group order` button.
- Confirmation URL: `/checkout/grouporder/<token>/thank-you`.

## React event-dispatch fallback (when `click` doesn't commit state)

Seamless's React-backed submodifier buttons (`.emi-submodifier-btn` spans) and the footer CTA sometimes don't register state updates from chrome-devtools `click` / `fill` / `press_key` — the element focuses but React's onClick handler never fires. Symptom: you click a required-modifier option, snapshot shows it unchanged, Add-to-bag stays disabled.

Fallback: dispatch the full pointer-event sequence via `evaluate_script`:

```js
const el = document.querySelector('<selector>');
const events = ['pointerdown', 'mousedown', 'pointerup', 'mouseup', 'click'];
for (const type of events) {
  el.dispatchEvent(new MouseEvent(type, { bubbles: true, cancelable: true, view: window }));
}
```

Works reliably for: submodifier option selection, tab expansion, Add-to-bag, Submit-to-group-order. Use only when `click` demonstrably failed — prefer plain `click` when it works.
