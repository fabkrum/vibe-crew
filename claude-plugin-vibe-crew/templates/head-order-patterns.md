# HTML Head Order Pattern Reference

Agent-facing reference for optimal `<head>` element ordering. The Builder reads this during the Design Phase for any feature involving HTML pages; the Code Reviewer checks compliance during review.
**Principle:** The `<head>` is the single biggest render-blocking part of a page. Element ordering directly affects when the browser can start painting. Follow the capo.js 11-weight system (Harry Roberts / Rick Viscomi research). Misordered elements can delay rendering by up to 7 seconds.

## Canonical Order (capo.js weights, highest to lowest)

| Weight | Category | Elements | Rationale |
|--------|----------|----------|-----------|
| 10 | Pragma | `<meta charset>`, `<meta viewport>`, `<meta http-equiv>`, `<base>` | Must be parsed before anything else. Charset in first 1024 bytes. CSP before any script. |
| 9 | Title | `<title>` | Needs charset for correct rendering. Browser tab needs it immediately. |
| 8 | Preconnect | `<link rel="preconnect">` | Starts DNS+TCP+TLS early for critical third-party origins. |
| 7 | Async Scripts | `<script async src>` | Non-blocking. Place high so preload scanner discovers early. |
| 6 | @import Styles | `<style>` with `@import` | CSS spec requires @import first. Discouraged — prefer `<link>`. |
| 5 | Sync Scripts | `<script src>` (no async/defer) | Before CSS so preload scanner discovers stylesheets in parallel. |
| 4 | Sync Styles | `<link rel="stylesheet">`, `<style>` | Render-blocking. After sync scripts for parallel discovery. |
| 3 | Preload | `<link rel="preload">`, `<link rel="modulepreload">` | Hints for soon-needed resources. Below actual resources. |
| 2 | Deferred Scripts | `<script defer>`, `<script type="module">` | Execute after parsing. Low urgency for early discovery. |
| 1 | Prefetch/Prerender | `<link rel="prefetch">`, `<link rel="dns-prefetch">`, `<script type="speculationrules">` | Future navigations. Must not compete with current-page resources. |
| 0 | Everything Else | OG tags, description, icons, canonical, alternate, manifest | No rendering impact. Bottom of `<head>`. |

## Key Rules

### 1. Charset First
- `<meta charset="utf-8">` must be the very first element in `<head>`.
- Must appear within the first 1024 bytes (HTML spec requirement).
- Late charset forces a full document re-parse.

### 2. CSP Before Scripts
- `<meta http-equiv="content-security-policy">` must precede ALL `<script>` elements.
- CSP after scripts disables the preload scanner and leaves preceding scripts unprotected.
- Prefer the HTTP header over the meta tag when possible.

### 3. Sync Scripts Before Sync CSS (Counterintuitive)
- Place `<script src>` BEFORE `<link rel="stylesheet">` when the script does not query CSSOM.
- CSS blocks JS execution. If JS is after CSS, the browser waits for CSS before running JS.
- Placing JS first lets the preload scanner discover CSS while JS executes — enabling parallel downloads.
- Exception: scripts that call `getComputedStyle()` or read layout properties must follow their stylesheet.
- Harry Roberts measured ~2x faster loads from this reorder.

### 4. Static async Over Snippet Pattern
- Always use `<script async src="...">` in HTML markup.
- Never use the old async snippet pattern (creating script elements via JS).
- The preload scanner cannot see URLs inside JavaScript — only in HTML markup.
- Measured improvement: 787ms faster execution despite 297ms longer download.

### 5. Preconnect Sparingly
- Limit to 2-4 critical origins.
- Always include `crossorigin` for font origins.
- Unused preconnects waste a full connection (DNS + TCP + TLS).
- Pair with dns-prefetch as fallback: `<link rel="preconnect" href="...">` + `<link rel="dns-prefetch" href="...">`.

### 6. SEO/Social Tags Last
- OG tags, meta description, canonical, favicons, alternate links — all weight 0.
- These have zero rendering impact. Never let them displace critical resources.

## Anti-Patterns

| Anti-Pattern | Impact | Fix |
|-------------|--------|-----|
| CSS before sync JS | JS blocked until CSS downloads + parses (~2x slower) | Move sync JS before CSS |
| Late charset | Full document re-parse (100-500ms) | Make charset first element |
| CSP after scripts | Preload scanner disrupted, scripts unprotected | Move CSP before all scripts |
| @import in CSS | Hidden waterfall, preload scanner blind | Replace with `<link>` tags |
| Async snippet pattern | Script invisible to preload scanner | Use static `<script async>` |
| document.write() | Kills parser, defeats preload scanner, Chrome blocks on 2G | Never use |
| async + defer on same script | defer ignored, confusing intent | Pick one |
| OG tags before stylesheets | Critical resources pushed down | Move OG tags to bottom |

## Template

```html
<head>
  <!-- Pragma (weight 10) -->
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Title (weight 9) -->
  <title>Page Title</title>

  <!-- Preconnect (weight 8) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <!-- Async scripts (weight 7) -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-..."></script>

  <!-- Sync scripts before CSS (weight 5) -->
  <script src="/critical.js"></script>

  <!-- Sync styles (weight 4) -->
  <style>/* critical inline CSS */</style>
  <link rel="stylesheet" href="/main.css">

  <!-- Preload (weight 3) -->
  <link rel="preload" href="/font.woff2" as="font" type="font/woff2" crossorigin>

  <!-- Deferred scripts (weight 2) -->
  <script defer src="/app.js"></script>

  <!-- Prefetch / Speculation Rules (weight 1) -->
  <link rel="dns-prefetch" href="https://analytics.example.com">
  <script type="speculationrules">
  {
    "prerender": [
      { "where": { "selector_matches": "[data-prefetch=prerender]" }, "eagerness": "immediate" },
      { "where": { "selector_matches": "[data-prefetch='']" }, "eagerness": "moderate" }
    ],
    "prefetch": [
      { "where": { "selector_matches": "[data-prefetch='']" }, "eagerness": "immediate" },
      { "where": { "and": [{ "href_matches": "/*" }, { "not": { "selector_matches": "[data-prefetch=false]" } }] }, "eagerness": "moderate" }
    ]
  }
  </script>

  <!-- Everything else (weight 0) -->
  <meta name="description" content="...">
  <link rel="canonical" href="https://example.com/page">
  <meta property="og:title" content="Page Title">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
</head>
```

## Validation Tools

- **capo.js** — Chrome extension + bookmarklet. Color-codes head elements by weight. Shows actual vs optimal order.
- **ct.css** — CSS-only bookmarklet by Harry Roberts. Highlights anti-patterns with colored borders.
- **astro-capo** — Astro integration that auto-sorts head output at build time.
- **nuxt-capo** — Nuxt 3 module for automatic head sorting.
- **Unhead v2** — Universal head manager with built-in capo.js sorting (Vue, Nuxt).

## Sources

- Harry Roberts: "CSS and Network Performance" (csswizardry.com, 2018)
- Harry Roberts: "Speeding Up Async Snippets" (csswizardry.com, 2022)
- Harry Roberts: ct.css (csswizardry.com/ct/)
- Rick Viscomi: capo.js (rviscomi.github.io/capo.js/)
- web.dev: "Don't Fight the Browser Preload Scanner" (2022)
