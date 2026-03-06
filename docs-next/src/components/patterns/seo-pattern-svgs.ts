/** SVG illustrations for SEO & AI Discoverability Patterns */
export const seoPatternSvgs: Record<string, string> = {

'Canonical URL Tag': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="22" width="70" height="35" rx="4" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="28" y="30" width="50" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="28" y="38" width="40" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="28" y="44" width="45" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="110" y="22" width="70" height="35" rx="4" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 2"/>
  <rect x="118" y="30" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="118" y="38" width="40" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="118" y="44" width="45" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <path d="M90 40 L110 40" style="stroke: var(--color-accent)" stroke-width="1.5" marker-end="url(#arrowC)"/>
  <defs><marker id="arrowC" markerWidth="6" markerHeight="4" refX="5" refY="2" orient="auto"><path d="M0,0 L6,2 L0,4" style="fill: var(--color-accent)"/></marker></defs>
  <rect x="20" y="68" width="160" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="30" y="78" style="fill: var(--color-accent); font-size: 7px; font-family: monospace" opacity="0.7">&lt;link rel="canonical"&gt;</text>
  <circle cx="175" cy="75" r="6" style="fill: var(--color-accent)" opacity="0.15"/>
  <path d="M172 75 L175 78 L179 72" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none"/>
</svg>`,

'XML Sitemap': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="100" cy="28" r="10" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="94" y="24" width="12" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <line x1="100" y1="38" x2="50" y2="58" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.4"/>
  <line x1="100" y1="38" x2="100" y2="58" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.4"/>
  <line x1="100" y1="38" x2="150" y2="58" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.4"/>
  <circle cx="50" cy="62" r="7" style="fill: var(--color-accent)" opacity="0.15"/>
  <circle cx="100" cy="62" r="7" style="fill: var(--color-accent)" opacity="0.15"/>
  <circle cx="150" cy="62" r="7" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="45" y="59" width="10" height="6" rx="1.5" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="95" y="59" width="10" height="6" rx="1.5" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="145" y="59" width="10" height="6" rx="1.5" style="fill: var(--color-accent)" opacity="0.4"/>
  <line x1="50" y1="69" x2="30" y2="84" style="stroke: var(--color-border)" stroke-width="0.75" opacity="0.5"/>
  <line x1="50" y1="69" x2="50" y2="84" style="stroke: var(--color-border)" stroke-width="0.75" opacity="0.5"/>
  <line x1="50" y1="69" x2="70" y2="84" style="stroke: var(--color-border)" stroke-width="0.75" opacity="0.5"/>
  <circle cx="30" cy="88" r="4" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="50" cy="88" r="4" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="70" cy="88" r="4" style="fill: var(--color-text)" opacity="0.1"/>
  <line x1="150" y1="69" x2="140" y2="84" style="stroke: var(--color-border)" stroke-width="0.75" opacity="0.5"/>
  <line x1="150" y1="69" x2="160" y2="84" style="stroke: var(--color-border)" stroke-width="0.75" opacity="0.5"/>
  <circle cx="140" cy="88" r="4" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="160" cy="88" r="4" style="fill: var(--color-text)" opacity="0.1"/>
</svg>`,

'robots.txt': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="22" width="100" height="70" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="32" y="35" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.7">User-agent: *</text>
  <text x="32" y="45" style="fill: var(--color-text); font-size: 6px; font-family: monospace" opacity="0.4">Allow: /</text>
  <text x="32" y="55" style="fill: var(--color-text); font-size: 6px; font-family: monospace" opacity="0.4">Disallow: /api/</text>
  <text x="32" y="68" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.7">User-agent: GPTBot</text>
  <text x="32" y="78" style="fill: var(--color-text); font-size: 6px; font-family: monospace" opacity="0.4">Allow: /docs/</text>
  <circle cx="155" cy="40" r="16" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.3"/>
  <circle cx="149" cy="36" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <circle cx="161" cy="36" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="147" y="43" width="16" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="145" y="62" width="20" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.12"/>
  <path d="M152 66 L155 69 L159 63" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.6"/>
  <rect x="145" y="76" width="20" height="8" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <line x1="150" y1="78" x2="160" y2="84" style="stroke: var(--color-text)" stroke-width="1" opacity="0.2"/>
  <line x1="160" y1="78" x2="150" y2="84" style="stroke: var(--color-text)" stroke-width="1" opacity="0.2"/>
</svg>`,

'Structured URL Hierarchy': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="22" width="150" height="16" rx="8" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="35" y="33" style="fill: var(--color-accent); font-size: 7px; font-family: monospace" opacity="0.6">/docs/guides/setup</text>
  <path d="M60 48 L60 55 L40 55 L40 62" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.3"/>
  <path d="M60 48 L60 55 L80 55 L80 62" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.3"/>
  <path d="M60 48 L60 55 L120 55 L120 62" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.3"/>
  <rect x="25" y="62" width="32" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="31" y="71" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.6">docs</text>
  <rect x="65" y="62" width="40" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="71" y="71" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.6">guides</text>
  <rect x="113" y="62" width="36" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="119" y="71" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.6">setup</text>
  <rect x="25" y="84" width="150" height="14" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="33" y="91" style="fill: var(--color-text); font-size: 5px; font-family: sans-serif" opacity="0.35">Home</text>
  <text x="48" y="91" style="fill: var(--color-text); font-size: 5px" opacity="0.2">/</text>
  <text x="55" y="91" style="fill: var(--color-text); font-size: 5px; font-family: sans-serif" opacity="0.35">Docs</text>
  <text x="72" y="91" style="fill: var(--color-text); font-size: 5px" opacity="0.2">/</text>
  <text x="79" y="91" style="fill: var(--color-text); font-size: 5px; font-family: sans-serif" opacity="0.35">Guides</text>
  <text x="102" y="91" style="fill: var(--color-text); font-size: 5px" opacity="0.2">/</text>
  <text x="109" y="91" style="fill: var(--color-accent); font-size: 5px; font-family: sans-serif" opacity="0.6">Setup</text>
</svg>`,

'Open Graph Tags': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="20" width="140" height="55" rx="4" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="20" width="140" height="32" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="40" y="28" width="40" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="40" y="36" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="40" y="42" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="36" y="58" width="90" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="36" y="66" width="128" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="20" y="84" width="160" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="30" y="94" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.5">og:title  og:image  og:url</text>
</svg>`,

'Twitter/X Card Tags': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="20" width="140" height="70" rx="8" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="20" width="140" height="40" rx="8" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="80" y="32" width="20" height="16" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <polygon points="86,37 96,42 86,47" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="38" y="66" width="70" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="38" y="74" width="100" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="38" y="80" width="50" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.07"/>
  <text x="30" y="105" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.5">summary_large_image</text>
</svg>`,

'Meta Description': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="22" width="150" height="55" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <rect x="32" y="30" width="100" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="32" y="47" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">example.com/getting-started</text>
  <rect x="32" y="54" width="130" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="32" y="60" width="120" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="32" y="66" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="25" y="86" width="90" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="32" y="94" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">150-160 characters</text>
</svg>`,

'Meta Robots Directives': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="22" width="65" height="36" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <circle cx="57" cy="32" r="5" style="fill: var(--color-accent)" opacity="0.2"/>
  <path d="M54 32 L57 35 L61 29" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.6"/>
  <text x="32" y="49" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">index, follow</text>
  <rect x="110" y="22" width="65" height="36" rx="4" style="fill: var(--color-text)" opacity="0.05"/>
  <circle cx="142" cy="32" r="5" style="fill: var(--color-text)" opacity="0.15"/>
  <line x1="139" y1="29" x2="145" y2="35" style="stroke: var(--color-text)" stroke-width="1.5" opacity="0.3"/>
  <line x1="145" y1="29" x2="139" y2="35" style="stroke: var(--color-text)" stroke-width="1.5" opacity="0.3"/>
  <text x="117" y="49" style="fill: var(--color-text); font-size: 5.5px; font-family: monospace" opacity="0.35">noindex</text>
  <rect x="25" y="68" width="40" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="30" y="74" style="fill: var(--color-accent); font-size: 4.5px" opacity="0.5">/docs</text>
  <rect x="70" y="68" width="40" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="75" y="74" style="fill: var(--color-accent); font-size: 4.5px" opacity="0.5">/blog</text>
  <rect x="115" y="68" width="40" height="8" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <text x="120" y="74" style="fill: var(--color-text); font-size: 4.5px" opacity="0.3">/admin</text>
  <rect x="160" y="68" width="25" height="8" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <text x="163" y="74" style="fill: var(--color-text); font-size: 4.5px" opacity="0.3">/api</text>
  <rect x="25" y="84" width="150" height="14" rx="3" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="33" y="94" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">&lt;meta name="robots" content="..."&gt;</text>
</svg>`,

'Favicon & App Manifest': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="22" width="30" height="30" rx="6" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="32" y="29" width="16" height="16" rx="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <text x="36" y="41" style="fill: var(--color-surface); font-size: 9px; font-weight: bold">V</text>
  <rect x="65" y="25" width="18" height="18" rx="4" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="70" y="37" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">32</text>
  <rect x="90" y="28" width="12" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="93" y="37" style="fill: var(--color-accent); font-size: 4px" opacity="0.5">16</text>
  <rect x="110" y="22" width="30" height="30" rx="8" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="115" y="41" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">180</text>
  <rect x="150" y="20" width="30" height="35" rx="4" style="stroke: var(--color-border)" stroke-width="0.75"/>
  <rect x="155" y="25" width="20" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="161" y="38" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.4">V</text>
  <rect x="155" y="48" width="20" height="3" rx="1" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="25" y="62" width="150" height="34" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="32" y="74" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">manifest.json</text>
  <rect x="32" y="80" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="32" y="86" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
</svg>`,

'JSON-LD WebSite Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="60" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="28" y="32" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.6">{"@type": "WebSite",</text>
  <text x="34" y="42" style="fill: var(--color-text); font-size: 5.5px; font-family: monospace" opacity="0.35">"name": "My Site",</text>
  <text x="34" y="52" style="fill: var(--color-text); font-size: 5.5px; font-family: monospace" opacity="0.35">"url": "https://...",</text>
  <text x="34" y="62" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">"potentialAction": {</text>
  <text x="40" y="72" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.4">"@type": "SearchAction"</text>
  <rect x="20" y="86" width="70" height="16" rx="8" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="28" y="90" width="54" height="8" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="0.5"/>
  <text x="34" y="96" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Search site...</text>
  <rect x="120" y="88" width="50" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="127" y="97" style="fill: var(--color-accent); font-size: 5.5px" opacity="0.5">Rich Result</text>
</svg>`,

'BreadcrumbList Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="28" y="33" style="fill: var(--color-accent); font-size: 6px" opacity="0.5">Home</text>
  <text x="50" y="33" style="fill: var(--color-text); font-size: 6px" opacity="0.2">></text>
  <text x="58" y="33" style="fill: var(--color-accent); font-size: 6px" opacity="0.5">Docs</text>
  <text x="78" y="33" style="fill: var(--color-text); font-size: 6px" opacity="0.2">></text>
  <text x="86" y="33" style="fill: var(--color-text); font-size: 6px; font-weight: bold" opacity="0.6">Setup Guide</text>
  <rect x="20" y="48" width="160" height="48" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="28" y="60" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">BreadcrumbList</text>
  <rect x="28" y="66" width="50" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="33" y="73" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.5">pos: 1</text>
  <rect x="84" y="66" width="50" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="89" y="73" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.5">pos: 2</text>
  <rect x="140" y="66" width="30" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="145" y="73" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.6">pos: 3</text>
  <path d="M78 71 L84 71" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.3" marker-end="url(#arrowB)"/>
  <path d="M134 71 L140 71" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.3" marker-end="url(#arrowB)"/>
  <defs><marker id="arrowB" markerWidth="4" markerHeight="3" refX="3" refY="1.5" orient="auto"><path d="M0,0 L4,1.5 L0,3" style="fill: var(--color-accent)" opacity="0.3"/></marker></defs>
</svg>`,

'Article Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="150" height="75" rx="4" style="stroke: var(--color-border)" stroke-width="0.75"/>
  <rect x="25" y="20" width="150" height="25" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <rect x="33" y="27" width="90" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="38" cy="40" r="5" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="46" y="37" width="40" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="46" y="42" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="33" y="52" width="130" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="33" y="58" width="120" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="33" y="64" width="100" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="33" y="76" width="55" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="38" y="82" style="fill: var(--color-accent); font-size: 4.5px; font-family: monospace" opacity="0.5">dateModified</text>
  <rect x="95" y="76" width="70" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="100" y="82" style="fill: var(--color-accent); font-size: 4.5px; font-family: monospace" opacity="0.5">TechArticle</text>
</svg>`,

'SoftwareApplication Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="22" width="40" height="40" rx="10" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="38" y="30" width="24" height="24" rx="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="44" y="47" style="fill: var(--color-surface); font-size: 12px; font-weight: bold">A</text>
  <rect x="80" y="25" width="90" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="80" y="34" width="70" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="80" y="44" width="38" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="85" y="51" style="fill: var(--color-accent); font-size: 5px" opacity="0.6">Free</text>
  <rect x="122" y="44" width="38" height="10" rx="3" style="fill: var(--color-text)" opacity="0.06"/>
  <text x="127" y="51" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Any OS</text>
  <rect x="30" y="72" width="140" height="24" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="38" y="83" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">"@type": "SoftwareApplication"</text>
  <text x="38" y="91" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"applicationCategory": "Dev..."</text>
</svg>`,

'Product Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="55" height="55" rx="6" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="33" y="28" width="39" height="39" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="44" y="52" style="fill: var(--color-accent); font-size: 14px" opacity="0.4">P</text>
  <rect x="90" y="24" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="90" y="33" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <text x="90" y="50" style="fill: var(--color-accent); font-size: 9px; font-weight: bold" opacity="0.6">$29/mo</text>
  <rect x="90" y="55" width="40" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="95" y="61" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">In Stock</text>
  <path d="M90 68 L95 68 L95 66 L100 66 L100 68 L105 68 L105 66 L110 66 L110 68" style="stroke: var(--color-accent); fill: none" stroke-width="1" opacity="0.4"/>
  <text x="113" y="69" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">4.8</text>
  <rect x="25" y="82" width="150" height="20" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="33" y="93" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">"@type": "Product"</text>
  <text x="33" y="99" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"offers": {"price": "29"}</text>
</svg>`,

'Organization Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="60" height="40" rx="6" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="35" y="26" width="40" height="28" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <circle cx="55" cy="37" r="7" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="51" y="41" style="fill: var(--color-surface); font-size: 8px; font-weight: bold">O</text>
  <rect x="40" y="47" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="95" y="22" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="95" y="31" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="95" y="38" width="70" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <circle cx="100" cy="52" r="5" style="fill: var(--color-accent)" opacity="0.12"/>
  <circle cx="115" cy="52" r="5" style="fill: var(--color-accent)" opacity="0.12"/>
  <circle cx="130" cy="52" r="5" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="97" y="54" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">X</text>
  <text x="112" y="54" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">G</text>
  <text x="127" y="54" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">L</text>
  <rect x="25" y="68" width="150" height="34" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="33" y="80" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">"@type": "Organization"</text>
  <text x="33" y="88" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"sameAs": ["twitter...", ...]</text>
  <text x="33" y="96" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"logo": "https://..."</text>
</svg>`,

'VideoObject Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="100" height="56" rx="4" style="fill: var(--color-text)" opacity="0.06"/>
  <polygon points="65,40 65,56 80,48" style="fill: var(--color-accent)" opacity="0.35"/>
  <circle cx="75" cy="48" r="14" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" opacity="0.2"/>
  <rect x="25" y="68" width="100" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="25" y="68" width="65" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="135" y="28" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Duration</text>
  <text x="135" y="37" style="fill: var(--color-accent); font-size: 7px; font-weight: bold" opacity="0.5">5:30</text>
  <text x="135" y="50" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Uploaded</text>
  <text x="135" y="59" style="fill: var(--color-accent); font-size: 6px" opacity="0.4">2025-01</text>
  <rect x="25" y="82" width="150" height="20" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="33" y="93" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">"@type": "VideoObject"</text>
  <text x="33" y="99" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"duration": "PT5M30S"</text>
</svg>`,

'Event Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="40" height="45" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="25" y="20" width="40" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="35" y="29" style="fill: var(--color-surface); font-size: 6px; font-weight: bold">MAR</text>
  <text x="36" y="50" style="fill: var(--color-accent); font-size: 16px; font-weight: bold" opacity="0.5">15</text>
  <rect x="75" y="22" width="95" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="75" y="31" width="70" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="75" y="40" width="40" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="80" y="46" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">Online</text>
  <rect x="120" y="40" width="40" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="125" y="46" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">Free</text>
  <rect x="75" y="53" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="74" width="150" height="28" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="33" y="86" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">"@type": "Event"</text>
  <text x="33" y="94" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"eventAttendanceMode": "Online"</text>
</svg>`,

'FAQ Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="22" width="150" height="18" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="33" y="34" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.5">Q: How do I get started?</text>
  <polygon points="163,28 168,33 158,33" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="25" y="42" width="150" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.04"/>
  <rect x="33" y="46" width="120" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="33" y="51" width="100" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="60" width="150" height="18" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="33" y="72" style="fill: var(--color-text); font-size: 6px; font-weight: bold" opacity="0.35">Q: What are the requirements?</text>
  <polygon points="163,66 168,71 158,71" style="fill: var(--color-text)" opacity="0.15" transform="rotate(180 163 68.5)"/>
  <rect x="25" y="82" width="150" height="18" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="33" y="94" style="fill: var(--color-text); font-size: 6px; font-weight: bold" opacity="0.35">Q: How much does it cost?</text>
  <polygon points="163,88 168,93 158,93" style="fill: var(--color-text)" opacity="0.15" transform="rotate(180 163 90.5)"/>
</svg>`,

'HowTo Schema': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="35" cy="30" r="9" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="32" y="34" style="fill: var(--color-accent); font-size: 8px; font-weight: bold" opacity="0.6">1</text>
  <rect x="50" y="25" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="50" y="32" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <circle cx="35" cy="55" r="9" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="32" y="59" style="fill: var(--color-accent); font-size: 8px; font-weight: bold" opacity="0.6">2</text>
  <rect x="50" y="50" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="50" y="57" width="70" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <circle cx="35" cy="80" r="9" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="32" y="84" style="fill: var(--color-accent); font-size: 8px; font-weight: bold" opacity="0.6">3</text>
  <rect x="50" y="75" width="75" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="50" y="82" width="55" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <line x1="35" y1="39" x2="35" y2="46" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.2" stroke-dasharray="2 2"/>
  <line x1="35" y1="64" x2="35" y2="71" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.2" stroke-dasharray="2 2"/>
  <rect x="150" y="25" width="30" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="150" y="50" width="30" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="150" y="75" width="30" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
</svg>`,

'llms.txt': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="100" height="80" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="32" y="34" style="fill: var(--color-accent); font-size: 7px; font-family: monospace; font-weight: bold" opacity="0.6"># My Project</text>
  <rect x="32" y="40" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="32" y="46" width="65" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <text x="32" y="60" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.5">## Key Links</text>
  <rect x="32" y="66" width="70" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="32" y="72" width="60" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="32" y="78" width="75" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.1"/>
  <circle cx="155" cy="50" r="20" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.2"/>
  <text x="143" y="48" style="fill: var(--color-accent); font-size: 7px; font-weight: bold" opacity="0.5">AI</text>
  <path d="M145 56 L155 56 L165 56" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.3"/>
  <circle cx="145" cy="56" r="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <circle cx="155" cy="56" r="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <circle cx="165" cy="56" r="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <path d="M135 50 L125 50" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.3" marker-start="url(#arrowL)"/>
  <defs><marker id="arrowL" markerWidth="5" markerHeight="4" refX="0" refY="2" orient="auto"><path d="M5,0 L0,2 L5,4" style="fill: var(--color-accent)" opacity="0.3"/></marker></defs>
</svg>`,

'llms-full.txt': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="40" height="50" rx="3" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="25" y="26" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="25" y="31" width="25" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="35" width="28" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="42" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="25" y="47" width="20" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="51" width="28" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="58" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="25" y="63" width="22" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="70" y="20" width="40" height="50" rx="3" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="75" y="26" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="75" y="31" width="25" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="75" y="35" width="28" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="75" y="42" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="75" y="47" width="22" height="2" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <path d="M60 45 L70 45" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.3"/>
  <rect x="125" y="18" width="60" height="82" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-accent)" stroke-width="1" opacity="0.2"/>
  <rect x="132" y="26" width="46" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="132" y="32" width="40" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="132" y="37" width="44" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="132" y="42" width="36" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="132" y="50" width="46" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="132" y="56" width="38" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="132" y="61" width="42" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="132" y="69" width="46" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="132" y="75" width="40" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="132" y="80" width="44" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="132" y="85" width="36" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.06"/>
  <path d="M110 45 L125 45" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.4" marker-end="url(#arrowF)"/>
  <defs><marker id="arrowF" markerWidth="5" markerHeight="4" refX="4" refY="2" orient="auto"><path d="M0,0 L5,2 L0,4" style="fill: var(--color-accent)" opacity="0.4"/></marker></defs>
  <text x="30" y="82" style="fill: var(--color-text); font-size: 5px" opacity="0.3">pages</text>
  <text x="135" y="96" style="fill: var(--color-accent); font-size: 5.5px; font-weight: bold" opacity="0.4">llms-full.txt</text>
</svg>`,

'AI-Friendly Content Structure': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="80" height="7" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="30" y="26" style="fill: var(--color-accent); font-size: 5px; font-weight: bold" opacity="0.7">H1 Page Title</text>
  <rect x="25" y="32" width="110" height="4" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="38" width="95" height="4" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="30" y="48" width="55" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="35" y="53" style="fill: var(--color-accent); font-size: 4.5px; font-weight: bold" opacity="0.6">H2 Section</text>
  <rect x="30" y="58" width="90" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="35" y="66" width="45" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="40" y="70" style="fill: var(--color-accent); font-size: 4px; font-weight: bold" opacity="0.5">H3 Sub</text>
  <rect x="35" y="74" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="140" y="22" width="40" height="35" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="145" y="32" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.4">${"`"}${"`"}${"`"}ts</text>
  <rect x="145" y="36" width="30" height="2.5" rx="1" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="145" y="41" width="25" height="2.5" rx="1" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="145" y="46" width="32" height="2.5" rx="1" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="145" y="55" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.4">${"`"}${"`"}${"`"}</text>
  <rect x="140" y="65" width="40" height="30" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <rect x="145" y="70" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="145" y="74" width="32" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="145" y="78" width="28" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="145" y="82" width="30" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.06"/>
  <line x1="25" y1="45" x2="25" y2="77" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.1"/>
</svg>`,

'robots.txt AI Bot Directives': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="90" height="80" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="28" y="32" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.6">GPTBot</text>
  <rect x="65" y="27" width="30" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="70" y="33" style="fill: var(--color-accent); font-size: 4.5px" opacity="0.5">Allow</text>
  <text x="28" y="47" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.6">ClaudeBot</text>
  <rect x="75" y="42" width="30" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="80" y="48" style="fill: var(--color-accent); font-size: 4.5px" opacity="0.5">Allow</text>
  <text x="28" y="62" style="fill: var(--color-text); font-size: 5.5px; font-family: monospace" opacity="0.4">Google-Ext</text>
  <rect x="80" y="57" width="25" height="8" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <text x="83" y="63" style="fill: var(--color-text); font-size: 4.5px" opacity="0.3">Block</text>
  <text x="28" y="77" style="fill: var(--color-text); font-size: 5.5px; font-family: monospace" opacity="0.4">Bytespider</text>
  <rect x="82" y="72" width="25" height="8" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <text x="85" y="78" style="fill: var(--color-text); font-size: 4.5px" opacity="0.3">Block</text>
  <rect x="125" y="25" width="55" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="133" y="35" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">Inference</text>
  <text x="138" y="42" style="fill: var(--color-accent); font-size: 4px" opacity="0.3">(answers)</text>
  <rect x="125" y="55" width="55" height="20" rx="4" style="fill: var(--color-text)" opacity="0.05"/>
  <text x="135" y="65" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Training</text>
  <text x="138" y="72" style="fill: var(--color-text); font-size: 4px" opacity="0.2">(models)</text>
</svg>`,

'Semantic HTML for Extraction': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="18" width="160" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="28" y="28" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.5">&lt;header&gt;</text>
  <rect x="82" y="21" width="40" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="87" y="28" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.5">&lt;nav&gt;</text>
  <rect x="20" y="36" width="110" height="50" rx="3" style="fill: var(--color-accent)" opacity="0.04"/>
  <text x="28" y="46" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.5">&lt;main&gt;</text>
  <rect x="30" y="50" width="90" height="30" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="38" y="60" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.4">&lt;article&gt;</text>
  <rect x="38" y="64" width="70" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="38" y="70" width="55" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="135" y="36" width="45" height="50" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="140" y="46" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">&lt;aside&gt;</text>
  <rect x="140" y="50" width="35" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="140" y="56" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="20" y="90" width="160" height="14" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="28" y="100" style="fill: var(--color-text); font-size: 6px; font-family: monospace" opacity="0.3">&lt;footer&gt;</text>
</svg>`,

'Heading Hierarchy': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="100" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="30" y="28" style="fill: var(--color-accent); font-size: 7px; font-weight: bold" opacity="0.7">H1</text>
  <rect x="45" y="22" width="70" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="35" y="36" width="80" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="40" y="42" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.6">H2</text>
  <rect x="55" y="37" width="50" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="45" y="48" width="60" height="7" rx="2" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="50" y="53" style="fill: var(--color-accent); font-size: 5px; font-weight: bold" opacity="0.5">H3</text>
  <rect x="63" y="49" width="35" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="55" y="58" width="45" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.05"/>
  <text x="60" y="63" style="fill: var(--color-accent); font-size: 4.5px; font-weight: bold" opacity="0.4">H4</text>
  <rect x="73" y="59" width="20" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="35" y="70" width="80" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="40" y="76" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.6">H2</text>
  <rect x="55" y="71" width="55" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="45" y="82" width="60" height="7" rx="2" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="50" y="87" style="fill: var(--color-accent); font-size: 5px; font-weight: bold" opacity="0.5">H3</text>
  <rect x="63" y="83" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <line x1="27" y1="30" x2="27" y2="90" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.1"/>
  <line x1="37" y1="44" x2="37" y2="55" style="stroke: var(--color-accent)" stroke-width="0.75" opacity="0.1"/>
  <line x1="37" y1="78" x2="37" y2="88" style="stroke: var(--color-accent)" stroke-width="0.75" opacity="0.1"/>
</svg>`,

'Internal Linking Strategy': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="100" cy="40" r="16" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="88" y="35" width="24" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="93" y="42" style="fill: var(--color-surface); font-size: 5px; font-weight: bold">Hub</text>
  <circle cx="45" cy="35" r="10" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="37" y="32" width="16" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="155" cy="35" r="10" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="147" y="32" width="16" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="55" cy="80" r="10" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="47" y="77" width="16" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="100" cy="90" r="10" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="92" y="87" width="16" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="145" cy="80" r="10" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="137" y="77" width="16" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <line x1="84" y1="38" x2="55" y2="36" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.25"/>
  <line x1="116" y1="38" x2="145" y2="36" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.25"/>
  <line x1="90" y1="52" x2="60" y2="74" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.25"/>
  <line x1="100" y1="56" x2="100" y2="80" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.25"/>
  <line x1="110" y1="52" x2="140" y2="74" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.25"/>
  <line x1="65" y1="80" x2="90" y2="88" style="stroke: var(--color-border)" stroke-width="0.5" opacity="0.3" stroke-dasharray="2 2"/>
  <line x1="110" y1="88" x2="135" y2="82" style="stroke: var(--color-border)" stroke-width="0.5" opacity="0.3" stroke-dasharray="2 2"/>
</svg>`,

'Image SEO': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="70" height="50" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border)" stroke-width="0.75"/>
  <circle cx="48" cy="36" r="8" style="fill: var(--color-accent)" opacity="0.1"/>
  <path d="M30 60 L45 45 L60 55 L75 40 L90 55 L90 65 L30 65 Z" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="25" y="72" width="70" height="12" rx="2" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="30" y="80" style="fill: var(--color-accent); font-size: 5px; font-family: monospace" opacity="0.5">alt="Dashboard..."</text>
  <rect x="110" y="20" width="70" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="116" y="29" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">loading="lazy"</text>
  <rect x="110" y="38" width="70" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="116" y="47" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">width + height</text>
  <rect x="110" y="56" width="70" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="116" y="65" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">WebP / AVIF</text>
  <rect x="110" y="74" width="70" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="116" y="83" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">srcset + sizes</text>
</svg>`,

'Anchor-Based Deep Linking': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="120" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="30" y="28" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.5">Section Title</text>
  <text x="120" y="28" style="fill: var(--color-accent); font-size: 8px" opacity="0.3">#</text>
  <rect x="25" y="34" width="100" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="40" width="90" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="25" y="50" width="110" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="30" y="58" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.5">Another Section</text>
  <text x="115" y="58" style="fill: var(--color-accent); font-size: 8px" opacity="0.3">#</text>
  <rect x="25" y="64" width="95" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="25" y="70" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="150" y="22" width="35" height="30" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="153" y="32" style="fill: var(--color-accent); font-size: 4.5px; font-family: monospace" opacity="0.4">#section-1</text>
  <text x="153" y="40" style="fill: var(--color-accent); font-size: 4.5px; font-family: monospace" opacity="0.4">#section-2</text>
  <text x="153" y="48" style="fill: var(--color-accent); font-size: 4.5px; font-family: monospace" opacity="0.4">#section-3</text>
  <rect x="25" y="82" width="160" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="32" y="92" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.4">example.com/docs/setup#section-2</text>
</svg>`,

'OG Image Generation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="18" width="150" height="80" rx="6" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-accent)" stroke-width="1" opacity="0.2"/>
  <rect x="35" y="28" width="40" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="41" y="37" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.6">Logo</text>
  <rect x="35" y="48" width="130" height="8" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <text x="40" y="54" style="fill: var(--color-text); font-size: 5.5px; font-weight: bold" opacity="0.5">Page Title Goes Here</text>
  <rect x="35" y="62" width="100" height="4" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="35" y="70" width="80" height="4" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="35" y="82" width="50" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="40" y="88" style="fill: var(--color-accent); font-size: 4.5px" opacity="0.4">example.com</text>
  <text x="140" y="88" style="fill: var(--color-text); font-size: 4px" opacity="0.25">1200 x 630</text>
</svg>`,

'Share URL Hygiene': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="22" width="160" height="16" rx="4" style="fill: var(--color-text)" opacity="0.05"/>
  <text x="28" y="33" style="fill: var(--color-text); font-size: 5.5px; font-family: monospace" opacity="0.3">example.com/blog/post?fbclid=abc&amp;utm_s...</text>
  <line x1="20" y1="30" x2="180" y2="30" style="stroke: var(--color-text)" stroke-width="1" opacity="0.15"/>
  <path d="M100 42 L100 52" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.3" marker-end="url(#arrowH)"/>
  <defs><marker id="arrowH" markerWidth="5" markerHeight="4" refX="4" refY="2" orient="auto"><path d="M0,0 L5,2 L0,4" style="fill: var(--color-accent)" opacity="0.3"/></marker></defs>
  <rect x="20" y="55" width="160" height="16" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="28" y="66" style="fill: var(--color-accent); font-size: 6px; font-family: monospace" opacity="0.6">example.com/blog/post</text>
  <circle cx="170" cy="63" r="6" style="fill: var(--color-accent)" opacity="0.15"/>
  <path d="M167 63 L170 66 L174 60" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.6"/>
  <rect x="20" y="80" width="70" height="20" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="28" y="92" style="fill: var(--color-text); font-size: 5px" opacity="0.3">+ utm_source=twitter</text>
  <text x="100" y="92" style="fill: var(--color-text); font-size: 4.5px" opacity="0.2">(added on share click)</text>
</svg>`,

'Rich Link Preview Testing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="70" height="50" rx="4" style="stroke: var(--color-border)" stroke-width="0.75"/>
  <rect x="25" y="20" width="70" height="25" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <rect x="32" y="28" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="32" y="35" width="50" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="32" y="50" width="45" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="32" y="57" width="55" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="32" y="63" width="40" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.04"/>
  <rect x="110" y="20" width="70" height="50" rx="4" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.3"/>
  <rect x="110" y="20" width="70" height="25" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="117" y="28" width="40" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="117" y="35" width="50" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="117" y="50" width="45" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="117" y="57" width="55" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="117" y="63" width="40" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.06"/>
  <circle cx="172" cy="25" r="6" style="fill: var(--color-accent)" opacity="0.15"/>
  <path d="M169 25 L172 28 L176 22" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.6"/>
  <rect x="25" y="80" width="50" height="20" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="32" y="92" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Facebook</text>
  <rect x="85" y="80" width="50" height="20" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="95" y="92" style="fill: var(--color-text); font-size: 5px" opacity="0.3">Twitter</text>
  <rect x="145" y="80" width="40" height="20" rx="3" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="150" y="92" style="fill: var(--color-text); font-size: 5px" opacity="0.3">LinkedIn</text>
</svg>`,

'Structured Data Validation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="90" height="50" rx="4" style="fill: var(--color-text)" opacity="0.03"/>
  <text x="32" y="32" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">{"@type": "..."</text>
  <text x="35" y="42" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"name": "..."</text>
  <text x="35" y="52" style="fill: var(--color-text); font-size: 5px; font-family: monospace" opacity="0.3">"url": "..."</text>
  <text x="32" y="62" style="fill: var(--color-accent); font-size: 5.5px; font-family: monospace" opacity="0.5">}</text>
  <path d="M115 45 L130 45" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.3" marker-end="url(#arrowV)"/>
  <defs><marker id="arrowV" markerWidth="5" markerHeight="4" refX="4" refY="2" orient="auto"><path d="M0,0 L5,2 L0,4" style="fill: var(--color-accent)" opacity="0.3"/></marker></defs>
  <rect x="130" y="25" width="50" height="40" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <circle cx="155" cy="38" r="8" style="fill: var(--color-accent)" opacity="0.12"/>
  <path d="M151 38 L155 42 L160 34" style="stroke: var(--color-accent)" stroke-width="2" fill="none" opacity="0.5"/>
  <text x="140" y="56" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">Valid</text>
  <rect x="25" y="78" width="60" height="16" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="32" y="89" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">Build check</text>
  <rect x="95" y="78" width="80" height="16" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="102" y="89" style="fill: var(--color-accent); font-size: 5px" opacity="0.4">Rich Results Test</text>
</svg>`,

'Search Console Integration': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="16" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="28" y="30" style="fill: var(--color-accent); font-size: 6px; font-weight: bold" opacity="0.5">Search Console</text>
  <rect x="140" y="23" width="30" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="146" y="30" style="fill: var(--color-accent); font-size: 5px" opacity="0.5">Live</text>
  <rect x="20" y="42" width="50" height="30" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="26" y="52" style="fill: var(--color-text); font-size: 4.5px; font-weight: bold" opacity="0.3">Impressions</text>
  <polyline points="28,65 35,60 42,62 50,55 58,58 65,52" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.4"/>
  <rect x="78" y="42" width="50" height="30" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="84" y="52" style="fill: var(--color-text); font-size: 4.5px; font-weight: bold" opacity="0.3">Coverage</text>
  <rect x="86" y="56" width="8" height="12" rx="1" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="97" y="60" width="8" height="8" rx="1" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="108" y="54" width="8" height="14" rx="1" style="fill: var(--color-accent)" opacity="0.25"/>
  <rect x="136" y="42" width="50" height="30" rx="4" style="fill: var(--color-text)" opacity="0.04"/>
  <text x="142" y="52" style="fill: var(--color-text); font-size: 4.5px; font-weight: bold" opacity="0.3">Vitals</text>
  <circle cx="161" cy="62" r="8" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.2"/>
  <path d="M161 54 A8 8 0 0 1 169 62" style="stroke: var(--color-accent)" stroke-width="2" fill="none" opacity="0.5"/>
  <rect x="20" y="80" width="160" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.04"/>
  <rect x="28" y="86" width="8" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="40" y="87" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="40" y="92" width="40" height="2.5" rx="1" style="fill: var(--color-text)" opacity="0.06"/>
</svg>`,

'Cache-Control for HTML Pages': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="70" height="35" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="55" y="34" text-anchor="middle" style="font-size: 8px; font-weight: 700; fill: var(--color-accent)">Browser</text>
  <text x="55" y="46" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-secondary)">no-cache</text>
  <path d="M90 38 L110 38" style="stroke: var(--color-accent)" stroke-width="1.5" marker-end="url(#arr-cc1)"/>
  <defs><marker id="arr-cc1" viewBox="0 0 6 6" refX="6" refY="3" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L6,3 L0,6" style="fill: var(--color-accent)"/></marker></defs>
  <rect x="110" y="20" width="70" height="35" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="145" y="34" text-anchor="middle" style="font-size: 8px; font-weight: 700; fill: var(--color-accent)">Server</text>
  <text x="145" y="46" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-secondary)">304 or 200</text>
  <rect x="20" y="65" width="70" height="18" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="55" y="77" text-anchor="middle" style="font-size: 7px; fill: var(--color-accent)">304 → use cache</text>
  <rect x="110" y="65" width="70" height="18" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="145" y="77" text-anchor="middle" style="font-size: 7px; fill: var(--color-accent)">200 → new HTML</text>
  <text x="100" y="98" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-muted)">Always revalidate, cache if unchanged</text>
</svg>`,

'Cache-Control for Fingerprinted Assets': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="22" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="100" y="34" text-anchor="middle" style="font-size: 8px; font-weight: 700; fill: var(--color-accent)">max-age=31536000, immutable</text>
  <rect x="20" y="50" width="50" height="28" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="45" y="62" text-anchor="middle" style="font-size: 7px; font-weight: 600; fill: var(--color-accent)">.ae3f66.css</text>
  <text x="45" y="73" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">1 year cache</text>
  <rect x="75" y="50" width="50" height="28" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="100" y="62" text-anchor="middle" style="font-size: 7px; font-weight: 600; fill: var(--color-accent)">.1be87a.js</text>
  <text x="100" y="73" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">No revalidate</text>
  <rect x="130" y="50" width="50" height="28" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="155" y="62" text-anchor="middle" style="font-size: 7px; font-weight: 600; fill: var(--color-accent)">.f4c2d1.woff</text>
  <text x="155" y="73" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">Skip on refresh</text>
  <text x="100" y="98" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-muted)">Hash in filename = safe to cache forever</text>
</svg>`,

'Cache-Control for Dynamic API Data': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="18" y="18" width="54" height="44" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="45" y="30" text-anchor="middle" style="font-size: 7px; font-weight: 700; fill: var(--color-accent)">Non-critical</text>
  <text x="45" y="42" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">max-age=60</text>
  <text x="45" y="52" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">swr=300</text>
  <rect x="76" y="18" width="52" height="44" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="102" y="30" text-anchor="middle" style="font-size: 7px; font-weight: 700; fill: var(--color-accent)">Critical</text>
  <text x="102" y="42" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">no-cache</text>
  <text x="102" y="52" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">always fresh</text>
  <rect x="132" y="18" width="52" height="44" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="158" y="30" text-anchor="middle" style="font-size: 7px; font-weight: 700; fill: var(--color-accent)">Sensitive</text>
  <text x="158" y="42" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">private</text>
  <text x="158" y="52" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">no-store</text>
  <rect x="18" y="70" width="164" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="100" y="84" text-anchor="middle" style="font-size: 7px; font-weight: 600; fill: var(--color-accent)">CDN: s-maxage=3600</text>
  <text x="100" y="94" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">Different TTL for CDN vs browser cache</text>
</svg>`,

'Cache-Control for Images & Media': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="18" y="18" width="50" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="24" y="24" width="38" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="43" y="38" text-anchor="middle" style="font-size: 10px; fill: var(--color-accent)">🖼</text>
  <text x="43" y="54" text-anchor="middle" style="font-size: 5.5px; fill: var(--color-text-secondary)">28 days</text>
  <rect x="74" y="18" width="50" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="80" y="24" width="38" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="99" y="38" text-anchor="middle" style="font-size: 10px; fill: var(--color-accent)">🎬</text>
  <text x="99" y="54" text-anchor="middle" style="font-size: 5.5px; fill: var(--color-text-secondary)">immutable</text>
  <rect x="130" y="18" width="50" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="136" y="24" width="38" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="155" y="38" text-anchor="middle" style="font-size: 10px; fill: var(--color-accent)">👤</text>
  <text x="155" y="54" text-anchor="middle" style="font-size: 5.5px; fill: var(--color-text-secondary)">1 hour</text>
  <text x="100" y="76" text-anchor="middle" style="font-size: 7px; fill: var(--color-accent)">ETag + Last-Modified for revalidation</text>
  <text x="100" y="90" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-muted)">Fingerprinted → immutable | General → 28d | Uploads → 1h</text>
</svg>`,

'Cache Busting Strategy': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="18" y="18" width="164" height="22" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <text x="100" y="28" text-anchor="middle" style="font-size: 7px; font-weight: 700; fill: var(--color-accent)">✓ style.ae3f66.css → content hash</text>
  <text x="100" y="37" text-anchor="middle" style="font-size: 6px; fill: var(--color-text-secondary)">Change content → new hash → new URL → cache busted</text>
  <rect x="18" y="46" width="164" height="14" rx="3" style="fill: var(--color-text-muted)" opacity="0.1"/>
  <text x="100" y="56" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-muted)">⚠ style.css?v=1.2 → query string (unreliable)</text>
  <rect x="18" y="64" width="164" height="14" rx="3" style="fill: #fef2f2"/>
  <text x="100" y="74" text-anchor="middle" style="font-size: 7px; fill: #ef4444">✕ style.css → no busting (dangerous)</text>
  <rect x="18" y="86" width="164" height="18" rx="3" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="100" y="98" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-secondary)">Build tools (Vite, webpack) fingerprint automatically</text>
</svg>`,

'Stale-While-Revalidate Pattern': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="100" y="24" text-anchor="middle" style="font-size: 8px; font-weight: 700; fill: var(--color-text)">Timeline</text>
  <line x1="30" y1="42" x2="170" y2="42" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="30" y="34" width="46" height="16" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="53" y="45" text-anchor="middle" style="font-size: 6px; font-weight: 600; fill: var(--color-accent)">Fresh (1h)</text>
  <rect x="76" y="34" width="70" height="16" rx="2" style="fill: #fefce8" stroke="#eab308" stroke-width="0.5"/>
  <text x="111" y="45" text-anchor="middle" style="font-size: 6px; font-weight: 600; fill: #a16207">Stale OK (24h)</text>
  <rect x="146" y="34" width="24" height="16" rx="2" style="fill: #fef2f2" stroke="#ef4444" stroke-width="0.5"/>
  <text x="158" y="45" text-anchor="middle" style="font-size: 5px; fill: #ef4444">Must</text>
  <text x="100" y="66" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-secondary)">Serve stale → revalidate in background</text>
  <text x="100" y="78" text-anchor="middle" style="font-size: 7px; fill: var(--color-text-secondary)">User sees content instantly</text>
  <rect x="30" y="86" width="140" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="100" y="96" text-anchor="middle" style="font-size: 6px; fill: var(--color-accent)">+ stale-if-error=86400 for outage resilience</text>
</svg>`,

};
