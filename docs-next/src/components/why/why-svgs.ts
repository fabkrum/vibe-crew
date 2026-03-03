/** SVG illustrations for the Why VibeCrew page */
export const whySvgs: Record<string, string> = {

/* ── Section 1: Aspirational hero ─────────────────────────────── */
'idea-to-product': `<svg viewBox="0 0 360 140" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Lightbulb -->
  <circle cx="40" cy="56" r="22" style="fill: var(--color-amber-dim)"/>
  <path d="M40 38 C28 38 20 48 20 58 C20 66 26 72 32 76 L32 84 L48 84 L48 76 C54 72 60 66 60 58 C60 48 52 38 40 38Z" style="fill: var(--color-amber); opacity: 0.8"/>
  <rect x="34" y="84" width="12" height="4" rx="2" style="fill: var(--color-amber)"/>
  <rect x="36" y="90" width="8" height="3" rx="1.5" style="fill: var(--color-amber); opacity: 0.6"/>
  <line x1="40" y1="26" x2="40" y2="20" style="stroke: var(--color-amber)" stroke-width="2" stroke-linecap="round"/>
  <line x1="56" y1="36" x2="60" y2="32" style="stroke: var(--color-amber)" stroke-width="2" stroke-linecap="round"/>
  <line x1="24" y1="36" x2="20" y2="32" style="stroke: var(--color-amber)" stroke-width="2" stroke-linecap="round"/>
  <text x="40" y="120" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Your idea</text>

  <!-- Arrow 1 -->
  <line x1="72" y1="58" x2="94" y2="58" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <polyline points="90,52 96,58 90,64" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

  <!-- Stage: Plan -->
  <rect x="100" y="42" width="56" height="32" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="128" y="63" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Plan</text>

  <!-- Arrow 2 -->
  <line x1="160" y1="58" x2="174" y2="58" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <polyline points="170,52 176,58 170,64" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

  <!-- Stage: Build -->
  <rect x="180" y="42" width="56" height="32" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="208" y="63" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Build</text>

  <!-- Arrow 3 -->
  <line x1="240" y1="58" x2="254" y2="58" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <polyline points="250,52 256,58 250,64" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

  <!-- Stage: Ship -->
  <rect x="260" y="42" width="56" height="32" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="288" y="63" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Ship</text>

  <!-- Arrow 4 -->
  <line x1="320" y1="58" x2="330" y2="58" style="stroke: var(--color-green)" stroke-width="2" stroke-linecap="round"/>

  <!-- Browser with checkmark -->
  <rect x="334" y="30" width="22" height="56" rx="4" style="fill: var(--color-surface); stroke: var(--color-green)" stroke-width="1.5"/>
  <rect x="334" y="30" width="22" height="10" rx="4" style="fill: var(--color-green); opacity: 0.15"/>
  <rect x="334" y="36" width="22" height="4" style="fill: var(--color-green); opacity: 0.15"/>
  <circle cx="339" cy="35" r="1.5" style="fill: var(--color-green); opacity: 0.5"/>
  <circle cx="344" cy="35" r="1.5" style="fill: var(--color-green); opacity: 0.5"/>
  <polyline points="340,58 344,62 352,52" style="stroke: var(--color-green); fill: none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="345" y="120" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Production-ready</text>
</svg>`,

/* ── Section 2: Before VibeCrew (pain) ────────────────────────── */
'before-vibecrew': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Code editor with red squiggles -->
  <rect x="8" y="8" width="80" height="56" rx="4" style="stroke: var(--color-red); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="8" y="8" width="80" height="12" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="8" y="16" width="80" height="4" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="28" width="40" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <path d="M16 40 Q20 36 24 40 Q28 44 32 40 Q36 36 40 40 Q44 44 48 40 Q52 36 56 40" style="stroke: var(--color-red); fill: none" stroke-width="1.5"/>
  <rect x="16" y="48" width="52" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.5"/>
  <path d="M16 56 Q20 52 24 56 Q28 60 32 56" style="stroke: var(--color-red); fill: none" stroke-width="1.5"/>

  <!-- Context bar at 95% (red) -->
  <rect x="108" y="8" width="84" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="110" y="10" width="76" height="16" rx="3" style="fill: var(--color-red); opacity: 0.2"/>
  <rect x="110" y="10" width="72" height="16" rx="3" style="fill: var(--color-red); opacity: 0.6"/>
  <text x="150" y="22" text-anchor="middle" style="fill: var(--color-red); font-size: 8px; font-weight: 700; font-family: var(--font-mono)">95%</text>
  <text x="150" y="38" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Context full</text>

  <!-- Token counter climbing -->
  <rect x="108" y="48" width="84" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="116" y="62" style="fill: var(--color-amber); font-size: 9px; font-weight: 700; font-family: var(--font-mono)">$ 47.82</text>
  <polyline points="168,64 174,56 180,60 186,52" style="stroke: var(--color-red); fill: none" stroke-width="1.5" stroke-linecap="round"/>

  <!-- Broken browser windows -->
  <rect x="8" y="76" width="40" height="36" rx="3" style="stroke: var(--color-red); fill: var(--color-surface); opacity: 0.7" stroke-width="1"/>
  <line x1="16" y1="88" x2="28" y2="100" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="28" y1="88" x2="16" y2="100" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="56" y="80" width="40" height="32" rx="3" style="stroke: var(--color-red); fill: var(--color-surface); opacity: 0.7" stroke-width="1"/>
  <line x1="64" y1="92" x2="76" y2="100" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="76" y1="92" x2="64" y2="100" style="stroke: var(--color-red)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="150" y="90" text-anchor="middle" style="fill: var(--color-red); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Broken in</text>
  <text x="150" y="102" text-anchor="middle" style="fill: var(--color-red); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">production</text>
</svg>`,

/* ── Section 3: Parallel workflow ─────────────────────────────── */
'parallel-workflow': `<svg viewBox="0 0 360 160" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Terminal A: Coding (blue spinner) -->
  <rect x="8" y="8" width="104" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="8" y="8" width="104" height="16" rx="6" style="fill: var(--color-surface-2)"/>
  <rect x="8" y="18" width="104" height="6" style="fill: var(--color-surface-2)"/>
  <circle cx="20" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <circle cx="28" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <circle cx="36" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <text x="60" y="18" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Project A</text>
  <rect x="18" y="34" width="56" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="18" y="44" width="72" height="4" rx="2" style="fill: var(--color-blue); opacity: 0.4"/>
  <rect x="18" y="54" width="48" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="18" y="64" width="64" height="4" rx="2" style="fill: var(--color-blue); opacity: 0.4"/>
  <!-- Blue spinner -->
  <circle cx="60" cy="88" r="6" style="stroke: var(--color-blue); fill: none" stroke-width="2" stroke-dasharray="20 12"/>
  <text x="60" y="102" text-anchor="middle" style="fill: var(--color-blue); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Coding...</text>

  <!-- Terminal B: Needs you (amber, highlighted) -->
  <rect x="128" y="8" width="104" height="100" rx="6" style="stroke: var(--color-amber); fill: var(--color-surface)" stroke-width="2.5"/>
  <rect x="128" y="8" width="104" height="16" rx="6" style="fill: var(--color-amber-dim)"/>
  <rect x="128" y="18" width="104" height="6" style="fill: var(--color-amber-dim)"/>
  <circle cx="140" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <circle cx="148" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <circle cx="156" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <text x="180" y="18" text-anchor="middle" style="fill: var(--color-amber); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">Project B</text>
  <rect x="138" y="34" width="64" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <rect x="138" y="44" width="48" height="4" rx="2" style="fill: var(--color-amber); opacity: 0.3"/>
  <rect x="138" y="54" width="72" height="4" rx="2" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <!-- Bell icon -->
  <path d="M176 76 C176 70 180 66 180 66 C180 66 184 70 184 76 L186 78 L174 78 Z" style="fill: var(--color-amber)"/>
  <circle cx="180" cy="82" r="2" style="fill: var(--color-amber)"/>
  <text x="180" y="96" text-anchor="middle" style="fill: var(--color-amber); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Needs you</text>

  <!-- Terminal C: Done (green checkmark) -->
  <rect x="248" y="8" width="104" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="248" y="8" width="104" height="16" rx="6" style="fill: var(--color-surface-2)"/>
  <rect x="248" y="18" width="104" height="6" style="fill: var(--color-surface-2)"/>
  <circle cx="260" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <circle cx="268" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <circle cx="276" cy="16" r="3" style="fill: var(--color-text-muted); opacity: 0.4"/>
  <text x="300" y="18" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Project C</text>
  <rect x="258" y="34" width="72" height="4" rx="2" style="fill: var(--color-green); opacity: 0.3"/>
  <rect x="258" y="44" width="56" height="4" rx="2" style="fill: var(--color-green); opacity: 0.3"/>
  <rect x="258" y="54" width="64" height="4" rx="2" style="fill: var(--color-green); opacity: 0.3"/>
  <!-- Green checkmark -->
  <polyline points="294,78 298,84 308,72" style="stroke: var(--color-green); fill: none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="300" y="96" text-anchor="middle" style="fill: var(--color-green); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Done</text>

  <!-- Notification toast -->
  <rect x="100" y="128" width="172" height="26" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-amber)" stroke-width="1.5"/>
  <circle cx="114" cy="141" r="5" style="fill: var(--color-amber); opacity: 0.2"/>
  <path d="M112 138 C112 135 114 133 114 133 C114 133 116 135 116 138 L117 139 L111 139 Z" style="fill: var(--color-amber)"/>
  <text x="126" y="144" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Feature complete — click to review</text>
  <!-- Arrow pointing up to center terminal -->
  <line x1="180" y1="126" x2="180" y2="112" style="stroke: var(--color-amber)" stroke-width="1.5" stroke-dasharray="3 2"/>
</svg>`,

/* ── Card 1: Architecture before code ─────────────────────────── */
'foundation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Bottom layer: Vision (widest) -->
  <rect x="20" y="76" width="160" height="28" rx="4" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1.5"/>
  <text x="100" y="94" text-anchor="middle" style="fill: var(--color-green); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Vision</text>

  <!-- Middle layer: Design System -->
  <rect x="36" y="46" width="128" height="28" rx="4" style="fill: var(--color-blue-dim); stroke: var(--color-blue)" stroke-width="1.5"/>
  <text x="100" y="64" text-anchor="middle" style="fill: var(--color-blue); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Design System</text>

  <!-- Top layer: Tech Stack (narrowest) -->
  <rect x="52" y="16" width="96" height="28" rx="4" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="100" y="34" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Tech Stack</text>

  <!-- Lock icon (phase gate) -->
  <rect x="168" y="40" width="20" height="16" rx="3" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1.5"/>
  <path d="M172 40 L172 36 C172 30 184 30 184 36 L184 40" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <circle cx="178" cy="48" r="2" style="fill: var(--color-green)"/>
</svg>`,

/* ── Card 2: Quality on autopilot ─────────────────────────────── */
'auto-quality': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Gear icon at top -->
  <circle cx="100" cy="12" r="8" style="stroke: var(--color-blue); fill: var(--color-blue-dim)" stroke-width="1.5"/>
  <circle cx="100" cy="12" r="3" style="fill: var(--color-blue)"/>

  <!-- Pipeline stages with checkmarks -->
  <g transform="translate(30, 26)">
    <rect x="0" y="0" width="140" height="16" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
    <text x="10" y="12" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Tests</text>
    <polyline points="124,4 128,10 136,2" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
  <g transform="translate(30, 44)">
    <rect x="0" y="0" width="140" height="16" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
    <text x="10" y="12" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Lint</text>
    <polyline points="124,4 128,10 136,2" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
  <g transform="translate(30, 62)">
    <rect x="0" y="0" width="140" height="16" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
    <text x="10" y="12" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Types</text>
    <polyline points="124,4 128,10 136,2" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
  <g transform="translate(30, 80)">
    <rect x="0" y="0" width="140" height="16" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
    <text x="10" y="12" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Review</text>
    <polyline points="124,4 128,10 136,2" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
  <g transform="translate(30, 98)">
    <rect x="0" y="0" width="140" height="16" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
    <text x="10" y="12" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Security</text>
    <polyline points="124,4 128,10 136,2" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>`,

/* ── Card 3: Patterns that convert ────────────────────────────── */
'patterns': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Left: Form with error state -->
  <rect x="8" y="8" width="84" height="104" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="16" y="24" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <rect x="16" y="28" width="68" height="14" rx="3" style="stroke: var(--color-red); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="24" y="38" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)">user@</text>
  <text x="16" y="52" style="fill: var(--color-red); font-size: 6px; font-family: var(--font-sans)">Please enter a valid email</text>
  <text x="16" y="66" style="fill: var(--color-text-secondary); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Password</text>
  <rect x="16" y="70" width="68" height="14" rx="3" style="stroke: var(--color-green); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="24" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)">********</text>
  <polyline points="74,76 76,78 80,74" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="16" y="92" width="68" height="14" rx="4" style="fill: var(--color-accent)"/>
  <text x="50" y="102" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Sign up</text>

  <!-- Right: Pricing card -->
  <rect x="108" y="8" width="84" height="104" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="126" y="4" width="48" height="12" rx="6" style="fill: var(--color-accent)"/>
  <text x="150" y="13" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 700; font-family: var(--font-sans)">Most Popular</text>
  <text x="150" y="36" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Pro</text>
  <text x="150" y="52" text-anchor="middle" style="fill: var(--color-accent); font-size: 14px; font-weight: 700; font-family: var(--font-sans)">$29</text>
  <text x="150" y="62" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">/month</text>
  <rect x="116" y="70" width="8" height="1.5" rx="0.75" style="fill: var(--color-green)"/>
  <text x="128" y="74" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Unlimited</text>
  <rect x="116" y="80" width="8" height="1.5" rx="0.75" style="fill: var(--color-green)"/>
  <text x="128" y="84" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Priority</text>
  <rect x="116" y="96" width="68" height="12" rx="4" style="fill: var(--color-accent)"/>
  <text x="150" y="105" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Get started</text>
</svg>`,

/* ── Accordion 1: Context management ──────────────────────────── */
'context-mgmt': `<svg viewBox="0 0 200 80" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Without VibeCrew -->
  <text x="48" y="10" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Without VibeCrew</text>
  <rect x="4" y="14" width="88" height="18" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="6" y="16" width="80" height="14" rx="3" style="fill: var(--color-red); opacity: 0.2"/>
  <rect x="6" y="16" width="76" height="14" rx="3" style="fill: var(--color-red); opacity: 0.6"/>
  <text x="48" y="27" text-anchor="middle" style="fill: var(--color-red); font-size: 8px; font-weight: 700; font-family: var(--font-mono)">95%</text>

  <!-- With VibeCrew -->
  <text x="150" y="10" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">With VibeCrew</text>
  <rect x="106" y="14" width="88" height="18" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="108" y="16" width="84" height="14" rx="3" style="fill: var(--color-green); opacity: 0.1"/>
  <rect x="108" y="16" width="34" height="14" rx="3" style="fill: var(--color-green); opacity: 0.6"/>
  <text x="150" y="27" text-anchor="middle" style="fill: var(--color-green); font-size: 8px; font-weight: 700; font-family: var(--font-mono)">40%</text>

  <!-- Labels -->
  <text x="48" y="48" text-anchor="middle" style="fill: var(--color-red); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Context wall</text>
  <text x="150" y="48" text-anchor="middle" style="fill: var(--color-green); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Room to work</text>

  <!-- Techniques -->
  <text x="150" y="62" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Worktree isolation</text>
  <text x="150" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">MCP + compaction</text>
</svg>`,

/* ── Accordion 2: Vibe Score ──────────────────────────────────── */
'vibe-score': `<svg viewBox="0 0 200 80" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Chart area -->
  <rect x="20" y="6" width="160" height="58" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <line x1="32" y1="56" x2="168" y2="56" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <line x1="32" y1="56" x2="32" y2="12" style="stroke: var(--color-border-subtle)" stroke-width="1"/>

  <!-- Session labels -->
  <text x="50" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S1</text>
  <text x="78" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S2</text>
  <text x="106" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S3</text>
  <text x="134" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S4</text>
  <text x="162" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S5</text>

  <!-- Score line trending up -->
  <polyline points="50,48 78,42 106,36 134,28 162,18" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="50" cy="48" r="3" style="fill: var(--color-accent)"/>
  <circle cx="78" cy="42" r="3" style="fill: var(--color-accent)"/>
  <circle cx="106" cy="36" r="3" style="fill: var(--color-accent)"/>
  <circle cx="134" cy="28" r="3" style="fill: var(--color-accent)"/>
  <circle cx="162" cy="18" r="3" style="fill: var(--color-accent)"/>

  <!-- Upward arrow -->
  <line x1="172" y1="18" x2="180" y2="10" style="stroke: var(--color-green)" stroke-width="2" stroke-linecap="round"/>
  <polyline points="176,10 180,10 180,14" style="stroke: var(--color-green); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

  <!-- Label -->
  <text x="100" y="78" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Each session more efficient</text>
</svg>`,

/* ── Accordion 3: Interrupt Protocol ──────────────────────────── */
'interrupt': `<svg viewBox="0 0 200 80" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Silent terminal -->
  <rect x="4" y="8" width="52" height="40" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="4" y="8" width="52" height="10" rx="4" style="fill: var(--color-surface-2)"/>
  <rect x="4" y="14" width="52" height="4" style="fill: var(--color-surface-2)"/>
  <rect x="12" y="24" width="28" height="3" rx="1.5" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <rect x="12" y="30" width="36" height="3" rx="1.5" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <rect x="12" y="36" width="20" height="3" rx="1.5" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <text x="30" y="60" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Silent</text>

  <!-- Event flash -->
  <circle cx="88" cy="28" r="12" style="fill: var(--color-amber); opacity: 0.15"/>
  <circle cx="88" cy="28" r="7" style="fill: var(--color-amber); opacity: 0.3"/>
  <circle cx="88" cy="28" r="3" style="fill: var(--color-amber)"/>
  <polyline points="72,28 62,28" style="stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="3 2"/>
  <polyline points="104,28 114,28" style="stroke: var(--color-amber)" stroke-width="1.5" stroke-dasharray="3 2"/>
  <text x="88" y="50" text-anchor="middle" style="fill: var(--color-amber); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Event</text>

  <!-- OS notification -->
  <rect x="120" y="8" width="76" height="40" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-amber)" stroke-width="1.5"/>
  <circle cx="134" cy="22" r="5" style="fill: var(--color-amber); opacity: 0.2"/>
  <text x="134" y="25" text-anchor="middle" style="fill: var(--color-amber); font-size: 9px">&#9889;</text>
  <text x="146" y="22" style="fill: var(--color-text-secondary); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">VibeCrew</text>
  <text x="130" y="36" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Click to open</text>
  <text x="158" y="60" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">One-click jump</text>
</svg>`,

/* ── Accordion 4: User profiles ───────────────────────────────── */
'profiles': `<svg viewBox="0 0 200 80" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Founder card -->
  <rect x="8" y="12" width="56" height="48" rx="6" style="stroke: var(--color-amber); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="36" cy="30" r="8" style="fill: var(--color-amber); opacity: 0.2"/>
  <text x="36" y="34" text-anchor="middle" style="fill: var(--color-amber); font-size: 10px">&#128161;</text>
  <rect x="18" y="44" width="36" height="8" rx="4" style="fill: var(--color-amber)"/>
  <text x="36" y="51" text-anchor="middle" style="fill: #fff; font-size: 6px; font-weight: 700; font-family: var(--font-sans)">Founder</text>

  <!-- Builder card -->
  <rect x="72" y="12" width="56" height="48" rx="6" style="stroke: var(--color-green); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="100" cy="30" r="8" style="fill: var(--color-green); opacity: 0.2"/>
  <text x="100" y="34" text-anchor="middle" style="fill: var(--color-green); font-size: 10px">&#128736;</text>
  <rect x="82" y="44" width="36" height="8" rx="4" style="fill: var(--color-green)"/>
  <text x="100" y="51" text-anchor="middle" style="fill: #fff; font-size: 6px; font-weight: 700; font-family: var(--font-sans)">Builder</text>

  <!-- Explorer card -->
  <rect x="136" y="12" width="56" height="48" rx="6" style="stroke: var(--color-blue); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="164" cy="30" r="8" style="fill: var(--color-blue); opacity: 0.2"/>
  <text x="164" y="34" text-anchor="middle" style="fill: var(--color-blue); font-size: 10px">&#128269;</text>
  <rect x="146" y="44" width="36" height="8" rx="4" style="fill: var(--color-blue)"/>
  <text x="164" y="51" text-anchor="middle" style="fill: #fff; font-size: 6px; font-weight: 700; font-family: var(--font-sans)">Explorer</text>

  <text x="100" y="76" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">2-minute interview or pick a preset</text>
</svg>`,

};
