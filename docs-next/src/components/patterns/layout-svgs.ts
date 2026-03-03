/** SVG illustrations for "Layout" patterns */
export const layoutSvgs: Record<string, string> = {

'Accordion': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="22" y="12" width="156" height="38" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="32" y="26" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Getting Started</text>
  <polyline points="162,22 166,28 170,22" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="32" y1="32" x2="168" y2="32" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="32" y="36" width="120" height="5" rx="2.5" style="fill: var(--color-surface-3)"/>
  <rect x="32" y="44" width="96" height="5" rx="2.5" style="fill: var(--color-surface-3)"/>
  <rect x="22" y="56" width="156" height="20" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="32" y="70" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Configuration</text>
  <polyline points="166,62 170,66 166,70" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="22" y="80" width="156" height="20" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="32" y="94" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Advanced</text>
  <polyline points="166,86 170,90 166,94" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
</svg>`,

'Aspect Ratio': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="90" rx="8" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <line x1="20" y1="10" x2="180" y2="100" style="stroke: var(--color-border-subtle)" stroke-width="0.5" stroke-dasharray="4 3"/>
  <rect x="40" y="34" width="40" height="40" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="60" y="58" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">1:1</text>
  <rect x="100" y="24" width="64" height="36" rx="4" style="stroke: var(--color-blue); fill: var(--color-blue-dim)" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="132" y="46" text-anchor="middle" style="fill: var(--color-blue); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">16:9</text>
  <rect x="100" y="68" width="48" height="26" rx="4" style="stroke: var(--color-green); fill: var(--color-green-dim)" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="124" y="85" text-anchor="middle" style="fill: var(--color-green); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">4:3</text>
  <text x="100" y="114" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Maintains proportions at any screen size</text>
</svg>`,

'Collapsible': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="8" width="168" height="30" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="30" y="27" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Advanced Options</text>
  <polyline points="164,18 168,24 172,18" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="16" y="42" width="168" height="68" rx="6" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="28" y="60" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Enable caching</text>
  <rect x="148" y="50" width="28" height="14" rx="7" style="fill: var(--color-accent)"/>
  <circle cx="168" cy="57" r="5" style="fill: #fff"/>
  <text x="28" y="82" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Debug mode</text>
  <rect x="148" y="72" width="28" height="14" rx="7" style="fill: var(--color-surface-3)"/>
  <circle cx="156" cy="79" r="5" style="fill: var(--color-text-muted)"/>
  <text x="28" y="102" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Timeout (ms)</text>
  <rect x="120" y="92" width="50" height="16" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="130" y="104" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-mono)">3000</text>
</svg>`,

'Resizable': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="6" width="176" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="16" y="10" width="80" height="100" rx="4" style="fill: var(--color-surface-2)"/>
  <text x="28" y="28" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Sidebar</text>
  <rect x="28" y="36" width="56" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="28" y="48" width="48" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="28" y="60" width="52" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="98" y="10" width="8" height="100" rx="4" style="fill: var(--color-surface-2)"/>
  <circle cx="102" cy="52" r="2" style="fill: var(--color-text-muted)"/>
  <circle cx="102" cy="60" r="2" style="fill: var(--color-text-muted)"/>
  <circle cx="102" cy="68" r="2" style="fill: var(--color-text-muted)"/>
  <polyline points="94,56 90,60 94,64" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-linecap="round"/>
  <polyline points="110,56 114,60 110,64" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-linecap="round"/>
  <rect x="108" y="10" width="76" height="100" rx="4" style="fill: var(--color-surface-2)"/>
  <text x="120" y="28" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Content</text>
  <rect x="120" y="36" width="52" height="6" rx="3" style="fill: var(--color-surface-3)"/>
  <rect x="120" y="48" width="44" height="6" rx="3" style="fill: var(--color-surface-3)"/>
</svg>`,

'Scroll Area': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="28" y="24" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Item 1</text>
  <line x1="24" y1="30" x2="168" y2="30" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="28" y="44" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Item 2</text>
  <line x1="24" y1="50" x2="168" y2="50" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="28" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Item 3</text>
  <line x1="24" y1="70" x2="168" y2="70" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="28" y="84" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Item 4</text>
  <line x1="24" y1="90" x2="168" y2="90" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="28" y="104" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Item 5…</text>
  <rect x="174" y="14" width="4" height="40" rx="2" style="fill: var(--color-accent); opacity: 0.6"/>
  <rect x="174" y="58" width="4" height="48" rx="2" style="fill: var(--color-surface-3)"/>
</svg>`,

'Separator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="24" text-anchor="middle" style="fill: var(--color-text); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">Account Settings</text>
  <text x="100" y="40" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Manage your preferences</text>
  <line x1="20" y1="52" x2="180" y2="52" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="28" y="72" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">General</text>
  <text x="80" y="72" style="fill: var(--color-border)" font-size="10px">|</text>
  <text x="92" y="72" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Privacy</text>
  <text x="132" y="72" style="fill: var(--color-border)" font-size="10px">|</text>
  <text x="144" y="72" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Billing</text>
  <line x1="20" y1="84" x2="180" y2="84" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="94" width="140" height="8" rx="4" style="fill: var(--color-surface-2)"/>
</svg>`,

};
