/** SVG illustrations for Notification Patterns */
export const notificationPatternSvgs: Record<string, string> = {

'Toast / Snackbar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <line x1="10" y1="30" x2="190" y2="30" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="15" y="15" width="40" height="8" rx="2" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="40" y="75" width="120" height="30" rx="6" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
  <circle cx="52" cy="90" r="6" style="fill: var(--color-accent)" opacity="0.6"/>
  <path d="M49 90 L51 92 L55 88" style="stroke: white" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="63" y="85" width="60" height="5" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="63" y="93" width="40" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <text x="140" y="92" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">3s</text>
</svg>`,

'In-App Banner': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="24" rx="6" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="10" y="28" width="180" height="6" style="fill: var(--color-accent)" opacity="0.12"/>
  <circle cx="24" cy="22" r="5" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="21" y="25" style="fill: white; font-size: 8px; font-weight: 700; font-family: var(--font-sans)">i</text>
  <rect x="34" y="19" width="100" height="5" rx="2" style="fill: var(--color-text)" opacity="0.5"/>
  <text x="178" y="25" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">x</text>
  <rect x="20" y="42" width="160" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="20" y="50" width="130" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="20" y="58" width="150" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
</svg>`,

'Push Notification (Web)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="5" width="140" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="42" cy="15" r="4" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="50" y="12" width="60" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="20" y="35" width="160" height="55" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="20" y="35" width="160" height="55" rx="8" style="fill: var(--color-accent)" opacity="0.05"/>
  <circle cx="40" cy="55" r="10" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="36" y="51" width="8" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="58" y="48" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="58" y="57" width="100" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="58" y="65" width="70" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="130" y="74" width="40" height="10" rx="4" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="138" y="82" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">View</text>
</svg>`,

'Push Notification (Mobile)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="5" width="80" height="110" rx="12" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="85" y="10" width="30" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="68" y="25" width="64" height="40" rx="6" style="fill: var(--color-accent)" opacity="0.08" stroke-width="1" style="stroke: var(--color-accent)" stroke-opacity="0.2"/>
  <circle cx="78" cy="36" r="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="87" y="33" width="38" height="4" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="87" y="40" width="30" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="72" y="49" width="56" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.25"/>
  <rect x="72" y="55" width="40" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="90" y="100" width="20" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
</svg>`,

'Email Notification': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="20" width="140" height="85" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <path d="M30 28 L100 62 L170 28" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.4"/>
  <rect x="45" y="45" width="60" height="5" rx="2" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="45" y="55" width="110" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.25"/>
  <rect x="45" y="62" width="100" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.25"/>
  <rect x="45" y="69" width="90" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.25"/>
  <rect x="45" y="80" width="50" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="55" y="90" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">View</text>
  <text x="45" y="102" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Unsubscribe</text>
</svg>`,

'In-App Message / Interstitial': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-text-muted)" opacity="0.08"/>
  <rect x="35" y="20" width="130" height="80" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="35" y="20" width="130" height="80" rx="8" style="fill: var(--color-accent)" opacity="0.03"/>
  <text x="155" y="33" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">x</text>
  <rect x="75" y="35" width="50" height="5" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="55" y="48" width="90" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="60" y="55" width="80" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="70" y="70" width="60" height="16" rx="6" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="84" y="81" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Got it</text>
</svg>`,

'Webhook / Real-Time Event': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="30" width="60" height="60" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="55" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Server</text>
  <rect x="125" y="30" width="60" height="60" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="140" y="55" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Client</text>
  <line x1="75" y1="50" x2="125" y2="50" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <polygon points="122,47 128,50 122,53" style="fill: var(--color-accent)"/>
  <line x1="75" y1="65" x2="125" y2="65" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="4 3" opacity="0.5"/>
  <polygon points="122,62 128,65 122,68" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="82" y="46" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">SSE</text>
  <text x="82" y="62" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)" opacity="0.5">WS</text>
  <circle cx="155" cy="70" r="4" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="152" y="73" style="fill: var(--color-accent); font-size: 6px; font-weight: 700; font-family: var(--font-sans)">3</text>
</svg>`,

'Bell Icon + Badge': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="17" width="40" height="5" rx="2" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <path d="M165 15 C165 12 162 9 158 9 C154 9 151 12 151 15 L151 20 L148 22 L168 22 L165 20 Z" style="fill: var(--color-text)" opacity="0.5"/>
  <circle cx="158" cy="24" r="1.5" style="fill: var(--color-text)" opacity="0.5"/>
  <circle cx="165" cy="11" r="5" style="fill: var(--color-accent)"/>
  <text x="163" y="14" style="fill: white; font-size: 6px; font-weight: 700; font-family: var(--font-sans)">3</text>
  <rect x="130" y="40" width="60" height="65" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="136" y="48" width="48" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <circle cx="143" cy="54" r="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="149" y="51" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="149" y="56" width="20" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="136" y="64" width="48" height="12" rx="3" style="fill: var(--color-surface)"/>
  <circle cx="143" cy="70" r="3" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="149" y="67" width="30" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="149" y="72" width="20" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="136" y="80" width="48" height="12" rx="3" style="fill: var(--color-surface)"/>
  <circle cx="143" cy="86" r="3" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="149" y="83" width="30" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="149" y="88" width="20" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
</svg>`,

'Notification Center / Drawer': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="5" width="80" height="110" rx="6" style="fill: var(--color-text-muted)" opacity="0.06"/>
  <rect x="100" y="5" width="90" height="110" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <rect x="108" y="12" width="50" height="5" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <text x="168" y="17" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">All read</text>
  <text x="108" y="28" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Today</text>
  <rect x="108" y="33" width="74" height="18" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <circle cx="115" cy="42" r="4" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="122" y="38" width="45" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="122" y="44" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <circle cx="178" cy="42" r="2" style="fill: var(--color-accent)"/>
  <rect x="108" y="55" width="74" height="18" rx="3" style="fill: var(--color-surface)"/>
  <circle cx="115" cy="64" r="4" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="122" y="60" width="45" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="122" y="66" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <text x="108" y="84" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Earlier</text>
  <rect x="108" y="88" width="74" height="18" rx="3" style="fill: var(--color-surface)"/>
  <circle cx="115" cy="97" r="4" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="122" y="93" width="45" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="122" y="99" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
</svg>`,

'Notification Item': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="40" rx="6" style="fill: var(--color-accent)" opacity="0.06" stroke-width="1" style="stroke: var(--color-border)"/>
  <circle cx="35" cy="35" r="10" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="31" y="39" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">A</text>
  <rect x="52" y="25" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="52" y="34" width="110" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.35"/>
  <rect x="52" y="42" width="60" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <text x="155" y="30" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">2m</text>
  <circle cx="175" cy="35" r="3" style="fill: var(--color-accent)"/>
  <rect x="15" y="65" width="170" height="40" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="35" cy="85" r="10" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <text x="31" y="89" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">B</text>
  <rect x="52" y="75" width="80" height="5" rx="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="52" y="84" width="100" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="52" y="92" width="50" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <text x="155" y="80" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">1h</text>
</svg>`,

'Inline Notification': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="20" y="23" width="140" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="20" y="38" width="160" height="35" rx="6" style="fill: var(--color-accent)" opacity="0.06"/>
  <rect x="20" y="38" width="3" height="35" rx="1.5" style="fill: var(--color-accent)"/>
  <circle cx="34" cy="50" r="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="31" y="53" style="fill: var(--color-accent); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">!</text>
  <rect x="44" y="46" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="44" y="55" width="120" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="44" y="62" width="100" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="20" y="82" width="160" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="20" y="90" width="130" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
</svg>`,

'Floating Action Badge': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="90" width="180" height="25" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="40" cy="102" r="8" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="36" y="99" width="8" height="6" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <circle cx="80" cy="102" r="8" style="fill: var(--color-accent)" opacity="0.1"/>
  <path d="M76 104 L80 100 L84 104" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.5"/>
  <circle cx="87" cy="96" r="5" style="fill: var(--color-accent)"/>
  <text x="85" y="99" style="fill: white; font-size: 6px; font-weight: 700; font-family: var(--font-sans)">5</text>
  <circle cx="120" cy="102" r="8" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="117" y="100" width="6" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <circle cx="160" cy="102" r="8" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <circle cx="160" cy="100" r="3" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="30" y="20" width="140" height="55" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="30" width="120" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="40" y="38" width="100" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="40" y="46" width="80" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.15"/>
</svg>`,

'Progress Notification': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="35" width="140" height="50" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="44" y="48" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="44" y="57" width="60" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="44" y="66" width="112" height="8" rx="4" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="44" y="66" width="76" height="8" rx="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="130" y="73" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">68%</text>
</svg>`,

'Read / Unread State': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="30" rx="5" style="fill: var(--color-accent)" opacity="0.06"/>
  <circle cx="28" cy="25" r="3" style="fill: var(--color-accent)"/>
  <rect x="38" y="18" width="70" height="5" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="38" y="27" width="100" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.35"/>
  <text x="160" y="23" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">new</text>
  <rect x="15" y="45" width="170" height="30" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="38" y="53" width="70" height="5" rx="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="38" y="62" width="100" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="15" y="80" width="170" height="30" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="38" y="88" width="70" height="5" rx="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="38" y="97" width="100" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
</svg>`,

'Notification Grouping': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="45" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="40" cy="32" r="8" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="48" cy="32" r="8" style="fill: var(--color-accent)" opacity="0.25"/>
  <circle cx="56" cy="32" r="8" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="53" y="35" style="fill: white; font-size: 7px; font-weight: 700; font-family: var(--font-sans)">3</text>
  <rect x="70" y="27" width="90" height="5" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="70" y="36" width="60" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <text x="165" y="50" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">v</text>
  <rect x="30" y="68" width="140" height="14" rx="3" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <circle cx="42" cy="75" r="4" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="50" y="72" width="60" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="30" y="85" width="140" height="14" rx="3" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <circle cx="42" cy="92" r="4" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="50" y="89" width="60" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
</svg>`,

'Smart Batching / Digest': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="30" height="25" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="50" y="10" width="30" height="25" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="85" y="10" width="30" height="25" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <circle cx="30" cy="22" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <circle cx="65" cy="22" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <circle cx="100" cy="22" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <path d="M30 35 L100 55" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="3 2" opacity="0.4"/>
  <path d="M65 35 L100 55" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="3 2" opacity="0.4"/>
  <path d="M100 35 L100 55" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="3 2" opacity="0.4"/>
  <rect x="60" y="55" width="80" height="50" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="68" y="62" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <text x="68" y="76" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">5 messages</text>
  <text x="68" y="85" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">3 mentions</text>
  <text x="68" y="94" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">2 updates</text>
</svg>`,

'Snooze & Remind Later': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="40" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="38" cy="35" r="8" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="52" y="27" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="52" y="36" width="60" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="140" y="27" width="30" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="144" y="37" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Zzz</text>
  <rect x="100" y="62" width="80" height="50" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="110" y="75" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">In 1 hour</text>
  <text x="110" y="86" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Tomorrow</text>
  <text x="110" y="97" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Next week</text>
  <text x="110" y="108" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">Custom...</text>
</svg>`,

'Notification Actions': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="160" height="55" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="38" cy="40" r="8" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="52" y="32" width="90" height="5" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="52" y="41" width="110" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="52" y="48" width="80" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.25"/>
  <rect x="52" y="58" width="45" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="59" y="67" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Accept</text>
  <rect x="103" y="58" width="45" height="12" rx="4" style="fill: var(--color-border)" opacity="0.3"/>
  <text x="110" y="67" style="fill: var(--color-text-muted); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Decline</text>
</svg>`,

'Notification History & Archive': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="8" width="170" height="20" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="28" cy="18" r="5" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="37" y="15" width="60" height="4" rx="2" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="130" y="13" width="45" height="10" rx="3" style="fill: var(--color-border)" opacity="0.2"/>
  <text x="138" y="21" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Filter</text>
  <rect x="15" y="33" width="170" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="25" y="38" width="50" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="43" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="15" y="53" width="170" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="25" y="58" width="50" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="63" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="15" y="73" width="170" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="25" y="78" width="50" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="83" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="15" y="93" width="170" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <rect x="25" y="98" width="50" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="103" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.15"/>
</svg>`,

'Notification Preferences Matrix': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="60" y="18" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">In-App</text>
  <text x="100" y="18" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Email</text>
  <text x="140" y="18" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Push</text>
  <line x1="15" y1="22" x2="185" y2="22" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <text x="15" y="36" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Messages</text>
  <rect x="68" y="28" width="16" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="80" cy="33" r="3.5" style="fill: white"/>
  <rect x="108" y="28" width="16" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="120" cy="33" r="3.5" style="fill: white"/>
  <rect x="148" y="28" width="16" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="152" cy="33" r="3.5" style="fill: white"/>
  <text x="15" y="54" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Updates</text>
  <rect x="68" y="46" width="16" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="80" cy="51" r="3.5" style="fill: white"/>
  <rect x="108" y="46" width="16" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="112" cy="51" r="3.5" style="fill: white"/>
  <rect x="148" y="46" width="16" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="152" cy="51" r="3.5" style="fill: white"/>
  <text x="15" y="72" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Marketing</text>
  <rect x="68" y="64" width="16" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="72" cy="69" r="3.5" style="fill: white"/>
  <rect x="108" y="64" width="16" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="112" cy="69" r="3.5" style="fill: white"/>
  <rect x="148" y="64" width="16" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="152" cy="69" r="3.5" style="fill: white"/>
  <text x="15" y="90" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Security</text>
  <rect x="68" y="82" width="16" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="80" cy="87" r="3.5" style="fill: white"/>
  <rect x="108" y="82" width="16" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="120" cy="87" r="3.5" style="fill: white"/>
  <rect x="148" y="82" width="16" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="160" cy="87" r="3.5" style="fill: white"/>
</svg>`,

'Frequency Controls': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="50" height="22" rx="5" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)" stroke-opacity="0.3"/>
  <text x="30" y="24" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Calm</text>
  <rect x="75" y="10" width="50" height="22" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="80" y="24" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Regular</text>
  <rect x="130" y="10" width="50" height="22" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="138" y="24" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Power</text>
  <text x="20" y="50" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Comments</text>
  <rect x="110" y="42" width="70" height="14" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="120" y="52" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Daily digest</text>
  <text x="20" y="72" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Mentions</text>
  <rect x="110" y="64" width="70" height="14" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="120" y="74" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Immediate</text>
  <text x="20" y="94" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Marketing</text>
  <rect x="110" y="86" width="70" height="14" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="120" y="96" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Weekly</text>
</svg>`,

'Do Not Disturb / Quiet Hours': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="50" r="35" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <line x1="100" y1="20" x2="100" y2="50" style="stroke: var(--color-text)" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="100" y1="50" x2="118" y2="58" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <circle cx="100" cy="50" r="2" style="fill: var(--color-text)"/>
  <text x="95" y="10" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">12</text>
  <text x="131" y="53" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">3</text>
  <text x="97" y="88" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">6</text>
  <text x="66" y="53" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">9</text>
  <path d="M100 15 A35 35 0 0 1 135 50" style="stroke: var(--color-accent)" stroke-width="3" fill="none" opacity="0.3" stroke-linecap="round"/>
  <text x="55" y="105" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">10 PM - 8 AM</text>
  <path d="M150 25 L160 25 L155 20 Z" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <text x="148" y="35" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">DND</text>
</svg>`,

'Channel-Specific Opt-Out': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="22" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="30" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">In-App</text>
  <rect x="140" y="21" width="28" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="162" cy="26" r="3.5" style="fill: white"/>
  <rect x="20" y="42" width="160" height="22" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="57" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Email</text>
  <rect x="140" y="48" width="28" height="10" rx="5" style="fill: var(--color-accent)" opacity="0.6"/><circle cx="162" cy="53" r="3.5" style="fill: white"/>
  <rect x="20" y="69" width="160" height="22" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="84" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Push</text>
  <rect x="140" y="75" width="28" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="146" cy="80" r="3.5" style="fill: white"/>
  <rect x="20" y="96" width="160" height="22" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="111" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">SMS</text>
  <rect x="140" y="102" width="28" height="10" rx="5" style="fill: var(--color-border)" opacity="0.3"/><circle cx="146" cy="107" r="3.5" style="fill: white"/>
</svg>`,

'Notification Onboarding': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="10" width="140" height="95" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="60" y="27" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Notification Setup</text>
  <rect x="50" y="33" width="100" height="3" rx="1.5" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="50" y="33" width="66" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="85" y="42" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Step 2 of 3</text>
  <text x="45" y="56" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">How often?</text>
  <rect x="45" y="62" width="110" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)" stroke-opacity="0.2"/>
  <text x="55" y="71" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Daily digest</text>
  <rect x="45" y="78" width="110" height="12" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="55" y="87" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Immediate</text>
  <text x="45" y="105" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Skip</text>
  <text x="130" y="105" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Next</text>
</svg>`,

'ARIA Live Region': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="35" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" stroke-dasharray="4 2"/>
  <text x="25" y="28" style="fill: var(--color-accent); font-size: 7px; font-family: monospace">aria-live="polite"</text>
  <rect x="25" y="34" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="25" y="41" width="70" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="15" y="60" width="170" height="35" rx="6" style="fill: var(--color-accent)" opacity="0.06" stroke-width="1" style="stroke: var(--color-accent)" stroke-dasharray="4 2" stroke-opacity="0.4"/>
  <text x="25" y="73" style="fill: var(--color-accent); font-size: 7px; font-family: monospace">role="alert"</text>
  <rect x="25" y="79" width="120" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="25" y="86" width="80" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <circle cx="170" cy="77" r="8" style="fill: none; stroke: var(--color-accent)" stroke-width="1.5" opacity="0.4"/>
  <text x="166" y="81" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)" opacity="0.5">!</text>
</svg>`,

'Focus Management': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="20" width="170" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="35" width="60" height="12" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="42" y="44" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Input</text>
  <rect x="30" y="55" width="60" height="12" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="2"/>
  <text x="42" y="64" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Input</text>
  <text x="36" y="64" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">|</text>
  <rect x="30" y="75" width="60" height="12" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="42" y="84" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Input</text>
  <rect x="120" y="30" width="55" height="30" rx="6" style="fill: var(--color-accent)" opacity="0.08" stroke-width="1" style="stroke: var(--color-accent)" stroke-opacity="0.2"/>
  <text x="128" y="43" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">New msg!</text>
  <rect x="125" y="48" width="45" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <path d="M115 55 L120 50 L120 60 Z" style="fill: var(--color-accent)" opacity="0.2"/>
  <path d="M65 61 C85 61 85 61 95 45" style="stroke: var(--color-text-muted)" stroke-width="1" fill="none" stroke-dasharray="2 2" opacity="0.3"/>
  <text x="75" y="40" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">focus stays</text>
</svg>`,

'Screen Reader Announcements': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="45" r="20" style="fill: var(--color-text-muted)" opacity="0.1"/>
  <circle cx="50" cy="38" r="7" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="42" y="48" width="16" height="10" rx="4" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <path d="M70 40 C85 30 95 30 110 35" style="stroke: var(--color-accent)" stroke-width="1" fill="none" stroke-dasharray="3 2"/>
  <polygon points="108,32 113,35 108,38" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="100" y="25" width="85" height="40" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="110" y="40" style="fill: var(--color-text); font-size: 6px; font-family: var(--font-sans)">"Alice commented</text>
  <text x="110" y="50" style="fill: var(--color-text); font-size: 6px; font-family: var(--font-sans)">on your PR"</text>
  <text x="110" y="60" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">2 minutes ago</text>
  <circle cx="50" cy="85" r="12" style="fill: var(--color-accent)" opacity="0.1"/>
  <path d="M44 82 L50 78 L50 92 L44 88 Z" style="fill: var(--color-accent)" opacity="0.4"/>
  <path d="M53 80 C56 83 56 87 53 90" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.4"/>
  <path d="M56 78 C60 82 60 88 56 92" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.3"/>
</svg>`,

'Keyboard Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="25" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="16" width="40" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="22" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="15" y="38" width="170" height="25" rx="5" style="fill: var(--color-accent)" opacity="0.08" stroke-width="2" style="stroke: var(--color-accent)" stroke-opacity="0.5"/>
  <rect x="25" y="44" width="40" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="25" y="50" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="140" y="44" width="30" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="147" y="52" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">View</text>
  <rect x="15" y="66" width="170" height="25" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="72" width="40" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="78" width="30" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="75" y="96" width="22" height="16" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="84" y="108" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">v</text>
  <rect x="100" y="96" width="22" height="16" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="107" y="107" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">^</text>
  <text x="128" y="108" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Navigate</text>
</svg>`,

'Reduced Motion Support': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="25" y="18" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Default</text>
  <rect x="15" y="25" width="75" height="40" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="40" width="45" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="37" y="49" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Saved!</text>
  <path d="M20 45 L30 45" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.4" stroke-dasharray="2 2"/>
  <path d="M75 45 L85 45" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.4"/>
  <text x="20" y="40" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)" opacity="0.3">~</text>
  <text x="125" y="18" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Reduced</text>
  <rect x="110" y="25" width="75" height="40" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="125" y="40" width="45" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="132" y="49" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Saved!</text>
  <text x="15" y="85" style="fill: var(--color-text-muted); font-size: 6px; font-family: monospace">@media (prefers-</text>
  <text x="15" y="93" style="fill: var(--color-text-muted); font-size: 6px; font-family: monospace">  reduced-motion)</text>
  <text x="15" y="101" style="fill: var(--color-accent); font-size: 6px; font-family: monospace">  animation: none</text>
</svg>`,

'Sound & Haptic Accessibility': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="70" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="30" y="38" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Sound</text>
  <path d="M35 50 L40 46 L40 60 L35 56 Z" style="fill: var(--color-accent)" opacity="0.4"/>
  <path d="M43 48 C46 51 46 55 43 58" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.4"/>
  <path d="M46 45 C51 49 51 57 46 61" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.3"/>
  <path d="M49 42 C56 47 56 59 49 64" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.2"/>
  <rect x="30" y="70" width="50" height="8" rx="4" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="30" y="70" width="30" height="8" rx="4" style="fill: var(--color-accent)" opacity="0.4"/>
  <circle cx="60" cy="74" r="4" style="fill: var(--color-accent)" opacity="0.6"/>
  <text x="30" y="90" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Volume</text>
  <rect x="110" y="20" width="70" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="120" y="38" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Haptic</text>
  <rect x="125" y="48" width="40" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="125" y="55" width="20" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="125" y="62" width="35" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="120" y="80" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Pattern:</text>
  <text x="120" y="90" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">short-long-short</text>
</svg>`,

'High Contrast Notifications': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="75" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="25" y="30" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Standard</text>
  <rect x="25" y="36" width="55" height="16" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <circle cx="33" cy="44" r="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="40" y="41" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="40" y="47" width="20" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="25" y="56" width="55" height="16" rx="4" style="fill: var(--color-surface)"/>
  <circle cx="33" cy="64" r="3" style="fill: var(--color-text-muted)" opacity="0.15"/>
  <rect x="40" y="61" width="30" height="3" rx="1.5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="40" y="67" width="20" height="2" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="110" y="15" width="75" height="90" rx="6" style="fill: #000" stroke="#fff" stroke-width="2"/>
  <text x="120" y="30" style="fill: #fff; font-size: 6px; font-family: var(--font-sans)">High Contrast</text>
  <rect x="120" y="36" width="55" height="16" rx="4" fill="none" stroke="#fff" stroke-width="1.5"/>
  <circle cx="128" cy="44" r="3" fill="#fff"/>
  <rect x="135" y="41" width="30" height="3" rx="1.5" fill="#ff0"/>
  <rect x="135" y="47" width="20" height="2" rx="1" fill="#fff" opacity="0.7"/>
  <rect x="120" y="56" width="55" height="16" rx="4" fill="none" stroke="#fff" stroke-width="1"/>
  <circle cx="128" cy="64" r="3" fill="#fff" opacity="0.5"/>
  <rect x="135" y="61" width="30" height="3" rx="1.5" fill="#fff" opacity="0.5"/>
  <rect x="135" y="67" width="20" height="2" rx="1" fill="#fff" opacity="0.3"/>
</svg>`,

};
