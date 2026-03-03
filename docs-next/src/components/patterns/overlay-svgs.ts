/** SVG illustrations for "Overlays & Modals" patterns */
export const overlaySvgs: Record<string, string> = {

'Dialog': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-bg); opacity: 0.5"/>
  <rect x="24" y="14" width="152" height="92" rx="10" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="40" y="36" style="fill: var(--color-text); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Edit Profile</text>
  <circle cx="160" cy="30" r="8" style="fill: var(--color-surface-2)"/>
  <line x1="156" y1="26" x2="164" y2="34" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="164" y1="26" x2="156" y2="34" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="36" y1="44" x2="164" y2="44" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="40" y="60" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Name</text>
  <rect x="40" y="64" width="120" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <rect x="40" y="90" width="56" height="18" rx="5" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="54" y="103" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Cancel</text>
  <rect x="102" y="90" width="56" height="18" rx="5" style="fill: var(--color-accent)"/>
  <text x="120" y="103" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Save</text>
</svg>`,

'Drawer': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1" opacity="0.3"/>
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-bg); opacity: 0.4"/>
  <rect x="8" y="46" width="184" height="70" rx="12" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="88" y="52" width="24" height="4" rx="2" style="fill: var(--color-text-muted)"/>
  <text x="100" y="72" text-anchor="middle" style="fill: var(--color-text); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Filter Options</text>
  <rect x="24" y="82" width="76" height="20" rx="5" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="42" y="96" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Category ▾</text>
  <rect x="108" y="82" width="76" height="20" rx="5" style="fill: var(--color-accent)"/>
  <text x="128" y="96" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Apply</text>
</svg>`,

'Popover': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="76" width="60" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="34" y="94" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">Colors</text>
  <polygon points="44,76 50,68 56,76" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="14" y="8" width="100" height="60" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="26" y="26" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Pick a color</text>
  <circle cx="32" cy="40" r="8" style="fill: var(--color-red)"/>
  <circle cx="52" cy="40" r="8" style="fill: var(--color-accent); stroke: var(--color-text)" stroke-width="2"/>
  <circle cx="72" cy="40" r="8" style="fill: var(--color-green)"/>
  <circle cx="92" cy="40" r="8" style="fill: var(--color-blue)"/>
  <rect x="26" y="54" width="76" height="8" rx="4" style="fill: var(--color-surface-2)"/>
</svg>`,

'Sheet': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1" opacity="0.3"/>
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-bg); opacity: 0.4"/>
  <rect x="80" y="4" width="112" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="96" y="26" style="fill: var(--color-text); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Details</text>
  <circle cx="176" cy="20" r="7" style="fill: var(--color-surface-2)"/>
  <line x1="173" y1="17" x2="179" y2="23" style="stroke: var(--color-text-muted)" stroke-width="1.3" stroke-linecap="round"/>
  <line x1="179" y1="17" x2="173" y2="23" style="stroke: var(--color-text-muted)" stroke-width="1.3" stroke-linecap="round"/>
  <line x1="90" y1="34" x2="184" y2="34" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="96" y="42" width="80" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="96" y="56" width="64" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="96" y="70" width="72" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="96" y="92" width="80" height="18" rx="5" style="fill: var(--color-accent)"/>
  <text x="136" y="105" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Save Changes</text>
</svg>`,

'Tooltip': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="72" y="64" width="56" height="36" rx="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 18px; font-family: var(--font-sans)">🗑</text>
  <rect x="52" y="14" width="96" height="32" rx="6" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="100" y="34" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">Delete item</text>
  <polygon points="94,46 100,54 106,46" style="fill: var(--color-surface-3)"/>
  <rect x="110" y="22" width="30" height="14" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="116" y="33" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Del</text>
</svg>`,

'Context Menu': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="60" y="20" width="44" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="60" y="34" width="36" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <circle cx="80" cy="50" r="3" style="fill: var(--color-accent)"/>
  <rect x="80" y="40" width="108" height="72" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="92" y="58" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Cut</text>
  <text x="164" y="58" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘X</text>
  <text x="92" y="74" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Copy</text>
  <text x="164" y="74" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘C</text>
  <rect x="84" y="80" width="100" height="18" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="92" y="93" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Paste</text>
  <text x="164" y="93" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">⌘V</text>
  <line x1="88" y1="102" x2="180" y2="102" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="92" y="112" style="fill: var(--color-red); font-size: 10px; font-family: var(--font-sans)">Delete</text>
</svg>`,

'Hover Card': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="20" y="26" style="fill: var(--color-accent); font-size: 11px; text-decoration: underline; font-family: var(--font-sans)">@janedoe</text>
  <rect x="20" y="32" width="148" height="76" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="44" cy="56" r="14" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="44" y="60" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">JD</text>
  <text x="66" y="52" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Jane Doe</text>
  <text x="66" y="64" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Product Designer</text>
  <line x1="28" y1="76" x2="160" y2="76" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="36" y="90" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">12 repos</text>
  <text x="88" y="90" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">48 followers</text>
  <rect x="36" y="96" width="56" height="16" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="48" y="108" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Follow</text>
</svg>`,

};
