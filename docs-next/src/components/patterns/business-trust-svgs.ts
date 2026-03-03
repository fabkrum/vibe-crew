/** SVG illustrations for "Business — Trust & Social Proof" patterns */
export const businessTrustSvgs: Record<string, string> = {

'Trust Signal Placement': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- CTA Button -->
  <rect x="36" y="16" width="128" height="36" rx="8" style="fill: var(--color-accent)"/>
  <text x="100" y="38" text-anchor="middle" style="fill: #fff; font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Buy Now — $49</text>
  <!-- Trust badges row directly below CTA -->
  <rect x="28" y="60" width="144" height="28" rx="6" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <!-- Lock icon -->
  <rect x="42" y="67" width="8" height="7" rx="1" style="stroke: var(--color-green); fill: none" stroke-width="1"/>
  <path d="M43,67 L43,64 C43,62 45,60 46,60 C47,60 49,62 49,64 L49,67" style="stroke: var(--color-green); fill: none" stroke-width="1" stroke-linecap="round"/>
  <text x="54" y="77" style="fill: var(--color-green); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">SSL</text>
  <!-- Divider -->
  <line x1="72" y1="64" x2="72" y2="84" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <!-- Shield icon -->
  <path d="M84,66 L80,68 L80,72 C80,76 84,78 84,78 C84,78 88,76 88,72 L88,68 Z" style="stroke: var(--color-accent); fill: none" stroke-width="1"/>
  <polyline points="82,72 83,73 86,70" style="stroke: var(--color-accent); fill: none" stroke-width="0.8" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="92" y="77" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Verified</text>
  <!-- Divider -->
  <line x1="118" y1="64" x2="118" y2="84" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <!-- Guarantee badge -->
  <circle cx="130" cy="73" r="6" style="stroke: var(--color-amber); fill: var(--color-amber-dim)" stroke-width="0.8"/>
  <text x="130" y="76" text-anchor="middle" style="fill: var(--color-amber); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">30d</text>
  <text x="140" y="77" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Refund</text>
  <!-- Proximity indicator line -->
  <line x1="100" y1="52" x2="100" y2="60" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="2 2"/>
  <!-- Annotation -->
  <text x="100" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-style: italic; font-family: var(--font-sans)">Trust signals near the CTA</text>
</svg>`,

'Social Proof by Commitment Level': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Vertical scale line -->
  <line x1="32" y1="14" x2="32" y2="110" style="stroke: var(--color-border)" stroke-width="1.5"/>
  <polyline points="28,18 32,10 36,18" style="stroke: var(--color-border); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- High commitment (top) — case study / security badge -->
  <text x="26" y="28" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">High</text>
  <circle cx="32" cy="30" r="3" style="fill: var(--color-accent)"/>
  <rect x="44" y="18" width="144" height="28" rx="5" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.2"/>
  <path d="M56,26 L52,28 L52,32 C52,35 56,37 56,37 C56,37 60,35 60,32 L60,28 Z" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.8"/>
  <text x="66" y="30" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Case Study: Acme +40%</text>
  <text x="66" y="40" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">SOC2 Certified</text>
  <!-- Medium commitment (middle) — testimonial -->
  <text x="26" y="64" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Med</text>
  <circle cx="32" cy="66" r="3" style="fill: var(--color-amber)"/>
  <rect x="44" y="54" width="144" height="26" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="58" cy="67" r="8" style="fill: var(--color-surface-3); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="56" y="70" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">J</text>
  <text x="72" y="65" style="fill: var(--color-text); font-size: 8px; font-style: italic; font-family: var(--font-sans)">"Saved us 20 hrs/week"</text>
  <text x="72" y="75" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">— Jane, CTO</text>
  <!-- Low commitment (bottom) — user count -->
  <text x="26" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Low</text>
  <circle cx="32" cy="100" r="3" style="fill: var(--color-green)"/>
  <rect x="44" y="92" width="144" height="20" rx="5" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="56" y="106" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">12,847 users</text>
  <text x="120" y="106" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">trust this product</text>
</svg>`,

'Risk Reversal': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="4" width="160" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <!-- CTA Button -->
  <rect x="36" y="14" width="128" height="32" rx="7" style="fill: var(--color-accent)"/>
  <text x="100" y="34" text-anchor="middle" style="fill: #fff; font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Start Free Trial</text>
  <!-- 30-day money-back guarantee -->
  <rect x="36" y="54" width="128" height="28" rx="6" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <!-- Shield/guarantee icon -->
  <path d="M52,62 L47,64 L47,69 C47,73 52,76 52,76 C52,76 57,73 57,69 L57,64 Z" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <polyline points="49,68 51,70 55,66" style="stroke: var(--color-green); fill: none" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="62" y="66" style="fill: var(--color-green); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">30-day money-back</text>
  <text x="62" y="76" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-sans)">guarantee — no questions asked</text>
  <!-- Cancel anytime badge -->
  <rect x="52" y="90" width="96" height="18" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="100" y="102" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Cancel anytime — no lock-in</text>
</svg>`,

'Security Indicators': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="4" width="168" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <!-- Header: Secure Checkout -->
  <rect x="24" y="12" width="152" height="20" rx="4" style="fill: var(--color-green-dim)"/>
  <!-- Lock icon -->
  <rect x="36" y="18" width="8" height="7" rx="1" style="stroke: var(--color-green); fill: none" stroke-width="1"/>
  <path d="M37,18 L37,16 C37,14 39,12 40,12 C41,12 43,14 43,16 L43,18" style="stroke: var(--color-green); fill: none" stroke-width="1" stroke-linecap="round"/>
  <text x="50" y="26" style="fill: var(--color-green); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Secure Checkout</text>
  <text x="120" y="26" style="fill: var(--color-green); font-size: 7px; font-family: var(--font-mono)">256-bit SSL</text>
  <!-- Card number field -->
  <text x="30" y="46" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Card number</text>
  <rect x="30" y="50" width="140" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="38" y="64" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">4242 **** **** ****</text>
  <!-- Expiry and CVC -->
  <rect x="30" y="76" width="64" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="38" y="88" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">MM / YY</text>
  <rect x="102" y="76" width="64" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="110" y="88" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-mono)">CVC</text>
  <!-- Payment provider logos (simplified rectangles) -->
  <rect x="30" y="100" width="24" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-blue)" stroke-width="0.8"/>
  <text x="42" y="109" text-anchor="middle" style="fill: var(--color-blue); font-size: 6px; font-weight: 700; font-family: var(--font-sans)">VISA</text>
  <rect x="58" y="100" width="24" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-amber)" stroke-width="0.8"/>
  <text x="70" y="109" text-anchor="middle" style="fill: var(--color-amber); font-size: 6px; font-weight: 700; font-family: var(--font-sans)">MC</text>
  <rect x="86" y="100" width="28" height="12" rx="2" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="0.8"/>
  <text x="100" y="109" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-weight: 700; font-family: var(--font-sans)">AMEX</text>
  <!-- PCI badge -->
  <rect x="130" y="100" width="36" height="12" rx="2" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="0.6"/>
  <text x="148" y="109" text-anchor="middle" style="fill: var(--color-green); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">PCI DSS</text>
</svg>`,

'Transparency Patterns': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="4" width="168" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <!-- Price header -->
  <text x="100" y="22" text-anchor="middle" style="fill: var(--color-text); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">Order Summary</text>
  <!-- Line items breakdown -->
  <text x="30" y="40" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Pro Plan (annual)</text>
  <text x="164" y="40" text-anchor="end" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-mono)">$228.00</text>
  <text x="30" y="54" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Discount (20%)</text>
  <text x="164" y="54" text-anchor="end" style="fill: var(--color-green); font-size: 9px; font-weight: 600; font-family: var(--font-mono)">-$45.60</text>
  <text x="30" y="68" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Tax</text>
  <text x="164" y="68" text-anchor="end" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-mono)">$18.24</text>
  <!-- Divider -->
  <line x1="30" y1="74" x2="170" y2="74" style="stroke: var(--color-border)" stroke-width="1"/>
  <!-- Total -->
  <text x="30" y="88" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Total</text>
  <text x="164" y="88" text-anchor="end" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-mono)">$200.64</text>
  <!-- "No hidden fees" badge -->
  <rect x="36" y="96" width="128" height="16" rx="4" style="fill: var(--color-accent-bg)"/>
  <!-- Eye / privacy icon -->
  <circle cx="52" cy="104" r="3" style="stroke: var(--color-accent); fill: none" stroke-width="0.8"/>
  <circle cx="52" cy="104" r="1.2" style="fill: var(--color-accent)"/>
  <path d="M46,104 C46,104 49,100 52,100 C55,100 58,104 58,104 C58,104 55,108 52,108 C49,108 46,104 46,104" style="stroke: var(--color-accent); fill: none" stroke-width="0.8"/>
  <text x="62" y="107" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">No hidden fees — full breakdown</text>
</svg>`,

};
