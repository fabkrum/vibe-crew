/** SVG illustrations for FAQ trust section entries */
export const faqSvgs: Record<string, string> = {

'your-control': `<svg viewBox="0 0 120 60" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Laptop -->
  <rect x="4" y="8" width="28" height="20" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="8" y="12" width="20" height="12" rx="1" style="fill: var(--color-accent-bg)"/>
  <rect x="0" y="28" width="36" height="4" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>

  <!-- Arrow -->
  <line x1="40" y1="20" x2="52" y2="20" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <polyline points="50,16 54,20 50,24" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>

  <!-- Git icon -->
  <circle cx="66" cy="20" r="10" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <circle cx="62" cy="18" r="2" style="fill: var(--color-accent)"/>
  <circle cx="70" cy="18" r="2" style="fill: var(--color-accent)"/>
  <circle cx="66" cy="24" r="2" style="fill: var(--color-accent)"/>
  <line x1="63" y1="19" x2="66" y2="23" style="stroke: var(--color-accent)" stroke-width="1"/>
  <line x1="69" y1="19" x2="66" y2="23" style="stroke: var(--color-accent)" stroke-width="1"/>

  <!-- Arrow -->
  <line x1="80" y1="20" x2="88" y2="20" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <polyline points="86,16 90,20 86,24" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>

  <!-- Shield with checkmark -->
  <path d="M104 10 L116 14 L116 24 C116 32 104 38 104 38 C104 38 92 32 92 24 L92 14 Z" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1.5"/>
  <polyline points="98,22 102,26 110,18" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="104" y="52" text-anchor="middle" style="fill: var(--color-green); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">You approve</text>
</svg>`,

'privacy': `<svg viewBox="0 0 120 60" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Laptop with lock -->
  <rect x="4" y="10" width="28" height="20" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="14" y="16" width="10" height="8" rx="2" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <path d="M16 16 L16 14 C16 11 22 11 22 14 L22 16" style="stroke: var(--color-green); fill: none" stroke-width="1" stroke-linecap="round"/>
  <rect x="0" y="30" width="36" height="3" rx="1.5" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>

  <!-- Arrow to Claude API -->
  <line x1="38" y1="20" x2="50" y2="20" style="stroke: var(--color-green)" stroke-width="1.5"/>
  <polyline points="48,16 52,20 48,24" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round"/>

  <!-- Claude API cloud -->
  <ellipse cx="72" cy="18" rx="16" ry="10" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="72" y="22" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 700; font-family: var(--font-sans)">Claude</text>

  <!-- Crossed-out arrow -->
  <line x1="92" y1="20" x2="108" y2="20" style="stroke: var(--color-red); opacity: 0.4" stroke-width="1.5"/>
  <line x1="96" y1="14" x2="104" y2="26" style="stroke: var(--color-red)" stroke-width="2" stroke-linecap="round"/>
  <text x="100" y="40" text-anchor="middle" style="fill: var(--color-red); font-size: 5px; font-weight: 600; font-family: var(--font-sans)">No other</text>
  <text x="100" y="48" text-anchor="middle" style="fill: var(--color-red); font-size: 5px; font-weight: 600; font-family: var(--font-sans)">servers</text>
</svg>`,

'safety-net': `<svg viewBox="0 0 120 60" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Git branch with revert -->
  <circle cx="16" cy="16" r="5" style="fill: var(--color-accent)"/>
  <circle cx="16" cy="36" r="5" style="fill: var(--color-accent)"/>
  <circle cx="40" cy="28" r="5" style="fill: var(--color-red); opacity: 0.6"/>
  <line x1="16" y1="21" x2="16" y2="31" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <path d="M16 20 Q28 20 36 24" style="stroke: var(--color-accent); fill: none; opacity: 0.5" stroke-width="1.5"/>
  <!-- Revert arrow -->
  <path d="M40 22 Q40 16 34 16" style="stroke: var(--color-amber); fill: none" stroke-width="1.5"/>
  <polyline points="36,12 34,16 38,18" style="stroke: var(--color-amber); fill: none" stroke-width="1.5" stroke-linecap="round"/>

  <!-- Quality gate barrier -->
  <rect x="60" y="8" width="4" height="44" rx="2" style="fill: var(--color-green)"/>
  <rect x="56" y="8" width="12" height="6" rx="3" style="fill: var(--color-green)"/>
  <line x1="64" y1="24" x2="72" y2="24" style="stroke: var(--color-green)" stroke-width="2"/>
  <line x1="64" y1="34" x2="72" y2="34" style="stroke: var(--color-green)" stroke-width="2"/>

  <!-- Red X caught -->
  <circle cx="86" cy="28" r="8" style="fill: var(--color-red-dim)"/>
  <line x1="82" y1="24" x2="90" y2="32" style="stroke: var(--color-red)" stroke-width="2" stroke-linecap="round"/>
  <line x1="90" y1="24" x2="82" y2="32" style="stroke: var(--color-red)" stroke-width="2" stroke-linecap="round"/>

  <!-- Green checkmark passing -->
  <polyline points="100,24 104,30 112,18" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="106" y="44" text-anchor="middle" style="fill: var(--color-green); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Passes</text>
</svg>`,

'no-lockin': `<svg viewBox="0 0 120 60" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Code files with checkmark -->
  <rect x="4" y="8" width="24" height="30" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="8" y="14" width="16" height="2" rx="1" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="8" y="19" width="12" height="2" rx="1" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="8" y="24" width="14" height="2" rx="1" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="8" y="29" width="10" height="2" rx="1" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <polyline points="12,44 14,46 20,40" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <text x="16" y="54" text-anchor="middle" style="fill: var(--color-green); font-size: 5px; font-weight: 600; font-family: var(--font-sans)">Your code</text>

  <!-- .vibecrew/ folder with trash icon -->
  <rect x="40" y="12" width="28" height="22" rx="3" style="stroke: var(--color-text-muted); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="3 2"/>
  <text x="54" y="22" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-mono)">.vibecrew/</text>
  <!-- Trash icon -->
  <rect x="50" y="28" width="8" height="4" rx="1" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="52" y="26" width="4" height="2" rx="0.5" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <text x="54" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Delete anytime</text>

  <!-- Arrow -->
  <line x1="74" y1="24" x2="84" y2="24" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <polyline points="82,20 86,24 82,28" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>

  <!-- Standard project -->
  <rect x="90" y="8" width="26" height="32" rx="3" style="stroke: var(--color-green); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="94" y="14" width="18" height="2" rx="1" style="fill: var(--color-green); opacity: 0.4"/>
  <rect x="94" y="19" width="14" height="2" rx="1" style="fill: var(--color-green); opacity: 0.4"/>
  <rect x="94" y="24" width="16" height="2" rx="1" style="fill: var(--color-green); opacity: 0.4"/>
  <rect x="94" y="29" width="12" height="2" rx="1" style="fill: var(--color-green); opacity: 0.4"/>
  <text x="103" y="52" text-anchor="middle" style="fill: var(--color-green); font-size: 5px; font-weight: 600; font-family: var(--font-sans)">Standard</text>
  <text x="103" y="58" text-anchor="middle" style="fill: var(--color-green); font-size: 5px; font-weight: 600; font-family: var(--font-sans)">project</text>
</svg>`,

};
