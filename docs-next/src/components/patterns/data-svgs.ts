/** SVG illustrations for "Displaying Data" patterns */
export const dataSvgs: Record<string, string> = {

'Avatar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="46" cy="48" r="26" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="46" y="54" text-anchor="middle" style="fill: var(--color-accent); font-size: 18px; font-weight: 700; font-family: var(--font-sans)">JD</text>
  <circle cx="108" cy="48" r="26" style="fill: var(--color-blue-dim); stroke: var(--color-blue)" stroke-width="1.5"/>
  <text x="108" y="54" text-anchor="middle" style="fill: var(--color-blue); font-size: 18px; font-weight: 700; font-family: var(--font-sans)">AS</text>
  <circle cx="162" cy="48" r="20" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1.5"/>
  <text x="162" y="54" text-anchor="middle" style="fill: var(--color-green); font-size: 14px; font-weight: 700; font-family: var(--font-sans)">MK</text>
  <circle cx="66" cy="68" r="6" style="fill: var(--color-green); stroke: var(--color-surface)" stroke-width="2"/>
  <text x="46" y="92" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">With initials</text>
  <text x="162" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Small</text>
  <text x="108" y="92" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Fallback</text>
</svg>`,

'Badge': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="52" height="22" rx="11" style="fill: var(--color-green-dim)"/>
  <text x="46" y="35" text-anchor="middle" style="fill: var(--color-green); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Active</text>
  <rect x="80" y="20" width="60" height="22" rx="11" style="fill: var(--color-amber-dim)"/>
  <text x="110" y="35" text-anchor="middle" style="fill: var(--color-amber); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Pending</text>
  <rect x="148" y="20" width="40" height="22" rx="11" style="fill: var(--color-red-dim)"/>
  <text x="168" y="35" text-anchor="middle" style="fill: var(--color-red); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Error</text>
  <rect x="20" y="54" width="50" height="22" rx="11" style="fill: var(--color-accent-bg)"/>
  <text x="45" y="69" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Admin</text>
  <rect x="78" y="54" width="36" height="22" rx="11" style="fill: var(--color-blue-dim)"/>
  <text x="96" y="69" text-anchor="middle" style="fill: var(--color-blue); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">New</text>
  <rect x="122" y="54" width="56" height="22" rx="11" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="150" y="69" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Outline</text>
</svg>`,

'Calendar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="16" y="6" width="168" height="24" rx="8" style="fill: var(--color-accent-bg)"/>
  <rect x="16" y="22" width="168" height="8" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="22" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">March 2026</text>
  <text x="36" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">M</text>
  <text x="60" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">T</text>
  <text x="84" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">W</text>
  <text x="108" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">T</text>
  <text x="132" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">F</text>
  <text x="156" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">S</text>
  <text x="36" y="62" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">23</text>
  <text x="60" y="62" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">24</text>
  <text x="84" y="62" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">1</text>
  <text x="108" y="62" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">2</text>
  <circle cx="132" cy="59" r="9" style="fill: var(--color-accent)"/>
  <text x="132" y="62" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-mono)">3</text>
  <text x="156" y="62" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">4</text>
  <text x="36" y="78" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">5</text>
  <text x="60" y="78" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">6</text>
  <text x="84" y="78" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">7</text>
  <rect x="99" y="70" width="42" height="14" rx="7" style="fill: var(--color-accent-bg)"/>
  <text x="108" y="80" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-mono)">8</text>
  <text x="132" y="80" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-mono)">9</text>
  <text x="156" y="78" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">10</text>
  <text x="36" y="94" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">11</text>
  <text x="60" y="94" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">12</text>
  <text x="84" y="94" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">13</text>
  <text x="108" y="94" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-mono)">14</text>
</svg>`,

'Card': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="16" y="6" width="168" height="36" rx="10" style="fill: var(--color-accent-bg)"/>
  <rect x="16" y="32" width="168" height="10" style="fill: var(--color-accent-bg)"/>
  <text x="30" y="30" style="fill: var(--color-accent); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Product Card</text>
  <text x="30" y="58" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Widget Pro</text>
  <text x="30" y="72" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">A powerful tool for teams</text>
  <rect x="30" y="84" width="48" height="18" rx="5" style="fill: var(--color-accent)"/>
  <text x="54" y="97" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">$29/mo</text>
  <rect x="84" y="84" width="52" height="18" rx="5" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="110" y="97" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Details</text>
</svg>`,

'Carousel': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="36" y="8" width="128" height="80" rx="8" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="100" y="52" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">Slide 2 of 4</text>
  <circle cx="16" cy="48" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <polyline points="19,44 14,48 19,52" style="stroke: var(--color-text-secondary); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="184" cy="48" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <polyline points="181,44 186,48 181,52" style="stroke: var(--color-text-secondary); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="88" cy="100" r="4" style="fill: var(--color-surface-3)"/>
  <circle cx="100" cy="100" r="4" style="fill: var(--color-accent)"/>
  <circle cx="112" cy="100" r="4" style="fill: var(--color-surface-3)"/>
</svg>`,

'Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="10" x2="30" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <line x1="30" y1="100" x2="185" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="70" width="22" height="30" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <rect x="70" y="40" width="22" height="60" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <rect x="100" y="55" width="22" height="45" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <rect x="130" y="20" width="22" height="80" rx="3" style="fill: var(--color-accent)"/>
  <rect x="160" y="50" width="22" height="50" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <text x="51" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Jan</text>
  <text x="81" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Feb</text>
  <text x="111" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Mar</text>
  <text x="141" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Apr</text>
  <text x="171" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">May</text>
</svg>`,

'Data Table': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="6" width="176" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="12" y="6" width="176" height="24" rx="8" style="fill: var(--color-surface-2)"/>
  <rect x="12" y="22" width="176" height="8" style="fill: var(--color-surface-2)"/>
  <text x="24" y="22" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Name ↓</text>
  <text x="80" y="22" style="fill: var(--color-text-muted); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Role</text>
  <text x="130" y="22" style="fill: var(--color-text-muted); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Status</text>
  <rect x="22" y="36" width="10" height="10" rx="2" style="fill: var(--color-accent)"/>
  <polyline points="24,41 27,44 30,39" style="stroke: #fff; fill: none" stroke-width="1.2" stroke-linecap="round"/>
  <text x="38" y="44" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Alice</text>
  <text x="80" y="44" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Admin</text>
  <rect x="130" y="36" width="36" height="12" rx="6" style="fill: var(--color-green-dim)"/>
  <text x="137" y="45" style="fill: var(--color-green); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Active</text>
  <line x1="16" y1="52" x2="184" y2="52" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="22" y="58" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="38" y="66" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Bob</text>
  <text x="80" y="66" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Editor</text>
  <rect x="130" y="58" width="36" height="12" rx="6" style="fill: var(--color-green-dim)"/>
  <text x="137" y="67" style="fill: var(--color-green); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Active</text>
  <line x1="16" y1="74" x2="184" y2="74" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="22" y="80" width="10" height="10" rx="2" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="38" y="88" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">Carol</text>
  <text x="80" y="88" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Viewer</text>
  <rect x="130" y="80" width="44" height="12" rx="6" style="fill: var(--color-amber-dim)"/>
  <text x="137" y="89" style="fill: var(--color-amber); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Pending</text>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">1 – 3 of 24 rows</text>
</svg>`,

'Table': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="6" width="176" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="12" y="6" width="176" height="22" rx="8" style="fill: var(--color-surface-2)"/>
  <rect x="12" y="22" width="176" height="6" style="fill: var(--color-surface-2)"/>
  <text x="24" y="21" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Feature</text>
  <text x="90" y="21" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Free</text>
  <text x="132" y="21" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Pro</text>
  <text x="24" y="44" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Storage</text>
  <text x="90" y="44" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">5 GB</text>
  <text x="132" y="44" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">100 GB</text>
  <line x1="16" y1="50" x2="184" y2="50" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="24" y="64" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Users</text>
  <text x="90" y="64" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">1</text>
  <text x="132" y="64" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Unlimited</text>
  <line x1="16" y1="70" x2="184" y2="70" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="24" y="84" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Support</text>
  <text x="90" y="84" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Email</text>
  <text x="132" y="84" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Priority</text>
  <line x1="16" y1="90" x2="184" y2="90" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="24" y="104" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">API Access</text>
  <text x="90" y="104" style="fill: var(--color-red); font-size: 9px; font-family: var(--font-sans)">—</text>
  <text x="132" y="104" style="fill: var(--color-green); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">✓</text>
  <line x1="82" y1="12" x2="82" y2="110" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <line x1="124" y1="12" x2="124" y2="110" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
</svg>`,

'Progress': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="22" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Uploading…</text>
  <text x="170" y="22" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-mono)">72%</text>
  <rect x="20" y="30" width="160" height="10" rx="5" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="30" width="115" height="10" rx="5" style="fill: var(--color-accent)"/>
  <text x="20" y="62" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Step 2 of 4</text>
  <rect x="20" y="70" width="36" height="6" rx="3" style="fill: var(--color-green)"/>
  <rect x="60" y="70" width="36" height="6" rx="3" style="fill: var(--color-accent)"/>
  <rect x="100" y="70" width="36" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="140" y="70" width="36" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="20" y="100" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Loading…</text>
  <rect x="20" y="106" width="160" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="106" width="80" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.6"/>
</svg>`,

'Skeleton': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="36" cy="30" r="16" style="fill: var(--color-surface-3)"/>
  <rect x="62" y="18" width="100" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="62" y="34" width="70" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="20" y="58" width="160" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="20" y="76" width="140" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="20" y="94" width="120" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <line x1="60" y1="10" x2="100" y2="110" style="stroke: var(--color-accent); opacity: 0.06" stroke-width="30"/>
  <line x1="110" y1="10" x2="150" y2="110" style="stroke: var(--color-accent); opacity: 0.04" stroke-width="30"/>
</svg>`,

};
