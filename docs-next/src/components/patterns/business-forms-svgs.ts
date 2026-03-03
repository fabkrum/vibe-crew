/** SVG illustrations for "Business — Forms & Conversion" patterns */
export const businessFormsSvgs: Record<string, string> = {

'Single-Column Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Single-column form (preferred) -->
  <rect x="8" y="6" width="100" height="108" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="18" y="20" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Name</text>
  <rect x="18" y="24" width="80" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="18" y="52" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <rect x="18" y="56" width="80" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="18" y="84" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Message</text>
  <rect x="18" y="88" width="80" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <circle cx="58" cy="10" r="0" style="fill: none"/>
  <!-- Green checkmark for preferred -->
  <circle cx="96" cy="10" r="5" style="fill: var(--color-green-dim)"/>
  <polyline points="93,10 95,12 99,8" style="stroke: var(--color-green); fill: none" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Two-column form (crossed out) -->
  <rect x="120" y="6" width="72" height="108" rx="6" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1" opacity="0.5"/>
  <rect x="128" y="24" width="26" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8" opacity="0.5"/>
  <rect x="158" y="24" width="26" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8" opacity="0.5"/>
  <rect x="128" y="44" width="26" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8" opacity="0.5"/>
  <rect x="158" y="44" width="26" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8" opacity="0.5"/>
  <rect x="128" y="64" width="26" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8" opacity="0.5"/>
  <rect x="158" y="64" width="26" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8" opacity="0.5"/>
  <!-- Red X for don't do this -->
  <circle cx="180" cy="10" r="5" style="fill: var(--color-red-dim)"/>
  <line x1="178" y1="8" x2="182" y2="12" style="stroke: var(--color-red)" stroke-width="1.2" stroke-linecap="round"/>
  <line x1="182" y1="8" x2="178" y2="12" style="stroke: var(--color-red)" stroke-width="1.2" stroke-linecap="round"/>
  <!-- Crossed-out diagonal line -->
  <line x1="122" y1="10" x2="188" y2="110" style="stroke: var(--color-red)" stroke-width="1" opacity="0.4"/>
</svg>`,

'Inline Validation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Valid field -->
  <text x="20" y="18" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <rect x="20" y="22" width="160" height="26" rx="5" style="stroke: var(--color-green); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="30" y="39" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">jane@company.com</text>
  <circle cx="168" cy="35" r="6" style="fill: var(--color-green-dim)"/>
  <polyline points="164,35 167,38 172,32" style="stroke: var(--color-green); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Invalid field -->
  <text x="20" y="66" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Phone</text>
  <rect x="20" y="70" width="160" height="26" rx="5" style="stroke: var(--color-red); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="30" y="87" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">12345</text>
  <circle cx="168" cy="83" r="6" style="fill: var(--color-red-dim)"/>
  <text x="168" y="87" text-anchor="middle" style="fill: var(--color-red); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">!</text>
  <text x="20" y="108" style="fill: var(--color-red); font-size: 8px; font-family: var(--font-sans)">Enter a valid phone number (e.g. +1 555-1234)</text>
</svg>`,

'Smart Defaults': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="14" y="4" width="172" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <!-- Country field (auto-detected) -->
  <text x="26" y="20" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Country</text>
  <rect x="26" y="24" width="110" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="34" y="38" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">United States</text>
  <!-- Location pin icon -->
  <circle cx="154" cy="34" r="10" style="fill: var(--color-accent-bg)"/>
  <circle cx="154" cy="31" r="3" style="stroke: var(--color-accent); fill: none" stroke-width="1.2"/>
  <path d="M154,28 C151,28 149,30 149,32 C149,35 154,39 154,39 C154,39 159,35 159,32 C159,30 157,28 154,28" style="stroke: var(--color-accent); fill: none" stroke-width="1"/>
  <text x="145" y="50" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">auto</text>
  <!-- Currency field (pre-selected) -->
  <text x="26" y="60" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Currency</text>
  <rect x="26" y="64" width="110" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="34" y="78" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-mono)">USD ($)</text>
  <!-- Timezone field (pre-filled) -->
  <text x="26" y="96" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Timezone</text>
  <rect x="26" y="100" width="110" height="14" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="34" y="111" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">America/New_York</text>
  <!-- Sparkle / magic icon -->
  <polygon points="168,70 170,66 172,70 176,72 172,74 170,78 168,74 164,72" style="fill: var(--color-accent)" opacity="0.7"/>
  <polygon points="162,84 163,82 164,84 166,85 164,86 163,88 162,86 160,85" style="fill: var(--color-accent)" opacity="0.5"/>
</svg>`,

'Error Message Clarity': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Clear error (good) -->
  <text x="12" y="14" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <rect x="12" y="18" width="176" height="24" rx="5" style="stroke: var(--color-red); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="22" y="34" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">john@com</text>
  <!-- Warning icon -->
  <circle cx="178" cy="30" r="5" style="fill: var(--color-red-dim)"/>
  <text x="178" y="33" text-anchor="middle" style="fill: var(--color-red); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">!</text>
  <!-- Specific error message -->
  <text x="12" y="54" style="fill: var(--color-red); font-size: 8px; font-family: var(--font-sans)">Enter a valid email (e.g. name@example.com)</text>
  <!-- Green checkmark for good pattern -->
  <circle cx="188" cy="50" r="5" style="fill: var(--color-green-dim)"/>
  <polyline points="185,50 187,52 191,48" style="stroke: var(--color-green); fill: none" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Divider -->
  <line x1="12" y1="66" x2="188" y2="66" style="stroke: var(--color-border-subtle)" stroke-width="1" stroke-dasharray="4 3"/>
  <!-- Vague error (bad, crossed out) -->
  <rect x="12" y="74" width="176" height="24" rx="5" style="stroke: var(--color-red); fill: var(--color-surface-2)" stroke-width="1" opacity="0.5"/>
  <text x="22" y="90" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">john@com</text>
  <text x="12" y="110" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Invalid</text>
  <!-- Strikethrough on vague error -->
  <line x1="10" y1="110" x2="42" y2="110" style="stroke: var(--color-red)" stroke-width="1" opacity="0.6"/>
  <!-- Red X for bad pattern -->
  <circle cx="188" cy="106" r="5" style="fill: var(--color-red-dim)"/>
  <line x1="186" y1="104" x2="190" y2="108" style="stroke: var(--color-red)" stroke-width="1" stroke-linecap="round"/>
  <line x1="190" y1="104" x2="186" y2="108" style="stroke: var(--color-red)" stroke-width="1" stroke-linecap="round"/>
</svg>`,

'Field Count Optimization': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Left: many fields -->
  <rect x="10" y="8" width="64" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="18" y="16" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="28" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="40" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="52" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="64" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="76" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="88" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <rect x="18" y="100" width="48" height="8" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="0.8"/>
  <!-- Arrow from left to right -->
  <line x1="82" y1="60" x2="110" y2="60" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <polyline points="106,56 112,60 106,64" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Conversion indicator -->
  <text x="96" y="50" text-anchor="middle" style="fill: var(--color-green); font-size: 9px; font-weight: 700; font-family: var(--font-mono)">+34%</text>
  <text x="96" y="76" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">conversions</text>
  <!-- Right: fewer fields -->
  <rect x="120" y="8" width="70" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <rect x="130" y="24" width="50" height="14" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="130" y="46" width="50" height="14" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="130" y="68" width="50" height="14" rx="3" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="130" y="92" width="50" height="14" rx="4" style="fill: var(--color-accent)"/>
  <text x="155" y="103" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Submit</text>
</svg>`,

'Guest Checkout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="24" y="4" width="152" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="100" y="22" text-anchor="middle" style="fill: var(--color-text); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Checkout</text>
  <!-- Guest checkout button (prominent) -->
  <rect x="40" y="32" width="120" height="32" rx="7" style="fill: var(--color-accent)"/>
  <text x="100" y="52" text-anchor="middle" style="fill: #fff; font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Guest Checkout</text>
  <!-- Arrow pointing to guest checkout -->
  <text x="100" y="76" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">No account needed</text>
  <!-- Divider with "or" -->
  <line x1="40" y1="86" x2="76" y2="86" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="100" y="89" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">or</text>
  <line x1="124" y1="86" x2="160" y2="86" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <!-- Sign in option (secondary) -->
  <rect x="56" y="96" width="88" height="14" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Sign in to your account</text>
</svg>`,

};
