/** SVG illustrations for Filter & Search Patterns */
export const filterSearchPatternSvgs: Record<string, string> = {

'Search Bar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="40" width="160" height="32" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="40" cy="56" r="7" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5"/>
  <line x1="45" y1="61" x2="50" y2="66" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="56" y="60" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Search...</text>
</svg>`,

'Instant Search': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">react ho|</text>
  <rect x="20" y="42" width="160" height="68" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="26" y="48" width="148" height="18" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="34" y="61" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">React Hooks Guide</text>
  <text x="34" y="80" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">React Hot Toast</text>
  <text x="34" y="98" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">React Hook Form</text>
</svg>`,

'Search Suggestions': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">sneakers</text>
  <rect x="20" y="42" width="160" height="70" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="58" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">sneakers men</text>
  <text x="34" y="74" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">sneakers women</text>
  <text x="34" y="90" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">sneakers sale</text>
  <text x="34" y="104" style="fill: var(--color-text-muted); font-size: 8px; font-style: italic; font-family: var(--font-sans)">Popular searches</text>
</svg>`,

'Search Results Page': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="18" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">247 results for "hooks"</text>
  <rect x="20" y="26" width="160" height="26" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="37" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">React Hooks Guide</text>
  <text x="28" y="48" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Learn about useState, useEffect...</text>
  <rect x="20" y="56" width="160" height="26" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="67" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Custom Hooks</text>
  <text x="28" y="78" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Building reusable hooks...</text>
  <rect x="20" y="86" width="160" height="26" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="97" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Hook Rules</text>
  <text x="28" y="108" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Rules of hooks explained...</text>
</svg>`,

'Faceted Search': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="55" height="100" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="16" y="24" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Brand</text>
  <rect x="16" y="28" width="8" height="8" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="28" y="36" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Nike (42)</text>
  <rect x="16" y="40" width="8" height="8" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="28" y="48" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Adidas (38)</text>
  <text x="16" y="66" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Price</text>
  <rect x="16" y="72" width="40" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="72" width="24" height="4" rx="2" style="fill: var(--color-accent)"/>
  <circle cx="40" cy="74" r="4" style="fill: var(--color-accent)"/>
  <rect x="75" y="10" width="115" height="28" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="75" y="42" width="115" height="28" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="75" y="74" width="115" height="28" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

'Full-Text Search': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">deployment</text>
  <rect x="20" y="48" width="160" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="62" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">...configure the <tspan style="fill: var(--color-accent); font-weight: 700">deployment</tspan> pipeline</text>
  <text x="28" y="74" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">in CI/CD docs, page 3</text>
  <rect x="20" y="84" width="160" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="98" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">...automated <tspan style="fill: var(--color-accent); font-weight: 700">deployment</tspan> strategies</text>
  <text x="28" y="110" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">in Architecture docs, page 7</text>
</svg>`,

'Fuzzy Matching': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="33" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">javasrcip</text>
  <text x="20" y="62" style="fill: var(--color-text-muted); font-size: 9px; font-style: italic; font-family: var(--font-sans)">Did you mean:</text>
  <text x="20" y="78" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">javascript</text>
  <text x="20" y="100" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Showing results for "javascript"</text>
</svg>`,

'Recent Searches': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="28" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Search...</text>
  <rect x="20" y="42" width="160" height="70" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="30" y="56" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Recent</text>
  <text x="140" y="56" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Clear</text>
  <text x="38" y="72" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">react hooks</text>
  <text x="38" y="88" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">deployment guide</text>
  <text x="38" y="104" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">api reference</text>
</svg>`,

'Saved Searches': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="130" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="26" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">react + frontend</text>
  <rect x="155" y="12" width="28" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="169" y="26" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Save</text>
  <text x="20" y="52" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Saved Searches</text>
  <rect x="20" y="58" width="160" height="18" rx="3" style="fill: var(--color-surface)"/>
  <text x="28" y="70" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">Frontend jobs - Remote</text>
  <rect x="20" y="78" width="160" height="18" rx="3" style="fill: var(--color-surface)"/>
  <text x="28" y="90" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">React Senior - $150k+</text>
</svg>`,

'Search Scoping': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="30" width="50" height="28" rx="6 0 0 6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="30" y="48" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">All &#x25BE;</text>
  <rect x="70" y="30" width="110" height="28" rx="0 6 6 0" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="80" y="48" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Search...</text>
  <rect x="20" y="68" width="160" height="18" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="28" y="80" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">All | Docs | API | Blog | Community</text>
</svg>`,

'Sidebar Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="5" width="60" height="110" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="16" y="20" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Category &#x25B4;</text>
  <rect x="16" y="24" width="8" height="8" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="28" y="32" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Books</text>
  <rect x="16" y="36" width="8" height="8" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="28" y="44" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Music</text>
  <text x="16" y="62" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Rating &#x25B4;</text>
  <text x="16" y="76" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">&#x2605;&#x2605;&#x2605;&#x2605;&#x2606;</text>
  <text x="16" y="90" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">&#x2605;&#x2605;&#x2605;&#x2606;&#x2606;</text>
  <text x="16" y="104" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Price &#x25BE;</text>
  <rect x="80" y="5" width="110" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="80" y="41" width="110" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="80" y="77" width="110" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

'Horizontal Filter Bar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="15" width="50" height="22" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="18" y="30" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Brand &#x25BE;</text>
  <rect x="64" y="15" width="45" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="72" y="30" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Price &#x25BE;</text>
  <rect x="113" y="15" width="40" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="120" y="30" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Size &#x25BE;</text>
  <rect x="157" y="15" width="36" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="163" y="30" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Color</text>
  <rect x="10" y="48" width="183" height="60" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="20" y="66" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">124 results</text>
</svg>`,

'Filter Chips': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="40" width="58" height="22" rx="11" style="fill: var(--color-accent-bg)"/>
  <text x="18" y="55" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Nike &#x2715;</text>
  <rect x="72" y="40" width="50" height="22" rx="11" style="fill: var(--color-accent-bg)"/>
  <text x="80" y="55" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">$50+ &#x2715;</text>
  <rect x="126" y="40" width="64" height="22" rx="11" style="fill: var(--color-accent-bg)"/>
  <text x="134" y="55" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">In stock &#x2715;</text>
  <text x="10" y="82" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">3 filters active</text>
  <text x="140" y="82" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">Clear all</text>
</svg>`,

'Multi-Select Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="18" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Brand</text>
  <rect x="20" y="24" width="10" height="10" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="20" y="32" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 700; font-family: var(--font-sans)"></text>
  <text x="35" y="33" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Nike</text>
  <text x="150" y="33" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">(42)</text>
  <rect x="20" y="40" width="10" height="10" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="35" y="49" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Adidas</text>
  <text x="150" y="49" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">(38)</text>
  <rect x="20" y="56" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="65" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Puma</text>
  <text x="150" y="65" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">(21)</text>
  <rect x="20" y="72" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="81" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Reebok</text>
  <text x="150" y="81" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">(15)</text>
  <text x="20" y="100" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">Show 8 more</text>
</svg>`,

'Range Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="20" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Price Range</text>
  <rect x="20" y="35" width="160" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="50" y="35" width="80" height="6" rx="3" style="fill: var(--color-accent)"/>
  <circle cx="50" cy="38" r="7" style="fill: var(--color-accent); stroke: var(--color-surface)" stroke-width="2"/>
  <circle cx="130" cy="38" r="7" style="fill: var(--color-accent); stroke: var(--color-surface)" stroke-width="2"/>
  <rect x="20" y="58" width="70" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="74" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">$25</text>
  <text x="98" y="74" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">to</text>
  <rect x="110" y="58" width="70" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="118" y="74" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">$150</text>
</svg>`,

'Toggle Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="32" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">In stock only</text>
  <rect x="140" y="20" width="36" height="20" rx="10" style="fill: var(--color-accent)"/>
  <circle cx="166" cy="30" r="8" style="fill: #fff"/>
  <text x="20" y="62" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Free shipping</text>
  <rect x="140" y="50" width="36" height="20" rx="10" style="fill: var(--color-accent)"/>
  <circle cx="166" cy="60" r="8" style="fill: #fff"/>
  <text x="20" y="92" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">On sale</text>
  <rect x="140" y="80" width="36" height="20" rx="10" style="fill: var(--color-surface-2)"/>
  <circle cx="150" cy="90" r="8" style="fill: #fff"/>
</svg>`,

'Cascading Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="18" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Category</text>
  <rect x="20" y="22" width="160" height="24" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="30" y="38" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Electronics</text>
  <line x1="100" y1="46" x2="100" y2="54" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <polygon points="96,54 100,60 104,54" style="fill: var(--color-accent)"/>
  <text x="20" y="70" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Subcategory</text>
  <rect x="20" y="74" width="160" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="30" y="90" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Screen Size &#x25BE;</text>
</svg>`,

'Filter Presets': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="42" width="52" height="24" rx="12" style="fill: var(--color-accent)"/>
  <text x="20" y="58" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Top Rated</text>
  <rect x="66" y="42" width="54" height="24" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="76" y="58" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">New Arrivals</text>
  <rect x="124" y="42" width="66" height="24" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="134" y="58" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Budget Picks</text>
  <text x="10" y="86" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Quick filter presets</text>
</svg>`,

'Saved Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="30" y="28" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">My Filters &#x25BE;</text>
  <rect x="20" y="42" width="160" height="68" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="30" y="58" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">Work Laptop Search</text>
  <text x="30" y="72" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Brand: Dell, Price: $800-1200</text>
  <line x1="26" y1="80" x2="174" y2="80" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="30" y="94" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">Budget Monitor</text>
  <text x="30" y="106" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Size: 27", Price: &lt;$300</text>
</svg>`,

'Search Within Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="16" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Brand</text>
  <rect x="20" y="22" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="30" y="37" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Search brands...</text>
  <rect x="20" y="50" width="10" height="10" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="35" y="59" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Nike (42)</text>
  <rect x="20" y="66" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="75" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">New Balance (28)</text>
  <rect x="20" y="82" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="91" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">North Face (19)</text>
  <text x="20" y="110" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Showing 3 of 47 brands matching "n"</text>
</svg>`,

'Sort Dropdown': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="22" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">247 results</text>
  <rect x="110" y="8" width="75" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="120" y="24" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Relevance &#x25BE;</text>
  <rect x="110" y="36" width="75" height="76" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="114" y="40" width="67" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="120" y="52" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Relevance</text>
  <text x="120" y="70" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Newest</text>
  <text x="120" y="86" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Price: Low &#x2192; High</text>
  <text x="120" y="102" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Price: High &#x2192; Low</text>
</svg>`,

'Column Sort': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="15" width="180" height="22" rx="0" style="fill: var(--color-surface-2)"/>
  <text x="18" y="30" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Name</text>
  <text x="80" y="30" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Price &#x25B2;</text>
  <text x="140" y="30" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Rating</text>
  <line x1="10" y1="37" x2="190" y2="37" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="18" y="52" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Widget A</text>
  <text x="80" y="52" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">$12.99</text>
  <text x="140" y="52" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">4.5</text>
  <line x1="10" y1="58" x2="190" y2="58" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="18" y="72" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Widget B</text>
  <text x="80" y="72" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">$24.99</text>
  <text x="140" y="72" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">4.8</text>
  <line x1="10" y1="78" x2="190" y2="78" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="18" y="92" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Widget C</text>
  <text x="80" y="92" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">$34.99</text>
  <text x="140" y="92" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">4.2</text>
</svg>`,

'Default Sort Order': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="22" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Default sort by context:</text>
  <text x="20" y="46" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Search</text>
  <text x="80" y="46" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">&#x2192; Relevance</text>
  <text x="20" y="66" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Feed</text>
  <text x="80" y="66" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">&#x2192; Newest first</text>
  <text x="20" y="86" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Products</text>
  <text x="80" y="86" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">&#x2192; Recommended</text>
  <text x="20" y="106" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-family: var(--font-sans)">&#x2717; Avoid alphabetical as default</text>
</svg>`,

'Sort Direction Indicators': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="30" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Name</text>
  <text x="50" y="30" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">&#x21C5;</text>
  <text x="80" y="20" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">unsorted</text>
  <text x="20" y="62" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Price</text>
  <text x="50" y="62" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">&#x25B2;</text>
  <text x="80" y="52" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">ascending</text>
  <text x="20" y="94" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Date</text>
  <text x="50" y="94" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">&#x25BC;</text>
  <text x="80" y="84" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">descending</text>
</svg>`,

'Search + Filter + Sort Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="5" width="180" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="18" y="18" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">&#x1F50D; Search products...</text>
  <rect x="10" y="30" width="35" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="15" y="40" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Brand</text>
  <rect x="48" y="30" width="35" height="14" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="53" y="40" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Price</text>
  <rect x="86" y="30" width="35" height="14" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="91" y="40" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Rating</text>
  <text x="10" y="60" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">124 results</text>
  <text x="145" y="60" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Sort: Relevance</text>
  <rect x="10" y="66" width="88" height="46" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="102" y="66" width="88" height="46" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

'URL-Synced Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="15" width="180" height="22" rx="4" style="fill: var(--color-surface-2)"/>
  <text x="18" y="30" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)">site.com/shop?brand=nike&amp;min=50&amp;sort=price</text>
  <line x1="100" y1="42" x2="100" y2="52" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <polygon points="96,52 100,58 104,52" style="fill: var(--color-accent)"/>
  <rect x="20" y="62" width="55" height="18" rx="9" style="fill: var(--color-accent-bg)"/>
  <text x="30" y="74" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Nike &#x2715;</text>
  <rect x="80" y="62" width="55" height="18" rx="9" style="fill: var(--color-accent-bg)"/>
  <text x="90" y="74" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">$50+ &#x2715;</text>
  <text x="20" y="100" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">&#x2190; &#x2192; Bookmark / Share / Back</text>
</svg>`,

'Filter Counts': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="18" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Size</text>
  <rect x="20" y="24" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="33" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Small</text>
  <rect x="140" y="24" width="28" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="154" y="34" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">42</text>
  <rect x="20" y="42" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="51" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Medium</text>
  <rect x="140" y="42" width="28" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="154" y="52" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">87</text>
  <rect x="20" y="60" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="69" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Large</text>
  <rect x="140" y="60" width="28" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="154" y="70" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">31</text>
  <rect x="20" y="78" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="87" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">XL</text>
  <rect x="140" y="78" width="28" height="14" rx="7" style="fill: var(--color-surface-2)"/>
  <text x="154" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">0</text>
</svg>`,

'Active Filter Summary': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="20" width="180" height="36" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="18" y="34" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Active filters:</text>
  <rect x="18" y="38" width="44" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="24" y="48" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Nike &#x2715;</text>
  <rect x="66" y="38" width="38" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="72" y="48" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">$50+ &#x2715;</text>
  <rect x="108" y="38" width="50" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="114" y="48" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">4+ stars &#x2715;</text>
  <text x="164" y="48" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Clear all</text>
  <text x="18" y="76" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Showing 42 of 1,247 products</text>
  <rect x="10" y="82" width="88" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="102" y="82" width="88" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

'Apply Button with Count': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="20" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Brand</text>
  <rect x="20" y="26" width="10" height="10" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="35" y="35" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Nike</text>
  <rect x="20" y="40" width="10" height="10" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="35" y="49" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Adidas</text>
  <rect x="20" y="54" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="35" y="63" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Puma</text>
  <rect x="20" y="80" width="160" height="30" rx="6" style="fill: var(--color-accent)"/>
  <text x="100" y="99" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Show 80 results</text>
</svg>`,

'Debounced Search Input': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="34" y="33" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">react ho|</text>
  <text x="20" y="62" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">r</text>
  <text x="40" y="62" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">re</text>
  <text x="60" y="62" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">rea</text>
  <text x="80" y="62" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">reac</text>
  <text x="100" y="62" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">react</text>
  <text x="130" y="62" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">&#x2192; API</text>
  <text x="20" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">keystrokes debounced (300ms)</text>
  <text x="130" y="80" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">single request</text>
</svg>`,

'Server-Side vs Client-Side Filtering': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="50" y="16" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Client-Side</text>
  <rect x="15" y="22" width="70" height="40" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1"/>
  <text x="22" y="36" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">All data loaded</text>
  <text x="22" y="48" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Filter in browser</text>
  <text x="22" y="56" style="fill: hsl(142, 71%, 45%); font-size: 7px; font-family: var(--font-sans)">&#x2713; &lt;1000 items</text>
  <text x="150" y="16" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Server-Side</text>
  <rect x="115" y="22" width="70" height="40" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1"/>
  <text x="122" y="36" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Send params to API</text>
  <text x="122" y="48" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Get filtered results</text>
  <text x="122" y="56" style="fill: hsl(142, 71%, 45%); font-size: 7px; font-family: var(--font-sans)">&#x2713; Large datasets</text>
  <text x="100" y="84" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Hybrid</text>
  <rect x="45" y="88" width="110" height="26" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="52" y="104" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Server initial + Client refine</text>
</svg>`,

'Filter Result Caching': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="68" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="31" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">brand=nike</text>
  <text x="96" y="31" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">&#x2192;</text>
  <rect x="110" y="15" width="70" height="24" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="118" y="31" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Cached &#x2713;</text>
  <rect x="20" y="50" width="68" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="66" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">brand=adidas</text>
  <text x="96" y="66" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">&#x2192;</text>
  <rect x="110" y="50" width="70" height="24" rx="4" style="stroke: hsl(38, 92%, 50%); fill: var(--color-surface)" stroke-width="1"/>
  <text x="118" y="66" style="fill: hsl(38, 92%, 50%); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Stale (30s)</text>
  <rect x="20" y="85" width="68" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="101" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">brand=puma</text>
  <text x="96" y="101" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">&#x2192;</text>
  <rect x="110" y="85" width="70" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="118" y="101" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Fetch...</text>
</svg>`,

'Search Indexing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="30" y="16" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Documents</text>
  <rect x="15" y="22" width="50" height="14" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="15" y="38" width="50" height="14" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="15" y="54" width="50" height="14" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="80" y="46" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">&#x2192;</text>
  <text x="120" y="16" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Index</text>
  <rect x="95" y="22" width="90" height="50" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="102" y="36" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-mono)">react &#x2192; [1,3]</text>
  <text x="102" y="48" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-mono)">hooks &#x2192; [1,2]</text>
  <text x="102" y="60" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-mono)">form  &#x2192; [2,3]</text>
  <text x="20" y="88" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Pagefind | Lunr | Fuse.js | Meilisearch | Algolia</text>
</svg>`,

'Search Landmark': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="20" width="170" height="50" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="22" y="16" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">&lt;search&gt;</text>
  <rect x="25" y="32" width="120" height="26" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="34" y="49" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Search...</text>
  <rect x="150" y="32" width="28" height="26" rx="5" style="fill: var(--color-accent)"/>
  <text x="164" y="49" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Go</text>
  <text x="20" y="90" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Screen readers: "Search landmark"</text>
  <text x="20" y="104" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Jump via landmark navigation</text>
</svg>`,

'Live Result Count': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="26" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="32" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">sneakers</text>
  <rect x="20" y="50" width="160" height="24" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="28" y="60" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-mono)">aria-live="polite"</text>
  <text x="28" y="70" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">247 results found</text>
  <text x="20" y="96" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">&#x1F50A; "247 results found"</text>
  <text x="20" y="110" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Announced after debounce settles</text>
</svg>`,

'Filter Keyboard Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="30" height="18" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="28" y="22" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Tab</text>
  <text x="56" y="22" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Move between groups</text>
  <rect x="20" y="34" width="30" height="18" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="24" y="46" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Space</text>
  <text x="56" y="46" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Toggle checkbox</text>
  <rect x="20" y="58" width="30" height="18" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="28" y="70" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">&#x2191; &#x2193;</text>
  <text x="56" y="70" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Navigate within group</text>
  <rect x="20" y="82" width="30" height="18" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="26" y="94" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Enter</text>
  <text x="56" y="94" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Apply / activate button</text>
</svg>`,

'Filter Group Labeling': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="22" y="8" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-mono)">&lt;fieldset&gt;</text>
  <text x="22" y="26" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Brand</text>
  <text x="60" y="26" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-mono)">&lt;legend&gt;</text>
  <rect x="22" y="34" width="10" height="10" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="38" y="43" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Nike</text>
  <rect x="22" y="50" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="38" y="59" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Adidas</text>
  <rect x="22" y="66" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="38" y="75" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Puma</text>
  <text x="22" y="98" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">SR: "Brand group, Nike checkbox, checked"</text>
</svg>`,

'Bottom Sheet Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="5" width="120" height="110" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="88" y="10" width="24" height="4" rx="2" style="fill: var(--color-text-muted)"/>
  <rect x="40" y="40" width="120" height="75" rx="0 0 12 12" style="fill: var(--color-surface-2)"/>
  <rect x="88" y="44" width="24" height="3" rx="1.5" style="fill: var(--color-text-muted)"/>
  <text x="48" y="60" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Filters</text>
  <text x="146" y="60" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">&#x2715;</text>
  <rect x="48" y="66" width="8" height="8" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="60" y="74" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">In stock</text>
  <rect x="48" y="80" width="8" height="8" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="60" y="88" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">On sale</text>
  <rect x="48" y="96" width="104" height="16" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="107" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 700; font-family: var(--font-sans)">Show 42 results</text>
</svg>`,

'Collapsible Filter Panel': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="22" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="30" y="24" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Brand &#x25B4;</text>
  <rect x="20" y="32" width="160" height="30" rx="0 0 4 4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="28" y="38" width="8" height="8" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="40" y="46" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Nike (42)</text>
  <rect x="28" y="50" width="8" height="8" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="40" y="58" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Adidas (38)</text>
  <rect x="20" y="70" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="30" y="84" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Price &#x25BE;</text>
  <rect x="20" y="96" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="30" y="110" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Rating &#x25BE;</text>
</svg>`,

'Full-Screen Filter Overlay': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="5" width="140" height="110" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="38" y="20" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Filters</text>
  <text x="158" y="20" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">&#x2715;</text>
  <line x1="30" y1="26" x2="170" y2="26" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="38" y="40" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Brand</text>
  <text x="38" y="54" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Price</text>
  <text x="38" y="68" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Rating</text>
  <text x="38" y="82" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Color</text>
  <line x1="75" y1="30" x2="75" y2="90" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="82" y="32" width="8" height="8" rx="2" style="stroke: var(--color-accent); fill: var(--color-accent)" stroke-width="1"/>
  <text x="94" y="40" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Nike</text>
  <rect x="82" y="44" width="8" height="8" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="94" y="52" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Adidas</text>
  <rect x="38" y="94" width="124" height="16" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="105" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Show 42 results</text>
</svg>`,

'Horizontal Scroll Chips': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="40" width="200" height="34" rx="0" style="fill: var(--color-surface)"/>
  <rect x="8" y="46" width="42" height="22" rx="11" style="fill: var(--color-accent)"/>
  <text x="16" y="60" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">All</text>
  <rect x="54" y="46" width="48" height="22" rx="11" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="62" y="60" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Shoes</text>
  <rect x="106" y="46" width="52" height="22" rx="11" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="114" y="60" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Clothing</text>
  <rect x="162" y="46" width="50" height="22" rx="11" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="170" y="60" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Acces...</text>
  <rect x="186" y="40" width="14" height="34" style="fill: linear-gradient(to right, transparent, var(--color-surface))"/>
  <text x="80" y="88" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">&#x2190; swipe to see more &#x2192;</text>
</svg>`,

'Sort & Filter Button': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="5" width="120" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="50" y="20" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Search...</text>
  <rect x="40" y="34" width="120" height="26" rx="5" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="64" y="51" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Sort &amp; Filter</text>
  <rect x="142" y="38" width="14" height="14" rx="7" style="fill: var(--color-accent)"/>
  <text x="149" y="48" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 700; font-family: var(--font-sans)">3</text>
  <rect x="40" y="66" width="56" height="46" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="104" y="66" width="56" height="46" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

};
