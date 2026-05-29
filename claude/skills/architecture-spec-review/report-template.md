# Report Templates

Two output formats for an architecture spec review. **Markdown is the default**; use HTML when richer formatting or color-coded cost badges help. Fill every `<...>` placeholder and delete sections that genuinely don't apply.

## Markdown skeleton

```markdown
# Architecture Review — <branch / PR title>

> Diff: `<base>...<head>` · <N files, +X / −Y lines> · Generated <date>

## 1. Reconstructed Spec

**Problem & requirements.** <what this change is actually trying to accomplish — functional + non-functional>

**Components & abstractions.** <new/modified, each with its responsibility>

**Data & control flow.** <how a request/operation moves through the new code>

**Boundaries & seams.** <where this plugs into the existing system>

**Key decisions & tradeoffs.** <decisions made, alternatives not taken, and why>

## 2. Future-Feature Stress Test

| Future feature | Blast radius | Cost | Why |
|----------------|--------------|------|-----|
| <concrete, domain-specific feature> | <modules / interfaces touched> | Low / Med / High | <localized vs cross-cutting, what breaks> |

**Abstraction diagnosis.** <name the specific leaky abstractions, missing extension points, rigid seams, and over-engineering revealed by the cost pattern above>

## 3. Assessment

**Verdict.** <do the abstractions fit the spec? commit to a position>

**Top risks.**
1. <risk>
2. <risk>
3. <risk>

**Recommendations.** <specific seams to add / move / remove, each tied to the future(s) that justify it — including abstractions to delete>
```

## HTML template

Standalone single file: inline `<style>`, no external assets, prints cleanly. Adapt placeholders; the `.cost-*` classes color-code Low/Med/High in the stress-test table.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Architecture Review — <TITLE></title>
<style>
  :root { --fg:#1f2328; --muted:#656d76; --line:#d0d7de; --bg:#fff;
          --low:#1a7f37; --med:#9a6700; --high:#cf222e; --accent:#0969da; }
  * { box-sizing: border-box; }
  body { font: 16px/1.6 -apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;
         color: var(--fg); background: var(--bg); max-width: 880px;
         margin: 0 auto; padding: 2.5rem 1.25rem; }
  h1 { font-size: 1.9rem; border-bottom: 2px solid var(--line); padding-bottom: .4rem; }
  h2 { font-size: 1.35rem; margin-top: 2.2rem; border-bottom: 1px solid var(--line); padding-bottom: .3rem; }
  .meta { color: var(--muted); font-size: .9rem; margin-top: -.4rem; }
  code { background: #eff1f3; padding: .1rem .35rem; border-radius: 4px; font-size: .88em; }
  table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
  th, td { border: 1px solid var(--line); padding: .55rem .7rem; text-align: left; vertical-align: top; }
  th { background: #f6f8fa; }
  .badge { display: inline-block; padding: .05rem .55rem; border-radius: 999px;
           font-size: .78rem; font-weight: 600; color: #fff; white-space: nowrap; }
  .cost-low  { background: var(--low); }
  .cost-med  { background: var(--med); }
  .cost-high { background: var(--high); }
  blockquote { border-left: 4px solid var(--accent); margin: 1rem 0; padding: .2rem 1rem; color: var(--muted); }
  ol, ul { padding-left: 1.4rem; }
  @media print { body { padding: 0; } a { color: inherit; } }
</style>
</head>
<body>
  <h1>Architecture Review — <TITLE></h1>
  <p class="meta">Diff <code><BASE>...<HEAD></code> · <N files, +X / −Y> · Generated <DATE></p>

  <h2>1. Reconstructed Spec</h2>
  <p><strong>Problem &amp; requirements.</strong> <…></p>
  <p><strong>Components &amp; abstractions.</strong> <…></p>
  <p><strong>Data &amp; control flow.</strong> <…></p>
  <p><strong>Boundaries &amp; seams.</strong> <…></p>
  <p><strong>Key decisions &amp; tradeoffs.</strong> <…></p>

  <h2>2. Future-Feature Stress Test</h2>
  <table>
    <thead><tr><th>Future feature</th><th>Blast radius</th><th>Cost</th><th>Why</th></tr></thead>
    <tbody>
      <tr><td><…></td><td><…></td><td><span class="badge cost-low">Low</span></td><td><…></td></tr>
      <tr><td><…></td><td><…></td><td><span class="badge cost-med">Med</span></td><td><…></td></tr>
      <tr><td><…></td><td><…></td><td><span class="badge cost-high">High</span></td><td><…></td></tr>
    </tbody>
  </table>
  <p><strong>Abstraction diagnosis.</strong> <leaky abstractions, missing extension points, rigid seams, over-engineering></p>

  <h2>3. Assessment</h2>
  <p><strong>Verdict.</strong> <…></p>
  <p><strong>Top risks.</strong></p>
  <ol><li><…></li><li><…></li><li><…></li></ol>
  <p><strong>Recommendations.</strong> <seams to add/move/remove, tied to justifying futures></p>
</body>
</html>
```
