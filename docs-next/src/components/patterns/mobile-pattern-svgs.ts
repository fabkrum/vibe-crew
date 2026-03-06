/** SVG illustrations for Mobile & Touch Patterns */
export const mobilePatternSvgs: Record<string, string> = {

'Thumb Zone Design': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="64" y="8" width="72" height="104" rx="8" style="fill: var(--color-surface)"/>
  <!-- Stretch zone (top) -->
  <rect x="64" y="8" width="72" height="30" rx="8" style="fill: var(--color-accent-bg); opacity: 0.3"/>
  <text x="100" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">STRETCH</text>
  <!-- Reach zone (middle) -->
  <rect x="64" y="38" width="72" height="30" style="fill: var(--color-accent-bg); opacity: 0.5"/>
  <text x="100" y="56" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">REACH</text>
  <!-- Thumb zone (bottom) - highlighted -->
  <rect x="64" y="68" width="72" height="44" rx="0 0 8 8" style="fill: var(--color-accent-bg); opacity: 0.8"/>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 700; font-family: var(--font-sans)">THUMB ZONE</text>
  <rect x="72" y="94" width="56" height="14" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="104" text-anchor="middle" style="fill: var(--color-surface); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Action</text>
</svg>`,

'Touch Target Sizing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Small target (bad) -->
  <rect x="20" y="20" width="16" height="16" rx="3" style="stroke: var(--color-text-muted); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="31" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">x</text>
  <text x="28" y="52" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">16px</text>
  <line x1="20" y1="46" x2="36" y2="46" style="stroke: var(--color-text-muted)" stroke-width="0.5" stroke-dasharray="2"/>
  <!-- Arrow -->
  <text x="62" y="32" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 14px; font-family: var(--font-sans)">→</text>
  <!-- Good target with expanded hit area -->
  <rect x="80" y="8" width="48" height="48" rx="6" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-dasharray="3"/>
  <rect x="96" y="24" width="16" height="16" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="104" y="35" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">x</text>
  <text x="104" y="72" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">48px</text>
  <line x1="80" y1="66" x2="128" y2="66" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="2"/>
  <!-- Label -->
  <text x="104" y="88" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">::after hit area</text>
  <!-- Finger circle -->
  <circle cx="165" cy="35" r="22" style="fill: var(--color-accent-bg); opacity: 0.5"/>
  <text x="165" y="38" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">finger</text>
</svg>`,

'Large Tap Areas': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Card with full tap area -->
  <rect x="15" y="10" width="170" height="40" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <circle cx="40" cy="30" r="12" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="60" y="26" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Entire card tappable</text>
  <text x="60" y="38" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">display: block on anchor</text>
  <text x="158" y="32" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">→</text>
  <!-- Bad example: only text tappable -->
  <rect x="15" y="64" width="170" height="40" rx="6" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <circle cx="40" cy="84" r="12" style="fill: var(--color-surface-2)"/>
  <text x="60" y="80" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Only</text>
  <text x="78" y="80" style="fill: var(--color-accent); font-size: 9px; text-decoration: underline; font-family: var(--font-sans)">link text</text>
  <text x="110" y="80" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">tappable</text>
  <text x="60" y="92" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Dead space frustrates users</text>
</svg>`,

'Minimum Spacing Between Targets': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Bad: no spacing -->
  <text x="30" y="16" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Too close</text>
  <rect x="10" y="22" width="40" height="32" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="50" y="22" width="40" height="32" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="30" y="42" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Btn A</text>
  <text x="70" y="42" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Btn B</text>
  <line x1="50" y1="58" x2="50" y2="62" style="stroke: var(--color-text-muted)" stroke-width="1"/>
  <text x="50" y="70" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">0px!</text>
  <!-- Good: 8px gap -->
  <text x="155" y="16" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">8px gap</text>
  <rect x="115" y="22" width="40" height="32" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <rect x="163" y="22" width="40" height="32" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="135" y="42" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">Btn A</text>
  <text x="183" y="42" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">Btn B</text>
  <line x1="155" y1="30" x2="163" y2="30" style="stroke: var(--color-accent)" stroke-width="1"/>
  <line x1="155" y1="28" x2="155" y2="32" style="stroke: var(--color-accent)" stroke-width="1"/>
  <line x1="163" y1="28" x2="163" y2="32" style="stroke: var(--color-accent)" stroke-width="1"/>
  <text x="159" y="72" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">gap: 8px</text>
  <!-- Ghost touch label -->
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-style: italic; font-family: var(--font-sans)">Prevents ghost touch errors</text>
</svg>`,

'FAB Placement': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Content lines -->
  <rect x="68" y="14" width="50" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="22" width="64" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="30" width="40" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="42" width="64" height="20" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="66" width="64" height="20" rx="3" style="fill: var(--color-surface-2)"/>
  <!-- FAB -->
  <circle cx="124" cy="92" r="14" style="fill: var(--color-accent)"/>
  <text x="124" y="97" text-anchor="middle" style="fill: var(--color-surface); font-size: 16px; font-weight: 300; font-family: var(--font-sans)">+</text>
  <!-- Tab bar -->
  <rect x="60" y="100" width="80" height="16" rx="0 0 12 12" style="fill: var(--color-surface-2)"/>
  <!-- Label -->
  <text x="30" y="95" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">56px</text>
  <line x1="45" y1="92" x2="110" y2="92" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="2"/>
  <text x="170" y="95" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">above tab bar</text>
</svg>`,

'Input Field Sizing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Bad: small input -->
  <text x="50" y="16" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">font-size: 14px</text>
  <rect x="10" y="22" width="80" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="18" y="38" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Email...</text>
  <text x="50" y="58" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-style: italic; font-family: var(--font-sans)">iOS zooms!</text>
  <!-- Good: proper input -->
  <text x="150" y="16" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">font-size: 16px</text>
  <rect x="110" y="22" width="80" height="32" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="118" y="42" style="fill: var(--color-text-secondary); font-size: 11px; font-family: var(--font-sans)">Email...</text>
  <text x="150" y="68" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">48px height</text>
  <!-- Arrow with dimension -->
  <line x1="102" y1="22" x2="102" y2="54" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="2"/>
  <!-- Bottom label -->
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">16px prevents iOS auto-zoom</text>
</svg>`,

'Bottom Tab Bar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Content area -->
  <rect x="68" y="14" width="64" height="72" rx="4" style="fill: var(--color-surface-2); opacity: 0.3"/>
  <!-- Tab bar -->
  <rect x="64" y="90" width="72" height="22" rx="4" style="fill: var(--color-surface-2)"/>
  <!-- Tab 1: Home (active) -->
  <circle cx="78" cy="97" r="4" style="fill: var(--color-accent)"/>
  <text x="78" y="108" text-anchor="middle" style="fill: var(--color-accent); font-size: 5px; font-weight: 600; font-family: var(--font-sans)">Home</text>
  <!-- Tab 2 -->
  <circle cx="92" cy="97" r="3" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <text x="92" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Search</text>
  <!-- Tab 3 -->
  <circle cx="106" cy="97" r="3" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <text x="106" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Cart</text>
  <!-- Tab 4 -->
  <circle cx="120" cy="97" r="3" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <text x="120" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Profile</text>
  <!-- Labels -->
  <text x="22" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">3-5</text>
  <text x="22" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">tabs</text>
</svg>`,

'Drawer Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Phone outline -->
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Backdrop -->
  <rect x="64" y="8" width="72" height="104" rx="8" style="fill: var(--color-text); opacity: 0.15"/>
  <!-- Drawer panel -->
  <rect x="64" y="8" width="52" height="104" rx="8 0 0 8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Close X -->
  <text x="108" y="20" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">×</text>
  <!-- Nav items -->
  <rect x="70" y="22" width="40" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="74" y="29" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Home</text>
  <rect x="70" y="34" width="40" height="8" rx="2" style="fill: var(--color-surface)"/>
  <text x="74" y="41" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">Products</text>
  <rect x="70" y="46" width="40" height="8" rx="2" style="fill: var(--color-surface)"/>
  <text x="74" y="53" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">About</text>
  <rect x="70" y="58" width="40" height="8" rx="2" style="fill: var(--color-surface)"/>
  <text x="74" y="65" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">Contact</text>
  <!-- Width label -->
  <text x="30" y="60" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">80vw</text>
  <line x1="40" y1="58" x2="60" y2="58" style="stroke: var(--color-text-muted)" stroke-width="0.5" stroke-dasharray="2"/>
</svg>`,

'Back Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Header bar -->
  <rect x="64" y="8" width="72" height="20" rx="8 8 0 0" style="fill: var(--color-surface-2)"/>
  <!-- Back chevron -->
  <text x="74" y="22" style="fill: var(--color-accent); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">‹</text>
  <text x="84" y="21" style="fill: var(--color-text); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Details</text>
  <!-- Content -->
  <rect x="68" y="34" width="64" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="44" width="50" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="54" width="58" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- Touch target indicator -->
  <rect x="66" y="10" width="20" height="16" rx="3" style="stroke: var(--color-accent); fill: none" stroke-width="1" stroke-dasharray="2"/>
  <text x="20" y="22" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">44x44</text>
  <line x1="35" y1="20" x2="64" y2="18" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="2"/>
  <!-- Swipe gesture hint -->
  <text x="36" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">← swipe</text>
  <text x="36" y="90" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">from edge</text>
</svg>`,

'Collapsing Header': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Expanded state -->
  <rect x="10" y="8" width="80" height="48" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="14" y="12" width="72" height="20" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="50" y="26" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Page Title</text>
  <text x="50" y="42" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Subtitle text here</text>
  <text x="50" y="52" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">56px</text>
  <!-- Arrow -->
  <text x="100" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">scroll ↓</text>
  <!-- Collapsed state -->
  <rect x="110" y="16" width="80" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="150" y="34" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Page Title</text>
  <text x="150" y="56" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">44px</text>
  <!-- Content below -->
  <rect x="110" y="50" width="80" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="110" y="58" width="70" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="110" y="66" width="75" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- More content label -->
  <text x="150" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">More content visible</text>
</svg>`,

'Bottom Sheet': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Dimmed background -->
  <rect x="64" y="8" width="72" height="40" rx="8 8 0 0" style="fill: var(--color-text); opacity: 0.1"/>
  <!-- Bottom sheet -->
  <rect x="64" y="48" width="72" height="64" rx="8 8 0 0" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Drag handle -->
  <rect x="90" y="52" width="20" height="3" rx="1.5" style="fill: var(--color-text-muted)"/>
  <!-- Sheet content -->
  <text x="100" y="68" text-anchor="middle" style="fill: var(--color-text); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Sheet Title</text>
  <rect x="72" y="74" width="56" height="8" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="72" y="86" width="56" height="8" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="72" y="98" width="56" height="10" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-surface); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Action</text>
  <!-- Height label -->
  <text x="30" y="76" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">60%</text>
  <line x1="42" y1="48" x2="42" y2="112" style="stroke: var(--color-text-muted)" stroke-width="0.5" stroke-dasharray="2"/>
</svg>`,

'Swipe Left / Right': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- List item being swiped left -->
  <rect x="10" y="10" width="180" height="30" rx="4" style="fill: var(--color-surface-2)"/>
  <!-- Revealed red action -->
  <rect x="150" y="10" width="40" height="30" rx="0 4 4 0" style="fill: #ef4444; opacity: 0.8"/>
  <text x="170" y="29" text-anchor="middle" style="fill: white; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Delete</text>
  <!-- Item sliding left -->
  <rect x="0" y="10" width="155" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="16" y="29" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">List item swiped left</text>
  <!-- Arrow -->
  <text x="80" y="52" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">← swipe left = destructive</text>
  <!-- Swipe right example -->
  <rect x="10" y="64" width="180" height="30" rx="4" style="fill: var(--color-surface-2)"/>
  <!-- Revealed green action -->
  <rect x="10" y="64" width="40" height="30" rx="4 0 0 4" style="fill: #22c55e; opacity: 0.8"/>
  <text x="30" y="83" text-anchor="middle" style="fill: white; font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Done</text>
  <!-- Item sliding right -->
  <rect x="45" y="64" width="155" height="30" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="60" y="83" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">List item swiped right</text>
  <!-- Arrow -->
  <text x="105" y="106" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">swipe right = affirmative →</text>
</svg>`,

'Pull to Refresh': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Pull arrow -->
  <text x="100" y="22" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">↓</text>
  <!-- Spinner -->
  <circle cx="100" cy="36" r="8" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-dasharray="10 40" stroke-linecap="round"/>
  <!-- Pushed down content -->
  <rect x="68" y="50" width="64" height="10" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="64" width="64" height="10" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="78" width="64" height="10" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="92" width="64" height="10" rx="3" style="fill: var(--color-surface-2)"/>
  <!-- Label -->
  <text x="30" y="40" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">64px</text>
  <text x="30" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">threshold</text>
</svg>`,

'Long Press Context Menu': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Phone outline -->
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Item being pressed -->
  <rect x="68" y="14" width="64" height="16" rx="3" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="76" y="25" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Pressed item</text>
  <!-- Hold timer -->
  <text x="30" y="24" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">500ms</text>
  <text x="30" y="34" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">hold</text>
  <!-- Context bottom sheet -->
  <rect x="64" y="58" width="72" height="54" rx="8 8 0 0" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="90" y="62" width="20" height="3" rx="1.5" style="fill: var(--color-text-muted)"/>
  <text x="74" y="78" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Copy</text>
  <text x="74" y="90" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Share</text>
  <text x="74" y="102" style="fill: #ef4444; font-size: 7px; font-family: var(--font-sans)">Delete</text>
  <line x1="70" y1="82" x2="130" y2="82" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <line x1="70" y1="94" x2="130" y2="94" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
</svg>`,

'Pinch to Zoom': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Image container -->
  <rect x="30" y="10" width="100" height="75" rx="6" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <!-- Mountain scene placeholder -->
  <polygon points="50,65 70,35 90,65" style="fill: var(--color-accent); opacity: 0.3"/>
  <polygon points="75,65 95,45 115,65" style="fill: var(--color-accent); opacity: 0.5"/>
  <circle cx="105" cy="30" r="8" style="fill: var(--color-accent); opacity: 0.2"/>
  <!-- Pinch gesture fingers -->
  <circle cx="60" cy="45" r="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <circle cx="100" cy="50" r="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <!-- Arrows showing spread -->
  <line x1="66" y1="45" x2="55" y2="42" style="stroke: var(--color-accent)" stroke-width="1" stroke-linecap="round"/>
  <line x1="94" y1="50" x2="105" y2="53" style="stroke: var(--color-accent)" stroke-width="1" stroke-linecap="round"/>
  <!-- +/- buttons -->
  <rect x="145" y="25" width="24" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="157" y="41" text-anchor="middle" style="fill: var(--color-text); font-size: 14px; font-family: var(--font-sans)">+</text>
  <rect x="145" y="55" width="24" height="24" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="157" y="72" text-anchor="middle" style="fill: var(--color-text); font-size: 14px; font-family: var(--font-sans)">−</text>
  <!-- Label -->
  <text x="157" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Always</text>
  <text x="157" y="106" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">provide</text>
</svg>`,

'Swipe to Dismiss': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Toast being swiped -->
  <rect x="30" y="25" width="130" height="32" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" opacity="0.6" transform="rotate(-3 95 41)"/>
  <text x="46" y="43" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)" opacity="0.6" transform="rotate(-3 95 41)">Item saved</text>
  <text x="140" y="43" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)" opacity="0.6" transform="rotate(-3 95 41)">×</text>
  <!-- Motion arrow -->
  <line x1="140" y1="40" x2="180" y2="38" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <polygon points="180,34 186,38 180,42" style="fill: var(--color-accent)"/>
  <!-- Velocity indicator -->
  <text x="100" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">velocity > 0.5px/ms → dismiss</text>
  <!-- Static toast for comparison -->
  <rect x="30" y="82" width="140" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="48" cy="96" r="6" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="60" y="99" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">Notification</text>
  <text x="152" y="99" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">×</text>
</svg>`,

'Haptic Feedback': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Phone outline -->
  <rect x="70" y="10" width="60" height="100" rx="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Vibration waves -->
  <path d="M62 40 Q58 50 62 60" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M56 35 Q50 50 56 65" style="stroke: var(--color-accent); fill: none; opacity: 0.6" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M138 40 Q142 50 138 60" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M144 35 Q150 50 144 65" style="stroke: var(--color-accent); fill: none; opacity: 0.6" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Button being tapped -->
  <rect x="80" y="42" width="40" height="16" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="53" text-anchor="middle" style="fill: var(--color-surface); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Tap</text>
  <!-- Feedback labels -->
  <text x="100" y="76" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">10ms = success</text>
  <text x="100" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">100-50-100ms</text>
  <text x="100" y="98" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">= error pattern</text>
</svg>`,

'Safe Area Insets': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="2" width="80" height="116" rx="14" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Notch / Dynamic Island -->
  <rect x="86" y="2" width="28" height="10" rx="5" style="fill: var(--color-text); opacity: 0.2"/>
  <!-- Safe area top inset -->
  <line x1="64" y1="16" x2="136" y2="16" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="3"/>
  <text x="148" y="14" style="fill: var(--color-accent); font-size: 5px; font-family: var(--font-sans)">safe-area-top</text>
  <!-- Content area -->
  <rect x="66" y="18" width="68" height="82" rx="2" style="fill: var(--color-accent-bg); opacity: 0.3"/>
  <text x="100" y="60" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">Safe content</text>
  <!-- Safe area bottom inset -->
  <line x1="64" y1="102" x2="136" y2="102" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="3"/>
  <text x="148" y="106" style="fill: var(--color-accent); font-size: 5px; font-family: var(--font-sans)">safe-area-bottom</text>
  <!-- Home indicator -->
  <rect x="88" y="110" width="24" height="3" rx="1.5" style="fill: var(--color-text); opacity: 0.2"/>
  <!-- Left/right insets -->
  <line x1="66" y1="18" x2="66" y2="100" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="3"/>
  <line x1="134" y1="18" x2="134" y2="100" style="stroke: var(--color-accent)" stroke-width="0.5" stroke-dasharray="3"/>
</svg>`,

'Dynamic Viewport Height': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Phone with URL bar (100vh problem) -->
  <rect x="15" y="8" width="70" height="104" rx="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <!-- URL bar -->
  <rect x="19" y="12" width="62" height="14" rx="4" style="fill: var(--color-surface-2)"/>
  <text x="50" y="22" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">example.com</text>
  <!-- Content overflows -->
  <rect x="19" y="28" width="62" height="80" rx="4" style="fill: var(--color-accent-bg); opacity: 0.3"/>
  <text x="50" y="60" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">100vh</text>
  <text x="50" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-style: italic; font-family: var(--font-sans)">overflows!</text>
  <!-- Home indicator -->
  <rect x="35" y="104" width="20" height="3" rx="1.5" style="fill: var(--color-text); opacity: 0.2"/>
  <!-- Phone without URL bar (100dvh correct) -->
  <rect x="115" y="8" width="70" height="104" rx="10" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Content fits perfectly -->
  <rect x="119" y="12" width="62" height="92" rx="4" style="fill: var(--color-accent-bg); opacity: 0.5"/>
  <text x="150" y="55" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">100dvh</text>
  <text x="150" y="67" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">fits perfectly</text>
  <!-- Home indicator -->
  <rect x="135" y="104" width="20" height="3" rx="1.5" style="fill: var(--color-text); opacity: 0.2"/>
</svg>`,

'One-Handed Reachability': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Info at top (readable, rarely tapped) -->
  <rect x="68" y="12" width="64" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="22" width="50" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="32" width="58" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <text x="20" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Info</text>
  <text x="20" y="34" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">(read)</text>
  <!-- Reverse pyramid arrow -->
  <polygon points="100,48 85,48 100,54 115,48" style="fill: var(--color-accent); opacity: 0.2"/>
  <!-- Actions at bottom (easy to reach) -->
  <rect x="72" y="62" width="56" height="12" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="71" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Input field</text>
  <rect x="72" y="78" width="56" height="12" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="87" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Secondary</text>
  <rect x="72" y="94" width="56" height="14" rx="4" style="fill: var(--color-accent)"/>
  <text x="100" y="104" text-anchor="middle" style="fill: var(--color-surface); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Primary CTA</text>
  <text x="170" y="90" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Actions</text>
  <text x="170" y="100" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">(tap)</text>
</svg>`,

'Prevent Zoom on Input Focus': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Bad: zoomed in -->
  <rect x="10" y="10" width="80" height="48" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="50" y="24" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">14px font-size</text>
  <rect x="18" y="28" width="64" height="22" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" transform="scale(1.3) translate(-4, -2)"/>
  <text x="50" y="52" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-style: italic; font-family: var(--font-sans)">iOS zooms in!</text>
  <!-- Good: no zoom -->
  <rect x="110" y="10" width="80" height="48" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="150" y="24" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">16px font-size</text>
  <rect x="118" y="28" width="64" height="22" rx="3" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="126" y="42" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">Email</text>
  <text x="150" y="52" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">No zoom</text>
  <!-- Warning -->
  <text x="100" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Never use user-scalable=no</text>
  <text x="100" y="92" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Fix: font-size ≥ 16px</text>
</svg>`,

'Stories Format': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Full-screen story background -->
  <rect x="64" y="8" width="72" height="104" rx="8" style="fill: var(--color-accent-bg); opacity: 0.4"/>
  <!-- Progress bars at top -->
  <rect x="68" y="12" width="14" height="2" rx="1" style="fill: var(--color-accent)"/>
  <rect x="84" y="12" width="14" height="2" rx="1" style="fill: var(--color-accent)"/>
  <rect x="100" y="12" width="14" height="2" rx="1" style="fill: var(--color-accent); opacity: 0.5"/>
  <rect x="116" y="12" width="14" height="2" rx="1" style="fill: var(--color-text-muted); opacity: 0.3"/>
  <!-- Story content -->
  <text x="100" y="50" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Story Content</text>
  <text x="100" y="64" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">5-7s auto-advance</text>
  <!-- Tap zones -->
  <line x1="86" y1="20" x2="86" y2="106" style="stroke: var(--color-text-muted); opacity: 0.3" stroke-width="0.5" stroke-dasharray="3"/>
  <text x="76" y="98" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">← back</text>
  <text x="116" y="98" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">next →</text>
  <!-- Labels -->
  <text x="25" y="34" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">hold</text>
  <text x="25" y="44" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">= pause</text>
</svg>`,

'Pull-Down Banner': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Banner sliding down -->
  <rect x="66" y="10" width="68" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5">
  </rect>
  <!-- Banner content -->
  <circle cx="78" cy="24" r="6" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="88" y="21" style="fill: var(--color-text); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">New message</text>
  <text x="88" y="30" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Tap to view</text>
  <!-- Slide down arrow -->
  <text x="46" y="20" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans)">↓</text>
  <!-- Content below -->
  <rect x="68" y="46" width="64" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="58" width="64" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="70" width="64" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- Auto-dismiss timer -->
  <text x="170" y="22" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">4s auto-</text>
  <text x="170" y="32" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">dismiss</text>
  <!-- Swipe up hint -->
  <text x="100" y="104" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">↑ swipe to dismiss</text>
</svg>`,

'Mobile Skeleton Loading': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Skeleton card 1 -->
  <rect x="15" y="10" width="170" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <circle cx="34" cy="25" r="10" style="fill: var(--color-surface-2)"/>
  <rect x="50" y="18" width="80" height="5" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="50" y="27" width="50" height="5" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- Shimmer gradient overlay -->
  <rect x="15" y="10" width="170" height="30" rx="4" style="fill: url(#shimmer); opacity: 0.3"/>
  <!-- Skeleton card 2 -->
  <rect x="15" y="46" width="170" height="30" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <circle cx="34" cy="61" r="10" style="fill: var(--color-surface-2)"/>
  <rect x="50" y="54" width="70" height="5" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="50" y="63" width="60" height="5" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- Labels -->
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Heights match real content</text>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">aspect-ratio locks layout</text>
  <defs>
    <linearGradient id="shimmer" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" style="stop-color: var(--color-surface-2); stop-opacity: 0"/>
      <stop offset="0.5" style="stop-color: var(--color-accent); stop-opacity: 0.15"/>
      <stop offset="1" style="stop-color: var(--color-surface-2); stop-opacity: 0"/>
    </linearGradient>
  </defs>
</svg>`,

'Timeline / Activity Feed': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Vertical timeline line -->
  <line x1="50" y1="10" x2="50" y2="110" style="stroke: var(--color-border)" stroke-width="2"/>
  <!-- Event 1 -->
  <circle cx="50" cy="20" r="5" style="fill: var(--color-accent)"/>
  <rect x="62" y="12" width="120" height="18" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="68" y="24" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Order confirmed</text>
  <text x="150" y="24" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">2m ago</text>
  <!-- Event 2 -->
  <circle cx="50" cy="48" r="5" style="fill: var(--color-accent); opacity: 0.6"/>
  <rect x="62" y="40" width="120" height="18" rx="4" style="fill: var(--color-surface)"/>
  <text x="68" y="52" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">Payment processed</text>
  <text x="150" y="52" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">5m ago</text>
  <!-- Event 3 -->
  <circle cx="50" cy="76" r="5" style="fill: var(--color-text-muted)"/>
  <rect x="62" y="68" width="120" height="18" rx="4" style="fill: var(--color-surface)"/>
  <text x="68" y="80" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Cart updated</text>
  <text x="150" y="80" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">1h ago</text>
  <!-- CSS ::before label -->
  <text x="28" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">CSS ::before</text>
</svg>`,

'Star Rating': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Star 1 (filled) -->
  <polygon points="40,35 44,47 56,47 46,54 50,66 40,58 30,66 34,54 24,47 36,47" style="fill: var(--color-accent)"/>
  <!-- Star 2 (filled) -->
  <polygon points="70,35 74,47 86,47 76,54 80,66 70,58 60,66 64,54 54,47 66,47" style="fill: var(--color-accent)"/>
  <!-- Star 3 (filled) -->
  <polygon points="100,35 104,47 116,47 106,54 110,66 100,58 90,66 94,54 84,47 96,47" style="fill: var(--color-accent)"/>
  <!-- Star 4 (filled) -->
  <polygon points="130,35 134,47 146,47 136,54 140,66 130,58 120,66 124,54 114,47 126,47" style="fill: var(--color-accent)"/>
  <!-- Star 5 (empty) -->
  <polygon points="160,35 164,47 176,47 166,54 170,66 160,58 150,66 154,54 144,47 156,47" style="fill: none; stroke: var(--color-border)" stroke-width="1"/>
  <!-- Touch target boxes -->
  <rect x="24" y="30" width="32" height="40" rx="3" style="stroke: var(--color-accent); fill: none; opacity: 0.3" stroke-width="0.5" stroke-dasharray="2"/>
  <rect x="54" y="30" width="32" height="40" rx="3" style="stroke: var(--color-accent); fill: none; opacity: 0.3" stroke-width="0.5" stroke-dasharray="2"/>
  <rect x="84" y="30" width="32" height="40" rx="3" style="stroke: var(--color-accent); fill: none; opacity: 0.3" stroke-width="0.5" stroke-dasharray="2"/>
  <rect x="114" y="30" width="32" height="40" rx="3" style="stroke: var(--color-accent); fill: none; opacity: 0.3" stroke-width="0.5" stroke-dasharray="2"/>
  <rect x="144" y="30" width="32" height="40" rx="3" style="stroke: var(--color-accent); fill: none; opacity: 0.3" stroke-width="0.5" stroke-dasharray="2"/>
  <!-- Label -->
  <text x="100" y="88" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">4 out of 5 stars</text>
  <text x="100" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">44px+ touch targets per star</text>
</svg>`,

'Stepper / Wizard': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Desktop stepper -->
  <text x="100" y="14" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Desktop</text>
  <!-- Step 1 (done) -->
  <circle cx="30" cy="32" r="10" style="fill: var(--color-accent)"/>
  <text x="30" y="36" text-anchor="middle" style="fill: var(--color-surface); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">✓</text>
  <text x="30" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Details</text>
  <!-- Line 1-2 -->
  <line x1="40" y1="32" x2="62" y2="32" style="stroke: var(--color-accent)" stroke-width="2"/>
  <!-- Step 2 (active) -->
  <circle cx="72" cy="32" r="10" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="2"/>
  <text x="72" y="36" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 700; font-family: var(--font-sans)">2</text>
  <text x="72" y="50" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Payment</text>
  <!-- Line 2-3 -->
  <line x1="82" y1="32" x2="104" y2="32" style="stroke: var(--color-border)" stroke-width="2"/>
  <!-- Step 3 (upcoming) -->
  <circle cx="114" cy="32" r="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="114" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">3</text>
  <text x="114" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Review</text>
  <!-- Line 3-4 -->
  <line x1="124" y1="32" x2="146" y2="32" style="stroke: var(--color-border)" stroke-width="2"/>
  <!-- Step 4 (upcoming) -->
  <circle cx="156" cy="32" r="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="156" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">4</text>
  <text x="156" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Confirm</text>
  <!-- Mobile compact -->
  <text x="100" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mobile</text>
  <rect x="40" y="78" width="120" height="24" rx="6" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="100" y="93" text-anchor="middle" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Step 2 of 4</text>
  <!-- Progress bar -->
  <rect x="44" y="99" width="112" height="3" rx="1.5" style="fill: var(--color-surface-2)"/>
  <rect x="44" y="99" width="56" height="3" rx="1.5" style="fill: var(--color-accent)"/>
</svg>`,

'Dark Mode Toggle': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Three-state toggle -->
  <rect x="30" y="30" width="140" height="32" rx="16" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- System option -->
  <rect x="34" y="34" width="42" height="24" rx="12" style="fill: var(--color-surface-2)"/>
  <text x="55" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">System</text>
  <!-- Light option (active) -->
  <rect x="78" y="34" width="42" height="24" rx="12" style="fill: var(--color-accent)"/>
  <text x="99" y="50" text-anchor="middle" style="fill: var(--color-surface); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Light</text>
  <!-- Dark option -->
  <rect x="122" y="34" width="42" height="24" rx="12" style="fill: var(--color-surface-2)"/>
  <text x="143" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Dark</text>
  <!-- Sun/moon icons -->
  <circle cx="55" cy="80" r="8" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <text x="55" y="84" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">⚙</text>
  <circle cx="99" cy="80" r="8" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="99" y="84" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">☀</text>
  <circle cx="143" cy="80" r="8" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <text x="143" y="84" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">☾</text>
  <!-- Label -->
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">prefers-color-scheme + localStorage</text>
</svg>`,

'Back to Top Button': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Scrolled content -->
  <rect x="68" y="12" width="64" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="22" width="54" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="32" width="60" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="42" width="50" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="52" width="64" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="62" width="58" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="72" width="52" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="68" y="82" width="60" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- Back to top button -->
  <circle cx="124" cy="96" r="12" style="fill: var(--color-accent)"/>
  <text x="124" y="100" text-anchor="middle" style="fill: var(--color-surface); font-size: 12px; font-weight: 600; font-family: var(--font-sans)">↑</text>
  <!-- Labels -->
  <text x="30" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Shows</text>
  <text x="30" y="58" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">after</text>
  <text x="30" y="66" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">400px</text>
  <text x="170" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Intersection</text>
  <text x="170" y="106" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Observer</text>
</svg>`,

'Share Sheet / Action Sheet': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Dimmed background -->
  <rect x="64" y="8" width="72" height="30" rx="8 8 0 0" style="fill: var(--color-text); opacity: 0.1"/>
  <!-- Action sheet -->
  <rect x="64" y="38" width="72" height="74" rx="8 8 0 0" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Drag handle -->
  <rect x="90" y="42" width="20" height="3" rx="1.5" style="fill: var(--color-text-muted)"/>
  <!-- Share options -->
  <text x="76" y="58" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">📋 Copy link</text>
  <line x1="70" y1="62" x2="130" y2="62" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="76" y="74" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">✉ Email</text>
  <line x1="70" y1="78" x2="130" y2="78" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="76" y="90" style="fill: var(--color-text); font-size: 7px; font-family: var(--font-sans)">💬 Message</text>
  <line x1="70" y1="94" x2="130" y2="94" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <!-- Cancel button -->
  <rect x="70" y="98" width="60" height="12" rx="4" style="fill: var(--color-surface-2)"/>
  <text x="100" y="107" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Cancel</text>
  <!-- navigator.share label -->
  <text x="30" y="70" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">navigator</text>
  <text x="30" y="78" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">.share()</text>
</svg>`,

'Swipeable Card Stack': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Back cards (stacked) -->
  <rect x="46" y="18" width="108" height="70" rx="8" style="fill: var(--color-surface-2); opacity: 0.4" transform="scale(0.9) translate(11, 8)"/>
  <rect x="44" y="14" width="112" height="74" rx="8" style="fill: var(--color-surface-2); opacity: 0.6" transform="scale(0.95) translate(5, 4)"/>
  <!-- Top card (being swiped) -->
  <rect x="42" y="10" width="116" height="78" rx="8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5" transform="rotate(-5 100 49)"/>
  <text x="92" y="42" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)" transform="rotate(-5 100 49)">Card Content</text>
  <text x="92" y="58" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)" transform="rotate(-5 100 49)">Swipe to decide</text>
  <!-- Swipe direction indicators -->
  <text x="20" y="55" text-anchor="middle" style="fill: #ef4444; font-size: 9px; font-weight: 700; font-family: var(--font-sans)">✕</text>
  <text x="180" y="55" text-anchor="middle" style="fill: #22c55e; font-size: 9px; font-weight: 700; font-family: var(--font-sans)">♥</text>
  <!-- Button alternatives -->
  <circle cx="70" cy="104" r="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="70" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">←</text>
  <circle cx="130" cy="104" r="10" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="130" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">→</text>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">keyboard alt</text>
</svg>`,

'Horizontal Scroll with Snap': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Container -->
  <rect x="10" y="20" width="180" height="60" rx="6" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <!-- Snap items -->
  <rect x="16" y="26" width="50" height="48" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="41" y="54" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Item 1</text>
  <rect x="72" y="26" width="50" height="48" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="97" y="54" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Item 2</text>
  <rect x="128" y="26" width="50" height="48" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="153" y="54" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Item 3</text>
  <!-- Gradient fade on right edge -->
  <rect x="170" y="20" width="20" height="60" rx="0 6 6 0" style="fill: url(#edgeFade)"/>
  <!-- Scroll indicators -->
  <circle cx="88" cy="96" r="3" style="fill: var(--color-accent)"/>
  <circle cx="100" cy="96" r="3" style="fill: var(--color-surface-2)"/>
  <circle cx="112" cy="96" r="3" style="fill: var(--color-surface-2)"/>
  <!-- Snap label -->
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">scroll-snap-type: x mandatory</text>
  <defs>
    <linearGradient id="edgeFade" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" style="stop-color: var(--color-surface); stop-opacity: 0"/>
      <stop offset="1" style="stop-color: var(--color-surface); stop-opacity: 0.9"/>
    </linearGradient>
  </defs>
</svg>`,

};
