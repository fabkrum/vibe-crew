/** SVG illustrations for "Navigation" patterns */
export const navigationSvgs: Record<string, string> = {

'Breadcrumb': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="36" width="168" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="28" y="54" style="fill: var(--color-accent); font-size: 11px; font-family: var(--font-sans)">Home</text>
  <text x="62" y="54" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">/</text>
  <text x="72" y="54" style="fill: var(--color-accent); font-size: 11px; font-family: var(--font-sans)">Products</text>
  <text x="126" y="54" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">/</text>
  <text x="136" y="54" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Details</text>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Shows where you are in the site hierarchy</text>
</svg>`,

'Command': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="6" width="160" height="108" rx="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="30" y="14" width="140" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="42" y="32" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Type a command…</text>
  <rect x="140" y="20" width="24" height="16" rx="4" style="fill: var(--color-surface-3)"/>
  <text x="146" y="32" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘K</text>
  <line x1="30" y1="48" x2="170" y2="48" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="36" y="60" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; font-family: var(--font-sans)">Actions</text>
  <rect x="30" y="66" width="140" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="42" y="80" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Create new project</text>
  <text x="42" y="98" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Open settings</text>
</svg>`,

'Dropdown Menu': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="80" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="40" y="26" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">Actions</text>
  <polyline points="84,20 88,24 92,20" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="20" y="40" width="120" height="72" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="58" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Edit</text>
  <text x="116" y="58" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘E</text>
  <line x1="28" y1="64" x2="132" y2="64" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="32" y="78" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Duplicate</text>
  <text x="116" y="78" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘D</text>
  <line x1="28" y1="84" x2="132" y2="84" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="32" y="100" style="fill: var(--color-red); font-size: 10px; font-family: var(--font-sans)">Delete</text>
  <text x="116" y="100" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌫</text>
</svg>`,

'Menubar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="14" width="176" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="16" y="18" width="36" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="24" y="32" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">File</text>
  <text x="62" y="32" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Edit</text>
  <text x="92" y="32" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">View</text>
  <text x="122" y="32" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Help</text>
  <rect x="12" y="44" width="100" height="68" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="24" y="62" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">New File</text>
  <text x="86" y="62" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘N</text>
  <rect x="16" y="68" width="92" height="18" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="24" y="81" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Open</text>
  <text x="86" y="81" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘O</text>
  <line x1="18" y1="90" x2="108" y2="90" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="24" y="104" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Save</text>
  <text x="86" y="104" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘S</text>
</svg>`,

'Navigation Menu': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="14" width="176" height="28" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="26" cy="28" r="8" style="fill: var(--color-accent)"/>
  <text x="44" y="32" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Home</text>
  <text x="78" y="32" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Products ▾</text>
  <text x="138" y="32" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">About</text>
  <rect x="60" y="44" width="128" height="68" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="72" y="62" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">All Products</text>
  <text x="72" y="76" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Browse our full catalog</text>
  <line x1="68" y1="84" x2="180" y2="84" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="72" y="98" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">New Releases</text>
  <text x="72" y="108" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Just arrived this week</text>
</svg>`,

'Pagination': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="28" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Showing 1 – 10 of 97 results</text>
  <rect x="16" y="40" width="28" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="32,50 27,54 32,58" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="50" y="40" width="28" height="28" rx="6" style="fill: var(--color-accent)"/>
  <text x="64" y="58" text-anchor="middle" style="fill: #fff; font-size: 11px; font-weight: 600; font-family: var(--font-mono)">1</text>
  <rect x="84" y="40" width="28" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="98" y="58" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-mono)">2</text>
  <rect x="118" y="40" width="28" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="132" y="58" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-mono)">3</text>
  <text x="155" y="58" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-mono)">…</text>
  <rect x="164" y="40" width="28" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="176,50 181,54 176,58" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <text x="100" y="90" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Default choice over infinite scroll</text>
</svg>`,

'Sidebar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="6" width="68" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="88" y="6" width="100" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="20" y="14" width="20" height="20" rx="5" style="fill: var(--color-accent)"/>
  <text x="44" y="28" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">App</text>
  <line x1="18" y1="40" x2="74" y2="40" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="18" y="46" width="56" height="18" rx="4" style="fill: var(--color-accent-bg)"/>
  <rect x="18" y="48" width="3" height="14" rx="1.5" style="fill: var(--color-accent)"/>
  <text x="28" y="58" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Dashboard</text>
  <text x="28" y="78" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Projects</text>
  <text x="28" y="94" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Settings</text>
  <rect x="96" y="16" width="84" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="96" y="30" width="76" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="96" y="44" width="60" height="8" rx="4" style="fill: var(--color-surface-2)"/>
</svg>`,

'Tabs': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="6" width="176" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <line x1="12" y1="36" x2="188" y2="36" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="32" y="26" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">General</text>
  <line x1="28" y1="36" x2="78" y2="36" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="96" y="26" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">Security</text>
  <text x="156" y="26" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">Billing</text>
  <rect x="24" y="48" width="120" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="24" y="64" width="100" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="24" y="80" width="140" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="24" y="96" width="80" height="8" rx="4" style="fill: var(--color-surface-2)"/>
</svg>`,

};
