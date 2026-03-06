export interface HeadOrderPattern {
  name: string;
  category: 'pragma' | 'critical' | 'hints' | 'anti_patterns' | 'seo_social' | 'tooling';
  description: string;
  implementation: string;
  impact: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<HeadOrderPattern['category'], string> = {
  pragma: 'Pragma Directives',
  critical: 'Critical Rendering Resources',
  hints: 'Resource Hints & Optimization',
  anti_patterns: 'Anti-Patterns',
  seo_social: 'SEO & Social Meta',
  tooling: 'Validation & Tooling',
};

export const categoryOrder: HeadOrderPattern['category'][] = [
  'pragma', 'critical', 'hints', 'anti_patterns', 'seo_social', 'tooling',
];

export const headOrderPatterns: HeadOrderPattern[] = [
  // --- Pragma Directives (Weight 10 — must be first) ---
  {
    name: 'Charset Declaration',
    category: 'pragma',
    description: 'The <meta charset="utf-8"> tag must appear as early as possible in the <head> — ideally as the very first element. The HTML specification requires that the character encoding declaration appear within the first 1024 bytes of the document. If the browser encounters content before knowing the encoding, it may speculatively parse with the wrong encoding and then re-parse the entire document when it discovers the charset, wasting time and causing visual flashes.',
    implementation: 'Place <meta charset="utf-8"> as the first child of <head>, before any other element including <title>. Use the short form (charset attribute) rather than the legacy <meta http-equiv="Content-Type" content="text/html; charset=utf-8">. The short form is 22 bytes vs 74 bytes — fewer bytes before the parser knows the encoding. Never place comments, whitespace-heavy markup, or other tags before charset.',
    impact: 'A late charset declaration forces the browser to re-parse the entire document from the beginning when it finally discovers the encoding. This can add 100-500ms of wasted parsing time depending on document size. ct.css flags charset that appears after the 5th child element in <head> as a warning.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta#charset',
  },
  {
    name: 'Viewport Meta',
    category: 'pragma',
    description: 'The <meta name="viewport" content="width=device-width, initial-scale=1"> tag tells the browser how to scale and size the viewport on mobile devices. Without it, mobile browsers render at a desktop width (typically 980px) and then shrink everything down. This must appear very early in the <head> because layout calculations depend on knowing the viewport dimensions.',
    implementation: 'Place immediately after <meta charset>. Use content="width=device-width, initial-scale=1". Do not include maximum-scale=1 or user-scalable=no — these break pinch-to-zoom accessibility. Do not include minimum-scale. The viewport meta is a pragma directive that must precede any resource loading to ensure correct layout calculations from the start.',
    impact: 'Without an early viewport meta, the browser starts layout at the wrong dimensions and must recalculate once it encounters the tag. This affects Largest Contentful Paint (LCP) and Cumulative Layout Shift (CLS). A late viewport meta also wastes any CSS media query evaluation that occurred before the correct viewport was known.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag',
  },
  {
    name: 'Content Security Policy',
    category: 'pragma',
    description: 'The <meta http-equiv="content-security-policy"> tag defines which resources the browser is allowed to load. This is a critical security pragma that MUST appear before any <script> or <link> tag in the <head>. If CSP appears after a script element, the browser\'s preload scanner may have already started fetching resources that CSP would block, causing wasted connections and potential security gaps.',
    implementation: 'Place <meta http-equiv="content-security-policy" content="..."> after charset and viewport but before any script or link element. Prefer the HTTP header version (Content-Security-Policy) over the meta tag when possible — the header is processed before any HTML parsing begins. If using the meta tag, only a subset of CSP directives are supported (no frame-ancestors, report-uri, or sandbox).',
    impact: 'ct.css flags CSP meta tags that appear after any script element as a critical error. A late CSP can disable the preload scanner for resources that precede it, and resources fetched before CSP is parsed may be blocked and re-fetched, adding round-trip latency. Harry Roberts considers this one of the most impactful head ordering mistakes.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP',
  },
  {
    name: 'Base URL',
    category: 'pragma',
    description: 'The <base href="..."> tag sets the base URL for all relative URLs in the document. Because every subsequent <link>, <script>, <a>, and <img> with a relative URL resolves against the base, it must appear before any element that uses a relative URL. Placing it late means earlier elements may resolve to the wrong URL, causing failed resource loads and broken links.',
    implementation: 'If using <base>, place it after charset and viewport but before any <link>, <script>, or other resource-loading elements. Only one <base> element is allowed per document. Include both href (base URL) and optionally target (default target for links). Prefer absolute URLs throughout the document instead of relying on <base> — it can cause subtle bugs with fragment identifiers and SVG references.',
    impact: 'A late <base> tag causes all preceding relative URLs to resolve against the document URL instead of the intended base. This can trigger 404 errors for stylesheets, scripts, and preconnect hints, adding multiple round trips of wasted network time. The impact compounds with each broken resource.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base',
  },
  {
    name: 'HTTP-Equiv Pragma Directives',
    category: 'pragma',
    description: 'Additional <meta http-equiv> directives that control browser behavior before parsing begins. Includes: accept-ch (Client Hints), delegate-ch (delegated Client Hints), x-dns-prefetch-control (enable/disable DNS prefetching), default-style (preferred stylesheet), origin-trial (enable experimental features), and content-type (legacy charset declaration). All are pragma directives that must be discovered before resources they affect.',
    implementation: 'Place all http-equiv meta tags in the pragma section after charset and viewport. accept-ch: list the Client Hints headers the server supports (e.g., "DPR, Width, Viewport-Width"). x-dns-prefetch-control: set to "on" to enable speculative DNS resolution. origin-trial: include the trial token to enable experimental APIs. These are all browser instructions that must precede the resources they govern.',
    impact: 'Late pragma directives are wasted directives. If accept-ch appears after resource requests have started, those requests won\'t include Client Hints headers. If x-dns-prefetch-control appears after links, DNS prefetching behavior for those links is undefined. capo.js assigns all pragma directives the highest weight (10) because they must be processed first to be effective.',
    docsUrl: null,
  },

  // --- Critical Rendering Resources (Weights 9-4) ---
  {
    name: 'Title Element',
    category: 'critical',
    description: 'The <title> element should appear immediately after pragma directives (capo.js weight 9). The browser needs the title early to populate the tab/window title bar. More importantly, the title must appear after <meta charset> to ensure correct character rendering — a title decoded with the wrong charset may display garbled text. ct.css flags the title as an error if it appears after synchronous JavaScript.',
    implementation: 'Place <title> after all pragma directives (charset, viewport, CSP, base) and before any resource-loading elements (preconnect, scripts, stylesheets). Keep the title under 60 characters for search engine display. Dynamic titles should be set server-side, not via client-side JavaScript — the browser and search engines need the title in the initial HTML.',
    impact: 'A title placed after synchronous JavaScript is blocked until that JavaScript executes, meaning the browser tab shows a blank or default title during script execution. On slow connections this can last several seconds. ct.css treats title-after-JS as an error because it degrades perceived performance (users see no title in the tab).',
    docsUrl: null,
  },
  {
    name: 'Preconnect Hints',
    category: 'critical',
    description: 'The <link rel="preconnect" href="https://..."> hint tells the browser to start DNS resolution, TCP handshake, and TLS negotiation with a third-party origin before any resource from that origin is needed. Placed at weight 8 by capo.js — after pragma directives and title, but before any scripts or stylesheets. Preconnects are most valuable for origins that will be needed for render-blocking resources (fonts, CSS CDNs, critical API endpoints).',
    implementation: 'Place preconnect hints immediately after <title> and before any <script> or <link rel="stylesheet"> tags. Include crossorigin attribute for font origins and any origin that will receive CORS requests: <link rel="preconnect" href="https://fonts.googleapis.com"> <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>. Limit to 2-4 critical origins — each preconnect costs a connection. Use dns-prefetch as a fallback for browsers that do not support preconnect.',
    impact: 'A single preconnect saves 100-300ms per connection (DNS + TCP + TLS). Harry Roberts\' csswizardry.com uses conditional preconnects per page type. If placed too late (after the resources that need them), the connection has already started from the resource request itself, and the preconnect hint is wasted. If placed too early and the connection isn\'t used within 10 seconds, the browser closes it — wasted work.',
    docsUrl: 'https://csswizardry.com/2023/12/correctly-configure-preconnections/',
  },
  {
    name: 'Async Script Placement',
    category: 'critical',
    description: 'Scripts with the async attribute (<script async src="...">) should appear high in the <head> (capo.js weight 7). Despite being non-blocking, they still need to be discovered early by the browser\'s preload scanner to begin downloading as soon as possible. The key insight from Harry Roberts: use static <script async> markup instead of JavaScript-injected async snippets — the preload scanner cannot see scripts created by JavaScript.',
    implementation: 'Place <script async src="..."> after preconnect hints and before synchronous resources. Always use the declarative async attribute in HTML markup rather than the old "async snippet" pattern (creating a script element via JS). The snippet pattern hides the resource from the preload scanner, delaying its download. If the script origin differs from the page, add a preconnect hint for it above.',
    impact: 'Harry Roberts demonstrated that replacing an async JS snippet with a static <script async> tag resulted in 787ms faster execution despite a 297ms longer download — because the preload scanner discovered it immediately. The key metric: execution timestamp dropped from 3,127ms to 2,340ms. This is a ~25% improvement from simply changing how the async script is declared.',
    docsUrl: 'https://csswizardry.com/2022/10/speeding-up-async-snippets/',
  },
  {
    name: 'Sync Scripts Before Stylesheets',
    category: 'critical',
    description: 'The most counterintuitive rule in head ordering: synchronous scripts (weight 5) should appear BEFORE synchronous stylesheets (weight 4) in the <head>. The reason: CSS blocks JavaScript execution. When the browser encounters a synchronous <script> after a <link rel="stylesheet">, it must wait for the CSS to fully download and parse before executing the script — and it cannot parse any HTML after the script during that wait. Placing the script first allows the preload scanner to discover and begin downloading the stylesheet while the script downloads and executes.',
    implementation: 'Place <script src="..."> (without async or defer) before <link rel="stylesheet"> and <style> tags. This applies only to scripts that do NOT depend on CSSOM (computed styles). If a script must query computed styles (e.g., getComputedStyle()), it must go after the stylesheet it depends on. The optimal split pattern is: [Non-CSSOM JS] -> [CSS] -> [CSSOM-dependent JS]. Most third-party analytics, tracking, and utility scripts do not depend on CSSOM.',
    impact: 'Harry Roberts\' 2018 article "CSS and Network Performance" demonstrated ~2x faster page loads by moving synchronous scripts before CSS. The preload scanner can discover and start fetching the stylesheet in parallel with script execution, rather than the script sitting idle waiting for CSS to complete. This is one of the highest-impact head ordering optimizations — easily worth 500ms-2s on real sites.',
    docsUrl: 'https://csswizardry.com/2018/11/css-and-network-performance/',
  },
  {
    name: 'Synchronous Stylesheets',
    category: 'critical',
    description: 'Synchronous stylesheets — <link rel="stylesheet"> and <style> tags — are render-blocking by design: the browser will not paint anything until all synchronous CSS is downloaded and parsed. Placed at weight 4 by capo.js. Despite being critical for rendering, they come after synchronous scripts to enable parallel resource discovery via the preload scanner. Inline <style> blocks are treated identically to external stylesheets for ordering purposes.',
    implementation: 'Place all <link rel="stylesheet"> and <style> tags after synchronous scripts. For critical CSS, inline the above-the-fold styles in a <style> tag and load the full stylesheet asynchronously or via <link rel="preload" as="style">. Avoid multiple render-blocking stylesheets from different origins — each requires a separate connection. Consolidate CSS into as few files as possible. Use media attribute to make non-matching stylesheets non-render-blocking: <link rel="stylesheet" href="print.css" media="print">.',
    impact: 'Every synchronous stylesheet adds its download + parse time to the critical rendering path. Each additional CSS file from a different origin adds DNS + TCP + TLS + download latency. Harry Roberts\' csswizardry.com inlines all critical CSS in a single <style> tag to eliminate external CSS requests from the critical path, measuring CSS load time with Performance API marks (CSS_Start / CSS_End).',
    docsUrl: null,
  },
  {
    name: 'Critical Inline CSS',
    category: 'critical',
    description: 'Inlining critical above-the-fold CSS directly in a <style> tag eliminates the network round trip for the most important styles. The browser can start rendering immediately after parsing the inline styles without waiting for an external file. Harry Roberts\' csswizardry.com bundles its entire main CSS inline. This is the fastest possible way to deliver render-blocking CSS — zero network latency for styles.',
    implementation: 'Extract critical CSS (styles needed for above-the-fold content) and inline it in a <style> tag in the <head>. Load the remaining CSS asynchronously: <link rel="preload" href="full.css" as="style" onload="this.onload=null;this.rel=\'stylesheet\'">. Tools for extraction: Critical (npm), Critters (webpack), Astro (built-in). Keep inline CSS under 14KB (fits in first TCP round trip). Place the <style> tag in the synchronous styles position (after sync scripts).',
    impact: 'Inline CSS eliminates one or more network round trips from the critical rendering path. On a 3G connection, this can save 500-1500ms for First Contentful Paint. The tradeoff: inline CSS cannot be cached separately. For repeat visitors, an external cached stylesheet is faster. The optimal strategy is inline critical CSS + preload full stylesheet for the best of both worlds.',
    docsUrl: null,
  },

  // --- Resource Hints & Optimization (Weights 3-1) ---
  {
    name: 'Preload for Current Page',
    category: 'hints',
    description: 'The <link rel="preload"> hint tells the browser to fetch a resource that will be needed soon for the current page, even before the parser naturally discovers it. Placed at weight 3 by capo.js — after all render-blocking resources but before deferred scripts. Common preload targets: fonts, hero images, critical JSON/data files, and above-the-fold images. Preload is for resources needed NOW, not for future navigations.',
    implementation: 'Syntax: <link rel="preload" href="font.woff2" as="font" type="font/woff2" crossorigin>. Always include the as attribute (font, image, style, script, fetch). For fonts: always add crossorigin (even for same-origin fonts — this is required by the spec). For responsive images: use imagesrcset and imagesizes instead of href. Add fetchpriority="high" for LCP images. Limit preloads to 2-5 critical resources — too many preloads compete with each other.',
    impact: 'Preloading fonts typically saves 100-500ms by starting the download before CSS is parsed (normally fonts are only discovered when the browser evaluates font-face rules). Preloading LCP images can improve Largest Contentful Paint by 200-800ms. But excessive preloads (10+) can hurt performance by competing for bandwidth with render-blocking resources.',
    docsUrl: 'https://web.dev/articles/preload-critical-assets',
  },
  {
    name: 'Module Preload',
    category: 'hints',
    description: 'The <link rel="modulepreload"> hint preloads ES module scripts and their dependency graph. Unlike regular preload, modulepreload also compiles and caches the module, not just downloads it. Placed alongside regular preloads (weight 3) by capo.js. Essential for applications using ES modules, as the browser would otherwise discover and fetch module dependencies one by one in a waterfall pattern.',
    implementation: 'Syntax: <link rel="modulepreload" href="/src/app.js">. Preload the main entry module and its direct static imports. The browser will recursively fetch and compile the entire dependency chain. No as attribute needed (it is always "script"). No crossorigin attribute needed for same-origin modules. For code-split apps, preload the route module for the current page. Place after sync stylesheets and before deferred scripts.',
    impact: 'Module scripts create dependency waterfalls: the browser must download, parse, and discover imports before fetching the next level. Without modulepreload, a 3-level deep dependency tree requires 3 sequential network round trips. Modulepreload flattens this to a single round trip, potentially saving 300-900ms on typical connection speeds.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/rel/modulepreload',
  },
  {
    name: 'Deferred Scripts',
    category: 'hints',
    description: 'Scripts with the defer attribute (<script defer src="...">) and module scripts (<script type="module" src="...">) download in parallel without blocking the parser, and execute in document order after HTML parsing is complete. capo.js assigns weight 2 — they are needed for the current page but are not time-critical for rendering. Module scripts are defer by default unless they also have async.',
    implementation: 'Place <script defer src="..."> after preloads and before prefetch hints. Deferred scripts execute in the order they appear in the document, making them ideal for scripts with dependencies. Use defer instead of async when execution order matters. Module scripts (<script type="module">) are deferred by default — no need to add defer explicitly. Deferred scripts execute before the DOMContentLoaded event fires.',
    impact: 'Defer removes JavaScript from the critical rendering path entirely — the browser never blocks on deferred script downloads. This directly improves First Contentful Paint and Largest Contentful Paint. However, placing defer scripts too high in the <head> (before render-blocking resources) wastes preload scanner bandwidth on non-critical resources when it should be discovering stylesheets and fonts first.',
    docsUrl: null,
  },
  {
    name: 'DNS Prefetch',
    category: 'hints',
    description: 'The <link rel="dns-prefetch" href="https://..."> hint performs DNS resolution only (no TCP or TLS) for a third-party origin. Cheaper than preconnect and appropriate for origins that are likely but not certain to be needed. capo.js assigns weight 1 (prefetch tier) — these are speculative hints for the current page and should not compete with critical resources.',
    implementation: 'Place dns-prefetch hints near the bottom of <head>, after all critical and deferred resources. Use for: analytics domains, ad networks, CDNs for non-critical resources, third-party widgets that may or may not load. Pair with preconnect as a fallback: <link rel="preconnect" href="https://example.com"> <link rel="dns-prefetch" href="https://example.com"> — browsers that do not support preconnect will still benefit from dns-prefetch. Costs almost nothing (a single DNS lookup).',
    impact: 'DNS resolution typically takes 20-120ms. The cost of a dns-prefetch hint is negligible, making it a low-risk optimization. Unlike preconnect, it does not open a connection that might time out unused. Use liberally for any third-party origin that might be needed. But placing dns-prefetch high in the <head> (before critical resources) can delay discovery of more important resources by the preload scanner.',
    docsUrl: null,
  },
  {
    name: 'Prefetch for Next Page',
    category: 'hints',
    description: 'The <link rel="prefetch" href="..."> hint fetches a resource that will be needed for a future navigation, not the current page. The browser downloads it at idle priority, only using leftover bandwidth. capo.js assigns weight 1 — the lowest actionable weight. Prefetched resources are stored in the HTTP cache and used instantly when the user navigates to the next page.',
    implementation: 'Place prefetch hints at the very bottom of the <head>, after everything needed for the current page. Prefetch entire next-page HTML: <link rel="prefetch" href="/next-page">. Prefetch critical resources for the likely next route: CSS, JS bundles, key images. Use sparingly — each prefetch uses bandwidth that could serve the current page. Only prefetch resources with high navigation probability (e.g., "next" in a wizard, most common link clicked from this page).',
    impact: 'Prefetch makes subsequent page loads feel instant — the HTML, CSS, and JS are already in the cache when the user clicks. Can reduce next-page load time from 1-3 seconds to near-zero. But aggressive prefetching wastes bandwidth for users who do not navigate to the prefetched page. On mobile data connections, this is a real cost to the user.',
    docsUrl: null,
  },
  {
    name: 'Speculation Rules',
    category: 'hints',
    description: 'The <script type="speculationrules"> element is the modern replacement for <link rel="prerender">. Use a 4-tier layered approach: (1) Immediate prerender for high-confidence targets (top nav, CTAs) via data-prefetch="prerender", (2) Immediate prefetch for likely navigations via data-prefetch, (3) On-demand prerender that upgrades prefetched links on hover (eagerness: moderate), (4) Fallback prefetch for all internal links on hover. This cascading strategy gives near-instant transitions for probable targets while keeping resource usage proportional to navigation probability. Supported in Chrome 109+ and Edge; ignored by other browsers.',
    implementation: 'Place at the bottom of <head>. Use data-prefetch attributes on <a> elements to control tiers: data-prefetch="prerender" (Tier 1), data-prefetch (Tier 2/3), data-prefetch="false" (opt-out). The speculation rules JSON contains all 4 tiers: {"prerender":[{"where":{"selector_matches":"[data-prefetch=prerender]"},"eagerness":"immediate"},{"where":{"selector_matches":"[data-prefetch=\'\']"},"eagerness":"moderate"}],"prefetch":[{"where":{"selector_matches":"[data-prefetch=\'\']"},"eagerness":"immediate"},{"where":{"and":[{"href_matches":"/*"},{"not":{"selector_matches":"[data-prefetch=false]"}}]},"eagerness":"moderate"}]}. IMPORTANT: use [data-prefetch=\'\'] (exact match) not [data-prefetch] (wildcard) to exclude data-prefetch="false" links. Never prerender/prefetch logout, payment, or state-changing endpoints — add data-prefetch="false" to those.',
    impact: 'Prerendering makes page transitions feel instant (0ms perceived load time). Chrome reports near-perfect Core Web Vitals on prerendered navigations. The 4-tier approach balances aggressiveness with resource cost: top nav gets full prerender (most expensive, highest payoff), all other internal links get on-hover prefetch (cheapest, broadest coverage). Each prerendered page is a full hidden tab — limit Tier 1 to 2-3 links maximum. On mobile, excessive prerendering wastes battery and data. Chrome 138+ supports prefetchCache/prerenderCache in the Clear-Site-Data header for forced purging.',
    docsUrl: 'https://developer.chrome.com/docs/web-platform/prerender-pages',
  },

  // --- Anti-Patterns (what NOT to do) ---
  {
    name: 'CSS Blocking JavaScript',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Placing synchronous scripts AFTER stylesheets. When the browser encounters a <script> after a <link rel="stylesheet">, it halts script execution until the stylesheet is fully downloaded and parsed (CSSOM construction). The browser does this defensively — the script might call getComputedStyle() — but most scripts don\'t need CSSOM. This ordering serializes downloads that could be parallel, potentially doubling load time.',
    implementation: 'WRONG: <link rel="stylesheet" href="styles.css"> then <script src="app.js"></script>. The script waits for CSS to download + parse before executing. CORRECT: <script src="app.js"></script> then <link rel="stylesheet" href="styles.css">. The preload scanner discovers the stylesheet while the script downloads and executes in parallel. EXCEPTION: scripts that query CSSOM (getComputedStyle, offsetHeight, etc.) must remain after the stylesheet they depend on.',
    impact: 'Harry Roberts demonstrated ~2x faster page loads by reordering scripts before CSS. On a typical page with 200KB of CSS and 100KB of JS, the serialized order adds the full CSS download time to the JS execution delay. On 3G, this can mean 1-3 seconds of unnecessary blocking. This is the single most impactful head ordering fix for most websites.',
    docsUrl: 'https://csswizardry.com/2018/11/css-and-network-performance/',
  },
  {
    name: 'Late Charset Declaration',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Placing <meta charset> anywhere other than the very first element in <head>. The HTML specification requires the encoding declaration within the first 1024 bytes. If the browser has already started parsing content before discovering the charset, it must throw away all work and re-parse from the beginning with the correct encoding. This is an invisible but costly mistake.',
    implementation: 'WRONG: <title>My Page</title> then <meta charset="utf-8">. WRONG: <meta name="viewport" ...> then <meta charset="utf-8">. CORRECT: <meta charset="utf-8"> as the very first element in <head>. ct.css flags charset that appears after the 5th child element as a warning. capo.js assigns charset weight 10 (highest). Ensure no HTML comments or whitespace-heavy markup appears before the charset tag.',
    impact: 'A late charset causes a full document re-parse. On a 100KB HTML page, this means the browser parses the entire document twice — doubling parse time (50-200ms on modern hardware, more on mobile). Additionally, any text rendered before charset discovery may flash with incorrect characters before the re-parse corrects them, causing a visual glitch.',
    docsUrl: null,
  },
  {
    name: 'CSP After Scripts',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Placing a <meta http-equiv="content-security-policy"> tag after any <script> element. When CSP appears mid-<head> after scripts, the preload scanner may have already initiated fetches that CSP would block. Those fetches are wasted (aborted when CSP is applied). Worse, some browsers may partially disable the preload scanner for content that appeared before the CSP directive, losing parallelism entirely.',
    implementation: 'WRONG: <script src="app.js"></script> then <meta http-equiv="content-security-policy" content="...">. CORRECT: <meta http-equiv="content-security-policy" content="..."> before any script or link element. BEST: Use the Content-Security-Policy HTTP header instead of the meta tag — the header is processed before any HTML parsing begins, eliminating the ordering concern entirely.',
    impact: 'ct.css flags this as a critical error (red highlight). The performance cost is twofold: (1) wasted network requests for resources that will be blocked by CSP, and (2) potential preload scanner disruption for all resources above the CSP tag. The security cost is also real — scripts that execute before CSP is applied are not governed by the policy.',
    docsUrl: null,
  },
  {
    name: '@import in Stylesheets',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Using @import rules in stylesheets instead of <link> tags. @import creates a hidden waterfall: the browser must download and parse the first stylesheet before it can discover the @import URL, then download the imported stylesheet serially. With <link> tags, the preload scanner discovers all stylesheets immediately and downloads them in parallel. capo.js assigns @import styles a higher weight (6) to flag them for early placement, but the real fix is eliminating @import entirely.',
    implementation: 'WRONG: <style>@import url("reset.css"); @import url("theme.css");</style> — downloads reset.css, waits, then discovers and downloads theme.css. CORRECT: <link rel="stylesheet" href="reset.css"> <link rel="stylesheet" href="theme.css"> — both discovered and downloaded in parallel by the preload scanner. If @import is unavoidable (e.g., CSS framework requirement), place the <style> tag with @import above other stylesheets (capo.js weight 6 position).',
    impact: 'Each @import adds one full round trip to the CSS loading waterfall. Two levels of @import on a 3G connection can add 1-2 seconds to render time. The preload scanner is blind to URLs inside @import rules — it only sees URLs in HTML markup. This is one of the oldest known CSS performance anti-patterns, documented since at least 2009.',
    docsUrl: null,
  },
  {
    name: 'Async Snippet Pattern',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Using a JavaScript snippet to dynamically create and inject an async script, instead of using a static <script async src="..."> tag. The classic pattern (used by Google Analytics pre-gtag) creates a <script> element via JS and appends it to the DOM. The problem: the preload scanner only reads HTML markup — it cannot execute JavaScript. So the injected script URL is completely invisible until the parent script runs, which may be blocked by CSS.',
    implementation: 'WRONG: <script>(function(){var s=document.createElement("script");s.src="analytics.js";s.async=true;document.head.appendChild(s);})()</script> — the preload scanner never sees "analytics.js". CORRECT: <script async src="analytics.js"></script> — the preload scanner discovers the URL immediately and begins downloading in parallel. Replace all async snippet patterns with declarative <script async src> tags.',
    impact: 'Harry Roberts measured a 787ms improvement in script execution time by replacing an async snippet with a static <script async> tag. Despite the static version taking 297ms longer to download, it executed nearly a second sooner because the preload scanner found it immediately instead of waiting for the parent script to create the element. This is a free performance win on any site using the old snippet pattern.',
    docsUrl: 'https://csswizardry.com/2022/10/speeding-up-async-snippets/',
  },
  {
    name: 'Redundant async + defer',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Adding both async and defer attributes to the same <script> element. While browsers handle this gracefully (async takes precedence; defer acts as a fallback for browsers that support defer but not async), it signals confusion about the developer\'s intent. In modern browsers (all browsers since IE10), the defer attribute is completely ignored when async is present. It adds bytes without benefit.',
    implementation: 'WRONG: <script async defer src="app.js"></script> — defer is ignored, async wins. CORRECT: <script async src="app.js"></script> for scripts where execution order does not matter. CORRECT: <script defer src="app.js"></script> for scripts that must execute in document order. Choose one based on the script\'s requirements. ct.css flags scripts with both attributes as a warning.',
    impact: 'The performance impact is negligible (just extra bytes). The real cost is maintainability — future developers may misunderstand the script\'s loading behavior. The combination was historically used as a progressive enhancement for IE9 (which supported defer but not async), but that browser has been dead for a decade. Remove the redundant attribute.',
    docsUrl: null,
  },
  {
    name: 'document.write() Scripts',
    category: 'anti_patterns',
    description: 'ANTI-PATTERN: Using document.write() to inject scripts or stylesheets into the <head>. document.write() is the nuclear option against performance: it forces the HTML parser to stop, inserts raw HTML into the parse stream, and in many cases completely defeats the preload scanner. Chrome actively intervenes against document.write() on slow connections (2G) by blocking the injected resource entirely.',
    implementation: 'NEVER use document.write() to inject resources. Replace with: DOM APIs (createElement + appendChild), <script async/defer> tags, or dynamic import(). For third-party scripts that use document.write() internally, load them with async or defer to reduce their blast radius. Chrome DevTools flags document.write() usage in the console with warnings about intervention on slow connections.',
    impact: 'document.write() can add 2-7 seconds of delay on slow connections. Chrome\'s intervention (blocking document.write()-injected scripts on 2G) means the script may simply never load for users on poor connections. Harry Roberts calls document.write() "one of the most harmful things you can do to the performance of a webpage." It is the only API that can actively prevent the preload scanner from doing its job.',
    docsUrl: 'https://csswizardry.com/2023/01/why-not-document-write/',
  },

  // --- SEO & Social Meta (Weight 0 — last) ---
  {
    name: 'Canonical URL',
    category: 'seo_social',
    description: 'The <link rel="canonical" href="..."> tag tells search engines which URL is the authoritative version of the page. It has zero rendering or loading impact — search engines process it after the page loads. Placed at weight 0 ("everything else") by capo.js. There is no performance reason to place canonical early in the <head>; it should not displace any rendering-critical resource.',
    implementation: 'Place <link rel="canonical" href="https://example.com/page"> near the bottom of <head>, grouped with other SEO meta tags. Use a full absolute URL, not a relative path. Ensure the canonical URL matches the actual page URL (or the preferred URL for duplicate content). Self-referencing canonicals (pointing to the current page) are recommended by Google. Include on every page, not just pages with duplicates.',
    impact: 'Zero performance impact on page rendering or loading. Canonical tags are processed by crawlers, not browsers. The only timing consideration: search engine crawlers may stop parsing <head> early on very large pages, so keeping canonical within the first few KB of the document ensures it is seen. But this is a crawl-budget concern, not a performance concern.',
    docsUrl: null,
  },
  {
    name: 'Open Graph Tags',
    category: 'seo_social',
    description: 'Open Graph <meta property="og:..."> tags control how the page appears when shared on social media platforms (Facebook, LinkedIn, Twitter/X, Slack, Discord, etc.). They have absolutely no impact on page rendering, loading, or performance. capo.js weight 0 — "everything else." Place at the bottom of <head> where they belong, and never let them displace render-critical resources.',
    implementation: 'Place all OG tags near the bottom of <head>: <meta property="og:title">, <meta property="og:description">, <meta property="og:image">, <meta property="og:url">, <meta property="og:type">. Minimum required: og:title, og:image, og:url. Image should be 1200x630px for optimal display. Include og:type="website" for homepages, "article" for blog posts. Do not place OG tags before stylesheets, scripts, or preconnect hints.',
    impact: 'Zero rendering performance impact. OG tags are only read by social media crawlers when the URL is shared. However, placing a large block of OG tags (10+ meta tags) high in the <head> before render-critical resources pushes those resources further from the start of the document, adding tiny but unnecessary latency to resource discovery by the preload scanner.',
    docsUrl: 'https://ogp.me/',
  },
  {
    name: 'Meta Description',
    category: 'seo_social',
    description: 'The <meta name="description" content="..."> tag provides a summary of the page for search engine result pages (SERPs). Like all SEO meta tags, it has zero impact on rendering or performance and belongs at the bottom of <head>. Search engines may use it as the SERP snippet text, but modern search engines increasingly generate their own snippets from page content.',
    implementation: 'Place near the bottom of <head> alongside OG tags and canonical URL. Keep under 155 characters for full SERP display. Write unique descriptions for each page — duplicate descriptions across pages reduce their SEO value. Do not keyword-stuff. If the page has a good OG description, the meta description can be similar or identical. Place after all resource-loading and rendering-critical elements.',
    impact: 'Zero performance impact. The meta description is invisible to the browser\'s rendering engine and resource loader. It is only processed by search engine crawlers and social media scrapers. There is never a performance reason to place it before stylesheets, scripts, or resource hints.',
    docsUrl: null,
  },
  {
    name: 'Favicon & App Icons',
    category: 'seo_social',
    description: 'Favicon and app icon declarations (<link rel="icon">, <link rel="apple-touch-icon">, <link rel="manifest">) should be placed at the bottom of the <head>. Browsers fetch the favicon at low priority and only display it in the tab after the page starts rendering. These resources should never displace render-critical elements. capo.js weight 0 — "everything else."',
    implementation: 'Place icon links near the bottom of <head>: <link rel="icon" href="/favicon.svg" type="image/svg+xml"> <link rel="apple-touch-icon" href="/apple-touch-icon.png"> <link rel="manifest" href="/site.webmanifest">. Use SVG favicons for crisp display at any size (supported by all modern browsers except Safari, which uses apple-touch-icon). Include a PNG fallback. Keep favicon files small (<10KB). Do not preload favicons — they are not render-critical.',
    impact: 'Favicon requests are inherently low priority. Placing favicon <link> tags high in <head> wastes preload scanner attention on non-critical resources when it should be discovering stylesheets and fonts. On pages with many icon declarations (favicon, apple-touch-icon, multiple sizes, manifest), the cumulative impact of displacing critical resources can be measurable (50-100ms of delayed critical resource discovery).',
    docsUrl: null,
  },
  {
    name: 'RSS & Alternate Links',
    category: 'seo_social',
    description: '<link rel="alternate"> tags for RSS/Atom feeds, language alternates (hreflang), and canonical format alternates. These are metadata for feed readers, search engines, and internationalization — they have no impact on page rendering. Browsers show an RSS icon for discoverable feeds, but this happens after page rendering is complete. Place at the bottom of <head> with other non-rendering metadata.',
    implementation: 'Place near the bottom of <head>: <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="/feed.xml"> <link rel="alternate" hreflang="es" href="/es/page">. For multilingual sites, include one alternate per language variant plus an x-default fallback. RSS/Atom feeds: include type attribute for auto-discovery by feed readers. These can safely be the last elements in <head>.',
    impact: 'Zero rendering performance impact. Alternate links are processed by crawlers, feed readers, and browser feed auto-discovery — none of which affect page load time. The only consideration is keeping them out of the way of more critical elements.',
    docsUrl: null,
  },

  // --- Validation & Tooling ---
  {
    name: 'capo.js Audit',
    category: 'tooling',
    description: 'capo.js by Rick Viscomi is the definitive tool for auditing HTML <head> element ordering. Available as a Chrome extension, bookmarklet, or npm package. It color-codes every element in your <head> by its weight (10 = red/highest priority, 0 = grey/lowest), logs the actual order and optimal order to the console, and highlights high-impact elements that are out of order. Inspired by Harry Roberts\' ct.css and Vitaly Friedman\'s research.',
    implementation: 'Install the Chrome extension from the Chrome Web Store, or use the bookmarklet from rviscomi.github.io/capo.js. Run on any page — it logs two groups to the console: "Actual" (current order with color-coded weights) and "Sorted" (recommended order). Look for red/orange elements appearing after green/blue ones — those are the highest-impact reordering opportunities. The capo.js API also exposes ElementWeights for programmatic access in build tools.',
    impact: 'capo.js provides instant visual feedback on <head> ordering issues. The 11-weight system (Pragma 10, Title 9, Preconnect 8, Async 7, Import 6, Sync Script 5, Sync Style 4, Preload 3, Defer 2, Prefetch 1, Other 0) is the most comprehensive head ordering framework available. Framework integrations (astro-capo, nuxt-capo) can enforce optimal ordering automatically at build time.',
    docsUrl: 'https://rviscomi.github.io/capo.js/',
  },
  {
    name: 'ct.css Diagnostic',
    category: 'tooling',
    description: 'ct.css by Harry Roberts (CSS Wizardry) is a diagnostic CSS snippet that visually highlights performance issues in your <head>. Named after CT scans, it uses CSS-only selectors to detect anti-patterns: late charset, CSS blocking JS, redundant attributes, third-party resources in <head>, and more. Issues are highlighted with colored borders that disappear as you fix them. Available as a bookmarklet at csswizardry.com/ct/.',
    implementation: 'Drag the bookmarklet from csswizardry.com/ct/ to your bookmarks bar. Click it on any page to inject the diagnostic styles. Red with solid borders = critical errors (title after JS, CSP after scripts). Orange with dashed borders = warnings (blocking scripts, third-party resources). The snippet disappears when all issues are fixed. Can also be added as a development stylesheet: <link rel="stylesheet" href="ct.css">.',
    impact: 'ct.css catches the most impactful head ordering mistakes with zero JavaScript overhead (pure CSS selectors). It is specifically designed to flag issues that Harry Roberts has measured as causing the largest performance regressions: scripts blocking on CSS, late charset, CSP ordering, and third-party resources in the critical path. Use alongside capo.js — ct.css catches anti-patterns while capo.js shows optimal ordering.',
    docsUrl: 'https://csswizardry.com/ct/',
  },
  {
    name: 'Framework Integrations',
    category: 'tooling',
    description: 'Several frameworks now have plugins that automatically enforce optimal <head> ordering at build time, using the capo.js weight system. astro-capo sorts Astro\'s <head> output automatically. nuxt-capo does the same for Nuxt 3. Unhead (the universal <head> manager used by Nuxt, Vue, and others) has built-in capo.js sorting. These tools eliminate head ordering mistakes by making correct ordering the default.',
    implementation: 'Astro: install astro-capo and add to astro.config.mjs integrations — it automatically reorders <head> elements in the build output. Nuxt 3: install nuxt-capo as a module — sorts <head> via Unhead integration. Unhead v2: built-in head sorting enabled by default using capo.js weights. React/Next.js: no official integration yet — manually order <head> elements or use a custom Document component. For any framework: validate with capo.js bookmarklet after building.',
    impact: 'Build-time head sorting eliminates an entire class of performance bugs. Developers can add <head> elements in any order during development, and the build tool ensures optimal ordering in production. astro-capo was adopted by the Astro core team and is the reference implementation. Unhead v2 making capo.js sorting the default means Vue and Nuxt applications get optimal head ordering without any developer action.',
    docsUrl: 'https://github.com/rviscomi/capo.js',
  },
  {
    name: 'Performance Marks in Head',
    category: 'tooling',
    description: 'Harry Roberts uses the Performance API (performance.mark() and performance.measure()) directly in the <head> to measure how long each section takes to parse and load. His csswizardry.com <head> includes marks for HEAD_Start, CSS_Start, CSS_End, and HEAD_End, giving precise measurements of <head> parsing time. This technique allows you to quantify the impact of head ordering changes.',
    implementation: 'Add inline scripts at section boundaries: <script>performance.mark("HEAD_Start")</script> at the top of <head>, <script>performance.mark("CSS_Start")</script> before stylesheets, <script>performance.mark("CSS_End");performance.measure("CSS", "CSS_Start", "CSS_End")</script> after stylesheets, and <script>performance.mark("HEAD_End");performance.measure("HEAD", "HEAD_Start", "HEAD_End")</script> at the bottom. Access measurements via performance.getEntriesByType("measure") or see them in DevTools Performance panel.',
    impact: 'Performance marks provide hard data for head ordering decisions. Instead of guessing whether a reordering helped, you can measure the exact millisecond impact. Harry Roberts\' csswizardry.com shows CSS parse time and total <head> processing time as custom metrics. This technique costs only ~50 bytes per mark (inline scripts are tiny) and the Performance API has negligible overhead.',
    docsUrl: null,
  },
];
