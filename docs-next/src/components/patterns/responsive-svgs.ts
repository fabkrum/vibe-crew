/** SVG illustrations for "Responsive Design" patterns */
export const responsiveSvgs: Record<string, string> = {

'Mobile-First Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="35" height="60" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="24" y="22" width="27" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="24" y="32" width="27" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="24" y="42" width="27" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="37" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">base</text>
  <path d="M65 45 L80 45" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="76,41 80,45 76,49" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="90" y="10" width="50" height="70" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="94" y="17" width="42" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="94" y="27" width="20" height="20" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="116" y="27" width="20" height="20" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="115" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">768px+</text>
  <path d="M150 45 L165 45" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="161,41 165,45 161,49" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="180" y="48" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">…</text>
</svg>`,

'Breakpoint System': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="20" y1="80" x2="180" y2="80" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="40" y1="75" x2="40" y2="85" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="40" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">360</text>
  <line x1="80" y1="75" x2="80" y2="85" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="80" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">768</text>
  <line x1="120" y1="75" x2="120" y2="85" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="120" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">1024</text>
  <line x1="160" y1="75" x2="160" y2="85" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="160" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">1440</text>
  <rect x="20" y="20" width="25" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="55" y="15" width="35" height="50" rx="3" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="100" y="10" width="45" height="55" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="155" y="5" width="25" height="65" rx="3" style="fill: var(--color-accent)"/>
</svg>`,

'Container Query': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="80" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="55" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">container</text>
  <rect x="22" y="32" width="66" height="28" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <rect x="22" y="64" width="66" height="28" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <rect x="110" y="10" width="75" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="147" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">container</text>
  <rect x="117" y="32" width="30" height="60" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <rect x="151" y="32" width="28" height="60" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
</svg>`,

'Fluid Typography': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="30" y="35" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Aa</text>
  <text x="80" y="45" style="fill: var(--color-text); font-size: 16px; font-weight: 700; font-family: var(--font-sans)">Aa</text>
  <text x="130" y="55" style="fill: var(--color-text); font-size: 24px; font-weight: 700; font-family: var(--font-sans)">Aa</text>
  <path d="M25 70 C60 68, 120 60, 175 50" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="100" y="95" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">clamp(min, preferred, max)</text>
</svg>`,

'Touch Target Sizing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="20" width="44" height="44" rx="8" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <rect x="39" y="29" width="26" height="26" rx="6" style="fill: var(--color-accent)"/>
  <text x="52" y="46" text-anchor="middle" style="fill: #fff; font-size: 14px; font-weight: 700; font-family: var(--font-sans)">×</text>
  <text x="52" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">44×44px</text>
  <rect x="100" y="25" width="20" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.4"/>
  <line x1="100" y1="20" x2="120" y2="50" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5"/>
  <line x1="120" y1="20" x2="100" y2="50" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5"/>
  <text x="110" y="80" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-family: var(--font-sans)">Too small</text>
  <rect x="140" y="20" width="44" height="44" rx="8" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="162" y="80" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">8px gap ↕</text>
</svg>`,

'Responsive Images': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="45" height="35" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="42" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">400w</text>
  <rect x="75" y="10" width="55" height="45" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="102" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">800w</text>
  <rect x="140" y="5" width="45" height="55" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="162" y="36" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">1200w</text>
  <text x="100" y="80" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">srcset + sizes</text>
  <text x="100" y="95" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">loading="lazy"</text>
</svg>`,

'Responsive Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="15" width="55" height="10" rx="3" style="fill: var(--color-accent)"/>
  <rect x="10" y="28" width="55" height="60" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="14" y="34" width="47" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="14" y="44" width="47" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="37" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Desktop</text>
  <rect x="80" y="72" width="50" height="16" rx="3" style="fill: var(--color-accent)"/>
  <circle cx="92" cy="80" r="3" style="fill: #fff"/>
  <circle cx="105" cy="80" r="3" style="fill: #fff"/>
  <circle cx="118" cy="80" r="3" style="fill: #fff"/>
  <rect x="80" y="15" width="50" height="54" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="105" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Mobile</text>
  <rect x="145" y="15" width="45" height="10" rx="3" style="fill: var(--color-accent)"/>
  <line x1="175" y1="18" x2="175" y2="18" style="stroke: #fff" stroke-width="4" stroke-linecap="round"/>
  <line x1="175" y1="22" x2="175" y2="22" style="stroke: #fff" stroke-width="4" stroke-linecap="round"/>
  <rect x="145" y="28" width="45" height="60" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="167" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Hamburger</text>
</svg>`,

'Logical Properties': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="70" height="40" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="55" y="30" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">LTR →</text>
  <rect x="28" y="36" width="54" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="55" y="45" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">inline-start</text>
  <rect x="110" y="15" width="70" height="40" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="145" y="30" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">← RTL</text>
  <rect x="118" y="36" width="54" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="145" y="45" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">inline-start</text>
  <text x="100" y="80" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Same CSS, both directions</text>
  <text x="100" y="95" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">margin-inline not margin-left</text>
</svg>`,

};
