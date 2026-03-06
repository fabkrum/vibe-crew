# SEO & AI Discoverability Pattern Reference

Agent-facing reference for search engine optimization and AI agent discoverability. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Make content discoverable by both search engines and AI agents. Structured data serves both audiences. Prioritize standards-based approaches. Semantic HTML benefits crawlers, AI agents, and screen readers equally.

## 1. Technical SEO

### Canonical URL Tag
- **When:** Every page. Non-negotiable baseline.
- **What:** `<link rel="canonical" href="{absolute-url}">` in `<head>`. Self-referencing for unique pages, cross-domain for syndicated content. Full absolute URL with protocol. Strip tracking params (utm_*, fbclid, etc.).
- **A11y:** Invisible metadata. No accessibility impact.
- **Anti-pattern:** Never use relative URLs. Never point all paginated pages to page 1. Never omit canonical on pages accessible via multiple URLs.

### XML Sitemap
- **When:** Every site with more than a handful of pages.
- **What:** Auto-generated at build time. Include only canonical, indexable URLs. `<lastmod>` from actual modification date. Register in robots.txt: `Sitemap: https://example.com/sitemap.xml`. Split at 50k URLs.
- **A11y:** Machine-readable file. No user-facing component.
- **Anti-pattern:** Never include noindex pages, redirects, or error pages in the sitemap. Never set fake lastmod dates.

### robots.txt
- **When:** Every site.
- **What:** `/robots.txt` at root. Default: `User-agent: * Allow: /`. Block: `/api/`, `/admin/`, `/search?`, `/_next/`. Sitemap directive. Separate AI bot sections (GPTBot, ClaudeBot).
- **A11y:** Machine-readable file. No user-facing component.
- **Anti-pattern:** Never block CSS/JS files needed for rendering. Never use complex wildcards. Never rely on robots.txt for security (it's advisory, not enforcement).

### Structured URL Hierarchy
- **When:** Site architecture and routing decisions.
- **What:** Lowercase, hyphen-separated: `/docs/guides/setup`. 3-5 segments max. Match breadcrumb levels. 301 redirects for changed URLs. Consistent trailing slash convention.
- **A11y:** Clean URLs benefit screen readers (they announce URLs). Descriptive paths > opaque IDs.
- **Anti-pattern:** Never use IDs, query strings for content, file extensions, underscores, or uppercase in URLs. Never 302 redirect permanent URL changes.

### Performance Signals
- **When:** Every page. Direct ranking factor.
- **What:** LCP < 2.5s (preload hero image, inline critical CSS). INP < 200ms (defer non-critical JS, break long tasks). CLS < 0.1 (explicit width/height on images/embeds, CSS aspect-ratio). WebP/AVIF images. HTTP/2. CDN.
- **A11y:** Performance directly impacts accessibility. Slow pages disproportionately affect assistive technology users. CLS prevention prevents content jumping under screen readers.
- **Anti-pattern:** Never load render-blocking scripts above the fold. Never omit image dimensions. Never lazy-load above-fold content.

## 2. Meta Tags

### Open Graph Tags
- **When:** Every public page.
- **What:** `og:title`, `og:description`, `og:image` (1200x630px, absolute HTTPS URL), `og:url` (canonical), `og:type` ("website" or "article"), `og:site_name`. Unique per page. Site-wide defaults as fallback.
- **A11y:** Invisible metadata. No accessibility impact.
- **Anti-pattern:** Never share identical OG tags across pages. Never use relative image URLs. Never omit og:image (it's the highest-impact tag).

### Twitter/X Card Tags
- **When:** Every public page (if Twitter/X sharing matters).
- **What:** `twitter:card` ("summary_large_image"), `twitter:title`, `twitter:description`, `twitter:image`, `twitter:site` ("@handle"). Always set `twitter:card` (no OG equivalent). Falls back to OG for title/description.
- **A11y:** Invisible metadata. No accessibility impact.
- **Anti-pattern:** Never omit twitter:card. Never assume OG fallback covers everything.

### Meta Description
- **When:** Every public page.
- **What:** `<meta name="description" content="...">`. 150-160 characters. Unique per page. Action-oriented for landing pages, content-summarizing for articles. Include primary keyword naturally.
- **A11y:** Invisible metadata. Screen readers don't read meta descriptions.
- **Anti-pattern:** Never duplicate descriptions across pages. Never keyword-stuff. Never exceed 160 characters.

### Meta Robots Directives
- **When:** Utility pages that should not appear in search results.
- **What:** `<meta name="robots" content="noindex">` on: search result pages, paginated archives (page 2+), login/register, admin, dashboards, thank-you pages. Default (omittable): `index, follow`.
- **A11y:** Invisible metadata. No accessibility impact.
- **Anti-pattern:** Never noindex your homepage or key landing pages. Never use noindex as a substitute for proper URL management.

### Favicon & App Manifest
- **When:** Every site.
- **What:** SVG favicon (modern browsers), 32x32 PNG (fallback), 180x180 Apple touch icon. `manifest.json` with name, icons (192x192, 512x512), theme_color, background_color. Link both in `<head>`.
- **A11y:** Visual brand indicator. Manifest theme_color should contrast with white text.
- **Anti-pattern:** Never omit the PNG fallback. Never use only one favicon size.

## 3. Structured Data

### JSON-LD WebSite Schema
- **When:** Homepage.
- **What:** `{"@type":"WebSite","name":"...","url":"...","description":"...","potentialAction":{"@type":"SearchAction","target":"...?q={search_term_string}","query-input":"required name=search_term_string"}}`. Only include SearchAction if site search exists. Validate with Rich Results Test.
- **A11y:** Invisible machine-readable metadata.
- **Anti-pattern:** Never add SearchAction without a working site search. Never place WebSite schema on every page (homepage only).

### BreadcrumbList Schema
- **When:** Every interior page with visible breadcrumbs.
- **What:** JSON-LD with position, name, item (URL) for each level. Last item omits URL. Names match visible breadcrumb text. Generate from navigation data.
- **A11y:** JSON-LD is separate from visible breadcrumb. Visible: `<nav aria-label="Breadcrumb">` with `<ol>`.
- **Anti-pattern:** Never mismatch JSON-LD breadcrumbs with visible breadcrumb UI. Never start position at 0 (starts at 1).

### Article/TechArticle Schema
- **When:** Blog posts, documentation pages.
- **What:** `headline`, `datePublished`, `dateModified` (ISO 8601, from actual content changes), `author` (Person with URL), `publisher` (Organization with logo), `image`, `description`. Use TechArticle for technical content.
- **A11y:** Visible article: `<article>`, `<header>`, `<time datetime="...">`, `<address>`.
- **Anti-pattern:** Never set dateModified to deploy date (use actual content modification). Never omit author attribution.

### SoftwareApplication Schema
- **When:** Product pages, download pages, landing pages for developer tools.
- **What:** `name`, `applicationCategory` ("DeveloperApplication"), `operatingSystem`, `offers` (price), `description`, `url`. Add `aggregateRating` if verified ratings exist.
- **A11y:** Invisible metadata.
- **Anti-pattern:** Never add fake ratings. Never omit price/offers information.

### FAQ Schema
- **When:** FAQ pages, pages with expandable Q&A sections.
- **What:** `FAQPage` with `Question` + `acceptedAnswer` pairs. Answer text can include HTML. Limit 10-15 questions. Questions must match visible page content.
- **A11y:** Visible FAQ: `<details>`/`<summary>` or buttons with `aria-expanded`.
- **Anti-pattern:** Never mark up invisible content as FAQ. Never add FAQ schema to pages without visible Q&A.

### HowTo Schema
- **When:** Tutorial pages, step-by-step guides, getting-started docs.
- **What:** Steps with name, text, image, URL (anchor to section). Include totalTime if applicable. Steps match visible content.
- **A11y:** Visible tutorial: `<ol>` for sequential steps.
- **Anti-pattern:** Never create HowTo schema for content that isn't sequential steps. Never omit step anchors.

## 4. AI Agent Discovery

### llms.txt
- **When:** Every site with public documentation or content.
- **What:** `/llms.txt` at root. Markdown format: `# Project Name`, one-paragraph description, `## Key Links` with important pages. Under 500 lines. Facts, not marketing. Link to llms-full.txt.
- **A11y:** Machine-readable file. No user-facing component.
- **Anti-pattern:** Never include marketing fluff. Never make it too long (AI agents need concise summaries). Never forget to update on deploy.

### llms-full.txt
- **When:** Sites with extensive documentation.
- **What:** `/llms-full.txt` — build-time concatenation of all docs as markdown. Table of contents at top. Strip nav chrome. Logical page order. Under 100k tokens. Generation timestamp.
- **A11y:** Machine-readable file. No user-facing component.
- **Anti-pattern:** Never include navigation/header/footer boilerplate. Never generate manually (automate at build time).

### AI-Friendly Content Structure
- **When:** Every content page.
- **What:** Single H1 matching title. Logical H2-H4 nesting. TLDR/summary after H1 on long pages. Code blocks with language tags. Tables for comparisons. `<dl>` for definitions. Anchor IDs on all headings. Key facts in first paragraph.
- **A11y:** AI-friendly structure IS accessibility-friendly. Clear heading hierarchy is WCAG 2.1 requirement.
- **Anti-pattern:** Never skip heading levels. Never use headings for styling. Never write prose where a table or code block is clearer.

### robots.txt AI Bot Directives
- **When:** Any site wanting to control AI crawler access.
- **What:** Separate `User-agent` blocks: GPTBot, ChatGPT-User, ClaudeBot, Google-Extended, Applebot-Extended, Bytespider, CCBot, PerplexityBot. Distinguish inference bots (allow for discoverability) from training bots (consider blocking).
- **A11y:** Machine-readable file. No user-facing component.
- **Anti-pattern:** Never block all AI bots without understanding the distinction between inference and training. Never assume all bots respect robots.txt.

### Semantic HTML for Extraction
- **When:** Every page.
- **What:** `<main>`, `<header>`, `<footer>`, `<nav>`, `<article>`, `<aside>` landmarks. `<time datetime="...">` for dates. `<code>` for code. `<abbr title="...">` for abbreviations. `<cite>` for citations. No `<div>`/`<span>` where semantic elements exist.
- **A11y:** Semantic HTML IS the foundation of web accessibility. Landmarks create screen reader navigation regions. This is equally an a11y and AI pattern.
- **Anti-pattern:** Never use div soup. Never omit `<main>`. Never use `<section>` without a heading.

## 5. Content SEO

### Heading Hierarchy
- **When:** Every page.
- **What:** Single `<h1>` matching `<title>`. `<h2>` for sections, `<h3>` for subsections. No skipped levels. Descriptive text, not styling. Include keywords naturally.
- **A11y:** WCAG 2.1 Level A (1.3.1). Screen reader users navigate by headings. Non-negotiable.
- **Anti-pattern:** Never have multiple H1s. Never skip levels (h2 to h4). Never use headings for font size.

### Internal Linking Strategy
- **When:** Every page should link to 3-5 related pages.
- **What:** Contextual links with descriptive anchor text. Hub-and-spoke topology. No orphan pages. "Related pages" sections. Topic cluster model for large sites.
- **A11y:** WCAG 2.1 Level A (2.4.4). "Click here" is inaccessible. Descriptive anchor text required.
- **Anti-pattern:** Never use "click here" or "read more" as anchor text. Never create orphan pages. Never link only from navigation.

### Image SEO
- **When:** Every page with images.
- **What:** Descriptive alt text (content and function). Descriptive filenames. `width`/`height` attributes. `loading="lazy"` below fold. WebP/AVIF with fallback. `srcset`/`sizes` for responsive. Quality 80 for photos.
- **A11y:** WCAG 2.1 Level A (1.1.1). Alt text is non-negotiable. Decorative images: `alt=""`. Charts: text alternative required.
- **Anti-pattern:** Never omit alt text on informative images. Never keyword-stuff alt text. Never omit width/height (causes CLS). Never lazy-load above-fold images.

### Anchor-Based Deep Linking
- **When:** All content pages with sections or reference items.
- **What:** `id` on all H2-H4 headings (lowercase, hyphenated from text). Hover-visible link icon. Unique IDs per page. Use in schema URLs for deep linking.
- **A11y:** Hover link icon should be keyboard-accessible (visible on focus). Anchor IDs must not conflict with ARIA IDs.
- **Anti-pattern:** Never use auto-generated opaque IDs. Never duplicate IDs on a page.

## 6. Social & Sharing SEO

### OG Image Generation
- **When:** Every page that may be shared on social media.
- **What:** 1200x630px per-page images. Template: title + logo + brand colors. Build-time generation with satori/@vercel/og or static design. Absolute HTTPS URLs. Test with Facebook Sharing Debugger.
- **A11y:** External-only (social platforms). og:title and og:description serve as the text alternative.
- **Anti-pattern:** Never use a single generic OG image for all pages. Never use relative or HTTP URLs.

### Share URL Hygiene
- **When:** All share metadata and share button implementations.
- **What:** Canonical URL and og:url are always clean (no query params). UTM params added client-side at share time. Strip fbclid, gclid, session IDs before sharing. Shared URL should work for any user.
- **A11y:** No direct accessibility impact.
- **Anti-pattern:** Never bake UTM params into canonical URLs. Never include session IDs or auth tokens in share URLs.

### Rich Link Preview Testing
- **When:** Before launch. Before publishing key content.
- **What:** Test with Facebook Sharing Debugger, Twitter Card Validator, LinkedIn Post Inspector. Clear platform caches after OG updates. Automate in CI (validate required properties, image resolution, HTTPS). Test each page template type.
- **A11y:** No direct accessibility impact on your site.
- **Anti-pattern:** Never launch without testing link previews. Never forget to clear platform caches after updates.

## 7. Monitoring & Validation

### Structured Data Validation
- **When:** Build pipeline. CI/CD.
- **What:** Parse JSON-LD, validate syntax, check required properties per schema type. Use Rich Results Test API. Check: no duplicate schemas per page, absolute HTTPS URLs, ISO 8601 dates, image URLs resolve. Fail build on errors.
- **A11y:** Build concern. FAQ and HowTo schemas should have corresponding accessible visible content.
- **Anti-pattern:** Never deploy invalid JSON-LD. Never skip build-time validation (errors are silent in production).

### Search Console Integration
- **When:** Every production site.
- **What:** Google Search Console verification (meta tag or DNS). Submit sitemap. Monitor: Index Coverage, Performance, Core Web Vitals, Enhancements. Email alerts for critical issues. Fix crawl errors promptly. URL Inspection for individual pages.
- **A11y:** External monitoring tool. No direct accessibility impact.
- **Anti-pattern:** Never ignore coverage errors. Never skip sitemap submission. Never ignore Core Web Vitals warnings.
