/** SVG illustrations for "Business — Retention" patterns */
export const businessRetentionSvgs: Record<string, string> = {

'Habit Loops': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="62" r="36" style="stroke: var(--color-border-subtle); fill: none" stroke-width="1" stroke-dasharray="4 3"/>
  <circle cx="100" cy="26" r="14" style="fill: var(--color-blue-dim); stroke: var(--color-blue)" stroke-width="1"/>
  <path d="M97,23 L103,23 L103,27 L105,27 L100,32 L95,27 L97,27 Z" style="fill: var(--color-blue)"/>
  <text x="100" y="16" text-anchor="middle" style="fill: var(--color-blue); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Cue</text>
  <circle cx="136" cy="82" r="14" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <circle cx="136" cy="80" r="3" style="fill: var(--color-accent)"/>
  <rect x="133" y="84" width="6" height="6" rx="1" style="fill: none; stroke: var(--color-accent)" stroke-width="1"/>
  <text x="136" y="102" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Action</text>
  <circle cx="64" cy="82" r="14" style="fill: var(--color-amber-dim); stroke: var(--color-amber)" stroke-width="1"/>
  <polygon points="64,74 66,80 72,80 67,84 69,90 64,86 59,90 61,84 56,80 62,80" style="fill: var(--color-amber)"/>
  <text x="64" y="102" text-anchor="middle" style="fill: var(--color-amber); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Reward</text>
  <path d="M114,30 L128,68" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2" marker-end="url(#arrowR)"/>
  <path d="M122,88 L78,88" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2" marker-end="url(#arrowR)"/>
  <path d="M72,68 L86,30" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2" marker-end="url(#arrowR)"/>
  <defs>
    <marker id="arrowR" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
      <polygon points="0,0 6,3 0,6" style="fill: var(--color-text-muted)"/>
    </marker>
  </defs>
</svg>`,

'Progress Mechanics': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="10" width="168" height="100" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="30" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Complete your profile</text>
  <text x="100" y="44" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Finish setup to unlock all features</text>
  <rect x="28" y="54" width="144" height="10" rx="5" style="fill: var(--color-surface-3)"/>
  <rect x="28" y="54" width="46" height="10" rx="5" style="fill: var(--color-accent)"/>
  <text x="172" y="62" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-mono)"/>
  <circle cx="28" cy="59" r="3" style="fill: var(--color-accent)"/>
  <circle cx="64" cy="59" r="3" style="fill: var(--color-accent)"/>
  <circle cx="100" cy="59" r="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <circle cx="136" cy="59" r="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <circle cx="172" cy="59" r="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="100" y="80" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">20% complete</text>
  <text x="32" y="96" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-sans)">Name</text>
  <text x="62" y="96" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-sans)">Email</text>
  <text x="92" y="96" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Avatar</text>
  <text x="122" y="96" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Bio</text>
  <text x="152" y="96" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Links</text>
</svg>`,

'Re-engagement': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="28" y="26" style="fill: var(--color-text); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Welcome back!</text>
  <rect x="130" y="14" width="44" height="16" rx="8" style="fill: var(--color-red-dim)"/>
  <text x="152" y="26" text-anchor="middle" style="fill: var(--color-red); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">3 new</text>
  <line x1="24" y1="36" x2="176" y2="36" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="28" y="50" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">While you were away:</text>
  <circle cx="36" cy="64" r="4" style="fill: var(--color-blue-dim)"/>
  <circle cx="36" cy="64" r="1.5" style="fill: var(--color-blue)"/>
  <text x="46" y="67" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Alex shared "Q4 Report" with you</text>
  <circle cx="36" cy="80" r="4" style="fill: var(--color-green-dim)"/>
  <circle cx="36" cy="80" r="1.5" style="fill: var(--color-green)"/>
  <text x="46" y="83" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Build #142 deployed successfully</text>
  <circle cx="36" cy="96" r="4" style="fill: var(--color-amber-dim)"/>
  <circle cx="36" cy="96" r="1.5" style="fill: var(--color-amber)"/>
  <text x="46" y="99" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">2 comments on your pull request</text>
</svg>`,

'Streak/Progress Mechanics': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <path d="M92,14 C92,14 88,24 88,30 C88,36 92,40 96,40 L100,40 L104,40 C108,40 112,36 112,30 C112,24 108,14 108,14 C108,14 104,22 100,22 C96,22 92,14 92,14 Z" style="fill: var(--color-amber)"/>
  <path d="M96,28 C96,28 94,32 94,34 C94,36 96,38 98,38 L100,38 L102,38 C104,38 106,36 106,34 C106,32 104,28 104,28 C104,28 102,32 100,32 C98,32 96,28 96,28 Z" style="fill: var(--color-red)"/>
  <text x="100" y="56" text-anchor="middle" style="fill: var(--color-amber); font-size: 13px; font-weight: 800; font-family: var(--font-sans)">7 Day Streak!</text>
  <text x="36" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">M</text>
  <text x="60" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">T</text>
  <text x="83" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">W</text>
  <text x="105" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">T</text>
  <text x="130" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">F</text>
  <text x="152" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S</text>
  <text x="172" y="80" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">S</text>
  <circle cx="38" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="34,92 37,95 42,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="62" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="58,92 61,95 66,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="86" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="82,92 85,95 90,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="108" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="104,92 107,95 112,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="132" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="128,92 131,95 136,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="154" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="150,92 153,95 158,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="174" cy="92" r="8" style="fill: var(--color-green)"/>
  <polyline points="170,92 173,95 178,89" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`,

'Variable Rewards': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="70" y="36" width="60" height="50" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <rect x="76" y="34" width="48" height="4" rx="2" style="fill: var(--color-accent)"/>
  <rect x="92" y="28" width="16" height="8" rx="2" style="fill: var(--color-accent)"/>
  <text x="100" y="62" text-anchor="middle" style="fill: var(--color-accent); font-size: 18px; font-weight: 700; font-family: var(--font-sans)">?</text>
  <text x="100" y="78" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Open reward</text>
  <polygon points="38,24 40,30 46,30 41,34 43,40 38,36 33,40 35,34 30,30 36,30" style="fill: var(--color-amber)"/>
  <polygon points="160,20 161,23 164,23 162,25 163,28 160,26 157,28 158,25 156,23 159,23" style="fill: var(--color-amber); opacity: 0.6"/>
  <polygon points="46,80 48,86 54,86 49,90 51,96 46,92 41,96 43,90 38,86 44,86" style="fill: var(--color-green)"/>
  <polygon points="152,72 153,75 156,75 154,77 155,80 152,78 149,80 150,77 148,75 151,75" style="fill: var(--color-blue); opacity: 0.7"/>
  <circle cx="162" cy="98" r="8" style="fill: var(--color-amber-dim); stroke: var(--color-amber)" stroke-width="1"/>
  <text x="162" y="102" text-anchor="middle" style="fill: var(--color-amber); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">+5</text>
  <circle cx="36" cy="60" r="6" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <text x="36" y="63" text-anchor="middle" style="fill: var(--color-green); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">+1</text>
  <circle cx="168" cy="46" r="10" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="168" y="50" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">+50</text>
  <text x="100" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Rewards vary each time</text>
</svg>`,

};
