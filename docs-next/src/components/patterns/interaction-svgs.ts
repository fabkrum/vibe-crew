/** SVG illustrations for "Interaction & Performance Patterns" */
export const interactionSvgs: Record<string, string> = {

'Optimistic UI': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="10" width="168" height="56" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="32" y="32" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Great post!</text>
  <rect x="32" y="40" width="56" height="20" rx="10" style="fill: var(--color-red-dim); stroke: var(--color-red)" stroke-width="1"/>
  <path d="M52,44 C52,42 54,40 56,40 C58,40 60,42 60,44 C60,42 62,40 64,40 C66,40 68,42 68,44 C68,48 60,52 60,52 C60,52 52,48 52,44Z" style="fill: var(--color-red)"/>
  <text x="72" y="54" style="fill: var(--color-red); font-size: 9px; font-weight: 600; font-family: var(--font-mono)">24</text>
  <polyline points="142,42 146,48 156,36" style="stroke: var(--color-green); fill: none" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="148" cy="42" r="12" style="stroke: var(--color-green); fill: none" stroke-width="1"/>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">saving...</text>
  <rect x="80" y="92" width="40" height="3" rx="1.5" style="fill: var(--color-surface-2)"/>
  <rect x="80" y="92" width="24" height="3" rx="1.5" style="fill: var(--color-accent); opacity: 0.6"/>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Instant feedback, background sync</text>
</svg>`,

'Skeleton Loading': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="36" cy="30" r="18" style="fill: var(--color-surface-3)"/>
  <rect x="64" y="16" width="110" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="64" y="34" width="80" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="20" y="60" width="160" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="20" y="78" width="140" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="20" y="96" width="100" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <line x1="50" y1="8" x2="90" y2="114" style="stroke: var(--color-accent); opacity: 0.06" stroke-width="30"/>
  <line x1="110" y1="8" x2="150" y2="114" style="stroke: var(--color-accent); opacity: 0.04" stroke-width="30"/>
</svg>`,

'Import on Interaction': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="48" y="10" width="104" height="28" rx="6" style="fill: var(--color-accent)"/>
  <text x="100" y="28" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Open Editor</text>
  <rect x="30" y="48" width="140" height="60" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="6 4"/>
  <rect x="42" y="60" width="80" height="8" rx="2" style="fill: var(--color-surface-3); opacity: 0.5"/>
  <rect x="42" y="74" width="64" height="8" rx="2" style="fill: var(--color-surface-3); opacity: 0.5"/>
  <rect x="42" y="88" width="96" height="8" rx="2" style="fill: var(--color-surface-3); opacity: 0.5"/>
  <path d="M148,72 L148,64 L154,68Z" style="fill: var(--color-amber); opacity: 0.7"/>
  <line x1="146" y1="62" x2="146" y2="74" style="stroke: var(--color-amber); opacity: 0.7" stroke-width="2" stroke-linecap="round"/>
  <text x="100" y="118" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Heavy code loads only on click</text>
</svg>`,

'Import on Visibility': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="8" width="140" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="38" y="14" width="80" height="8" rx="4" style="fill: var(--color-surface-3)"/>
  <rect x="30" y="34" width="140" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="38" y="40" width="60" height="8" rx="4" style="fill: var(--color-surface-3)"/>
  <line x1="16" y1="62" x2="184" y2="62" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="6 4"/>
  <text x="186" y="60" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">viewport</text>
  <rect x="30" y="70" width="140" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1" opacity="0.35"/>
  <rect x="38" y="76" width="100" height="8" rx="4" style="fill: var(--color-surface-3); opacity: 0.35"/>
  <rect x="30" y="96" width="140" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1" opacity="0.2"/>
  <rect x="38" y="102" width="72" height="8" rx="4" style="fill: var(--color-surface-3); opacity: 0.2"/>
  <polyline points="96,66 100,72 104,66" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
</svg>`,

'List Virtualization': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="6" width="120" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="48" y="12" width="104" height="14" rx="3" style="fill: var(--color-surface-2)" opacity="0.2"/>
  <rect x="56" y="16" width="60" height="6" rx="3" style="fill: var(--color-surface-3); opacity: 0.2"/>
  <rect x="48" y="30" width="104" height="14" rx="3" style="fill: var(--color-surface-2)" opacity="0.35"/>
  <rect x="56" y="34" width="72" height="6" rx="3" style="fill: var(--color-surface-3); opacity: 0.35"/>
  <line x1="44" y1="48" x2="156" y2="48" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <rect x="48" y="52" width="104" height="14" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <rect x="56" y="56" width="80" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="48" y="70" width="104" height="14" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <rect x="56" y="74" width="64" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="48" y="88" width="104" height="14" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <rect x="56" y="92" width="88" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <line x1="44" y1="106" x2="156" y2="106" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <text x="20" y="76" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-mono)" transform="rotate(-90 20 76)">visible</text>
</svg>`,

'Prefetch on Hover': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="10" width="168" height="28" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="32" y="28" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Home</text>
  <rect x="72" y="14" width="60" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="82" y="28" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Products</text>
  <text x="148" y="28" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">About</text>
  <path d="M110,42 L110,36 L116,42 L110,42Z M110,42 L116,42 L116,48" style="fill: var(--color-text-muted); stroke: var(--color-text-muted)" stroke-width="0.8"/>
  <circle cx="140" cy="52" r="6" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-dasharray="4 3" stroke-linecap="round"/>
  <text x="140" y="70" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">prefetch</text>
  <rect x="30" y="82" width="140" height="30" rx="6" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="4 3"/>
  <rect x="40" y="88" width="80" height="6" rx="3" style="fill: var(--color-surface-3); opacity: 0.5"/>
  <rect x="40" y="100" width="60" height="6" rx="3" style="fill: var(--color-surface-3); opacity: 0.5"/>
</svg>`,

'Progressive Disclosure': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="6" width="160" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="24" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Name</text>
  <rect x="32" y="28" width="136" height="16" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="32" y="58" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <rect x="32" y="62" width="136" height="16" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="100" y="92" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Show advanced options</text>
  <polyline points="82,95 100,100 118,95" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-linecap="round"/>
  <text x="48" y="110" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans); opacity: 0.4">Timezone</text>
  <rect x="96" y="104" width="56" height="8" rx="4" style="fill: var(--color-surface-3); opacity: 0.3"/>
</svg>`,

'Stale-While-Revalidate': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="10" width="168" height="100" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="28" y="28" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Dashboard</text>
  <rect x="150" y="14" width="24" height="24" rx="12" style="fill: var(--color-accent-bg)"/>
  <path d="M162,20 A6,6 0 1,1 156,26" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="162,17 162,21 158,21" style="stroke: var(--color-accent); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="28" y="36" width="68" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="36" y="50" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Revenue</text>
  <text x="36" y="62" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-mono)">$12,400</text>
  <rect x="104" y="36" width="68" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="112" y="50" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Users</text>
  <text x="112" y="62" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-mono)">1,847</text>
  <rect x="28" y="76" width="144" height="8" rx="4" style="fill: var(--color-surface-3)"/>
  <rect x="28" y="90" width="120" height="8" rx="4" style="fill: var(--color-surface-3)"/>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Cached data shown, refreshing in background</text>
</svg>`,

'Debounced Search': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="36" cy="24" r="7" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5"/>
  <line x1="41" y1="29" x2="44" y2="32" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="52" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-mono)">reac...</text>
  <circle cx="162" cy="24" r="8" style="stroke: var(--color-amber); fill: var(--color-amber-dim)" stroke-width="1"/>
  <line x1="162" y1="20" x2="162" y2="24" style="stroke: var(--color-amber)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="162" y1="24" x2="165" y2="27" style="stroke: var(--color-amber)" stroke-width="1.2" stroke-linecap="round"/>
  <text x="162" y="46" text-anchor="middle" style="fill: var(--color-amber); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">300ms</text>
  <rect x="20" y="52" width="160" height="60" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="32" y="70" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">React</text>
  <text x="60" y="70" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">— UI library</text>
  <line x1="28" y1="78" x2="172" y2="78" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="32" y="92" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">React</text>
  <text x="60" y="92" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)"> Router — navigation</text>
  <line x1="28" y1="100" x2="172" y2="100" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
</svg>`,

'Infinite Scroll vs Pagination': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="100" y1="4" x2="100" y2="116" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="50" y="14" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">SCROLL</text>
  <rect x="20" y="20" width="60" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="20" y="36" width="60" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="20" y="52" width="60" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="20" y="68" width="60" height="12" rx="3" style="fill: var(--color-surface-2); opacity: 0.5"/>
  <rect x="20" y="84" width="60" height="12" rx="3" style="fill: var(--color-surface-2); opacity: 0.25"/>
  <text x="50" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Loading...</text>
  <text x="150" y="14" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">PAGES &#x2713;</text>
  <rect x="116" y="20" width="68" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="116" y="36" width="68" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="116" y="52" width="68" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="116" y="68" width="68" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="118" y="88" width="20" height="18" rx="4" style="fill: var(--color-accent)"/>
  <text x="128" y="101" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-mono)">1</text>
  <rect x="142" y="88" width="20" height="18" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="152" y="101" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">2</text>
  <rect x="166" y="88" width="20" height="18" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="176" y="101" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">3</text>
</svg>`,

'Route-Based Splitting': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="14" width="56" height="44" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="36" y="32" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-mono)">/home</text>
  <rect x="20" y="40" width="32" height="10" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="36" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-mono)">12 kB</text>
  <rect x="72" y="14" width="56" height="44" rx="6" style="stroke: var(--color-blue); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="32" text-anchor="middle" style="fill: var(--color-blue); font-size: 9px; font-weight: 600; font-family: var(--font-mono)">/about</text>
  <rect x="84" y="40" width="32" height="10" rx="3" style="fill: var(--color-blue-dim)"/>
  <text x="100" y="48" text-anchor="middle" style="fill: var(--color-blue); font-size: 6px; font-weight: 600; font-family: var(--font-mono)">8 kB</text>
  <rect x="136" y="14" width="56" height="44" rx="6" style="stroke: var(--color-green); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="164" y="32" text-anchor="middle" style="fill: var(--color-green); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">/dash</text>
  <rect x="148" y="40" width="32" height="10" rx="3" style="fill: var(--color-green-dim)"/>
  <text x="164" y="48" text-anchor="middle" style="fill: var(--color-green); font-size: 6px; font-weight: 600; font-family: var(--font-mono)">24 kB</text>
  <line x1="36" y1="62" x2="36" y2="76" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 2"/>
  <line x1="100" y1="62" x2="100" y2="76" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 2"/>
  <line x1="164" y1="62" x2="164" y2="76" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 2"/>
  <rect x="16" y="78" width="40" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="36" y="87" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-mono)">bundle</text>
  <rect x="80" y="78" width="40" height="12" rx="3" style="fill: var(--color-blue-dim)"/>
  <text x="100" y="87" text-anchor="middle" style="fill: var(--color-blue); font-size: 7px; font-family: var(--font-mono)">bundle</text>
  <rect x="144" y="78" width="40" height="12" rx="3" style="fill: var(--color-green-dim)"/>
  <text x="164" y="87" text-anchor="middle" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-mono)">bundle</text>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Each route loads only its own code</text>
</svg>`,

'Page Transitions': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="14" width="72" height="92" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="22" y="20" width="60" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="52" y="29" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Page A</text>
  <rect x="22" y="38" width="56" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="22" y="50" width="48" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="22" y="62" width="52" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <polyline points="98,52 110,60 98,68" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <line x1="96" y1="60" x2="112" y2="60" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <rect x="112" y="14" width="72" height="92" rx="8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="118" y="20" width="60" height="12" rx="3" style="fill: var(--color-accent)"/>
  <text x="148" y="29" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Page B</text>
  <rect x="118" y="38" width="56" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="118" y="50" width="48" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="118" y="62" width="52" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <text x="100" y="116" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Smooth animation between routes</text>
</svg>`,

};
