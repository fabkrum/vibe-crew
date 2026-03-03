/** SVG illustrations for agent-related glossary terms */
export const agentSvgs: Record<string, string> = {

'Agent': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="40" cy="32" r="12" style="fill: var(--color-accent)"/>
  <ellipse cx="40" cy="62" rx="16" ry="12" style="fill: var(--color-accent); opacity: 0.7"/>
  <circle cx="100" cy="32" r="12" style="fill: var(--color-text-secondary)"/>
  <ellipse cx="100" cy="62" rx="16" ry="12" style="fill: var(--color-text-secondary); opacity: 0.7"/>
  <circle cx="160" cy="32" r="12" style="fill: var(--color-text-muted)"/>
  <ellipse cx="160" cy="62" rx="16" ry="12" style="fill: var(--color-text-muted); opacity: 0.7"/>
  <text x="40" y="90" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Plan</text>
  <text x="100" y="90" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Code</text>
  <text x="160" y="90" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Review</text>
  <text x="100" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Specialized team of AI agents</text>
</svg>`,

'Builder': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="16" y="6" width="168" height="18" rx="8" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="16" width="168" height="8" style="fill: var(--color-surface-2)"/>
  <circle cx="30" cy="15" r="3.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <circle cx="40" cy="15" r="3.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <circle cx="50" cy="15" r="3.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="30" y="34" width="48" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.7"/>
  <rect x="82" y="34" width="32" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="30" y="48" width="24" height="6" rx="3" style="fill: var(--color-text-secondary); opacity: 0.5"/>
  <rect x="58" y="48" width="64" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.5"/>
  <rect x="30" y="62" width="80" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="30" y="76" width="36" height="6" rx="3" style="fill: var(--color-text-secondary); opacity: 0.5"/>
  <rect x="70" y="76" width="52" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.6"/>
  <line x1="30" y1="88" x2="30" y2="98" style="stroke: var(--color-accent)" stroke-width="1.5"/>
</svg>`,

'Code Auditor': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="56" y="12" width="68" height="88" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="66" y="28" width="48" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="38" width="40" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="48" width="44" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="58" width="36" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="68" width="48" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="78" width="32" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <circle cx="132" cy="60" r="28" style="stroke: var(--color-accent); fill: none" stroke-width="2.5"/>
  <line x1="152" y1="80" x2="170" y2="98" style="stroke: var(--color-accent)" stroke-width="3" stroke-linecap="round"/>
  <polyline points="123,60 128,65 141,52" style="stroke: var(--color-accent); fill: none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`,

'Code Reviewer': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="8" width="128" height="104" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="30" y="24" width="64" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="30" y="40" width="52" height="5" rx="2.5" style="fill: var(--color-accent-bg)"/>
  <rect x="30" y="56" width="72" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="30" y="72" width="44" height="5" rx="2.5" style="fill: var(--color-accent-bg)"/>
  <rect x="30" y="88" width="60" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <polyline points="150,22 154,26 162,18" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="148" y="36" width="36" height="16" rx="8" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="166" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">fix?</text>
  <polyline points="150,62 154,66 162,58" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="148" y="68" width="36" height="16" rx="8" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="166" y="80" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">nice!</text>
  <line x1="152" y1="93" x2="158" y2="87" style="stroke: var(--color-text-muted)" stroke-width="2" stroke-linecap="round"/>
  <line x1="152" y1="87" x2="158" y2="93" style="stroke: var(--color-text-muted)" stroke-width="2" stroke-linecap="round"/>
</svg>`,

'Code Simplifier': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="16" width="68" height="88" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="20" y="28" width="48" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="20" y="38" width="36" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="20" y="48" width="44" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="20" y="58" width="28" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="20" y="68" width="52" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="20" y="78" width="40" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="20" y="88" width="32" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <polyline points="90,56 102,50 102,62 114,56" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="122" y="28" width="68" height="64" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="132" y="40" width="48" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.6"/>
  <rect x="132" y="52" width="36" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.6"/>
  <rect x="132" y="64" width="44" height="6" rx="3" style="fill: var(--color-accent); opacity: 0.6"/>
  <text x="44" y="12" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Before</text>
  <text x="156" y="22" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">After</text>
</svg>`,

'Doc Generator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="48" y="8" width="104" height="104" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="60" y="16" width="40" height="12" rx="4" style="fill: var(--color-accent)"/>
  <text x="80" y="25" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 700; font-family: var(--font-sans)">DOCS</text>
  <rect x="60" y="36" width="80" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="60" y="46" width="64" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="60" y="56" width="72" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="60" y="70" width="80" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="60" y="80" width="56" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="60" y="90" width="68" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <line x1="34" y1="92" x2="34" y2="40" style="stroke: var(--color-accent)" stroke-width="2.5" stroke-linecap="round"/>
  <polyline points="28,46 34,38 40,46" style="stroke: var(--color-accent); fill: none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="34" cy="96" r="3" style="fill: var(--color-accent)"/>
</svg>`,

'Inline Agent': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="100" rx="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <polygon points="20,90 8,102 20,98" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5" stroke-linejoin="round"/>
  <rect x="36" y="22" width="100" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="36" y="34" width="80" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <line x1="36" y1="50" x2="164" y2="50" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <circle cx="64" cy="72" r="14" style="fill: var(--color-accent); opacity: 0.15"/>
  <circle cx="64" cy="66" r="6" style="fill: var(--color-accent)"/>
  <ellipse cx="64" cy="80" rx="8" ry="6" style="fill: var(--color-accent); opacity: 0.8"/>
  <rect x="86" y="64" width="72" height="5" rx="2.5" style="fill: var(--color-accent); opacity: 0.4"/>
  <rect x="86" y="76" width="56" height="5" rx="2.5" style="fill: var(--color-accent); opacity: 0.4"/>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Works inside your session</text>
</svg>`,

'Opponent Processor': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="14" width="76" height="48" rx="10" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <polygon points="52,62 62,74 42,74" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5" stroke-linejoin="round"/>
  <rect x="52" y="60" width="36" height="4" style="fill: var(--color-accent-bg)"/>
  <text x="50" y="35" text-anchor="middle" style="fill: var(--color-accent); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">PRO</text>
  <rect x="22" y="44" width="56" height="5" rx="2.5" style="fill: var(--color-accent); opacity: 0.3"/>
  <rect x="22" y="52" width="40" height="5" rx="2.5" style="fill: var(--color-accent); opacity: 0.3"/>
  <rect x="112" y="14" width="76" height="48" rx="10" style="fill: var(--color-surface-2); stroke: var(--color-text-secondary)" stroke-width="1.5"/>
  <polygon points="148,62 158,74 138,74" style="fill: var(--color-surface-2); stroke: var(--color-text-secondary)" stroke-width="1.5" stroke-linejoin="round"/>
  <rect x="138" y="60" width="20" height="4" style="fill: var(--color-surface-2)"/>
  <text x="150" y="35" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">CON</text>
  <rect x="122" y="44" width="56" height="5" rx="2.5" style="fill: var(--color-text-secondary); opacity: 0.3"/>
  <rect x="122" y="52" width="40" height="5" rx="2.5" style="fill: var(--color-text-secondary); opacity: 0.3"/>
  <line x1="90" y1="36" x2="110" y2="36" style="stroke: var(--color-border)" stroke-width="1.5" stroke-dasharray="3 3"/>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Devil's advocate debate</text>
</svg>`,

'Performance Coach': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="16" width="120" height="80" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <line x1="36" y1="82" x2="36" y2="28" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <line x1="36" y1="82" x2="128" y2="82" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <polyline points="44,74 60,66 76,58 92,46 108,34 120,28" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="44" cy="74" r="2.5" style="fill: var(--color-accent)"/>
  <circle cx="60" cy="66" r="2.5" style="fill: var(--color-accent)"/>
  <circle cx="76" cy="58" r="2.5" style="fill: var(--color-accent)"/>
  <circle cx="92" cy="46" r="2.5" style="fill: var(--color-accent)"/>
  <circle cx="108" cy="34" r="2.5" style="fill: var(--color-accent)"/>
  <circle cx="120" cy="28" r="2.5" style="fill: var(--color-accent)"/>
  <circle cx="164" cy="44" r="20" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <circle cx="164" cy="38" r="4" style="fill: var(--color-accent)"/>
  <rect x="160" y="44" width="8" height="12" rx="2" style="fill: var(--color-accent)"/>
  <text x="100" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Tracks trends and suggests improvements</text>
</svg>`,

'Stack Scout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="52" r="28" style="stroke: var(--color-accent); fill: none" stroke-width="2"/>
  <circle cx="100" cy="52" r="20" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <circle cx="100" cy="52" r="4" style="fill: var(--color-accent)"/>
  <line x1="100" y1="32" x2="100" y2="28" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <line x1="100" y1="76" x2="100" y2="72" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <line x1="72" y1="52" x2="76" y2="52" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <line x1="124" y1="52" x2="128" y2="52" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <rect x="20" y="12" width="32" height="16" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="36" y="23" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">React</text>
  <rect x="148" y="12" width="32" height="16" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="164" y="23" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">Next</text>
  <rect x="20" y="88" width="32" height="16" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="36" y="99" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">Supa</text>
  <rect x="148" y="88" width="32" height="16" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <text x="164" y="99" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">Stripe</text>
  <line x1="52" y1="20" x2="76" y2="38" style="stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="3 3"/>
  <line x1="148" y1="20" x2="124" y2="38" style="stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="3 3"/>
  <line x1="52" y1="96" x2="76" y2="68" style="stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="3 3"/>
  <line x1="148" y1="96" x2="124" y2="68" style="stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="3 3"/>
</svg>`,

'Worktree Agent': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="108" y="8" width="80" height="104" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="148" y="22" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Main</text>
  <rect x="118" y="30" width="60" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="118" y="40" width="48" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="118" y="50" width="56" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="118" y="60" width="40" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="118" y="70" width="52" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="118" y="80" width="44" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <rect x="118" y="90" width="60" height="5" rx="2.5" style="fill: var(--color-surface-2)"/>
  <line x1="96" y1="14" x2="96" y2="106" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="5 4"/>
  <rect x="12" y="24" width="72" height="72" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="48" cy="48" r="8" style="fill: var(--color-accent)"/>
  <ellipse cx="48" cy="64" rx="10" ry="8" style="fill: var(--color-accent); opacity: 0.7"/>
  <rect x="22" y="78" width="52" height="4" rx="2" style="fill: var(--color-accent); opacity: 0.3"/>
  <rect x="22" y="86" width="40" height="4" rx="2" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="48" y="106" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Isolated</text>
</svg>`,

};
