/** SVG illustrations for Data Visualization Patterns */
export const datavizPatternSvgs: Record<string, string> = {

'Line Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="180" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <line x1="30" y1="100" x2="30" y2="15" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="40,80 65,65 90,70 115,45 140,50 165,30" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="40" cy="80" r="3" style="fill: var(--color-accent)"/>
  <circle cx="65" cy="65" r="3" style="fill: var(--color-accent)"/>
  <circle cx="90" cy="70" r="3" style="fill: var(--color-accent)"/>
  <circle cx="115" cy="45" r="3" style="fill: var(--color-accent)"/>
  <circle cx="140" cy="50" r="3" style="fill: var(--color-accent)"/>
  <circle cx="165" cy="30" r="3" style="fill: var(--color-accent)"/>
  <text x="38" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Jan</text>
  <text x="88" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mar</text>
  <text x="138" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">May</text>
</svg>`,

'Bar Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="180" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="40" width="20" height="60" rx="3" style="fill: var(--color-accent)" opacity="0.9"/>
  <rect x="70" y="55" width="20" height="45" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="100" y="25" width="20" height="75" rx="3" style="fill: var(--color-accent)" opacity="0.9"/>
  <rect x="130" y="60" width="20" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="160" y="35" width="20" height="65" rx="3" style="fill: var(--color-accent)" opacity="0.9"/>
  <text x="45" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">A</text>
  <text x="75" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">B</text>
  <text x="105" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">C</text>
  <text x="135" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">D</text>
  <text x="165" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">E</text>
</svg>`,

'Area Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="180" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <defs><linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" style="stop-color: var(--color-accent)" stop-opacity="0.3"/><stop offset="100%" style="stop-color: var(--color-accent)" stop-opacity="0.02"/></linearGradient></defs>
  <path d="M40,75 L65,60 L90,65 L115,40 L140,45 L165,25 L165,100 L40,100 Z" fill="url(#areaGrad)"/>
  <polyline points="40,75 65,60 90,65 115,40 140,45 165,25" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`,

'Pie & Donut Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="60" r="40" style="stroke: var(--color-surface); fill: none" stroke-width="16"/>
  <circle cx="100" cy="60" r="40" style="stroke: var(--color-accent)" stroke-width="16" stroke-dasharray="100 151" stroke-dashoffset="0" transform="rotate(-90 100 60)"/>
  <circle cx="100" cy="60" r="40" style="stroke: var(--color-text-muted)" stroke-width="16" stroke-dasharray="60 191" stroke-dashoffset="-100" transform="rotate(-90 100 60)" opacity="0.5"/>
  <circle cx="100" cy="60" r="40" style="stroke: var(--color-border)" stroke-width="16" stroke-dasharray="40 211" stroke-dashoffset="-160" transform="rotate(-90 100 60)" opacity="0.3"/>
  <text x="92" y="57" style="fill: var(--color-text); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">42%</text>
  <text x="88" y="68" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Revenue</text>
</svg>`,

'Scatter Plot': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="180" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <line x1="30" y1="100" x2="30" y2="15" style="stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="50" cy="82" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="65" cy="70" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="80" cy="65" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="95" cy="55" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="110" cy="50" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="125" cy="42" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="140" cy="38" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="155" cy="30" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="72" cy="78" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="118" cy="58" r="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="160" cy="85" r="5" style="fill: var(--color-text-muted)" opacity="0.6"/>
  <line x1="35" y1="90" x2="170" y2="25" style="stroke: var(--color-text-muted)" stroke-width="1" stroke-dasharray="4 3" opacity="0.5"/>
</svg>`,

'Heatmap': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="35" y="20" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="60" y="20" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="85" y="20" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.9"/>
  <rect x="110" y="20" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="135" y="20" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="35" y="46" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="60" y="46" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="85" y="46" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="110" y="46" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="135" y="46" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.9"/>
  <rect x="35" y="72" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="60" y="72" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="85" y="72" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="110" y="72" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.9"/>
  <rect x="135" y="72" width="22" height="22" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="18" y="35" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mon</text>
  <text x="18" y="61" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Wed</text>
  <text x="22" y="87" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Fri</text>
  <text x="40" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">9am</text>
  <text x="88" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">12pm</text>
  <text x="136" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">5pm</text>
</svg>`,

'Sparkline': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="25" width="160" height="70" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="32" y="48" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Revenue</text>
  <text x="32" y="68" style="fill: var(--color-text); font-size: 16px; font-weight: 700; font-family: var(--font-sans)">$4.2M</text>
  <text x="90" y="68" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">+12%</text>
  <polyline points="120,75 128,68 136,72 144,60 152,55 160,50 168,42" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="168" cy="42" r="2" style="fill: var(--color-accent)"/>
</svg>`,

'Gauge / Radial Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 55 95 A 45 45 0 1 1 145 95" style="stroke: var(--color-surface-2, var(--color-border))" stroke-width="10" fill="none" stroke-linecap="round"/>
  <path d="M 55 95 A 45 45 0 1 1 135 75" style="stroke: var(--color-accent)" stroke-width="10" fill="none" stroke-linecap="round"/>
  <text x="85" y="80" style="fill: var(--color-text); font-size: 18px; font-weight: 700; font-family: var(--font-sans)">73%</text>
  <text x="83" y="95" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">CPU Usage</text>
</svg>`,

'Funnel Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="12" width="150" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.9"/>
  <text x="80" y="26" style="fill: white; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">1,000</text>
  <rect x="40" y="36" width="120" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <text x="85" y="50" style="fill: white; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">620</text>
  <rect x="55" y="60" width="90" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="88" y="74" style="fill: white; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">280</text>
  <rect x="70" y="84" width="60" height="20" rx="3" style="fill: var(--color-accent)" opacity="0.35"/>
  <text x="91" y="98" style="fill: white; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">42</text>
  <text x="5" y="26" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Visit</text>
  <text x="5" y="50" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Sign up</text>
  <text x="5" y="74" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Trial</text>
  <text x="5" y="98" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Paid</text>
</svg>`,

'Treemap': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="100" height="60" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <text x="45" y="42" style="fill: white; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Sales 42%</text>
  <rect x="118" y="10" width="68" height="35" rx="3" style="fill: var(--color-accent)" opacity="0.55"/>
  <text x="132" y="32" style="fill: white; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Eng 24%</text>
  <rect x="118" y="48" width="68" height="22" rx="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <text x="128" y="63" style="fill: white; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Marketing 15%</text>
  <rect x="15" y="74" width="60" height="36" rx="3" style="fill: var(--color-accent)" opacity="0.35"/>
  <text x="24" y="95" style="fill: white; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Support 12%</text>
  <rect x="78" y="74" width="108" height="36" rx="3" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="112" y="95" style="fill: white; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Other 7%</text>
</svg>`,

'Sankey Diagram': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="12" height="40" rx="2" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="15" y="65" width="12" height="30" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="173" y="10" width="12" height="25" rx="2" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="173" y="42" width="12" height="20" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="173" y="70" width="12" height="30" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <path d="M27,25 C80,25 120,18 173,18" style="stroke: var(--color-accent)" stroke-width="12" fill="none" opacity="0.2"/>
  <path d="M27,42 C80,42 120,48 173,48" style="stroke: var(--color-accent)" stroke-width="8" fill="none" opacity="0.15"/>
  <path d="M27,72 C80,72 120,82 173,82" style="stroke: var(--color-accent)" stroke-width="10" fill="none" opacity="0.18"/>
  <text x="5" y="10" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Source</text>
  <text x="163" y="7" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Destination</text>
</svg>`,

'KPI Card': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="15" width="85" height="90" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="22" y="38" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Total Revenue</text>
  <text x="22" y="60" style="fill: var(--color-text); font-size: 18px; font-weight: 700; font-family: var(--font-sans)">$12.4k</text>
  <text x="22" y="78" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">+23.5%</text>
  <polyline points="22,90 32,86 42,88 52,82 62,78 72,74 82,70" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <rect x="105" y="15" width="85" height="90" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="117" y="38" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Active Users</text>
  <text x="117" y="60" style="fill: var(--color-text); font-size: 18px; font-weight: 700; font-family: var(--font-sans)">2,847</text>
  <text x="117" y="78" style="fill: var(--color-text-muted); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">-3.2%</text>
  <polyline points="117,80 127,82 137,84 147,83 157,86 167,88 177,92" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
</svg>`,

'Dashboard Grid Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="58" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="72" y="10" width="58" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="134" y="10" width="58" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="10" y="46" width="90" height="64" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="104" y="46" width="88" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="104" y="80" width="88" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="24" y="28" style="fill: var(--color-accent); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">$4.2k</text>
  <text x="88" y="28" style="fill: var(--color-accent); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">847</text>
  <text x="148" y="28" style="fill: var(--color-accent); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">92%</text>
  <polyline points="20,90 35,80 50,82 65,70 80,65 90,60" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
</svg>`,

'Dashboard Header with Global Filters': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="28" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="16" y="16" width="70" height="16" rx="3" style="stroke: var(--color-accent); fill: none" stroke-width="1"/>
  <text x="22" y="28" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Jan 1 - Mar 31</text>
  <rect x="92" y="16" width="44" height="16" rx="3" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <text x="98" y="28" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">All teams</text>
  <text x="148" y="28" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Updated 2m ago</text>
  <rect x="10" y="46" width="85" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="100" y="46" width="90" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="10" y="84" width="180" height="32" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

'Chart Card with Header': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="25" y="30" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Monthly Revenue</text>
  <text x="25" y="42" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Jan - Jun 2025</text>
  <circle cx="165" cy="30" r="2" style="fill: var(--color-text-muted)"/>
  <circle cx="165" cy="35" r="2" style="fill: var(--color-text-muted)"/>
  <circle cx="165" cy="40" r="2" style="fill: var(--color-text-muted)"/>
  <line x1="25" y1="48" x2="175" y2="48" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <polyline points="30,90 55,80 80,82 105,65 130,60 155,50 175,45" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <line x1="30" y1="95" x2="175" y2="95" style="stroke: var(--color-border)" stroke-width="0.5"/>
</svg>`,

'Tabbed Dashboard Views': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="25" width="180" height="85" rx="0 0 6 6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="10" y="10" width="50" height="20" rx="4 4 0 0" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="18" y="24" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Overview</text>
  <rect x="62" y="12" width="48" height="18" rx="4 4 0 0" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="70" y="24" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Revenue</text>
  <rect x="112" y="12" width="40" height="18" rx="4 4 0 0" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="120" y="24" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Users</text>
  <rect x="20" y="35" width="75" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="105" y="35" width="75" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="20" y="72" width="160" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
</svg>`,

'Comparison Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="175" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="40,70 65,55 90,60 115,40 140,35 165,25" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <polyline points="40,80 65,75 90,78 115,65 140,60 165,55" style="stroke: var(--color-text-muted)" stroke-width="2" fill="none" stroke-linecap="round" stroke-dasharray="5 3"/>
  <rect x="110" y="10" width="60" height="22" rx="3" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1"/>
  <line x1="116" y1="20" x2="128" y2="20" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="132" y="23" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">This month</text>
  <line x1="116" y1="28" x2="128" y2="28" style="stroke: var(--color-text-muted)" stroke-width="2" stroke-dasharray="4 2"/>
  <text x="132" y="30" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Last month</text>
</svg>`,

'Empty Dashboard State': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="4 3"/>
  <line x1="60" y1="85" x2="140" y2="85" style="stroke: var(--color-border)" stroke-width="1" opacity="0.4"/>
  <line x1="60" y1="85" x2="60" y2="45" style="stroke: var(--color-border)" stroke-width="1" opacity="0.4"/>
  <rect x="70" y="65" width="12" height="20" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
  <rect x="88" y="55" width="12" height="30" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
  <rect x="106" y="60" width="12" height="25" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
  <rect x="124" y="50" width="12" height="35" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
  <text x="66" y="38" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">No data yet</text>
</svg>`,

'Tooltip on Hover': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="175" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="40,80 65,65 90,70 115,45 140,50 165,30" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <line x1="115" y1="100" x2="115" y2="45" style="stroke: var(--color-text-muted)" stroke-width="1" stroke-dasharray="3 2" opacity="0.5"/>
  <circle cx="115" cy="45" r="5" style="fill: var(--color-accent)"/>
  <rect x="85" y="15" width="60" height="26" rx="4" style="fill: var(--color-text); stroke: none"/>
  <text x="92" y="27" style="fill: var(--color-surface); font-size: 7px; font-family: var(--font-sans)">Apr: $8,420</text>
  <text x="92" y="37" style="fill: var(--color-surface); font-size: 6px; font-family: var(--font-sans)" opacity="0.7">+15% vs Mar</text>
</svg>`,

'Crosshair': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="100" x2="175" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="40,75 65,60 90,65 115,40 140,45 165,30" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <polyline points="40,85 65,78 90,80 115,65 140,62 165,55" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.5"/>
  <line x1="115" y1="15" x2="115" y2="100" style="stroke: var(--color-text-muted)" stroke-width="1" stroke-dasharray="3 2"/>
  <circle cx="115" cy="40" r="4" style="fill: var(--color-accent)"/>
  <circle cx="115" cy="65" r="4" style="fill: var(--color-text-muted)" opacity="0.6"/>
</svg>`,

'Brush / Range Selection': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="20" y1="72" x2="180" y2="72" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="30,60 55,45 80,50 105,30 130,35 155,20 175,25" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <rect x="20" y="82" width="160" height="28" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <polyline points="25,100 45,95 65,96 85,90 105,92 125,88 145,85 165,87 178,86" style="stroke: var(--color-text-muted)" stroke-width="1" fill="none" opacity="0.4"/>
  <rect x="55" y="82" width="80" height="28" rx="0" style="fill: var(--color-accent)" opacity="0.1"/>
  <line x1="55" y1="82" x2="55" y2="110" style="stroke: var(--color-accent)" stroke-width="2"/>
  <line x1="135" y1="82" x2="135" y2="110" style="stroke: var(--color-accent)" stroke-width="2"/>
</svg>`,

'Drill-Down': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="15" width="25" height="50" rx="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="70" y="30" width="25" height="35" rx="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="100" y="10" width="25" height="55" rx="3" style="fill: var(--color-accent; stroke: var(--color-accent))" stroke-width="2"/>
  <rect x="130" y="25" width="25" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <path d="M112,70 L112,80 L100,90" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round" marker-end="none"/>
  <text x="82" y="95" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Click to drill</text>
  <text x="60" y="110" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Overview > Q3 > Jul breakdown</text>
</svg>`,

'Chart Legend': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="20" y1="80" x2="180" y2="80" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="30,65 60,50 90,55 120,35 150,40 170,30" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <polyline points="30,72 60,68 90,70 120,58 150,55 170,50" style="stroke: var(--color-text-muted)" stroke-width="2" fill="none" stroke-linecap="round" stroke-dasharray="5 3"/>
  <rect x="40" y="92" width="120" height="20" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <line x1="50" y1="102" x2="62" y2="102" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="66" y="105" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Revenue</text>
  <line x1="110" y1="102" x2="122" y2="102" style="stroke: var(--color-text-muted)" stroke-width="2" stroke-dasharray="4 2"/>
  <text x="126" y="105" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Costs</text>
</svg>`,

'Chart Annotations': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="25" y1="95" x2="180" y2="95" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="35,75 60,65 85,68 110,50 135,30 160,35 175,40" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <line x1="110" y1="15" x2="110" y2="95" style="stroke: var(--color-text-muted)" stroke-width="1" stroke-dasharray="4 3"/>
  <rect x="78" y="10" width="62" height="16" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="0.5"/>
  <text x="84" y="21" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Product launch</text>
</svg>`,

'Chart Export': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="32" y="28" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Revenue</text>
  <polyline points="30,80 55,70 80,72 105,55 130,50 155,40 170,38" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <rect x="140" y="16" width="32" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <path d="M152,22 L156,26 L160,22" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <line x1="156" y1="19" x2="156" y2="26" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
</svg>`,

'Data Table Alternative': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="85" height="55" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <polyline points="20,50 35,40 50,42 65,30 80,25" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <rect x="105" y="10" width="85" height="55" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <line x1="105" y1="26" x2="190" y2="26" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <text x="112" y="22" style="fill: var(--color-text); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">Month</text>
  <text x="150" y="22" style="fill: var(--color-text); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">Value</text>
  <text x="112" y="36" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Jan</text>
  <text x="150" y="36" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">$4,200</text>
  <text x="112" y="48" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Feb</text>
  <text x="150" y="48" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">$5,100</text>
  <text x="112" y="60" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Mar</text>
  <text x="150" y="60" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">$4,800</text>
  <rect x="35" y="80" width="50" height="16" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="42" y="91" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Chart</text>
  <rect x="90" y="80" width="50" height="16" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="100" y="91" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Table</text>
</svg>`,

'Color-Blind Safe Palettes': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="40" cy="40" r="18" style="fill: #4e79a7"/>
  <circle cx="80" cy="40" r="18" style="fill: #f28e2b"/>
  <circle cx="120" cy="40" r="18" style="fill: #59a14f"/>
  <circle cx="160" cy="40" r="18" style="fill: #b07aa1"/>
  <rect x="22" y="70" width="36" height="6" rx="3" style="fill: #4e79a7"/>
  <rect x="22" y="82" width="36" height="6" rx="3" style="fill: #f28e2b"/>
  <rect x="22" y="94" width="36" height="6" rx="3" style="fill: #59a14f"/>
  <line x1="82" y1="73" x2="118" y2="73" style="stroke: #4e79a7" stroke-width="2"/>
  <line x1="82" y1="85" x2="118" y2="85" style="stroke: #f28e2b" stroke-width="2" stroke-dasharray="6 3"/>
  <line x1="82" y1="97" x2="118" y2="97" style="stroke: #59a14f" stroke-width="2" stroke-dasharray="2 3"/>
  <circle cx="100" cy="73" r="3" style="fill: #4e79a7"/>
  <rect x="97" y="82" width="6" height="6" style="fill: #f28e2b"/>
  <polygon points="100,92 103,98 97,98" style="fill: #59a14f"/>
  <text x="130" y="76" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Color + Shape</text>
  <text x="130" y="88" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Color + Pattern</text>
  <text x="130" y="100" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Color + Label</text>
</svg>`,

'Chart Container ARIA': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="6 3"/>
  <text x="22" y="26" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-mono, monospace)">role="img"</text>
  <text x="22" y="38" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-mono, monospace)">aria-label="Line chart showing..."</text>
  <rect x="25" y="48" width="150" height="52" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <polyline points="35,85 60,75 85,78 110,60 135,55 160,45" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
</svg>`,

'Keyboard-Navigable Data Points': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="95" x2="175" y2="95" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="40,80 65,65 90,70 115,45 140,50 165,30" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <circle cx="40" cy="80" r="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="65" cy="65" r="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="90" cy="70" r="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="115" cy="45" r="6" style="fill: var(--color-accent); stroke: var(--color-text); stroke-width: 2"/>
  <circle cx="140" cy="50" r="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="165" cy="30" r="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="95" y="20" width="42" height="16" rx="3" style="fill: var(--color-text)"/>
  <text x="101" y="31" style="fill: var(--color-surface); font-size: 7px; font-family: var(--font-sans)">Apr: $845</text>
  <text x="100" y="112" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Tab / Arrow keys</text>
</svg>`,

'High Contrast Mode': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="85" height="55" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="22" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Standard</text>
  <polyline points="18,50 33,40 48,42 63,30 78,28" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <polyline points="18,55 33,50 48,52 63,45 78,42" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.4"/>
  <rect x="105" y="10" width="85" height="55" rx="4" style="stroke: var(--color-text); fill: var(--color-surface)" stroke-width="2"/>
  <text x="117" y="22" style="fill: var(--color-text); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">High Contrast</text>
  <polyline points="113,50 128,40 143,42 158,30 173,28" style="stroke: var(--color-accent)" stroke-width="3" fill="none" stroke-linecap="round"/>
  <polyline points="113,55 128,50 143,52 158,45 173,42" style="stroke: var(--color-text)" stroke-width="3" fill="none" stroke-linecap="round" stroke-dasharray="6 4"/>
  <text x="55" y="88" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">prefers-contrast: more</text>
</svg>`,

'Sonification': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <polyline points="30,80 55,65 80,68 105,45 130,40 155,30 175,35" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round" opacity="0.3"/>
  <circle cx="105" cy="45" r="5" style="fill: var(--color-accent)"/>
  <path d="M95,68 C95,68 90,72 90,78 C90,84 95,88 100,88 C105,88 110,84 110,78 C110,72 105,68 105,68" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none"/>
  <path d="M88,64 C84,70 82,78 82,86" style="stroke: var(--color-text-muted)" stroke-width="1" fill="none" opacity="0.5"/>
  <path d="M112,64 C116,70 118,78 118,86" style="stroke: var(--color-text-muted)" stroke-width="1" fill="none" opacity="0.5"/>
  <text x="70" y="108" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Listen to chart</text>
  <rect x="60" y="96" width="80" height="18" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <polygon points="68,103 68,110 74,106.5" style="fill: var(--color-accent)"/>
</svg>`,

'Live-Updating Chart': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="25" y1="95" x2="180" y2="95" style="stroke: var(--color-border)" stroke-width="1"/>
  <polyline points="30,70 50,65 70,68 90,55 110,50 130,52 150,40 170,38" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <circle cx="170" cy="38" r="4" style="fill: var(--color-accent)"/>
  <circle cx="170" cy="38" r="7" style="stroke: var(--color-accent); fill: none" stroke-width="1" opacity="0.5"/>
  <circle cx="170" cy="38" r="10" style="stroke: var(--color-accent); fill: none" stroke-width="0.5" opacity="0.3"/>
  <circle cx="18" cy="18" r="4" style="fill: var(--color-accent)"/>
  <text x="26" y="21" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">LIVE</text>
</svg>`,

'Threshold Alerts': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="25" y1="95" x2="180" y2="95" style="stroke: var(--color-border)" stroke-width="1"/>
  <line x1="25" y1="40" x2="180" y2="40" style="stroke: #ef4444" stroke-width="1" stroke-dasharray="6 3"/>
  <text x="155" y="36" style="fill: #ef4444; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Critical</text>
  <line x1="25" y1="55" x2="180" y2="55" style="stroke: #eab308" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="155" y="52" style="fill: #eab308; font-size: 7px; font-family: var(--font-sans)">Warning</text>
  <polyline points="30,80 50,72 70,68 90,60 110,52 130,35 150,30 170,28" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <polyline points="130,35 150,30 170,28" style="stroke: #ef4444" stroke-width="2.5" fill="none" stroke-linecap="round"/>
</svg>`,

'Auto-Refresh with Indicator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="28" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="25" y="28" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Updated 15s ago</text>
  <circle cx="160" cy="24" r="9" style="stroke: var(--color-border)" stroke-width="2" fill="none"/>
  <path d="M160,15 A9,9 0 1,1 155,32" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <path d="M155,27 L155,33 L161,33" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <rect x="15" y="46" width="170" height="64" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <polyline points="25,90 50,80 75,82 100,70 125,65 150,60 175,55" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
</svg>`,

'Streaming Data Buffer': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="40" width="45" height="40" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="16" y="35" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Stream</text>
  <rect x="16" y="48" width="32" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="16" y="55" width="32" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="16" y="62" width="32" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="16" y="69" width="32" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.3"/>
  <path d="M60,60 L75,60" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" marker-end="url(#arrowBuf)"/>
  <defs><marker id="arrowBuf" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L10,5 L0,10 Z" style="fill: var(--color-text-muted)"/></marker></defs>
  <rect x="78" y="40" width="45" height="40" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="84" y="35" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Buffer</text>
  <rect x="84" y="48" width="32" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <text x="90" y="56" style="fill: white; font-size: 6px; font-family: var(--font-sans)">batch</text>
  <path d="M128,60 L143,60" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" marker-end="url(#arrowBuf)"/>
  <rect x="146" y="30" width="50" height="60" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="152" y="25" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Render</text>
  <polyline points="152,75 160,65 168,68 176,55 184,50" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
</svg>`,

'Time Window Selector': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="24" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="24" y="19" width="24" height="16" rx="4" style="fill: var(--color-surface)"/>
  <text x="30" y="30" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">1h</text>
  <rect x="52" y="19" width="24" height="16" rx="4" style="fill: var(--color-surface)"/>
  <text x="57" y="30" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">6h</text>
  <rect x="80" y="19" width="28" height="16" rx="4" style="fill: var(--color-accent)"/>
  <text x="86" y="30" style="fill: white; font-size: 8px; font-weight: 600; font-family: var(--font-sans)">24h</text>
  <rect x="112" y="19" width="24" height="16" rx="4" style="fill: var(--color-surface)"/>
  <text x="118" y="30" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">7d</text>
  <rect x="140" y="19" width="36" height="16" rx="4" style="fill: var(--color-surface)"/>
  <text x="145" y="30" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Custom</text>
  <line x1="20" y1="55" x2="180" y2="55" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <polyline points="30,95 55,85 80,88 105,70 130,65 155,55 175,52" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <line x1="20" y1="100" x2="180" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
</svg>`,

'Sparkline in Table Cell': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <line x1="10" y1="32" x2="190" y2="32" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <line x1="10" y1="58" x2="190" y2="58" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <line x1="10" y1="84" x2="190" y2="84" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="20" y="25" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Metric</text>
  <text x="80" y="25" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Value</text>
  <text x="130" y="25" style="fill: var(--color-text); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">Trend</text>
  <text x="20" y="48" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Revenue</text>
  <text x="80" y="48" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">$4.2M</text>
  <polyline points="132,52 140,48 148,50 156,44 164,42 172,38" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <text x="20" y="74" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Users</text>
  <text x="80" y="74" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">2,847</text>
  <polyline points="132,68 140,70 148,72 156,74 164,76 172,80" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <text x="20" y="100" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Uptime</text>
  <text x="80" y="100" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">99.9%</text>
  <polyline points="132,96 140,94 148,94 156,92 164,92 172,90" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
</svg>`,

'Responsive Chart Container': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="10" width="120" height="70" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <polyline points="15,65 35,55 55,58 75,40 95,35 115,28" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <text x="40" y="8" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">width: 100%</text>
  <path d="M128,45 L138,45" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" marker-end="url(#arrowResp)"/>
  <defs><marker id="arrowResp" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L10,5 L0,10 Z" style="fill: var(--color-text-muted)"/></marker></defs>
  <rect x="142" y="20" width="52" height="68" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <polyline points="148,72 155,65 162,68 169,55 176,50 183,44" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
</svg>`,

'Axis Label Rotation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="80" x2="180" y2="80" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="40" width="18" height="40" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="68" y="30" width="18" height="50" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="96" y="50" width="18" height="30" rx="3" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="124" y="35" width="18" height="45" rx="3" style="fill: var(--color-accent)" opacity="0.75"/>
  <rect x="152" y="45" width="18" height="35" rx="3" style="fill: var(--color-accent)" opacity="0.65"/>
  <text x="40" y="100" transform="rotate(-45 40 100)" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">January</text>
  <text x="68" y="100" transform="rotate(-45 68 100)" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">February</text>
  <text x="96" y="100" transform="rotate(-45 96 100)" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">March</text>
  <text x="124" y="100" transform="rotate(-45 124 100)" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">April</text>
  <text x="152" y="100" transform="rotate(-45 152 100)" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">May</text>
</svg>`,

'Mobile Chart Simplification': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="5" width="90" height="65" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="25" y="15" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Desktop: daily</text>
  <polyline points="12,55 18,50 24,52 30,48 36,45 42,44 48,40 54,42 60,38 66,36 72,35 78,30 84,28" style="stroke: var(--color-accent)" stroke-width="1" fill="none" stroke-linecap="round"/>
  <rect x="110" y="5" width="55" height="65" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="118" y="15" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Mobile: weekly</text>
  <polyline points="118,55 128,48 138,42 148,35 158,30" style="stroke: var(--color-accent)" stroke-width="2" fill="none" stroke-linecap="round"/>
  <circle cx="118" cy="55" r="3" style="fill: var(--color-accent)"/>
  <circle cx="128" cy="48" r="3" style="fill: var(--color-accent)"/>
  <circle cx="138" cy="42" r="3" style="fill: var(--color-accent)"/>
  <circle cx="148" cy="35" r="3" style="fill: var(--color-accent)"/>
  <circle cx="158" cy="30" r="3" style="fill: var(--color-accent)"/>
  <text x="50" y="90" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Fewer points, larger targets</text>
</svg>`,

'Chart Skeleton Loading': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="100" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="30" y="18" width="60" height="8" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="30" y="30" width="40" height="6" rx="3" style="fill: var(--color-border)" opacity="0.2"/>
  <rect x="38" y="50" width="14" height="45" rx="2" style="fill: var(--color-border)" opacity="0.15"/>
  <rect x="60" y="42" width="14" height="53" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
  <rect x="82" y="55" width="14" height="40" rx="2" style="fill: var(--color-border)" opacity="0.15"/>
  <rect x="104" y="38" width="14" height="57" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
  <rect x="126" y="48" width="14" height="47" rx="2" style="fill: var(--color-border)" opacity="0.15"/>
  <rect x="148" y="35" width="14" height="60" rx="2" style="fill: var(--color-border)" opacity="0.2"/>
</svg>`,

'Stacked-to-Scrollable Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="10" width="55" height="45" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="65" y="10" width="55" height="45" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="125" y="10" width="55" height="45" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="60" y="5" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Desktop: grid</text>
  <rect x="50" y="68" width="50" height="45" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="104" y="68" width="50" height="45" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" opacity="0.5"/>
  <rect x="158" y="68" width="50" height="45" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" opacity="0.2"/>
  <text x="50" y="66" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mobile: scroll</text>
  <path d="M160,90 L170,90" style="stroke: var(--color-text-muted)" stroke-width="1.5" fill="none" marker-end="url(#arrowScroll)"/>
  <defs><marker id="arrowScroll" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L10,5 L0,10 Z" style="fill: var(--color-text-muted)"/></marker></defs>
</svg>`,

'Print-Optimized Charts': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="10" width="140" height="100" rx="2" style="stroke: var(--color-text); fill: white" stroke-width="1"/>
  <text x="70" y="26" style="fill: var(--color-text); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Revenue Q3</text>
  <line x1="40" y1="88" x2="160" y2="88" style="stroke: var(--color-text)" stroke-width="1"/>
  <line x1="40" y1="88" x2="40" y2="35" style="stroke: var(--color-text)" stroke-width="1"/>
  <rect x="50" y="50" width="16" height="38" rx="0" style="fill: var(--color-text)" opacity="0.8"/>
  <text x="54" y="46" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">$8k</text>
  <rect x="76" y="40" width="16" height="48" rx="0" style="fill: var(--color-text)" opacity="0.5"/>
  <text x="78" y="36" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">$12k</text>
  <rect x="102" y="55" width="16" height="33" rx="0" style="fill: var(--color-text)" opacity="0.8"/>
  <text x="105" y="51" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">$7k</text>
  <rect x="128" y="38" width="16" height="50" rx="0" style="fill: var(--color-text)" opacity="0.5"/>
  <text x="129" y="34" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">$13k</text>
  <text x="52" y="98" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Jul</text>
  <text x="78" y="98" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Aug</text>
  <text x="104" y="98" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Sep</text>
  <text x="130" y="98" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Oct</text>
</svg>`,

};
