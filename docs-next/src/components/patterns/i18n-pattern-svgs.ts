/** SVG illustrations for i18n Patterns */
export const i18nPatternSvgs: Record<string, string> = {

'Text Expansion Buffer': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="75" height="36" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="52" y="37" text-anchor="middle" style="fill: var(--color-accent); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">Cart</text>
  <text x="52" y="65" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">EN: 4 chars</text>
  <rect x="105" y="15" width="85" height="36" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="105" y="15" width="85" height="36" rx="6" style="stroke: hsl(0, 84%, 60%); fill: none" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="147" y="33" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Einkaufswag...</text>
  <text x="147" y="65" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">DE: 13 chars</text>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">+30-40% expansion</text>
</svg>`,

'Pluralization Rules': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="15" y="22" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">EN</text>
  <rect x="35" y="10" width="65" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="67" y="24" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-mono)">1 item</text>
  <rect x="108" y="10" width="65" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="140" y="24" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-mono)">2 items</text>
  <text x="15" y="55" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">AR</text>
  <rect x="35" y="42" width="30" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="50" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-mono)">0</text>
  <rect x="69" y="42" width="26" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="82" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-mono)">1</text>
  <rect x="99" y="42" width="26" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="112" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-mono)">2</text>
  <rect x="129" y="42" width="26" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="142" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-mono)">3-10</text>
  <rect x="159" y="42" width="26" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="172" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-mono)">11-99</text>
  <text x="15" y="88" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">JA</text>
  <rect x="35" y="76" width="138" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="104" y="90" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">no plural distinction</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">CLDR plural categories</text>
</svg>`,

'Single Full Name Field': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="15" y="18" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">FULL NAME</text>
  <rect x="15" y="22" width="170" height="28" rx="5" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="25" y="40" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">Sukarno</text>
  <circle cx="175" cy="36" r="8" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="175" y="40" text-anchor="middle" style="fill: var(--color-accent); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">&#x2713;</text>
  <line x1="15" y1="62" x2="185" y2="62" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3 3"/>
  <text x="15" y="78" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">FIRST NAME</text>
  <rect x="15" y="82" width="78" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="4 3" opacity="0.5"/>
  <text x="107" y="78" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">LAST NAME</text>
  <rect x="107" y="82" width="78" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="4 3" opacity="0.5"/>
  <line x1="15" y1="82" x2="93" y2="106" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" opacity="0.6"/>
  <line x1="93" y1="82" x2="15" y2="106" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" opacity="0.6"/>
  <line x1="107" y1="82" x2="185" y2="106" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" opacity="0.6"/>
  <line x1="185" y1="82" x2="107" y2="106" style="stroke: hsl(0, 84%, 60%)" stroke-width="1.5" opacity="0.6"/>
</svg>`,

'Phone Number Format': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="15" y="18" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">PHONE NUMBER</text>
  <rect x="15" y="24" width="45" height="28" rx="5" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="37" y="42" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">+1 ▾</text>
  <rect x="64" y="24" width="121" height="28" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="74" y="42" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-mono)">(415) 555-1234</text>
  <text x="15" y="72" style="fill: var(--color-text-muted); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">STORED AS</text>
  <rect x="15" y="76" width="170" height="22" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="100" y="91" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-mono)">+14155551234</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">E.164 format</text>
</svg>`,

'Dynamic Address Form': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="8" width="85" height="104" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="52" y="22" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">US</text>
  <rect x="18" y="28" width="69" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="22" y="38" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Street</text>
  <rect x="18" y="46" width="40" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="22" y="56" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">City</text>
  <rect x="62" y="46" width="25" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="66" y="56" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">ST</text>
  <rect x="18" y="64" width="40" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="22" y="74" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">ZIP</text>
  <rect x="105" y="8" width="85" height="104" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="147" y="22" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">DE</text>
  <rect x="113" y="28" width="69" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="117" y="38" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Stra&#223;e</text>
  <rect x="113" y="46" width="25" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="117" y="56" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">PLZ</text>
  <rect x="142" y="46" width="40" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="146" y="56" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Ort</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">country-specific layout</text>
</svg>`,

'Locale Number Format': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="28" rx="5" style="fill: var(--color-accent-bg)"/>
  <text x="30" y="22" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">US</text>
  <text x="170" y="28" text-anchor="end" style="fill: var(--color-accent); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">1,000.50</text>
  <rect x="15" y="44" width="170" height="28" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="56" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">DE</text>
  <text x="170" y="62" text-anchor="end" style="fill: var(--color-text); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">1.000,50</text>
  <rect x="15" y="78" width="170" height="28" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="90" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">FR</text>
  <text x="170" y="96" text-anchor="end" style="fill: var(--color-text); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">1 000,50</text>
  <text x="100" y="116" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Intl.NumberFormat</text>
</svg>`,

'Locale Date Format': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="80" height="50" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="55" y="34" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">US (MM/DD)</text>
  <text x="55" y="52" text-anchor="middle" style="fill: var(--color-accent); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">03/05</text>
  <text x="100" y="45" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 16px; font-weight: 300; font-family: var(--font-sans)">&#x2260;</text>
  <rect x="105" y="15" width="80" height="50" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="145" y="34" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">EU (DD.MM)</text>
  <text x="145" y="52" text-anchor="middle" style="fill: var(--color-text); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">05.03</text>
  <rect x="40" y="78" width="120" height="24" rx="5" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="94" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-mono)">5 Mar 2026</text>
  <text x="100" y="114" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">unambiguous format</text>
</svg>`,

'RTL Layout Support': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="85" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="52" y="24" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">LTR</text>
  <rect x="18" y="30" width="20" height="20" rx="3" style="fill: var(--color-accent)"/>
  <rect x="42" y="32" width="45" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="42" y="42" width="30" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="18" y="58" width="20" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="42" y="60" width="45" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="42" y="70" width="35" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="18" y="86" width="69" height="16" rx="4" style="fill: var(--color-accent)"/>
  <text x="52" y="97" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Submit →</text>
  <rect x="105" y="10" width="85" height="100" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="147" y="24" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">RTL</text>
  <rect x="162" y="30" width="20" height="20" rx="3" style="fill: var(--color-accent)"/>
  <rect x="113" y="32" width="45" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="128" y="42" width="30" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="162" y="58" width="20" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="113" y="60" width="45" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="123" y="70" width="35" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="113" y="86" width="69" height="16" rx="4" style="fill: var(--color-accent)"/>
  <text x="147" y="97" text-anchor="middle" style="fill: #fff; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">&#x2190; &#x625;&#x631;&#x633;&#x627;&#x644;</text>
</svg>`,

'Currency Formatting': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="8" width="170" height="28" rx="5" style="fill: var(--color-accent-bg)"/>
  <text x="30" y="20" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">US</text>
  <text x="170" y="26" text-anchor="end" style="fill: var(--color-accent); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">$100.00</text>
  <rect x="15" y="40" width="170" height="28" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="52" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">DE</text>
  <text x="170" y="58" text-anchor="end" style="fill: var(--color-text); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">100,00 &#x20AC;</text>
  <rect x="15" y="72" width="170" height="28" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="84" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">JP</text>
  <text x="170" y="90" text-anchor="end" style="fill: var(--color-text); font-size: 14px; font-weight: 700; font-family: var(--font-mono)">&#xA5;100</text>
  <text x="100" y="114" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">symbol position + decimals vary</text>
</svg>`,

'Locale Switcher': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="24" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="22" y="15" width="30" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="37" y="25" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Logo</text>
  <rect x="60" y="18" width="25" height="8" rx="2" style="fill: var(--color-accent-bg)" opacity="0.5"/>
  <rect x="90" y="18" width="25" height="8" rx="2" style="fill: var(--color-accent-bg)" opacity="0.5"/>
  <circle cx="148" cy="22" r="8" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <ellipse cx="148" cy="22" rx="3" ry="8" style="stroke: var(--color-accent); fill: none" stroke-width="1"/>
  <line x1="140" y1="22" x2="156" y2="22" style="stroke: var(--color-accent)" stroke-width="1"/>
  <rect x="160" y="15" width="18" height="14" rx="3" style="fill: var(--color-accent)"/>
  <text x="169" y="25" text-anchor="middle" style="fill: #fff; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">EN</text>
  <rect x="130" y="38" width="55" height="72" rx="5" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="136" y="44" width="43" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="157" y="55" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">English</text>
  <text x="157" y="73" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Deutsch</text>
  <text x="157" y="88" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">Fran&#231;ais</text>
  <text x="157" y="103" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">&#x65E5;&#x672C;&#x8A9E;</text>
</svg>`,

};
