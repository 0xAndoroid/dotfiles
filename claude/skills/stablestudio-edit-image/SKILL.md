---
name: stablestudio-edit-image
description: 'Photorealistic image-to-image edit of an existing photo via StableStudio Nano Banana Pro (with Flux 2 Pro / Nano Banana fallback). Uses agentcash for x402 micropayments. USE FOR: - Editing a real photo (room mockups, product staging, scene modifications, mural/painting placement) - Any "modify this photo to..." request where the source image must be preserved - Tasks where text-to-image generation is too unfaithful to the input. TRIGGERS: - "edit this photo", "modify this image", "change this picture" - "mockup [thing] above/in/on [existing photo]", "add [object] to this room photo" - "image-to-image edit", "nano banana edit", "stablestudio edit" - "/stablestudio-edit-image [image_path] [prompt]"'
---

## Inputs

- **source_image** — absolute path to local source image (jpg/png/webp). Verify it exists.
- **prompt** — natural-language edit instruction. Be explicit about what to change AND what to preserve ("keep the couch, window, floor exactly the same").
- **output_path** — absolute local path for the result (default `/tmp/edit-<timestamp>.png`).
- **aspect_ratio** (optional) — match source orientation. Allowed: `1:1|2:3|3:2|3:4|4:3|4:5|5:4|9:16|16:9|21:9`. Default: read from source dimensions.
- **image_size** (optional) — `1K|2K|4K`. Default `2K`. Pricing scales with size.
- **model** (optional) — `nano-banana-pro` (default, ~$0.13–$0.24), `flux-2-pro` (~$0.03–$0.06, fallback), `nano-banana` (~$0.045–$0.151, cheaper alt).

## Budget

- Per-edit envelope: **~$0.17** at 2K 4:3 (`$0.01` upload + `$0.16` edit).
- Hard cap default: $0.50. If user provides explicit budget, honor it.
- Single user request ≤ $1 needs no approval per project rules. > $1 → ask first.

## Preconditions

1. `agentcash` MCP connected. If not, abort with clear message.
2. Source image exists and is a real image (`file <path>` reports image format).
3. `mcp__agentcash__get_balance` ≥ budget envelope.

## Workflow

### Step 1 — Discover (only if uncertain about endpoint shape)

```
mcp__agentcash__discover_api_endpoints(url="https://stablestudio.dev", includeGuidance=true)
```

Skip if you've already loaded guidance in this session.

### Step 2 — Get upload token ($0.01, paid)

```
mcp__agentcash__fetch(
  url="https://stablestudio.dev/api/upload",
  method="POST",
  body='{"filename":"<basename>","contentType":"image/jpeg"}',
  maxAmount=0.05,
)
```

Response gives `{uploadId, clientToken, pathname, expiresAt}`. `expiresAt` is ~5 min — proceed immediately.

### Step 3 — PUT bytes to Vercel Blob (free, direct)

URL-encode the `pathname` (`/` → `%2F`). Use `--data-binary` so curl doesn't mangle bytes.

```bash
curl -sS -X PUT "https://vercel.com/api/blob/?pathname=<url-encoded-pathname>" \
  -H "authorization: Bearer <clientToken>" \
  -H "x-content-type: image/jpeg" \
  -H "x-api-version: 11" \
  --data-binary @<source_image>
```

Response gives `{url, downloadUrl, pathname, contentType}`. Capture `url` (the canonical blob URL).

### Step 4 — Confirm upload (free, SIWX)

```
mcp__agentcash__fetch(
  url="https://stablestudio.dev/api/upload/confirm",
  method="POST",
  body='{"uploadId":"<uploadId>","blobUrl":"<url-from-step-3>"}',
)
```

Response: `{success: true, upload: {...}}`.

### Step 5 — Submit edit job (paid, ~$0.13–$0.24 for nano-banana-pro at 2K)

```
mcp__agentcash__fetch(
  url="https://stablestudio.dev/api/generate/nano-banana-pro/edit",
  method="POST",
  body='{"prompt":"<prompt>","aspectRatio":"<ratio>","imageSize":"<size>","images":["<blob_url>"]}',
  maxAmount=0.4,
)
```

Response: `{success: true, jobId: "...", status: "pending", type: "nano-banana-pro-edit"}`.

**Note:** Some models use different keys (`flux-2-pro` uses `aspect_ratio` + `resolution`; `nano-banana` uses `aspectRatio` + `imageSize` + optional `thinkingLevel`). See input-schema reference at the bottom.

### Step 6 — Poll until complete

Wait ~8s before first poll, then every ~5s.

```
mcp__agentcash__fetch(
  url="https://stablestudio.dev/api/jobs/<jobId>",
  method="GET",
)
```

Status progression: `pending` → `loading` (with `progress` 0–100) → `complete`. Stop polling at `complete`. On `failed`, surface the `error` field and consider fallback model.

`complete` payload: `{status: "complete", result: {imageUrl: "https://...blob.vercel-storage.com/generated/<uuid>.png"}}`.

**Timeout:** 2 min for images. If still `loading` after 2 min, abort and report.

### Step 7 — Download immediately (URL expires in ~20 min)

```bash
curl -sS -o <output_path> "<imageUrl>"
file <output_path>   # verify it's a real image
```

### Step 8 — Report

If invoked from a background task with a parent, return via `message_parent` with the image attached. Otherwise, output the local path + cost summary.

## Success Criteria

- Job status is `complete`.
- Local output file exists and `file` reports a valid image (JPEG/PNG).
- Total spend ≤ budget envelope.

## Pitfalls

- **URL expiry** — generated `imageUrl` expires in ~20 min. Download in the same session.
- **Aspect ratio mismatch** — if you pass an aspect ratio different from the source, the edit may crop or distort. Always match source unless user wants a reframe.
- **Edit prompt too vague** — Nano Banana Pro can ignore subtle changes. Be explicit about (a) what to add/modify, (b) where, (c) what to preserve.
- **Pathname encoding** — must URL-encode `/` to `%2F` in the Vercel Blob PUT URL.
- **Upload token expiry** — ~5 min from issue. Don't batch step 2 long before step 3.
- **JSON booleans/numbers in body** — `mcp__agentcash__fetch` body is a JSON string; double-check escaping when prompt contains quotes or apostrophes (use `—` for em-dash if shell escaping bites).
- **MCP fetch may report higher max** — set `maxAmount` to a tight upper bound (0.05 for upload, 0.4 for nano-banana-pro/edit) so a price spike fails fast rather than overspending.

## Fallback Strategy

If `nano-banana-pro/edit` fails (price ceiling hit, model error, censored), retry once with the same blob URL on:

1. `flux-2-pro/edit` — body shape: `{"prompt":..., "aspect_ratio":..., "resolution":"2 MP", "images":[...]}` (~$0.03–$0.06).
2. `nano-banana/edit` — body shape: `{"prompt":..., "aspectRatio":..., "imageSize":"2K", "images":[...]}` (~$0.045–$0.151).

Don't fall back automatically without informing the user — quality drops noticeably.

## Model Schema Reference (edit endpoints)

| Model | Body keys | Size key | Cost (approx) |
|---|---|---|---|
| `nano-banana-pro/edit` | `prompt`, `aspectRatio`, `imageSize`, `images[]` | `1K\|2K\|4K` | $0.13–$0.24 |
| `nano-banana/edit` | `prompt`, `aspectRatio`, `imageSize`, `images[]`, `thinkingLevel?` | `512\|1K\|2K\|4K` | $0.045–$0.151 |
| `flux-2-pro/edit` | `prompt`, `aspect_ratio`, `resolution`, `images[]` | `0.5 MP\|1 MP\|2 MP` | $0.03–$0.06 |
| `flux-2-max/edit` | `prompt`, `aspect_ratio`, `resolution`, `images[]` | `0.5 MP\|1 MP\|2 MP\|4 MP` | $0.04–$0.17 |
| `gpt-image-2/edit` | `prompt`, `quality`, `size`, `images[]` | `1024x1024\|1536x1024\|1024x1536\|auto` | $0.005–$0.21 |
| `grok/edit` | `prompt`, `aspect_ratio`, `images[]` | n/a | $0.022 |

## Open Questions

- No support for masks/inpainting region — Nano Banana Pro is full-frame edit only. If user needs precise region control, GPT Image 2 edit is closer (but no native mask either at this provider).
- Multi-reference (compositing two photos) — `images[]` accepts up to 14 (nano-banana) or 14 (nano-banana-pro), but blending fidelity is unproven for this use case. Test before committing to a workflow.
