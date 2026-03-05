/** SVG illustrations for Animation Patterns */
export const animationPatternSvgs: Record<string, string> = {

'Reduced Motion': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="70" height="80" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="55" cy="50" r="12" style="fill: var(--color-accent)"/>
  <text x="55" y="54" text-anchor="middle" style="fill: #fff; font-size: 14px; font-weight: 700; font-family: var(--font-sans)">✓</text>
  <text x="55" y="82" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Motion ON</text>
  <rect x="110" y="20" width="70" height="80" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="145" cy="50" r="12" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="145" y="54" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 14px; font-weight: 700; font-family: var(--font-sans)">✓</text>
  <text x="145" y="82" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Reduced</text>
</svg>`,

'GPU-Safe Animation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="30" width="60" height="60" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5" transform="rotate(-5 50 60)"/>
  <text x="50" y="55" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">transform</text>
  <text x="50" y="70" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">opacity</text>
  <rect x="120" y="30" width="60" height="60" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="150" y="55" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">width</text>
  <text x="150" y="70" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">height</text>
  <line x1="120" y1="30" x2="180" y2="90" style="stroke: var(--color-text-muted)" stroke-width="1.5"/>
  <line x1="180" y1="30" x2="120" y2="90" style="stroke: var(--color-text-muted)" stroke-width="1.5"/>
</svg>`,

'Fade': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="30" width="40" height="60" rx="6" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="70" y="30" width="40" height="60" rx="6" style="fill: var(--color-accent)" opacity="0.45"/>
  <rect x="120" y="30" width="40" height="60" rx="6" style="fill: var(--color-accent)" opacity="0.75"/>
  <rect x="168" y="30" width="14" height="60" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">opacity 0 → 1</text>
</svg>`,

'Slide': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="130" y="10" width="60" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="136" y="20" width="48" height="8" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="136" y="34" width="48" height="8" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="136" y="48" width="48" height="8" rx="3" style="fill: var(--color-accent-bg)"/>
  <path d="M100 60 L120 60" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <polyline points="115,55 120,60 115,65" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="20" y="35" width="60" height="50" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="4 3" opacity="0.4"/>
</svg>`,

'Scale': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="35" width="35" height="50" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1" opacity="0.4"/>
  <rect x="45" y="20" width="65" height="80" rx="8" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5" opacity="0.7"/>
  <rect x="115" y="15" width="70" height="90" rx="8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="150" y="55" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Modal</text>
  <text x="150" y="70" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">scale 0.95→1</text>
</svg>`,

'Collapse': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="70" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="55" y="26" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Section ▼</text>
  <rect x="20" y="36" width="70" height="40" rx="5" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="28" y="44" width="54" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="28" y="54" width="40" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="110" y="10" width="70" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="145" y="26" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Section ▶</text>
  <rect x="110" y="36" width="70" height="4" rx="2" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1" opacity="0.3"/>
</svg>`,

'Hover Feedback': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="30" width="70" height="60" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="55" y="65" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Normal</text>
  <rect x="108" y="26" width="74" height="64" rx="8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="2"/>
  <rect x="110" y="24" width="74" height="64" rx="8" style="fill: none; stroke: var(--color-accent)" stroke-width="0" opacity="0.1"/>
  <text x="145" y="61" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Hovered</text>
  <text x="145" y="76" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">scale(1.02)</text>
</svg>`,

'Press Feedback': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="35" width="65" height="36" rx="8" style="fill: var(--color-accent)"/>
  <text x="57" y="57" text-anchor="middle" style="fill: #fff; font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Button</text>
  <rect x="112" y="38" width="61" height="32" rx="7" style="fill: var(--color-accent)" opacity="0.85"/>
  <text x="142" y="58" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Pressed</text>
  <text x="142" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">scale(0.97)</text>
</svg>`,

'Validation Shake': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="30" width="140" height="32" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="45" y="50" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">bad@email</text>
  <path d="M30 68 L35 62 L40 68 L45 62 L50 68" style="stroke: hsl(0, 84%, 60%); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <text x="30" y="90" style="fill: hsl(0, 84%, 60%); font-size: 10px; font-family: var(--font-sans)">Please enter a valid email</text>
</svg>`,

'Shimmer Loading': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="20" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="15" width="60" height="20" rx="4" style="fill: var(--color-accent-bg)" opacity="0.5"/>
  <rect x="20" y="45" width="160" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="65" width="120" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="85" width="160" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="85" width="40" height="12" rx="3" style="fill: var(--color-accent-bg)" opacity="0.3"/>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">shimmer sweep →</text>
</svg>`,

'Scroll Reveal': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="100" y1="5" x2="100" y2="115" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 3"/>
  <rect x="25" y="10" width="50" height="30" rx="5" style="fill: var(--color-accent)"/>
  <rect x="25" y="48" width="50" height="30" rx="5" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="25" y="86" width="50" height="30" rx="5" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="150" y="30" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">visible</text>
  <text x="150" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">entering</text>
  <text x="150" y="105" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">below fold</text>
  <polyline points="140,35 150,42 160,35" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
</svg>`,

'Staggered List': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="20" rx="4" style="fill: var(--color-accent)"/>
  <rect x="20" y="36" width="160" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="20" y="62" width="160" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="20" y="88" width="160" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="40" y="24" style="fill: #fff; font-size: 9px; font-family: var(--font-sans)">0ms</text>
  <text x="40" y="50" style="fill: #fff; font-size: 9px; font-family: var(--font-sans)">50ms</text>
  <text x="40" y="76" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">100ms</text>
  <text x="40" y="102" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">150ms</text>
</svg>`,

};
