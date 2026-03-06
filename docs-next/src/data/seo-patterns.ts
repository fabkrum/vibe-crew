export interface SeoPattern {
  name: string;
  category: 'technical' | 'meta' | 'structured_data' | 'ai_discovery' | 'content' | 'sharing' | 'monitoring';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<SeoPattern['category'], string> = {
  technical: 'Technical SEO',
  meta: 'Meta Tags',
  structured_data: 'Structured Data',
  ai_discovery: 'AI Agent Discovery',
  content: 'Content SEO',
  sharing: 'Social & Sharing SEO',
  monitoring: 'Monitoring & Validation',
};

export const categoryOrder: SeoPattern['category'][] = [
  'technical', 'meta', 'structured_data', 'ai_discovery', 'content', 'sharing', 'monitoring',
];

export const seoPatterns: SeoPattern[] = [
  // --- Technical SEO ---
  {
    name: 'Canonical URL Tag',
    category: 'technical',
    description: 'A <link rel="canonical"> tag on every page that tells search engines and AI agents which URL is the authoritative version of that content. Self-referencing on unique pages, cross-domain for syndicated or republished content. Prevents duplicate content penalties when the same page is accessible via multiple URLs (www vs non-www, HTTP vs HTTPS, trailing slashes, query parameters).',
    implementation: 'Add <link rel="canonical" href="{absolute-url}"> in <head> on every page. Use the full absolute URL including protocol. For paginated content, each page gets its own canonical (not all pointing to page 1). For syndicated content, point canonical to the original source. Ensure canonical URL matches the URL in the sitemap. Trailing slash consistency: pick one and enforce everywhere. Dynamic pages: generate canonical from the clean URL, stripping tracking parameters (utm_*, fbclid, etc.).',
    a11y: 'Canonical tags are invisible metadata. No accessibility impact. They exist purely for search engine and AI agent consumption.',
    docsUrl: 'https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls',
  },
  {
    name: 'XML Sitemap',
    category: 'technical',
    description: 'An auto-generated XML sitemap listing all indexable pages with their last modification date, change frequency, and priority. Registered in robots.txt so crawlers find it automatically. Split into sub-sitemaps at 50,000 URLs. Helps search engines discover and prioritize pages, especially for large sites or pages not well-linked internally.',
    implementation: 'Generate at build time. Include only canonical, indexable URLs (no noindex pages, no redirects, no error pages). Set <lastmod> from the file\'s actual last modification date (git commit date or CMS modified timestamp). <changefreq> and <priority> are advisory but use them consistently: homepage priority="1.0", key landing pages priority="0.8", blog posts priority="0.6". Register in robots.txt: Sitemap: https://example.com/sitemap.xml. For large sites, create a sitemap index file pointing to sub-sitemaps of 50k URLs max.',
    a11y: 'XML sitemaps are machine-readable files. No user-facing component and no accessibility impact.',
    docsUrl: 'https://www.sitemaps.org/protocol.html',
  },
  {
    name: 'robots.txt',
    category: 'technical',
    description: 'A plain text file at the site root that controls which crawlers can access which parts of the site. Blocks admin pages, API endpoints, search result pages, and paginated archives from indexing. Includes the sitemap URL directive. Provides separate directives for AI crawlers (GPTBot, ClaudeBot, etc.) to control what AI models can access.',
    implementation: 'Place at /robots.txt (must be at root). Default: User-agent: * Allow: /. Block utility paths: Disallow: /api/, /admin/, /search?, /_next/. Add sitemap: Sitemap: https://example.com/sitemap.xml. For AI crawlers, add specific sections: User-agent: GPTBot Allow: / and User-agent: ClaudeBot Allow: /. Test with Google Search Console\'s robots.txt tester. Keep rules simple -- complex wildcards are error-prone. Never block CSS/JS files that search engines need to render pages.',
    a11y: 'robots.txt is a machine-readable file. No user-facing component and no accessibility impact.',
    docsUrl: 'https://developers.google.com/search/docs/crawling-indexing/robots/intro',
  },
  {
    name: 'Structured URL Hierarchy',
    category: 'technical',
    description: 'Clean, descriptive, hierarchical URLs that reflect the site structure. Uses /docs/getting-started not /page?id=42. Breadcrumb-aligned so the URL path matches the navigation hierarchy. Combined with 301 redirects for any changed URLs to preserve link equity and avoid broken links.',
    implementation: 'Use lowercase, hyphen-separated words: /blog/my-post-title. Keep URLs short (3-5 segments max). Avoid: IDs, query strings for content, file extensions (.html), underscores, uppercase. URL segments should match breadcrumb levels: /docs/guides/setup maps to Docs > Guides > Setup. Implement 301 redirects when URLs change (never 302 for permanent moves). Trailing slash: pick a convention (with or without) and redirect the other. For dynamic routes, generate slugs from titles at creation time.',
    a11y: 'Clean URLs benefit all users by being readable, memorable, and shareable. Screen readers announce URLs -- descriptive paths are easier to understand than opaque IDs.',
    docsUrl: null,
  },
  {
    name: 'Performance Signals',
    category: 'technical',
    description: 'Core Web Vitals optimization as a direct SEO ranking factor. LCP (Largest Contentful Paint) under 2.5 seconds, INP (Interaction to Next Paint) under 200 milliseconds, CLS (Cumulative Layout Shift) under 0.1. These metrics measure real user experience and Google uses them as ranking signals. Fast sites rank higher and convert better.',
    implementation: 'LCP: preload the hero image/font with <link rel="preload">, inline critical CSS, use responsive images with srcset. INP: defer non-critical JS with async/defer, break long tasks (>50ms) into smaller chunks, use requestIdleCallback for analytics. CLS: set explicit width/height on all images and embeds, use CSS aspect-ratio, reserve space for dynamic content (ads, lazy-loaded images). Compress images (WebP/AVIF). Enable HTTP/2. Use a CDN. Measure with Lighthouse CI in your build pipeline.',
    a11y: 'Performance directly impacts accessibility. Slow pages disproportionately affect users on older devices, slow connections, and assistive technologies. CLS prevention (explicit dimensions) also prevents content from jumping under screen readers.',
    docsUrl: 'https://web.dev/articles/vitals',
  },

  // --- Meta Tags ---
  {
    name: 'Open Graph Tags',
    category: 'meta',
    description: 'Open Graph meta tags that control how pages appear when shared on social platforms, messaging apps, and link previews. Every page needs og:title, og:description, og:image, og:url, og:type, and og:site_name. The OG image is the single most impactful tag -- a compelling 1200x630px image dramatically increases click-through rates on shared links.',
    implementation: 'Add to <head>: <meta property="og:title" content="{title}">, <meta property="og:description" content="{description}">, <meta property="og:image" content="{absolute-image-url}">, <meta property="og:url" content="{canonical-url}">, <meta property="og:type" content="website"> (or "article" for blog posts), <meta property="og:site_name" content="{Site Name}">. Image requirements: 1200x630px minimum, absolute URL, HTTPS. Every page gets unique OG tags -- never share the same title/description across pages. Fallback: set site-wide defaults that individual pages override.',
    a11y: 'OG tags are invisible metadata. No accessibility impact. They only affect how the page appears when shared externally.',
    docsUrl: 'https://ogp.me/',
  },
  {
    name: 'Twitter/X Card Tags',
    category: 'meta',
    description: 'Twitter Card meta tags that control how links appear in Twitter/X posts and DMs. While Twitter falls back to OG tags, explicit Twitter Card tags give finer control. The summary_large_image card type displays the largest preview image and consistently gets higher engagement than summary cards.',
    implementation: 'Add to <head>: <meta name="twitter:card" content="summary_large_image">, <meta name="twitter:title" content="{title}">, <meta name="twitter:description" content="{description}">, <meta name="twitter:image" content="{image-url}">, <meta name="twitter:site" content="@{handle}">. If OG tags are already set, you can omit twitter:title and twitter:description (Twitter falls back to OG). But always set twitter:card (no OG equivalent) and twitter:image (can differ from og:image for aspect ratio optimization). Validate with Twitter Card Validator before launching.',
    a11y: 'Twitter Card tags are invisible metadata. No accessibility impact.',
    docsUrl: 'https://developer.x.com/en/docs/x-for-websites/cards/overview/abouts-cards',
  },
  {
    name: 'Meta Description',
    category: 'meta',
    description: 'A unique 150-160 character description for each page that appears in search engine result snippets. Not a direct ranking factor, but strongly influences click-through rate. Action-oriented for landing pages ("Start building in minutes"), content-summarizing for articles ("Learn how to implement OAuth 2.0 with PKCE in a React SPA").',
    implementation: 'Add <meta name="description" content="{description}"> to <head>. Keep between 150-160 characters (Google truncates around 155-160). Make each description unique -- never duplicate across pages. Include the primary keyword naturally. For landing pages: lead with a benefit or call to action. For articles: summarize the key takeaway. For product pages: highlight the main value proposition. Never keyword-stuff. Generate programmatically from content excerpts where possible, with manual overrides for key pages.',
    a11y: 'Meta descriptions are invisible metadata. No accessibility impact. Screen readers do not read meta descriptions -- they read page content.',
    docsUrl: 'https://developers.google.com/search/docs/appearance/snippet',
  },
  {
    name: 'Meta Robots Directives',
    category: 'meta',
    description: 'Per-page robots directives that control whether search engines index a page and follow its links. Used to prevent indexing of utility pages (search results, pagination, admin panels, login pages) that would dilute search quality. The default is index, follow -- only add noindex for pages that should not appear in search results.',
    implementation: 'Add <meta name="robots" content="{directives}"> to <head>. Common directives: index, follow (default -- can be omitted), noindex (exclude from search results), nofollow (don\'t follow links on this page), noarchive (no cached copy). Apply noindex to: search result pages, paginated archives beyond page 1, login/register pages, admin pages, user-specific dashboards, thank-you/confirmation pages, URL parameter variations. Never noindex your homepage or key landing pages. For sections: use robots.txt to block crawling entirely (saves crawl budget).',
    a11y: 'Meta robots are invisible metadata. No accessibility impact.',
    docsUrl: 'https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag',
  },
  {
    name: 'Favicon & App Manifest',
    category: 'meta',
    description: 'Multi-size favicons and a web app manifest that establish brand identity across browser tabs, bookmarks, home screens, and app stores. Modern browsers support SVG favicons for crisp rendering at any size. The manifest enables "Add to Home Screen" and provides app metadata for search engines.',
    implementation: 'Provide favicons at key sizes: <link rel="icon" type="image/svg+xml" href="/favicon.svg"> (modern browsers), <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png"> (fallback), <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png"> (iOS). Create manifest.json: { "name": "{App}", "short_name": "{App}", "icons": [{src, sizes, type}], "theme_color": "#...", "background_color": "#...", "display": "standalone" }. Link it: <link rel="manifest" href="/manifest.json">. Include 192x192 and 512x512 PNG icons in the manifest for PWA support.',
    a11y: 'Favicons are visual brand indicators. No direct accessibility impact, but they help all users identify tabs. The manifest\'s theme_color should have sufficient contrast with white text for address bar readability.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/Manifest',
  },

  // --- Structured Data ---
  {
    name: 'JSON-LD WebSite Schema',
    category: 'structured_data',
    description: 'Site-level JSON-LD structured data using the Schema.org WebSite type. Placed on the homepage, it tells search engines and AI agents the site name, URL, and description. Including a SearchAction enables the sitelinks search box in Google results -- a prominent feature that lets users search your site directly from the SERP.',
    implementation: 'Add to homepage <head>: <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebSite","name":"{Site Name}","url":"https://example.com","description":"{description}","potentialAction":{"@type":"SearchAction","target":"https://example.com/search?q={search_term_string}","query-input":"required name=search_term_string"}}</script>. Only include SearchAction if you have a functional site search. Validate with Google Rich Results Test. Include the publisher (Organization) if applicable.',
    a11y: 'JSON-LD is invisible to users and screen readers. It is purely machine-readable metadata in a <script> tag.',
    docsUrl: 'https://schema.org/WebSite',
  },
  {
    name: 'BreadcrumbList Schema',
    category: 'structured_data',
    description: 'JSON-LD breadcrumb structured data on every interior page that matches the visible breadcrumb UI. Enhances search result display with a breadcrumb trail instead of the raw URL. Helps search engines understand site hierarchy and improves click-through rates by showing the content path.',
    implementation: 'Add JSON-LD on every interior page: {"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Home","item":"https://example.com"},{"@type":"ListItem","position":2,"name":"Docs","item":"https://example.com/docs"},{"@type":"ListItem","position":3,"name":"Setup"}]}. The last item (current page) omits the "item" URL. Position starts at 1. Names should match the visible breadcrumb text. Generate automatically from the URL structure or navigation data.',
    a11y: 'JSON-LD breadcrumbs are invisible metadata. The visible breadcrumb UI should use <nav aria-label="Breadcrumb"> with an <ol> for proper screen reader support -- the structured data is a separate concern.',
    docsUrl: 'https://schema.org/BreadcrumbList',
  },
  {
    name: 'Article Schema',
    category: 'structured_data',
    description: 'JSON-LD Article or TechArticle structured data for blog posts and documentation pages. Enables rich snippets in search results with headline, author, publish date, and image. The dateModified field is particularly valuable -- it signals content freshness to search engines and AI agents, which both prefer up-to-date content.',
    implementation: 'Add to blog/doc pages: {"@context":"https://schema.org","@type":"TechArticle","headline":"{title}","datePublished":"{ISO-date}","dateModified":"{ISO-date}","author":{"@type":"Person","name":"{name}","url":"{profile-url}"},"publisher":{"@type":"Organization","name":"{org}","logo":{"@type":"ImageObject","url":"{logo-url}"}},"image":"{featured-image-url}","description":"{excerpt}"}. Use TechArticle for technical docs, Article for general blog posts. dateModified should reflect actual content changes (not redeploys). Generate from git commit dates or CMS timestamps.',
    a11y: 'JSON-LD Article schema is invisible metadata. The visible article should use semantic HTML: <article>, <header>, <time datetime="...">, <address> for author.',
    docsUrl: 'https://schema.org/TechArticle',
  },
  {
    name: 'SoftwareApplication Schema',
    category: 'structured_data',
    description: 'JSON-LD SoftwareApplication structured data for product and download pages. Enables software rich snippets in search results showing the app name, category, operating system, price, and rating. Particularly valuable for developer tools, SaaS products, and open-source projects.',
    implementation: 'Add to product/landing page: {"@context":"https://schema.org","@type":"SoftwareApplication","name":"{App Name}","applicationCategory":"DeveloperApplication","operatingSystem":"Any","offers":{"@type":"Offer","price":"0","priceCurrency":"USD"},"description":"{description}","url":"{landing-page-url}"}. For paid software, set the correct price. For freemium, use the free tier price. Add aggregateRating if you have verified ratings. applicationCategory values: DeveloperApplication, BusinessApplication, WebApplication, etc. Validate with Google Rich Results Test.',
    a11y: 'JSON-LD is invisible metadata. No accessibility impact.',
    docsUrl: 'https://schema.org/SoftwareApplication',
  },
  {
    name: 'FAQ Schema',
    category: 'structured_data',
    description: 'JSON-LD FAQPage structured data for pages with question-and-answer content. Enables FAQ rich results in Google -- expandable Q&A pairs directly in the search results that dramatically increase SERP real estate and click-through rates. Works for dedicated FAQ pages and for any page with an expandable Q&A section.',
    implementation: 'Add to pages with Q&A content: {"@context":"https://schema.org","@type":"FAQPage","mainEntity":[{"@type":"Question","name":"{question}","acceptedAnswer":{"@type":"Answer","text":"{answer}"}}]}. Each question-answer pair is a mainEntity item. The answer text can include HTML (links, lists). Limit to 10-15 questions per page for best results. Questions should match the visible page content exactly. Do not mark up content that is not visually present as Q&A. Google may show 2-4 FAQ results for your page.',
    a11y: 'JSON-LD FAQ schema is invisible metadata. The visible FAQ section should use proper disclosure/accordion patterns: <details>/<summary> or buttons with aria-expanded.',
    docsUrl: 'https://schema.org/FAQPage',
  },
  {
    name: 'HowTo Schema',
    category: 'structured_data',
    description: 'JSON-LD HowTo structured data for tutorial and step-by-step guide pages. Enables how-to rich results in Google with step previews, images, and time estimates. Ideal for setup guides, getting-started tutorials, and recipe-style content where the content naturally follows sequential steps.',
    implementation: 'Add to tutorial/guide pages: {"@context":"https://schema.org","@type":"HowTo","name":"{title}","description":"{summary}","step":[{"@type":"HowToStep","name":"{step title}","text":"{step description}","image":"{step-image-url}","url":"{page-url}#step-1"}]}. Include estimatedCost and totalTime if applicable. Each step\'s url should deep-link to the corresponding section on the page using anchor IDs. Steps should match the visible content. Add tool and supply items if the guide requires specific prerequisites.',
    a11y: 'JSON-LD HowTo is invisible metadata. The visible tutorial should use an <ol> (ordered list) for sequential steps, with descriptive headings for each step.',
    docsUrl: 'https://schema.org/HowTo',
  },

  // --- AI Agent Discovery ---
  {
    name: 'llms.txt',
    category: 'ai_discovery',
    description: 'A root-level /llms.txt file following the llmstxt.org specification. It is the first file AI agents and LLM-powered tools look for when trying to understand a website. Contains a concise markdown summary: project name, what it does, key capabilities, and links to important pages. Think of it as robots.txt for AI agents -- a machine-readable site introduction.',
    implementation: 'Create a plain text file at /llms.txt (public root). Format as markdown following the spec: start with # {Project Name}, then a one-paragraph description, then ## Key Links with the most important pages (docs, API reference, getting started). Keep it concise -- under 500 lines. Focus on what an AI agent needs to answer user questions about your product. Update on each deploy. Include version/date. Link to llms-full.txt for comprehensive content. Do not include marketing fluff -- AI agents need facts.',
    a11y: 'llms.txt is a machine-readable file. No user-facing component and no accessibility impact.',
    docsUrl: 'https://llmstxt.org/',
  },
  {
    name: 'llms-full.txt',
    category: 'ai_discovery',
    description: 'A comprehensive /llms-full.txt file that flattens all documentation into a single markdown document. Enables full-context ingestion by AI models that support large context windows. Auto-generated at build time by concatenating and converting all documentation pages. The counterpart to the concise llms.txt -- where llms.txt is the summary, llms-full.txt is the complete reference.',
    implementation: 'Build script: iterate all documentation pages, convert HTML to markdown (using a library like turndown or html-to-text), concatenate with ## headers separating pages. Include a table of contents at the top. Strip navigation chrome, sidebars, and repeated elements (headers/footers). Order pages logically (getting started first, reference last). Keep under 100k tokens if possible (most LLMs handle this well). Regenerate on every build. Add a generation timestamp at the top.',
    a11y: 'llms-full.txt is a machine-readable file. No user-facing component and no accessibility impact.',
    docsUrl: 'https://llmstxt.org/',
  },
  {
    name: 'AI-Friendly Content Structure',
    category: 'ai_discovery',
    description: 'Content organized for optimal extraction by AI agents: clear heading hierarchy (single H1, logical H2-H4), summary or TLDR at the top of long pages, code blocks with language tags, tables for structured comparisons instead of prose. AI agents parse content by headings and code blocks -- well-structured pages get more accurate citations and answers.',
    implementation: 'Every page: single <h1> matching the title, logical <h2>-<h4> nesting with no skipped levels. Long pages (>1000 words): add a TLDR or summary section after the H1. Code blocks: always include the language tag (```typescript, ```bash). Data comparisons: use tables instead of bullet lists when comparing features, options, or configurations. Definitions: use <dl>/<dt>/<dd> for glossary-style content. Anchor IDs on all headings for deep linking. Key facts in the first paragraph (inverted pyramid structure).',
    a11y: 'AI-friendly structure is also accessibility-friendly. Clear heading hierarchy is a WCAG 2.1 requirement. Proper code blocks, tables, and definition lists all improve screen reader navigation. This pattern is a convergence of SEO, AI, and accessibility best practices.',
    docsUrl: null,
  },
  {
    name: 'robots.txt AI Bot Directives',
    category: 'ai_discovery',
    description: 'Explicit allow/disallow rules in robots.txt for known AI crawler user agents: GPTBot (OpenAI), ClaudeBot (Anthropic), Applebot-Extended (Apple Intelligence), Google-Extended (Gemini training), Bytespider (TikTok), CCBot (Common Crawl). Gives site owners granular control over which AI models can access their content for training versus inference.',
    implementation: 'Add separate User-agent blocks for each AI bot: User-agent: GPTBot / Allow: /docs/ / Disallow: /api/. Common AI bots to configure: GPTBot, ChatGPT-User, ClaudeBot, Google-Extended, Applebot-Extended, Bytespider, CCBot, PerplexityBot, cohere-ai. Distinguish between training bots (Google-Extended trains Gemini) and inference bots (ChatGPT-User serves live answers). Allow inference bots for discoverability, consider blocking training bots if you want to protect content from model training. Test that bots respect your rules by monitoring access logs.',
    a11y: 'robots.txt is a machine-readable file. No user-facing component and no accessibility impact.',
    docsUrl: 'https://platform.openai.com/docs/bots',
  },
  {
    name: 'Semantic HTML for Extraction',
    category: 'ai_discovery',
    description: 'HTML landmark elements (<article>, <nav>, <main>, <aside>, <header>, <footer>) and semantic tags (<time datetime>, <code>, <abbr>, <cite>) that help AI agents extract structured information from pages. AI models use these landmarks to identify the main content versus navigation, sidebars, and boilerplate. Pages with strong semantic HTML get more precise AI-generated answers.',
    implementation: 'Every page: <main> wrapping the primary content, <header> for site header, <footer> for site footer, <nav> for navigation sections. Content pages: <article> wrapping each distinct piece of content. Sidebar: <aside>. Dates: <time datetime="2024-01-15">January 15, 2024</time>. Code: <code> for inline, <pre><code> for blocks. Abbreviations: <abbr title="Search Engine Optimization">SEO</abbr>. Citations: <cite>. Do not use <div> and <span> where a semantic element exists. These landmarks also directly improve screen reader navigation.',
    a11y: 'Semantic HTML is the foundation of web accessibility. <main>, <nav>, <header>, <footer> create landmark regions that screen readers use for navigation. <time> provides machine-readable dates. This pattern is equally an accessibility pattern and an AI discoverability pattern.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Element',
  },

  // --- Content SEO ---
  {
    name: 'Heading Hierarchy',
    category: 'content',
    description: 'A single <h1> per page matching the title tag, with logical <h2> through <h4> nesting and no skipped levels. Headings describe content, not style -- "Getting Started" not "Big Blue Text". Search engines weight heading content heavily for relevance. Screen readers and AI agents both navigate by heading structure, making this a convergence point of SEO, accessibility, and AI discoverability.',
    implementation: 'One <h1> per page, matching (or closely matching) the <title> tag content. <h2> for major sections, <h3> for subsections, <h4> for sub-subsections. Never skip levels (h2 directly to h4). Never use headings for styling -- use CSS classes instead. Keep headings concise and descriptive. Include relevant keywords naturally (not forced). For SPA/dynamic content: ensure the heading hierarchy is correct in the rendered DOM, not just the source template.',
    a11y: 'Heading hierarchy is a WCAG 2.1 Level A requirement (1.3.1 Info and Relationships). Screen reader users navigate by headings (the "H" shortcut). Skipped levels create confusing navigation. Single H1 clearly identifies the page topic. This is non-negotiable for accessible content.',
    docsUrl: null,
  },
  {
    name: 'Internal Linking Strategy',
    category: 'content',
    description: 'Contextual links between related pages in a hub-and-spoke topology. Pillar pages (hubs) link to detailed pages (spokes) and vice versa. Descriptive anchor text ("OAuth 2.0 implementation guide" not "click here") helps both crawlers and AI agents understand content relationships. Strong internal linking distributes page authority and keeps users engaged longer.',
    implementation: 'Every page should link to 3-5 related pages within the body content (not just navigation). Use descriptive anchor text that describes the destination. Hub pages (guides, overviews) link to all related detail pages. Detail pages link back to their hub and to sibling pages. Avoid orphan pages (pages with no internal links pointing to them). Add "Related pages" sections at the bottom of articles. For large sites, use a topic cluster model: one pillar page per major topic with spoke pages for subtopics.',
    a11y: 'Descriptive anchor text is a WCAG 2.1 Level A requirement (2.4.4 Link Purpose). "Click here" and "read more" are inaccessible -- screen reader users often navigate by link list and need descriptive text. This SEO best practice is also an accessibility requirement.',
    docsUrl: null,
  },
  {
    name: 'Image SEO',
    category: 'content',
    description: 'Descriptive alt text, lazy loading for below-fold images, explicit width/height attributes for CLS prevention, modern formats (WebP/AVIF), and descriptive filenames. Images are a major search traffic source via Google Images. Proper image SEO also directly supports accessibility (alt text) and performance (lazy loading, compression).',
    implementation: 'Alt text: describe the image content and function, not "image of..." (e.g., "Dashboard showing real-time analytics with 3 charts"). Filenames: use descriptive names (analytics-dashboard.webp not IMG_4523.webp). Dimensions: always include width and height attributes to prevent CLS. Loading: loading="lazy" on all images below the fold, eager (default) for above-fold hero images. Format: serve WebP or AVIF with <picture> fallback to JPEG/PNG. Use srcset and sizes for responsive images. Compress aggressively (quality 80 for photos).',
    a11y: 'Alt text is a WCAG 2.1 Level A requirement (1.1.1 Non-text Content). Every informative <img> must have descriptive alt text. Decorative images: alt="". Charts/diagrams: provide a text description or data table alternative. This is the strongest convergence of SEO and accessibility.',
    docsUrl: null,
  },
  {
    name: 'Anchor-Based Deep Linking',
    category: 'content',
    description: 'Meaningful id attributes on sections, patterns, and key content blocks that enable direct linking to specific content. AI agents and search engines can reference specific sections of a page. Users can share links to exact content. Combined with a visible anchor link icon on hover, this encourages citation and improves the granularity of search results.',
    implementation: 'Add id attributes to all <h2>, <h3>, and <h4> headings: <h2 id="getting-started">. Generate IDs from heading text (lowercase, hyphenated). Show a hover-visible link icon (# or chain icon) next to headings that copies or navigates to the anchor URL. Ensure IDs are unique within the page. For pattern pages or reference content, add IDs to individual items (not just headings). Use the anchor in BreadcrumbList and HowTo schema URLs for deep linking from structured data.',
    a11y: 'Anchor links improve navigation for all users. The hover link icon should be keyboard-accessible (visible on focus, not just hover). Anchor IDs should not conflict with ARIA IDs. Skip link (#main-content) is a related accessibility pattern.',
    docsUrl: null,
  },

  // --- Social & Sharing SEO ---
  {
    name: 'OG Image Generation',
    category: 'sharing',
    description: 'Dynamic or template-based OG images generated per page so every shared link has a unique, branded preview image. The OG image is the highest-impact meta tag for social sharing -- posts with custom images get 2-3x more engagement than those with generic or missing previews. Template-based generation ensures consistency while scaling to hundreds of pages.',
    implementation: 'Option A (build-time): Use satori (@vercel/og) to generate images from an HTML/CSS template at build time. Template: page title in large text, site logo, brand colors, optional category tag. Output: 1200x630px PNG. Generate one per page and reference the static file in og:image. Option B (static): design a reusable template in Figma, export variants for key pages, use a single default for others. Always use absolute HTTPS URLs for og:image. Test with Facebook Sharing Debugger and Twitter Card Validator.',
    a11y: 'OG images are only displayed on external platforms (social media, messaging). They have no direct accessibility impact on your site. However, the og:image alt text equivalent is the og:title and og:description -- ensure those are descriptive.',
    docsUrl: null,
  },
  {
    name: 'Share URL Hygiene',
    category: 'sharing',
    description: 'Clean canonical URLs in all share metadata, free of tracking parameters, session IDs, and internal state. UTM parameters for campaign tracking are added client-side at the moment of sharing, never baked into the canonical URL or OG tags. Ensures consistent URL identity across shares and prevents duplicate content from parameter variations.',
    implementation: 'Canonical URL and og:url must always be the clean URL (no query parameters). When generating share links (Static Share Links pattern), use the canonical URL as the base. Add UTM parameters client-side: ?utm_source={platform}&utm_medium=social&utm_campaign={campaign}. Strip existing tracking params (fbclid, gclid, mc_cid) before constructing share URLs. Never include session IDs, auth tokens, or user-specific parameters in share URLs. Test: shared URL should resolve to the same content for any user.',
    a11y: 'Share URL hygiene has no direct accessibility impact. It is a data cleanliness concern for analytics and SEO.',
    docsUrl: null,
  },
  {
    name: 'Rich Link Preview Testing',
    category: 'sharing',
    description: 'Systematic validation that OG tags and Twitter Cards render correctly across platforms before publishing. Uses platform debugger tools to preview exactly how shared links will appear. Catches missing images, truncated titles, wrong descriptions, and broken URLs before they reach your audience. Should be part of the pre-launch and content publishing checklist.',
    implementation: 'Test with: Facebook Sharing Debugger (developers.facebook.com/tools/debug/), Twitter Card Validator (cards-dev.twitter.com/validator), LinkedIn Post Inspector (linkedin.com/post-inspector/). Clear platform caches after updating OG tags (Facebook: "Scrape Again" button). Automate: add OG tag validation to your CI pipeline (validate required properties exist, image URL resolves, dimensions are correct). For content sites: test a sample page from each template type. Common issues: relative image URLs (must be absolute), HTTP images (must be HTTPS), images too small (<200px).',
    a11y: 'Link preview testing has no direct accessibility impact on your site. It ensures shared content is presented correctly on external platforms.',
    docsUrl: null,
  },

  // --- Monitoring & Validation ---
  {
    name: 'Structured Data Validation',
    category: 'monitoring',
    description: 'Automated testing of JSON-LD structured data at build time to catch syntax errors, missing required properties, and deprecated schema types before they reach production. Invalid structured data silently fails -- search engines ignore it without warning, and you lose rich results until someone manually checks. Build-time validation makes this a non-issue.',
    implementation: 'Add to CI pipeline: parse all JSON-LD blocks, validate syntax (valid JSON), validate against Schema.org types (required properties present, correct types). Use Google Rich Results Test API for automated validation. Check: no duplicate schema types on the same page, all URLs are absolute HTTPS, dates are ISO 8601 format, image URLs resolve. For development: add a browser extension or dev-mode overlay that highlights JSON-LD on the page. Run schema validation as a build step that fails on errors.',
    a11y: 'Structured data validation is a build/CI concern. No direct accessibility impact, but some schema types (FAQ, HowTo) should have corresponding accessible visible content.',
    docsUrl: 'https://search.google.com/test/rich-results',
  },
  {
    name: 'Search Console Integration',
    category: 'monitoring',
    description: 'Google Search Console verification and ongoing monitoring for indexing status, coverage errors, Core Web Vitals, and search performance data. The primary feedback loop for understanding how Google sees your site. Alerts you to crawl errors, security issues, manual actions, and indexing problems before they impact traffic.',
    implementation: 'Verify ownership via meta tag (<meta name="google-site-verification" content="{code}">) or DNS TXT record. Submit your sitemap. Monitor weekly: Index Coverage (errors, excluded pages, valid pages), Performance (impressions, clicks, CTR, average position), Core Web Vitals (LCP, INP, CLS), and Enhancements (structured data errors). Set up email alerts for critical issues. Fix crawl errors promptly (404s, server errors, redirect loops). Use the URL Inspection tool to debug individual page indexing. For multi-site: use Bing Webmaster Tools as a secondary signal.',
    a11y: 'Search Console is an external monitoring tool. No direct accessibility impact on your site.',
    docsUrl: 'https://search.google.com/search-console/about',
  },
];
