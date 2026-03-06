/** SVG illustrations for Dark Patterns Prevention */
export const darkPatternSvgs: Record<string, string> = {

'Fake Scarcity': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="10" width="140" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="44" y="22" width="112" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="33" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Only 2 left in stock!</text>
  <line x1="44" y1="22" x2="156" y2="36" style="stroke: hsl(0, 84%, 60%)" stroke-width="2" stroke-linecap="round"/>
  <line x1="156" y1="22" x2="44" y2="36" style="stroke: hsl(0, 84%, 60%)" stroke-width="2" stroke-linecap="round"/>
  <rect x="44" y="48" width="112" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="59" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">47 in stock (real data)</text>
  <polyline points="144,52 149,57 160,46" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Use real inventory data</text>
  <text x="100" y="98" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">from your database</text>
</svg>`,

'Fake Urgency': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="14" width="140" height="40" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="32" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 10px; font-weight: 700; font-family: var(--font-mono)">00:14:32</text>
  <text x="100" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">resets on refresh</text>
  <line x1="30" y1="14" x2="170" y2="54" style="stroke: hsl(0, 84%, 60%)" stroke-width="2" stroke-linecap="round"/>
  <line x1="170" y1="14" x2="30" y2="54" style="stroke: hsl(0, 84%, 60%)" stroke-width="2" stroke-linecap="round"/>
  <path d="M88 62 L100 74 L112 62" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="40" y="80" width="120" height="30" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Server-backed deadline</text>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)">expires: 2026-03-10T23:59Z</text>
</svg>`,

'Confirmshaming': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="18" y="8" width="164" height="50" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="24" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Subscribe to our newsletter?</text>
  <text x="100" y="46" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-style: italic; font-family: var(--font-sans)">No, I hate saving money</text>
  <line x1="40" y1="40" x2="160" y2="40" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M88 62 L100 74 L112 62" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="18" y="78" width="164" height="34" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <rect x="28" y="86" width="60" height="18" rx="4" style="fill: var(--color-accent)"/>
  <text x="58" y="98" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Subscribe</text>
  <rect x="96" y="86" width="60" height="18" rx="4" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <text x="126" y="98" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">No thanks</text>
</svg>`,

'Nagging': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="80" height="36" rx="4" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1"/>
  <text x="50" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Enable notifs?</text>
  <text x="50" y="38" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-family: var(--font-sans)">Session 1</text>
  <rect x="60" y="34" width="80" height="36" rx="4" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1"/>
  <text x="100" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Enable notifs?</text>
  <text x="100" y="62" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-family: var(--font-sans)">Session 2</text>
  <rect x="110" y="58" width="80" height="36" rx="4" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1"/>
  <text x="150" y="74" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Enable notifs?</text>
  <text x="150" y="86" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-family: var(--font-sans)">Session 3</text>
  <text x="100" y="110" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Ask once, store the decline</text>
</svg>`,

'Trick Wording': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="10" width="168" height="44" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="26" y="22" width="14" height="14" rx="2" style="stroke: hsl(0, 84%, 60%); fill: hsl(0, 84%, 60%)" stroke-width="1.5"/>
  <polyline points="29,29 32,32 38,26" style="stroke: #fff; fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="46" y="33" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Uncheck to not unsubscribe</text>
  <text x="158" y="48" text-anchor="end" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">confusing!</text>
  <path d="M88 58 L100 70 L112 58" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="16" y="76" width="168" height="34" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <rect x="26" y="86" width="14" height="14" rx="2" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="46" y="97" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Send me marketing emails</text>
  <text x="158" y="97" text-anchor="end" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">clear!</text>
</svg>`,

'Disguised Ads': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="30" y="20" width="140" height="5" rx="2" style="fill: var(--color-border)"/>
  <rect x="30" y="30" width="120" height="5" rx="2" style="fill: var(--color-border)"/>
  <rect x="30" y="42" width="140" height="26" rx="4" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="3 2"/>
  <text x="100" y="58" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Looks like content but is an ad</text>
  <rect x="30" y="74" width="140" height="26" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <rect x="36" y="78" width="48" height="12" rx="2" style="fill: var(--color-accent)"/>
  <text x="60" y="87" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 700; font-family: var(--font-sans)">Sponsored</text>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Clearly labeled promotion</text>
</svg>`,

'Fake Social Proof': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="44" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="28" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">12,847 people signed up today</text>
  <text x="100" y="44" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-family: var(--font-mono)">Math.random() * 15000</text>
  <line x1="20" y1="10" x2="180" y2="54" style="stroke: hsl(0, 84%, 60%)" stroke-width="2" stroke-linecap="round"/>
  <line x1="180" y1="10" x2="20" y2="54" style="stroke: hsl(0, 84%, 60%)" stroke-width="2" stroke-linecap="round"/>
  <rect x="20" y="68" width="160" height="42" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">2,341 teams use this product</text>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-mono)">SELECT COUNT(*) FROM users</text>
</svg>`,

'Visual Interference': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="8" width="180" height="46" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="20" y="18" width="100" height="26" rx="4" style="fill: hsl(0, 84%, 60%)"/>
  <text x="70" y="35" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Accept All</text>
  <text x="152" y="35" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans); text-decoration: underline">manage</text>
  <path d="M88 58 L100 70 L112 58" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="10" y="74" width="180" height="38" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <rect x="20" y="82" width="76" height="22" rx="4" style="fill: var(--color-accent)"/>
  <text x="58" y="97" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Accept All</text>
  <rect x="104" y="82" width="76" height="22" rx="4" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <text x="142" y="97" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Reject All</text>
</svg>`,

'Hidden Costs': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="6" width="160" height="108" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="36" y="24" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Order Summary</text>
  <text x="36" y="42" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Product</text>
  <text x="156" y="42" text-anchor="end" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">$49.99</text>
  <text x="36" y="56" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Service fee</text>
  <text x="156" y="56" text-anchor="end" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">$4.99</text>
  <text x="36" y="70" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Processing</text>
  <text x="156" y="70" text-anchor="end" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">$2.50</text>
  <line x1="36" y1="78" x2="164" y2="78" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="36" y="92" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Total</text>
  <text x="156" y="92" text-anchor="end" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">$57.48</text>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Show all fees upfront</text>
</svg>`,

'Hidden Subscription': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="8" width="140" height="56" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="100" y="28" text-anchor="middle" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Start Free Trial</text>
  <text x="100" y="42" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">14 days free, then $9.99/mo</text>
  <text x="100" y="54" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Cancel anytime before trial ends</text>
  <path d="M88 70 L100 82 L112 70" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="50" y="88" width="100" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="62" y="100" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)">Reminder email</text>
  <text x="62" y="108" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-mono)">3 days before charge</text>
</svg>`,

'Comparison Prevention': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="28" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Compare Plans</text>
  <line x1="10" y1="34" x2="190" y2="34" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="70" y="48" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Free</text>
  <text x="130" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Pro</text>
  <line x1="100" y1="34" x2="100" y2="110" style="stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="64" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Storage</text>
  <text x="70" y="64" text-anchor="middle" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">5 GB</text>
  <text x="130" y="64" text-anchor="middle" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">100 GB</text>
  <text x="30" y="80" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Users</text>
  <text x="70" y="80" text-anchor="middle" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">1</text>
  <text x="130" y="80" text-anchor="middle" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">10</text>
  <text x="30" y="96" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Support</text>
  <text x="70" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Email</text>
  <text x="130" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Priority</text>
</svg>`,

'Hard to Cancel': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="24" y="14" width="72" height="44" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="60" y="32" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Sign Up</text>
  <text x="60" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">1 click</text>
  <text x="100" y="40" text-anchor="middle" style="fill: var(--color-accent); font-size: 16px; font-weight: 800; font-family: var(--font-sans)">=</text>
  <rect x="104" y="14" width="72" height="44" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="140" y="32" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Cancel</text>
  <text x="140" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">2 clicks max</text>
  <rect x="40" y="74" width="120" height="32" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="88" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Cancel Subscription</text>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Are you sure? [Confirm]</text>
</svg>`,

'Forced Action': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="160" height="50" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="26" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Create account to continue</text>
  <rect x="40" y="34" width="120" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="45" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">(just to read an article)</text>
  <path d="M88 62 L100 74 L112 62" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="20" y="80" width="160" height="32" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Content accessible freely</text>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Account optional for personalization</text>
</svg>`,

'Sneaking': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="160" height="104" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="36" y="26" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Your Cart</text>
  <text x="36" y="44" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Widget Pro</text>
  <text x="156" y="44" text-anchor="end" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">$29.99</text>
  <text x="36" y="60" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-family: var(--font-sans)">Extended warranty</text>
  <text x="156" y="60" text-anchor="end" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-family: var(--font-sans)">$9.99</text>
  <text x="110" y="72" text-anchor="end" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-style: italic; font-family: var(--font-sans)">auto-added!</text>
  <line x1="36" y1="54" x2="164" y2="54" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="36" y1="66" x2="164" y2="66" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="36" y1="54" x2="164" y2="66" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="36" y="80" width="128" height="24" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Only user-added items in cart</text>
</svg>`,

'Preselection': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="14" y="8" width="80" height="104" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="54" y="24" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Bad</text>
  <rect x="24" y="32" width="12" height="12" rx="2" style="fill: hsl(0, 84%, 60%)"/>
  <polyline points="27,38 30,41 34,35" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="40" y="42" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Newsletter</text>
  <rect x="24" y="50" width="12" height="12" rx="2" style="fill: hsl(0, 84%, 60%)"/>
  <polyline points="27,56 30,59 34,53" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="40" y="60" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Share data</text>
  <rect x="24" y="68" width="12" height="12" rx="2" style="fill: hsl(0, 84%, 60%)"/>
  <polyline points="27,74 30,77 34,71" style="stroke: #fff; fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="40" y="78" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Premium</text>
  <text x="54" y="100" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 7px; font-family: var(--font-sans)">Pre-checked!</text>
  <rect x="106" y="8" width="80" height="104" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="146" y="24" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Good</text>
  <rect x="116" y="32" width="12" height="12" rx="2" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="132" y="42" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Newsletter</text>
  <rect x="116" y="50" width="12" height="12" rx="2" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="132" y="60" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Share data</text>
  <rect x="116" y="68" width="12" height="12" rx="2" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="132" y="78" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Premium</text>
  <text x="146" y="100" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">User decides</text>
</svg>`,

'Consent Asymmetry': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="8" width="180" height="46" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="20" y="18" width="100" height="26" rx="4" style="fill: hsl(0, 84%, 60%)"/>
  <text x="70" y="35" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Accept All</text>
  <text x="152" y="35" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans); text-decoration: underline">manage</text>
  <path d="M88 58 L100 70 L112 58" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="10" y="74" width="180" height="38" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <rect x="20" y="82" width="76" height="22" rx="4" style="fill: var(--color-accent)"/>
  <text x="58" y="97" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Accept All</text>
  <rect x="104" y="82" width="76" height="22" rx="4" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <text x="142" y="97" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Reject All</text>
</svg>`,

};
