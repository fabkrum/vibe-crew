/** SVG illustrations for "Keyboard & Focus Patterns" */
export const keyboardSvgs: Record<string, string> = {

'Focus Trapping': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-bg); opacity: 0.5"/>
  <rect x="30" y="14" width="140" height="92" rx="10" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="32" text-anchor="middle" style="fill: var(--color-text); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Modal</text>
  <line x1="42" y1="38" x2="158" y2="38" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="46" y="46" width="48" height="18" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="3 2"/>
  <text x="70" y="59" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Input</text>
  <rect x="106" y="46" width="48" height="18" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="130" y="59" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Cancel</text>
  <rect x="76" y="72" width="48" height="18" rx="5" style="fill: var(--color-accent)"/>
  <text x="100" y="85" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Save</text>
  <path d="M 56 44 C 40 36, 40 92, 56 92" style="stroke: var(--color-accent); fill: none" stroke-width="1.2" stroke-dasharray="3 2"/>
  <path d="M 144 44 C 160 36, 160 92, 144 92" style="stroke: var(--color-accent); fill: none" stroke-width="1.2" stroke-dasharray="3 2"/>
  <path d="M 56 92 C 80 100, 120 100, 144 92" style="stroke: var(--color-accent); fill: none" stroke-width="1.2" stroke-dasharray="3 2"/>
  <path d="M 144 44 C 120 36, 80 36, 56 44" style="stroke: var(--color-accent); fill: none" stroke-width="1.2" stroke-dasharray="3 2"/>
  <polygon points="56,42 52,46 60,46" style="fill: var(--color-accent)"/>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Tab cycles inside</text>
</svg>`,

'Focus Restoration': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="40" width="52" height="24" rx="6" style="fill: var(--color-accent)"/>
  <text x="38" y="56" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Open</text>
  <rect x="108" y="16" width="80" height="64" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="148" y="34" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Popup</text>
  <line x1="116" y1="40" x2="180" y2="40" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="116" y="48" width="64" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="116" y="62" width="48" height="12" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <path d="M 64 46 L 104 32" style="stroke: var(--color-green); fill: none" stroke-width="1.5"/>
  <polygon points="104,32 98,30 100,36" style="fill: var(--color-green)"/>
  <text x="84" y="30" text-anchor="middle" style="fill: var(--color-green); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">open</text>
  <path d="M 104 72 L 64 58" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <polygon points="64,58 70,56 68,62" style="fill: var(--color-accent)"/>
  <text x="84" y="74" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">return</text>
  <rect x="8" y="36" width="60" height="32" rx="8" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-dasharray="3 2"/>
  <text x="100" y="104" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Focus returns to trigger on close</text>
</svg>`,

'Arrow Key Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="10" width="100" height="100" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="48" y="18" width="84" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="60" y="32" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Settings</text>
  <rect x="48" y="42" width="84" height="20" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="60" y="56" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Profile</text>
  <rect x="48" y="66" width="84" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="60" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Security</text>
  <rect x="48" y="90" width="84" height="16" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="60" y="102" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Billing</text>
  <rect x="148" y="20" width="36" height="20" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <polygon points="166,26 162,32 170,32" style="fill: var(--color-text-muted)"/>
  <text x="166" y="24" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)"/>
  <rect x="148" y="56" width="36" height="20" rx="5" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <polygon points="166,70 162,64 170,64" style="fill: var(--color-text-muted)"/>
  <path d="M 166 42 L 166 54" style="stroke: var(--color-text-muted); fill: none" stroke-width="1" stroke-dasharray="2 2"/>
  <text x="166" y="90" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Arrow</text>
  <text x="166" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Keys</text>
</svg>`,

'Roving Tabindex': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="30" width="160" height="32" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="22" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Toolbar</text>
  <rect x="28" y="36" width="36" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="46" y="50" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">B</text>
  <rect x="68" y="36" width="36" height="20" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="2"/>
  <text x="86" y="50" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">I</text>
  <rect x="108" y="36" width="36" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="126" y="50" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">U</text>
  <rect x="148" y="36" width="24" height="20" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="160" y="50" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">S</text>
  <rect x="2" y="72" width="32" height="16" rx="4" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="18" y="84" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Tab</text>
  <path d="M 36 80 L 56 62" style="stroke: var(--color-green); fill: none" stroke-width="1.2"/>
  <polygon points="56,62 50,62 54,68" style="fill: var(--color-green)"/>
  <text x="32" y="96" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-sans)">enter</text>
  <path d="M 68 62 L 108 62" style="stroke: var(--color-accent); fill: none" stroke-width="1.2"/>
  <polygon points="104,58 110,62 104,66" style="fill: var(--color-accent)"/>
  <rect x="76" y="72" width="48" height="16" rx="4" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="100" y="84" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-mono)">Arrow Keys</text>
  <rect x="166" y="72" width="32" height="16" rx="4" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="182" y="84" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">Tab</text>
  <path d="M 164 80 L 144 62" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2"/>
  <polygon points="144,62 150,62 146,68" style="fill: var(--color-text-muted)"/>
  <text x="158" y="96" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">leave</text>
  <text x="100" y="114" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Tab enters/leaves, arrows move within</text>
</svg>`,

'Skip Link': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="6" width="176" height="108" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="12" y="6" width="176" height="22" rx="8" style="fill: var(--color-surface-2)"/>
  <rect x="12" y="20" width="176" height="8" style="fill: var(--color-surface-2)"/>
  <text x="24" y="20" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Logo</text>
  <text x="60" y="20" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Home</text>
  <text x="90" y="20" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">About</text>
  <text x="120" y="20" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Blog</text>
  <text x="150" y="20" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Contact</text>
  <line x1="12" y1="28" x2="188" y2="28" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="24" y="44" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Main Content</text>
  <rect x="24" y="50" width="140" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="24" y="64" width="120" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="24" y="78" width="152" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="24" y="92" width="100" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="40" y="0" width="80" height="14" rx="4" style="fill: var(--color-accent)"/>
  <text x="80" y="10" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Skip to content</text>
  <path d="M 80 14 C 80 14, 6 14, 6 44 L 6 44 L 20 36" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-dasharray="4 2"/>
  <polygon points="20,36 14,32 12,40" style="fill: var(--color-accent)"/>
</svg>`,

'Visible Focus Ring': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="20" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Tab through buttons</text>
  <rect x="14" y="38" width="48" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="38" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Prev</text>
  <rect x="72" y="34" width="56" height="36" rx="8" style="stroke: var(--color-accent)" stroke-width="3"/>
  <rect x="76" y="38" width="48" height="28" rx="6" style="fill: var(--color-accent)"/>
  <text x="100" y="56" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Save</text>
  <rect x="138" y="38" width="48" height="28" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="162" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Next</text>
  <path d="M 72 80 L 72 86 L 128 86 L 128 80" style="stroke: var(--color-accent); fill: none" stroke-width="1"/>
  <text x="100" y="98" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">:focus-visible</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">3px offset outline on focused element</text>
</svg>`,

'Escape to Close': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-bg); opacity: 0.4"/>
  <rect x="40" y="14" width="120" height="72" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="34" text-anchor="middle" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Popover</text>
  <line x1="52" y1="40" x2="148" y2="40" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="52" y="48" width="96" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="52" y="62" width="72" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="52" y="76" width="56" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="148" y="92" width="40" height="22" rx="5" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="168" y="107" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-mono)">Esc</text>
  <path d="M 148 100 L 130 90" style="stroke: var(--color-red); fill: none" stroke-width="1.5"/>
  <line x1="126" y1="84" x2="134" y2="92" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="134" y1="84" x2="126" y2="92" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="40" y="112" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Press Escape to dismiss any overlay</text>
</svg>`,

'Enter/Space to Activate': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="56" y="12" width="88" height="36" rx="8" style="fill: var(--color-accent)"/>
  <text x="100" y="35" text-anchor="middle" style="fill: #fff; font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Submit</text>
  <rect x="60" y="8" width="80" height="44" rx="10" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-dasharray="3 2"/>
  <rect x="16" y="68" width="76" height="22" rx="5" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="54" y="83" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-mono)">Enter</text>
  <path d="M 54 68 L 80 52" style="stroke: var(--color-green); fill: none" stroke-width="1.5"/>
  <polygon points="80,52 74,52 76,58" style="fill: var(--color-green)"/>
  <rect x="108" y="68" width="76" height="22" rx="5" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <text x="146" y="83" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-mono)">Space</text>
  <path d="M 146 68 L 120 52" style="stroke: var(--color-green); fill: none" stroke-width="1.5"/>
  <polygon points="120,52 126,52 124,58" style="fill: var(--color-green)"/>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Both keys must activate every clickable element</text>
</svg>`,

'Live Regions': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="16" y="12" width="168" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="26" width="120" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="40" width="140" height="8" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="120" y="62" width="68" height="38" rx="6" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <text x="154" y="78" text-anchor="middle" style="fill: var(--color-green); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Saved!</text>
  <rect x="126" y="86" width="56" height="10" rx="3" style="fill: var(--color-green); opacity: 0.3"/>
  <text x="154" y="94" text-anchor="middle" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-mono)">aria-live</text>
  <circle cx="110" cy="76" r="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <path d="M 107 76 L 113 76 L 113 72 L 107 72 Z" style="fill: var(--color-accent)"/>
  <path d="M 113 72 L 118 68 L 118 80 L 113 76" style="fill: var(--color-accent)"/>
  <path d="M 120 71 C 122 73, 122 79, 120 81" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-linecap="round"/>
  <path d="M 123 68 C 126 72, 126 80, 123 84" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-linecap="round"/>
  <text x="60" y="78" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Screen reader</text>
  <text x="60" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">announces change</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Dynamic updates announced without moving focus</text>
</svg>`,

};
