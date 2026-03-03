/** SVG illustrations for "Collecting User Input" patterns */
export const inputSvgs: Record<string, string> = {

'Button': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="16" width="160" height="40" rx="8" style="fill: var(--color-accent)"/>
  <text x="100" y="41" text-anchor="middle" style="fill: #fff; font-size: 13px; font-weight: 600; font-family: var(--font-sans)">Submit</text>
  <rect x="20" y="68" width="76" height="32" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="58" y="88" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-sans)">Cancel</text>
  <rect x="104" y="68" width="76" height="32" rx="6" style="fill: var(--color-surface-2); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="142" y="88" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Outline</text>
</svg>`,

'Checkbox': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="18" width="18" height="18" rx="4" style="fill: var(--color-accent)"/>
  <polyline points="25,27 29,31 35,23" style="stroke: #fff; fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="46" y="31" style="fill: var(--color-text); font-size: 12px; font-family: var(--font-sans)">Dark mode</text>
  <rect x="20" y="48" width="18" height="18" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="46" y="61" style="fill: var(--color-text-secondary); font-size: 12px; font-family: var(--font-sans)">Notifications</text>
  <rect x="20" y="78" width="18" height="18" rx="4" style="fill: var(--color-accent)"/>
  <polyline points="25,87 29,91 35,83" style="stroke: #fff; fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="46" y="91" style="fill: var(--color-text); font-size: 12px; font-family: var(--font-sans)">Auto-save</text>
</svg>`,

'Combobox': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="12" width="160" height="32" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="32" y="32" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">Austr</text>
  <line x1="56" y1="22" x2="56" y2="34" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <polyline points="164,24 168,30 172,24" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="20" y="46" width="160" height="66" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="26" y="52" width="148" height="24" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="36" y="68" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Australia</text>
  <text x="36" y="92" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-sans)">Austria</text>
</svg>`,

'Date Picker': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="160" height="104" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="60" y="26" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">March 2026</text>
  <polyline points="38,22 34,22" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="166,22 170,22" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="28" y1="34" x2="172" y2="34" style="stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="36" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">Mo</text>
  <text x="56" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">Tu</text>
  <text x="76" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">We</text>
  <text x="96" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">Th</text>
  <text x="116" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">Fr</text>
  <text x="136" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">Sa</text>
  <text x="156" y="48" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-mono)">Su</text>
  <text x="40" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">1</text>
  <text x="60" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">2</text>
  <circle cx="82" cy="60" r="10" style="fill: var(--color-accent)"/>
  <text x="79" y="64" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-mono)">3</text>
  <text x="100" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">4</text>
  <text x="120" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">5</text>
  <text x="140" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">6</text>
  <text x="160" y="64" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">7</text>
  <text x="40" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">8</text>
  <text x="60" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">9</text>
  <text x="78" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">10</text>
  <text x="98" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">11</text>
  <text x="118" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">12</text>
  <text x="138" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">13</text>
  <text x="158" y="80" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">14</text>
  <text x="40" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">15</text>
  <text x="58" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">16</text>
  <text x="78" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">17</text>
  <text x="98" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">18</text>
  <text x="118" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">19</text>
  <text x="138" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">20</text>
  <text x="158" y="96" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">21</text>
</svg>`,

'Form': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="30" y="26" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Name</text>
  <rect x="30" y="30" width="140" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="30" y="66" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <rect x="30" y="70" width="140" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <rect x="104" y="96" width="66" height="20" rx="5" style="fill: var(--color-accent)"/>
  <text x="137" y="110" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Submit</text>
</svg>`,

'Input': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="28" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Email address</text>
  <rect x="20" y="34" width="160" height="36" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="32" y="57" style="fill: var(--color-text-muted); font-size: 11px; font-family: var(--font-sans)">you@example.com</text>
  <text x="20" y="88" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">We'll never share your email.</text>
</svg>`,

'Input OTP': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="24" text-anchor="middle" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Enter verification code</text>
  <rect x="16" y="36" width="28" height="36" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="30" y="60" text-anchor="middle" style="fill: var(--color-text); font-size: 16px; font-weight: 700; font-family: var(--font-mono)">4</text>
  <rect x="50" y="36" width="28" height="36" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="64" y="60" text-anchor="middle" style="fill: var(--color-text); font-size: 16px; font-weight: 700; font-family: var(--font-mono)">8</text>
  <rect x="84" y="36" width="28" height="36" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="98" y="60" text-anchor="middle" style="fill: var(--color-text); font-size: 16px; font-weight: 700; font-family: var(--font-mono)">2</text>
  <circle cx="100" cy="42" r="3" style="fill: var(--color-accent)"/>
  <rect x="120" y="36" width="28" height="36" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface-2)" stroke-width="2"/>
  <line x1="134" y1="44" x2="134" y2="64" style="stroke: var(--color-accent)" stroke-width="1.5"/>
  <rect x="154" y="36" width="28" height="36" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="100" y="92" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Didn't receive it? Resend</text>
</svg>`,

'Label': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="28" style="fill: var(--color-text); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">Full Name</text>
  <text x="82" y="28" style="fill: var(--color-red); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">*</text>
  <rect x="20" y="36" width="160" height="32" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="32" y="56" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">Jane Doe</text>
  <text x="20" y="84" style="fill: var(--color-text-muted); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">Bio</text>
  <text x="38" y="84" style="fill: var(--color-text-muted); font-size: 10px; font-style: italic; font-family: var(--font-sans)">(optional)</text>
  <rect x="20" y="90" width="160" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
</svg>`,

'Radio Group': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="22" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Select plan</text>
  <circle cx="32" cy="44" r="8" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <circle cx="32" cy="44" r="4.5" style="fill: var(--color-accent)"/>
  <text x="48" y="48" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Free</text>
  <text x="48" y="60" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Basic features</text>
  <circle cx="32" cy="80" r="8" style="stroke: var(--color-border); fill: none" stroke-width="1.5"/>
  <text x="48" y="84" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-sans)">Pro — $10/mo</text>
  <circle cx="32" cy="104" r="8" style="stroke: var(--color-border); fill: none" stroke-width="1.5"/>
  <text x="48" y="108" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-sans)">Team — $25/mo</text>
</svg>`,

'Select': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="22" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Country</text>
  <rect x="20" y="28" width="160" height="32" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="32" y="49" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">United States</text>
  <polyline points="162,40 168,46 174,40" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="20" y="62" width="160" height="50" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="26" y="66" width="148" height="18" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="34" y="79" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">United States</text>
  <text x="34" y="100" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">United Kingdom</text>
</svg>`,

'Slider': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="24" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Price range</text>
  <text x="170" y="24" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-mono)">$75</text>
  <rect x="20" y="40" width="160" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="40" width="100" height="6" rx="3" style="fill: var(--color-accent)"/>
  <circle cx="120" cy="43" r="10" style="fill: var(--color-accent); stroke: var(--color-surface); " stroke-width="2"/>
  <text x="20" y="72" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-mono)">$0</text>
  <text x="164" y="72" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-mono)">$100</text>
  <text x="20" y="98" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Volume</text>
  <rect x="20" y="104" width="160" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="104" width="60" height="4" rx="2" style="fill: var(--color-accent)"/>
  <circle cx="80" cy="106" r="7" style="fill: var(--color-accent); stroke: var(--color-surface)" stroke-width="2"/>
</svg>`,

'Switch': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="44" height="24" rx="12" style="fill: var(--color-accent)"/>
  <circle cx="52" cy="32" r="9" style="fill: #fff"/>
  <text x="76" y="36" style="fill: var(--color-text); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">Dark mode</text>
  <text x="150" y="36" style="fill: var(--color-green); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">On</text>
  <rect x="20" y="60" width="44" height="24" rx="12" style="fill: var(--color-surface-3); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="32" cy="72" r="9" style="fill: var(--color-text-muted)"/>
  <text x="76" y="76" style="fill: var(--color-text-secondary); font-size: 12px; font-family: var(--font-sans)">Notifications</text>
  <text x="150" y="76" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Off</text>
</svg>`,

'Textarea': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="22" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Description</text>
  <rect x="20" y="28" width="160" height="72" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <text x="30" y="46" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">This product is designed</text>
  <text x="30" y="60" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">for teams who need a</text>
  <text x="30" y="74" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">fast and reliable…</text>
  <line x1="170" y1="92" x2="176" y2="98" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="164" y1="92" x2="176" y2="92" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="20" y="114" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">128 / 500 characters</text>
</svg>`,

'Toggle': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="28" width="36" height="36" rx="8" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="38" y="52" text-anchor="middle" style="fill: var(--color-accent); font-size: 16px; font-weight: 700; font-family: var(--font-sans)">B</text>
  <rect x="64" y="28" width="36" height="36" rx="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="82" y="52" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 16px; font-style: italic; font-family: var(--font-sans)">I</text>
  <rect x="108" y="28" width="36" height="36" rx="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="126" y="52" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 16px; text-decoration: underline; font-family: var(--font-sans)">U</text>
  <rect x="152" y="28" width="36" height="36" rx="8" style="fill: var(--color-surface-2); stroke: var(--color-border)" stroke-width="1.5"/>
  <text x="170" y="52" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 16px; text-decoration: line-through; font-family: var(--font-sans)">S</text>
  <text x="20" y="86" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Stays pressed until toggled off</text>
</svg>`,

'Toggle Group': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="24" width="168" height="36" rx="8" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5"/>
  <rect x="20" y="28" width="52" height="28" rx="6" style="fill: var(--color-accent)"/>
  <text x="46" y="46" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Grid</text>
  <text x="96" y="46" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">List</text>
  <text x="152" y="46" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Table</text>
  <text x="16" y="80" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Pick one or multiple from a segmented set</text>
</svg>`,

'File Upload': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="12" width="160" height="76" rx="8" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1.5" stroke-dasharray="6 4"/>
  <line x1="100" y1="36" x2="100" y2="56" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <polyline points="90,42 100,32 110,42" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="100" y="72" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Drag files here or click to browse</text>
  <text x="100" y="84" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">PNG, JPG up to 10 MB</text>
  <rect x="20" y="96" width="100" height="16" rx="4" style="fill: var(--color-surface-2); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <text x="28" y="108" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">photo.png</text>
  <text x="96" y="108" style="fill: var(--color-green); font-size: 9px; font-family: var(--font-sans)">✓</text>
</svg>`,

};
