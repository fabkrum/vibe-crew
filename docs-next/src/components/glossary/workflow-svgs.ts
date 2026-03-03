/** SVG illustrations for workflow-related glossary terms */
export const workflowSvgs: Record<string, string> = {

'Backlog': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="56" width="140" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="26" y="48" width="140" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="22" y="40" width="140" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="18" y="32" width="140" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="14" y="24" width="140" height="32" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="22" y="34" width="14" height="14" rx="3" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <polyline points="25,41 28,44 33,37" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="44" y="45" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Feature 1</text>
  <text x="14" y="100" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">5 features queued</text>
</svg>`,

'Feature Cycle': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="28" r="12" style="fill: var(--color-accent)"/>
  <text x="100" y="32" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 700; font-family: var(--font-sans)">P</text>
  <circle cx="142" cy="46" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="142" y="50" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">UI</text>
  <circle cx="142" cy="82" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="142" y="86" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">C</text>
  <circle cx="100" cy="100" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="104" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">T</text>
  <circle cx="58" cy="82" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="58" y="86" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">R</text>
  <circle cx="58" cy="46" r="12" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="58" y="50" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">D</text>
  <path d="M112 32 L130 40" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="127,36 130,40 126,42" style="stroke: var(--color-accent); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M148 58 L148 70" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="145,67 148,70 151,67" style="stroke: var(--color-border); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M130 88 L112 96" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="115,92 112,96 116,97" style="stroke: var(--color-border); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M88 96 L70 88" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="73,91 70,88 72,85" style="stroke: var(--color-border); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M52 70 L52 58" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="49,61 52,58 55,61" style="stroke: var(--color-border); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M70 40 L88 32" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="85,35 88,32 86,29" style="stroke: var(--color-border); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`,

'Foundation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="88" width="168" height="20" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="102" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Foundation</text>
  <rect x="28" y="36" width="24" height="52" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="88" y="36" width="24" height="52" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="148" y="36" width="24" height="52" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="34" y="46" width="12" height="16" rx="2" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2"/>
  <line x1="37" y1="52" x2="43" y2="52" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <line x1="37" y1="55" x2="42" y2="55" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <circle cx="100" cy="52" r="8" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2"/>
  <circle cx="100" cy="52" r="3" style="fill: var(--color-text-muted)"/>
  <circle cx="160" cy="52" r="8" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2"/>
  <rect x="157" y="48" width="6" height="8" rx="1" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <line x1="16" y1="30" x2="184" y2="30" style="stroke: var(--color-border-subtle)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="40" y="24" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Docs</text>
  <text x="92" y="24" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Design</text>
  <text x="152" y="24" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Tech</text>
</svg>`,

'Handoff': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M30 70 Q30 50 50 50 L68 50" style="stroke: var(--color-text-secondary); fill: none" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M30 70 Q30 80 40 82 L48 82" style="stroke: var(--color-text-secondary); fill: none" stroke-width="2" stroke-linecap="round"/>
  <path d="M30 70 Q28 78 36 84 L44 86" style="stroke: var(--color-text-secondary); fill: none" stroke-width="1.8" stroke-linecap="round"/>
  <rect x="72" y="38" width="36" height="28" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <line x1="80" y1="46" x2="100" y2="46" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <line x1="80" y1="50" x2="96" y2="50" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <line x1="80" y1="54" x2="98" y2="54" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <line x1="80" y1="58" x2="92" y2="58" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <path d="M112 50 L128 50" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round"/>
  <polyline points="124,46 128,50 124,54" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M170 70 Q170 50 150 50 L136 50" style="stroke: var(--color-text-secondary); fill: none" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M170 70 Q170 80 160 82 L152 82" style="stroke: var(--color-text-secondary); fill: none" stroke-width="2" stroke-linecap="round"/>
  <path d="M170 70 Q172 78 164 84 L156 86" style="stroke: var(--color-text-secondary); fill: none" stroke-width="1.8" stroke-linecap="round"/>
  <text x="40" y="106" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Session A</text>
  <text x="136" y="106" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Session B</text>
</svg>`,

'Phase Gate': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="88" y="16" width="8" height="76" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="104" y="16" width="8" height="76" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="86" y="40" width="28" height="6" rx="2" style="fill: var(--color-accent)"/>
  <rect x="36" y="32" width="36" height="28" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="44" y1="42" x2="64" y2="42" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <line x1="44" y1="46" x2="60" y2="46" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <line x1="44" y1="50" x2="62" y2="50" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <path d="M72 46 L84 46" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="80,42 84,46 80,50" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="140" cy="36" r="12" style="fill: var(--color-accent-bg)"/>
  <polyline points="134,36 138,40 146,32" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="140" y="60" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">PASS</text>
  <circle cx="140" cy="82" r="12" style="fill: var(--color-surface-2)"/>
  <line x1="135" y1="77" x2="145" y2="87" style="stroke: var(--color-text-muted)" stroke-width="2" stroke-linecap="round"/>
  <line x1="145" y1="77" x2="135" y2="87" style="stroke: var(--color-text-muted)" stroke-width="2" stroke-linecap="round"/>
  <text x="140" y="106" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">BLOCK</text>
</svg>`,

'Quality Gate': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M56 16 L80 8 L104 16 L104 56 Q80 72 56 56 Z" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <polyline points="70,38 77,45 90,30" style="stroke: var(--color-accent); fill: none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="130" cy="28" r="6" style="fill: var(--color-accent-bg)"/>
  <polyline points="127,28 129,30 133,26" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="142" y="32" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Types</text>
  <circle cx="130" cy="52" r="6" style="fill: var(--color-accent-bg)"/>
  <polyline points="127,52 129,54 133,50" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="142" y="56" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Lint</text>
  <circle cx="130" cy="76" r="6" style="fill: var(--color-accent-bg)"/>
  <polyline points="127,76 129,78 133,74" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="142" y="80" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Build</text>
  <text x="80" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">All checks passed</text>
</svg>`,

'Roadmap': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="24" y1="60" x2="176" y2="60" style="stroke: var(--color-border)" stroke-width="2" stroke-linecap="round"/>
  <circle cx="44" cy="60" r="8" style="fill: var(--color-accent)"/>
  <circle cx="44" cy="60" r="3" style="fill: #fff"/>
  <line x1="44" y1="48" x2="44" y2="34" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="44" y="28" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Vision</text>
  <circle cx="88" cy="60" r="8" style="fill: var(--color-accent)"/>
  <circle cx="88" cy="60" r="3" style="fill: #fff"/>
  <line x1="88" y1="72" x2="88" y2="86" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="88" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Design</text>
  <circle cx="132" cy="60" r="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="132" y1="48" x2="132" y2="34" style="stroke: var(--color-border)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="132" y="28" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Auth</text>
  <circle cx="176" cy="60" r="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="176" y1="72" x2="176" y2="86" style="stroke: var(--color-border)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="176" y="96" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">API</text>
  <polyline points="18,60 24,54 24,66 18,60" style="fill: var(--color-border)"/>
</svg>`,

'Tier 1': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="16" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Plan</text>
  <rect x="20" y="24" width="160" height="84" rx="6" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <line x1="80" y1="24" x2="80" y2="108" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="4 3" opacity="0.4"/>
  <line x1="140" y1="24" x2="140" y2="108" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="4 3" opacity="0.4"/>
  <line x1="20" y1="54" x2="180" y2="54" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="4 3" opacity="0.4"/>
  <line x1="20" y1="84" x2="180" y2="84" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="4 3" opacity="0.4"/>
  <rect x="30" y="32" width="38" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="49" y="42" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">VISION</text>
  <rect x="90" y="32" width="38" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="109" y="42" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">TDR</text>
  <rect x="30" y="62" width="38" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="49" y="72" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">DESIGN</text>
  <rect x="90" y="62" width="38" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="109" y="72" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">ARCH</text>
  <line x1="160" y1="92" x2="172" y2="92" style="stroke: var(--color-text-muted)" stroke-width="1.2" stroke-linecap="round"/>
  <line x1="166" y1="86" x2="166" y2="98" style="stroke: var(--color-text-muted)" stroke-width="1.2" stroke-linecap="round"/>
  <line x1="162" y1="100" x2="170" y2="100" style="stroke: var(--color-text-muted)" stroke-width="0.8" stroke-linecap="round"/>
  <polyline points="159,97 166,104 173,97" style="stroke: var(--color-text-muted); fill: none" stroke-width="0.8" stroke-linecap="round"/>
</svg>`,

'Tier 2': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="16" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Build</text>
  <rect x="24" y="74" width="152" height="12" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="50" width="32" height="24" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="46" y="66" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Auth</text>
  <rect x="68" y="50" width="32" height="24" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="84" y="66" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">API</text>
  <rect x="106" y="50" width="32" height="24" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="122" y="66" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">UI</text>
  <rect x="68" y="26" width="32" height="24" rx="4" style="fill: var(--color-accent); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="84" y="42" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Dash</text>
  <path d="M84 50 L84 50" style="stroke: var(--color-accent)" stroke-width="1"/>
  <circle cx="160" cy="38" r="12" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5"/>
  <rect x="156" y="33" width="8" height="10" rx="2" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2"/>
  <circle cx="160" cy="32" r="2" style="fill: var(--color-text-muted)"/>
  <text x="100" y="104" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Feature by feature</text>
</svg>`,

'WIP Limit': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="8" width="56" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="38" y="24" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">To Do</text>
  <line x1="10" y1="30" x2="66" y2="30" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="16" y="36" width="44" height="18" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="38" y="49" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Task 3</text>
  <rect x="16" y="58" width="44" height="18" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="38" y="71" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Task 4</text>
  <rect x="72" y="8" width="56" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="100" y="24" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Active</text>
  <line x1="72" y1="30" x2="128" y2="30" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.3"/>
  <rect x="78" y="36" width="44" height="18" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="100" y="49" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Task 1</text>
  <rect x="78" y="58" width="44" height="18" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="100" y="71" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Task 2</text>
  <rect x="78" y="84" width="44" height="18" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 2"/>
  <text x="100" y="97" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">MAX 2</text>
  <rect x="134" y="8" width="56" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="162" y="24" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Done</text>
  <line x1="134" y1="30" x2="190" y2="30" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="140" y="36" width="44" height="18" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="162" y="49" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Task 0</text>
</svg>`,

};
