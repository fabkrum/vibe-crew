/** SVG illustrations for tool-related glossary terms */
export const toolSvgs: Record<string, string> = {

'CLAUDE.md': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="8" width="120" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <polygon points="40,8 40,28 60,8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5" stroke-linejoin="round"/>
  <text x="72" y="28" style="fill: var(--color-accent); font-size: 10px; font-weight: 700; font-family: var(--font-mono)">CLAUDE.md</text>
  <line x1="56" y1="38" x2="144" y2="38" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="56" y="46" width="80" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <rect x="56" y="56" width="68" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="56" y="66" width="76" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.35"/>
  <rect x="56" y="76" width="60" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <rect x="56" y="86" width="72" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.25"/>
  <polygon points="140,12 148,8 148,24 140,20" style="fill: var(--color-accent)"/>
  <rect x="142" y="10" width="12" height="14" rx="2" style="fill: var(--color-accent)"/>
</svg>`,

'Context Window': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="8" width="140" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="24" y="20" width="124" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="24" y="30" width="108" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.35"/>
  <rect x="24" y="40" width="118" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <rect x="24" y="50" width="96" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.25"/>
  <rect x="24" y="60" width="110" height="6" rx="3" style="fill: var(--color-text-muted); opacity: 0.2"/>
  <rect x="168" y="8" width="20" height="104" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="171" y="11" width="14" height="40" rx="3" style="fill: var(--color-green)"/>
  <line x1="170" y1="70" x2="186" y2="70" style="stroke: var(--color-amber)" stroke-width="1" stroke-dasharray="2 2"/>
  <text x="190" y="73" style="fill: var(--color-amber); font-size: 7px; font-family: var(--font-mono)">60</text>
  <line x1="170" y1="90" x2="186" y2="90" style="stroke: var(--color-red)" stroke-width="1" stroke-dasharray="2 2"/>
  <text x="190" y="93" style="fill: var(--color-red); font-size: 7px; font-family: var(--font-mono)">80</text>
  <text x="178" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-mono)">%</text>
</svg>`,

'Hook': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="36" width="56" height="32" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="40" y="56" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Event</text>
  <rect x="132" y="36" width="56" height="32" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="160" y="56" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Script</text>
  <line x1="68" y1="52" x2="108" y2="52" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <polyline points="104,46 112,52 104,58" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M88,32 C88,32 96,32 96,40 C96,48 88,48 88,56 C88,64 96,64 96,72" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round"/>
  <circle cx="96" cy="76" r="3" style="fill: var(--color-accent)"/>
  <polyline points="76,46 80,52 76,58" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">PreToolUse → bash</text>
</svg>`,

'MCP': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="56" r="22" style="fill: var(--color-accent); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="100" y="61" text-anchor="middle" style="fill: #fff; font-size: 12px; font-weight: 700; font-family: var(--font-sans)">AI</text>
  <line x1="78" y1="46" x2="44" y2="28" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="122" y1="46" x2="156" y2="28" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="78" y1="66" x2="44" y2="88" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="122" y1="66" x2="156" y2="88" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="36" cy="24" r="14" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="30" y="18" width="12" height="10" rx="2" style="fill: none; stroke: var(--color-text-secondary)" stroke-width="1.2"/>
  <line x1="33" y1="28" x2="33" y2="32" style="stroke: var(--color-text-secondary)" stroke-width="1.2"/>
  <line x1="39" y1="28" x2="39" y2="32" style="stroke: var(--color-text-secondary)" stroke-width="1.2"/>
  <circle cx="164" cy="24" r="14" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="164" cy="22" r="6" style="fill: none; stroke: var(--color-text-secondary)" stroke-width="1.2"/>
  <polyline points="160,28 164,32 168,28" style="stroke: var(--color-text-secondary); fill: none" stroke-width="1.2" stroke-linecap="round"/>
  <circle cx="36" cy="92" r="14" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="30" y="86" width="12" height="12" rx="1" style="fill: none; stroke: var(--color-text-secondary)" stroke-width="1.2"/>
  <text x="36" y="95" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-mono)">{ }</text>
  <circle cx="164" cy="92" r="14" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="157" y="86" width="14" height="10" rx="2" style="fill: none; stroke: var(--color-text-secondary)" stroke-width="1.2"/>
  <line x1="160" y1="90" x2="168" y2="90" style="stroke: var(--color-text-secondary)" stroke-width="1"/>
  <line x1="160" y1="93" x2="165" y2="93" style="stroke: var(--color-text-secondary)" stroke-width="1"/>
</svg>`,

'MCP Server': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="28" y="16" width="88" height="88" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="72" y="36" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Server</text>
  <line x1="36" y1="42" x2="108" y2="42" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <circle cx="48" cy="56" r="5" style="fill: var(--color-green)"/>
  <rect x="60" y="52" width="28" height="8" rx="2" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <circle cx="48" cy="72" r="5" style="fill: var(--color-accent)"/>
  <rect x="60" y="68" width="36" height="8" rx="2" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <circle cx="48" cy="88" r="5" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="60" y="84" width="20" height="8" rx="2" style="fill: var(--color-text-muted); opacity: 0.2"/>
  <line x1="116" y1="56" x2="148" y2="56" style="stroke: var(--color-accent)" stroke-width="2"/>
  <rect x="128" y="50" width="12" height="12" rx="2" style="fill: var(--color-accent)"/>
  <rect x="131" y="53" width="6" height="6" rx="1" style="fill: #fff"/>
  <circle cx="164" cy="56" r="20" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="164" y="61" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">AI</text>
</svg>`,

'Profile': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="12" width="168" height="96" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="52" cy="48" r="18" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <circle cx="52" cy="43" r="7" style="fill: var(--color-accent)"/>
  <path d="M38,58 C38,52 44,48 52,48 C60,48 66,52 66,58" style="fill: var(--color-accent); stroke: none"/>
  <text x="52" y="80" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">User</text>
  <rect x="90" y="28" width="52" height="6" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="90" y="28" width="34" height="6" rx="3" style="fill: var(--color-accent)"/>
  <text x="148" y="34" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">auto</text>
  <rect x="90" y="44" width="52" height="6" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="90" y="44" width="44" height="6" rx="3" style="fill: var(--color-accent)"/>
  <text x="148" y="50" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">detail</text>
  <rect x="90" y="60" width="52" height="6" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="90" y="60" width="20" height="6" rx="3" style="fill: var(--color-accent)"/>
  <text x="148" y="66" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">light</text>
  <rect x="90" y="76" width="52" height="6" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="90" y="76" width="40" height="6" rx="3" style="fill: var(--color-accent)"/>
  <text x="148" y="82" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">balanced</text>
</svg>`,

'Session Learning': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="60" cy="48" r="24" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <path d="M60,30 L60,48 M52,42 L60,48 L68,42" style="stroke: var(--color-accent); fill: none" stroke-width="0"/>
  <ellipse cx="60" cy="36" rx="8" ry="10" style="fill: none; stroke: var(--color-accent)" stroke-width="1.5"/>
  <line x1="60" y1="46" x2="60" y2="56" style="stroke: var(--color-accent)" stroke-width="2"/>
  <line x1="52" y1="56" x2="68" y2="56" style="stroke: var(--color-accent)" stroke-width="2"/>
  <polyline points="48,60 52,56 56,60" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="64,60 68,56 72,60" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="90" y1="48" x2="118" y2="48" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <polyline points="114,42 122,48 114,54" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="126" y="20" width="60" height="72" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="156" y="38" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">CLAUDE</text>
  <text x="156" y="47" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-mono)">.md</text>
  <line x1="134" y1="54" x2="178" y2="54" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="134" y="60" width="36" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <rect x="134" y="68" width="28" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.25"/>
  <rect x="134" y="76" width="32" height="4" rx="2" style="fill: var(--color-accent); opacity: 0.6"/>
  <text x="60" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">insight</text>
  <text x="156" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">saved</text>
</svg>`,

'TDR': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="24" y="8" width="152" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="26" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Technology Decision</text>
  <line x1="36" y1="34" x2="164" y2="34" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <line x1="100" y1="34" x2="100" y2="102" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="66" y="48" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Option A</text>
  <text x="132" y="48" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Option B</text>
  <circle cx="56" cy="62" r="7" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <polyline points="52,62 55,65 60,59" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="68" y="65" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Perf</text>
  <circle cx="122" cy="62" r="7" style="fill: var(--color-red-dim); stroke: var(--color-red)" stroke-width="1"/>
  <line x1="119" y1="59" x2="125" y2="65" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="125" y1="59" x2="119" y2="65" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="134" y="65" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Perf</text>
  <circle cx="56" cy="80" r="7" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <polyline points="52,80 55,83 60,77" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="68" y="83" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">DX</text>
  <circle cx="122" cy="80" r="7" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <polyline points="118,80 121,83 126,77" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="134" y="83" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">DX</text>
  <circle cx="56" cy="98" r="7" style="fill: var(--color-red-dim); stroke: var(--color-red)" stroke-width="1"/>
  <line x1="53" y1="95" x2="59" y2="101" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="59" y1="95" x2="53" y2="101" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="68" y="101" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Size</text>
  <circle cx="122" cy="98" r="7" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <polyline points="118,98 121,101 126,95" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="134" y="101" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Size</text>
</svg>`,

'Vibe Dashboard': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="8" width="184" height="104" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="8" y1="24" x2="192" y2="24" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <circle cx="18" cy="16" r="3" style="fill: var(--color-red)"/>
  <circle cx="28" cy="16" r="3" style="fill: var(--color-amber)"/>
  <circle cx="38" cy="16" r="3" style="fill: var(--color-green)"/>
  <rect x="16" y="32" width="40" height="56" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="62" y="32" width="40" height="56" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="20" y="38" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="20" y="50" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="20" y="62" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="66" y="38" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="66" y="50" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="36" y="30" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">TODO</text>
  <text x="82" y="30" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">DOING</text>
  <rect x="110" y="32" width="80" height="28" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <polyline points="118,54 130,46 142,50 154,38 166,42 178,36" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="140" cy="84" r="16" style="fill: none; stroke: var(--color-surface-2)" stroke-width="6"/>
  <circle cx="140" cy="84" r="16" style="fill: none; stroke: var(--color-accent)" stroke-width="6" stroke-dasharray="80 100" stroke-dashoffset="25" transform="rotate(-90 140 84)"/>
  <text x="140" y="88" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-mono)">85</text>
  <text x="172" y="88" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">vibe</text>
  <text x="172" y="96" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">score</text>
</svg>`,

'VISION.md': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="44" y="8" width="112" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <polygon points="100,24 103,30 110,31 105,36 106,42 100,39 94,42 95,36 90,31 97,30" style="fill: var(--color-accent)"/>
  <line x1="100" y1="16" x2="100" y2="20" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="114" y1="20" x2="112" y2="24" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="86" y1="20" x2="88" y2="24" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="118" y1="30" x2="114" y2="30" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="82" y1="30" x2="86" y2="30" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="100" y="58" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-mono)">VISION</text>
  <line x1="60" y1="64" x2="140" y2="64" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <rect x="60" y="72" width="80" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="60" y="82" width="64" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.35"/>
  <rect x="60" y="92" width="72" height="5" rx="2.5" style="fill: var(--color-text-muted); opacity: 0.3"/>
</svg>`,

};
