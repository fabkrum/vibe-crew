/** SVG illustrations for Responsive Design Patterns */
export const responsivePatternSvgs: Record<string, string> = {

'Mobile-First CSS': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Mobile base (smallest) -->
  <rect x="10" y="15" width="40" height="70" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="14" y="20" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="14" y="32" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="14" y="44" width="32" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="30" y="68" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Base CSS</text>
  <!-- Arrow -->
  <text x="60" y="50" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">→</text>
  <!-- Tablet (enhanced) -->
  <rect x="70" y="10" width="50" height="80" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="74" y="15" width="20" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="96" y="15" width="20" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="74" y="27" width="20" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="96" y="27" width="20" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="95" y="58" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">min-width:</text>
  <text x="95" y="66" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">768px</text>
  <!-- Arrow -->
  <text x="128" y="50" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">→</text>
  <!-- Desktop (full) -->
  <rect x="138" y="6" width="56" height="88" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="142" y="11" width="14" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="158" y="11" width="14" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="174" y="11" width="14" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="142" y="21" width="14" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="158" y="21" width="14" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="174" y="21" width="14" height="6" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="166" y="54" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">min-width:</text>
  <text x="166" y="62" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">1024px</text>
  <text x="100" y="110" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Enhance progressively →</text>
</svg>`,

'Content-Driven Breakpoints': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Browser resize illustration -->
  <rect x="10" y="15" width="180" height="70" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <!-- Content that breaks at 620px -->
  <rect x="16" y="22" width="60" height="30" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="80" y="22" width="60" height="30" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="144" y="22" width="40" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <!-- Overflow indicator -->
  <rect x="144" y="38" width="40" height="14" rx="3" style="stroke: #ef4444; fill: none" stroke-width="1" stroke-dasharray="3"/>
  <text x="164" y="48" text-anchor="middle" style="fill: #ef4444; font-size: 6px; font-family: var(--font-sans)">overflow!</text>
  <!-- Breakpoint line -->
  <line x1="140" y1="15" x2="140" y2="85" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="4"/>
  <text x="140" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">620px breakpoint</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Break where content breaks</text>
</svg>`,

'Progressive Enhancement': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Layered cake diagram -->
  <!-- Layer 1: HTML (base) -->
  <rect x="30" y="80" width="140" height="24" rx="4" style="fill: var(--color-accent); opacity: 0.7"/>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-surface); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Semantic HTML (works everywhere)</text>
  <!-- Layer 2: CSS -->
  <rect x="40" y="56" width="120" height="22" rx="4" style="fill: var(--color-accent); opacity: 0.5"/>
  <text x="100" y="71" text-anchor="middle" style="fill: var(--color-surface); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">CSS Grid, Flex, Clamp</text>
  <!-- Layer 3: JS enhancements -->
  <rect x="50" y="34" width="100" height="20" rx="4" style="fill: var(--color-accent); opacity: 0.35"/>
  <text x="100" y="48" text-anchor="middle" style="fill: var(--color-text); font-size: 8px; font-family: var(--font-sans)">JS enhancements</text>
  <!-- Layer 4: Advanced -->
  <rect x="60" y="14" width="80" height="18" rx="4" style="fill: var(--color-accent); opacity: 0.2"/>
  <text x="100" y="27" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Animations, WebGL</text>
  <!-- Arrow -->
  <text x="16" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">↑</text>
  <text x="16" y="60" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">enhance</text>
</svg>`,

'Standard Breakpoints': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Breakpoint markers on a ruler -->
  <line x1="10" y1="50" x2="190" y2="50" style="stroke: var(--color-border)" stroke-width="2"/>
  <!-- 360px -->
  <line x1="30" y1="42" x2="30" y2="58" style="stroke: var(--color-text-muted)" stroke-width="2"/>
  <text x="30" y="38" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">360</text>
  <text x="30" y="70" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Mobile</text>
  <!-- 768px -->
  <line x1="80" y1="42" x2="80" y2="58" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="80" y="38" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">768</text>
  <text x="80" y="70" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">Tablet</text>
  <!-- 1024px -->
  <line x1="130" y1="42" x2="130" y2="58" style="stroke: var(--color-accent)" stroke-width="2"/>
  <text x="130" y="38" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">1024</text>
  <text x="130" y="70" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">Desktop</text>
  <!-- 1440px -->
  <line x1="170" y1="42" x2="170" y2="58" style="stroke: var(--color-text-muted)" stroke-width="2"/>
  <text x="170" y="38" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">1440</text>
  <text x="170" y="70" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Large</text>
  <!-- Range labels -->
  <rect x="30" y="80" width="50" height="10" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="55" y="88" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">sm</text>
  <rect x="80" y="80" width="50" height="10" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="105" y="88" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">md</text>
  <rect x="130" y="80" width="40" height="10" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="150" y="88" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">lg</text>
  <text x="100" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Starting points, not rules</text>
</svg>`,

'Container Queries': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Page layout with sidebar + main -->
  <rect x="10" y="10" width="180" height="100" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <!-- Sidebar container (narrow) -->
  <rect x="14" y="14" width="50" height="92" rx="3" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="39" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Sidebar (200px)</text>
  <!-- Card in sidebar (stacked) -->
  <rect x="18" y="30" width="42" height="32" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="22" y="34" width="14" height="10" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="22" y="48" width="34" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="22" y="54" width="26" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <!-- Main container (wide) -->
  <rect x="68" y="14" width="118" height="92" rx="3" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <text x="127" y="26" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Main (600px)</text>
  <!-- Card in main (horizontal) -->
  <rect x="72" y="30" width="110" height="32" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="76" y="34" width="24" height="24" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="104" y="36" width="60" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="104" y="44" width="50" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="104" y="52" width="40" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <!-- Label -->
  <text x="100" y="82" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Same component, different container</text>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">@container (min-width: 400px)</text>
</svg>`,

'Pointer & Hover Detection': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Mouse (pointer: fine) -->
  <text x="50" y="16" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">pointer: fine</text>
  <rect x="20" y="22" width="60" height="40" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="30" y="30" width="18" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="52" y="30" width="18" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="30" y="42" width="18" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="52" y="42" width="18" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <text x="50" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">24px targets OK</text>
  <text x="50" y="82" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">hover effects ✓</text>
  <!-- Arrow -->
  <text x="100" y="42" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">↔</text>
  <!-- Touch (pointer: coarse) -->
  <text x="150" y="16" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">pointer: coarse</text>
  <rect x="120" y="22" width="60" height="40" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="126" y="28" width="48" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="126" y="44" width="48" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="150" y="72" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">48px targets</text>
  <text x="150" y="82" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">no hover needed</text>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">@media (pointer: fine/coarse)</text>
</svg>`,

'Clamp-Based Font Sizing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Font scaling visualization -->
  <text x="20" y="24" style="fill: var(--color-text); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Heading</text>
  <text x="20" y="38" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">1.75rem (min)</text>
  <!-- Arrow showing growth -->
  <line x1="20" y1="48" x2="180" y2="48" style="stroke: var(--color-accent); opacity: 0.3" stroke-width="2"/>
  <line x1="20" y1="48" x2="130" y2="48" style="stroke: var(--color-accent)" stroke-width="2"/>
  <circle cx="130" cy="48" r="3" style="fill: var(--color-accent)"/>
  <!-- Large text -->
  <text x="100" y="70" style="fill: var(--color-text); font-size: 16px; font-weight: 700; font-family: var(--font-sans)">Heading</text>
  <text x="100" y="84" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">3rem (max)</text>
  <!-- Clamp formula -->
  <rect x="20" y="94" width="160" height="18" rx="4" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="107" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">clamp(1.75rem, 1.2rem + 2vw, 3rem)</text>
</svg>`,

'Fluid Spacing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Tight spacing (mobile) -->
  <text x="45" y="14" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mobile</text>
  <rect x="15" y="20" width="60" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="15" y="40" width="60" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="15" y="60" width="60" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <!-- Gap indicators -->
  <line x1="80" y1="36" x2="80" y2="40" style="stroke: var(--color-accent)" stroke-width="1"/>
  <text x="88" y="40" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">4px</text>
  <!-- Arrow -->
  <text x="100" y="50" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">→</text>
  <!-- Generous spacing (desktop) -->
  <text x="155" y="14" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Desktop</text>
  <rect x="125" y="20" width="60" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="125" y="48" width="60" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="125" y="76" width="60" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <!-- Gap indicators -->
  <line x1="190" y1="36" x2="190" y2="48" style="stroke: var(--color-accent)" stroke-width="1"/>
  <text x="194" y="44" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">12</text>
  <!-- Formula -->
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">clamp(0.75rem, 0.5rem + 1vw, 2rem)</text>
</svg>`,

'Line Length Control': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Too long lines -->
  <rect x="10" y="10" width="180" height="36" rx="4" style="stroke: var(--color-border-subtle); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="16" y="16" width="168" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="24" width="168" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="32" width="100" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <text x="10" y="56" style="fill: var(--color-text-muted); font-size: 7px; font-style: italic; font-family: var(--font-sans)">100+ characters — hard to read</text>
  <!-- Optimal width -->
  <rect x="10" y="66" width="120" height="36" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="16" y="72" width="108" height="4" rx="1" style="fill: var(--color-accent-bg)"/>
  <rect x="16" y="80" width="108" height="4" rx="1" style="fill: var(--color-accent-bg)"/>
  <rect x="16" y="88" width="70" height="4" rx="1" style="fill: var(--color-accent-bg)"/>
  <text x="10" y="112" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">max-width: 65ch (45-75 chars)</text>
</svg>`,

'srcset and sizes': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Multiple resolution images -->
  <rect x="10" y="20" width="36" height="24" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="28" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">400w</text>
  <rect x="54" y="14" width="48" height="34" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="78" y="36" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">800w</text>
  <rect x="110" y="8" width="60" height="42" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="140" y="34" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">1200w</text>
  <!-- Browser chooses -->
  <text x="100" y="68" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-family: var(--font-sans)">Browser picks the best match</text>
  <!-- sizes attribute -->
  <rect x="20" y="78" width="160" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="89" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">sizes="(max-width: 768px) 100vw, 33vw"</text>
  <text x="100" y="108" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Cap at 2x — eyes can't tell 3x</text>
</svg>`,

'Art Direction with Picture': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Mobile crop (square) -->
  <rect x="10" y="20" width="40" height="40" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <polygon points="20,48 30,32 40,48" style="fill: var(--color-accent); opacity: 0.4"/>
  <circle cx="38" cy="30" r="4" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="30" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Mobile</text>
  <text x="30" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">(square)</text>
  <!-- Tablet crop (4:3) -->
  <rect x="60" y="16" width="50" height="48" rx="4" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <polygon points="68,50 85,26 100,50" style="fill: var(--color-accent); opacity: 0.4"/>
  <circle cx="96" cy="26" r="4" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="85" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">Tablet</text>
  <text x="85" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">(4:3)</text>
  <!-- Desktop crop (panoramic) -->
  <rect x="120" y="22" width="70" height="36" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <polygon points="130,48 148,28 165,48" style="fill: var(--color-accent); opacity: 0.4"/>
  <polygon points="155,48 168,36 180,48" style="fill: var(--color-accent); opacity: 0.3"/>
  <circle cx="175" cy="30" r="4" style="fill: var(--color-accent); opacity: 0.3"/>
  <text x="155" y="72" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Desktop</text>
  <text x="155" y="80" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">(panoramic)</text>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Different crops per breakpoint</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">&lt;picture&gt; + &lt;source media&gt;</text>
</svg>`,

'Aspect Ratio Preservation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Bad: layout shift -->
  <text x="45" y="14" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">No aspect-ratio</text>
  <rect x="10" y="20" width="70" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="10" y="30" width="70" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="10" y="40" width="70" height="28" rx="3" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="45" y="58" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">image loads</text>
  <!-- Content shifted down -->
  <rect x="10" y="72" width="70" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <text x="76" y="78" style="fill: #ef4444; font-size: 8px; font-family: var(--font-sans)">↓ CLS!</text>
  <!-- Good: reserved space -->
  <text x="155" y="14" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">aspect-ratio: 16/9</text>
  <rect x="120" y="20" width="70" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="120" y="30" width="70" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="120" y="40" width="70" height="28" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="155" y="58" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">reserved!</text>
  <rect x="120" y="72" width="70" height="6" rx="2" style="fill: var(--color-surface-2)"/>
  <text x="186" y="78" style="fill: var(--color-accent); font-size: 8px; font-family: var(--font-sans)">stable</text>
  <text x="100" y="106" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Prevents layout shift (CLS)</text>
</svg>`,

'Lazy Loading Strategy': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Viewport boundary -->
  <rect x="30" y="5" width="140" height="80" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="100" y="16" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">viewport</text>
  <!-- LCP image (eager) -->
  <rect x="38" y="20" width="124" height="30" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="100" y="38" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Hero: loading="eager"</text>
  <text x="100" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">fetchpriority="high"</text>
  <!-- Content below viewport -->
  <rect x="38" y="56" width="60" height="24" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="102" y="56" width="60" height="24" rx="3" style="fill: var(--color-surface-2)"/>
  <!-- Below fold -->
  <line x1="30" y1="85" x2="170" y2="85" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="4"/>
  <text x="100" y="94" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">below fold</text>
  <!-- Lazy images -->
  <rect x="38" y="98" width="40" height="16" rx="3" style="stroke: var(--color-text-muted); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="3"/>
  <text x="58" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">lazy</text>
  <rect x="82" y="98" width="40" height="16" rx="3" style="stroke: var(--color-text-muted); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="3"/>
  <text x="102" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">lazy</text>
  <rect x="126" y="98" width="40" height="16" rx="3" style="stroke: var(--color-text-muted); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="3"/>
  <text x="146" y="110" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">lazy</text>
</svg>`,

'Auto-Fill Grid': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Grid cards that auto-fill -->
  <rect x="10" y="10" width="56" height="44" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="72" y="10" width="56" height="44" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="134" y="10" width="56" height="44" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="10" y="60" width="56" height="44" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="72" y="60" width="56" height="44" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <rect x="134" y="60" width="56" height="44" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1" stroke-dasharray="3"/>
  <!-- Labels -->
  <text x="38" y="36" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Card</text>
  <text x="100" y="36" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Card</text>
  <text x="162" y="36" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Card</text>
  <text x="38" y="86" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Card</text>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Card</text>
  <text x="162" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">auto-fill</text>
</svg>`,

'Flex Wrap Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Flex items wrapping -->
  <rect x="10" y="15" width="45" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="33" y="30" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">React</text>
  <rect x="61" y="15" width="55" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="89" y="30" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">TypeScript</text>
  <rect x="122" y="15" width="40" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="142" y="30" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Next.js</text>
  <rect x="168" y="15" width="26" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="181" y="30" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">CSS</text>
  <!-- Wrapped row -->
  <rect x="10" y="43" width="50" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="35" y="58" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Tailwind</text>
  <rect x="66" y="43" width="60" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="96" y="58" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">PostgreSQL</text>
  <rect x="132" y="43" width="42" height="22" rx="11" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="153" y="58" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Prisma</text>
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">flex-wrap: wrap + gap</text>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Items wrap naturally at any width</text>
</svg>`,

'Logical Properties': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- LTR example -->
  <text x="50" y="16" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">LTR (English)</text>
  <rect x="10" y="22" width="80" height="36" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="16" y="28" width="30" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="16" y="40" width="68" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="16" y="48" width="50" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <text x="14" y="36" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">→</text>
  <!-- RTL example -->
  <text x="150" y="16" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">RTL (Arabic)</text>
  <rect x="110" y="22" width="80" height="36" rx="4" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="154" y="28" width="30" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="116" y="40" width="68" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <rect x="134" y="48" width="50" height="4" rx="1" style="fill: var(--color-surface-2)"/>
  <text x="182" y="36" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">←</text>
  <!-- Same code -->
  <text x="100" y="78" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">Same CSS code</text>
  <rect x="25" y="86" width="150" height="14" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="100" y="96" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">margin-inline-start: 1rem</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Auto-adapts to dir="rtl"</text>
</svg>`,

'Sidebar Layout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Desktop layout (side by side) -->
  <text x="100" y="12" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Desktop: grid-template-columns: 260px 1fr</text>
  <rect x="10" y="18" width="50" height="50" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="35" y="46" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Sidebar</text>
  <rect x="64" y="18" width="126" height="50" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="127" y="46" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Main Content</text>
  <!-- Mobile layout (stacked) -->
  <text x="100" y="82" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mobile: grid-template-columns: 1fr</text>
  <rect x="40" y="88" width="120" height="12" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="100" y="97" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">Main Content</text>
  <rect x="40" y="103" width="120" height="12" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">Sidebar (below)</text>
</svg>`,

'Stack-to-Row Pattern': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Mobile: stacked -->
  <text x="35" y="12" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Mobile</text>
  <rect x="10" y="18" width="50" height="14" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="35" y="28" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Label</text>
  <rect x="10" y="36" width="50" height="14" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="35" y="46" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Input</text>
  <rect x="10" y="54" width="50" height="14" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="35" y="64" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Button</text>
  <text x="35" y="82" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">flex-direction:</text>
  <text x="35" y="90" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">column</text>
  <!-- Arrow -->
  <text x="80" y="46" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">→</text>
  <!-- Desktop: row -->
  <text x="145" y="12" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Desktop</text>
  <rect x="90" y="30" width="36" height="28" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="108" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Label</text>
  <rect x="130" y="30" width="36" height="28" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="148" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Input</text>
  <rect x="170" y="30" width="26" height="28" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="183" y="48" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Btn</text>
  <text x="145" y="76" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">flex-direction: row</text>
  <text x="100" y="112" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Most common responsive layout shift</text>
</svg>`,

'Responsive Nav Pattern': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Desktop: horizontal nav -->
  <rect x="10" y="8" width="180" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="14" y="12" width="24" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="42" y="12" width="20" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="12" width="20" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="90" y="12" width="20" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="114" y="12" width="20" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="170" y="20" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">1024+</text>
  <!-- Tablet: condensed with "More" -->
  <rect x="10" y="36" width="120" height="20" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="14" y="40" width="24" height="12" rx="3" style="fill: var(--color-accent-bg)"/>
  <rect x="42" y="40" width="20" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="66" y="40" width="20" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="100" y="40" width="26" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="113" y="49" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">More</text>
  <text x="170" y="48" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">768-1023</text>
  <!-- Mobile: bottom tab bar -->
  <rect x="40" y="62" width="80" height="52" rx="8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="44" y="96" width="72" height="14" rx="4" style="fill: var(--color-accent-bg)"/>
  <circle cx="56" cy="102" r="3" style="fill: var(--color-accent)"/>
  <circle cx="72" cy="102" r="3" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <circle cx="88" cy="102" r="3" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <circle cx="104" cy="102" r="3" style="stroke: var(--color-text-muted); fill: none" stroke-width="1"/>
  <text x="170" y="90" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">&lt;768</text>
  <text x="170" y="100" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">bottom</text>
  <text x="170" y="108" text-anchor="middle" style="fill: var(--color-accent); font-size: 6px; font-family: var(--font-sans)">tab bar</text>
</svg>`,

'Priority+ Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Nav bar with items + More dropdown -->
  <rect x="10" y="20" width="180" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="16" y="26" width="30" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="31" y="37" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-family: var(--font-sans)">Home</text>
  <rect x="50" y="26" width="38" height="16" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="69" y="37" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Products</text>
  <rect x="92" y="26" width="30" height="16" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="107" y="37" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">About</text>
  <!-- More button -->
  <rect x="150" y="26" width="34" height="16" rx="3" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="167" y="37" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">More ▾</text>
  <!-- Dropdown -->
  <rect x="138" y="50" width="50" height="42" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="163" y="64" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Blog</text>
  <line x1="142" y1="70" x2="184" y2="70" style="stroke: var(--color-border-subtle)" stroke-width="0.5"/>
  <text x="163" y="82" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">Contact</text>
  <!-- Label -->
  <text x="70" y="78" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Overflow items → "More"</text>
  <text x="70" y="92" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 7px; font-family: var(--font-sans)">ResizeObserver recalculates</text>
</svg>`,

'Off-Canvas Navigation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="4" width="80" height="112" rx="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <!-- Backdrop -->
  <rect x="64" y="8" width="72" height="104" rx="8" style="fill: var(--color-text); opacity: 0.15"/>
  <!-- Off-canvas panel -->
  <rect x="64" y="8" width="52" height="104" rx="8 0 0 8" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="108" y="20" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">×</text>
  <rect x="70" y="22" width="40" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="70" y="34" width="40" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="70" y="46" width="40" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="70" y="58" width="40" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="70" y="70" width="40" height="8" rx="2" style="fill: var(--color-surface-2)"/>
  <!-- Hamburger trigger indicator -->
  <text x="20" y="20" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">☰</text>
  <line x1="30" y1="18" x2="60" y2="12" style="stroke: var(--color-text-muted)" stroke-width="0.5" stroke-dasharray="2"/>
  <text x="30" y="60" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">role=</text>
  <text x="30" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">"dialog"</text>
  <text x="30" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">focus</text>
  <text x="30" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">trapped</text>
</svg>`,

'Responsive Table': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Desktop table -->
  <text x="50" y="12" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Desktop: table</text>
  <rect x="10" y="16" width="80" height="48" rx="3" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="10" y="16" width="80" height="12" rx="3 3 0 0" style="fill: var(--color-accent-bg)"/>
  <text x="24" y="25" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Name</text>
  <text x="50" y="25" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Email</text>
  <text x="74" y="25" style="fill: var(--color-accent); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Role</text>
  <text x="16" y="38" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">Alice</text>
  <text x="46" y="38" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">a@b.co</text>
  <text x="74" y="38" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">Admin</text>
  <text x="16" y="52" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">Bob</text>
  <text x="46" y="52" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">b@c.co</text>
  <text x="74" y="52" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">User</text>
  <!-- Arrow -->
  <text x="100" y="44" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">→</text>
  <!-- Mobile: cards -->
  <text x="155" y="12" text-anchor="middle" style="fill: var(--color-accent); font-size: 7px; font-weight: 600; font-family: var(--font-sans)">Mobile: cards</text>
  <rect x="120" y="16" width="70" height="24" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="126" y="26" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Name</text>
  <text x="148" y="26" style="fill: var(--color-text); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Alice</text>
  <text x="126" y="36" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Email</text>
  <text x="148" y="36" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">a@b.co</text>
  <rect x="120" y="44" width="70" height="24" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="126" y="54" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Name</text>
  <text x="148" y="54" style="fill: var(--color-text); font-size: 6px; font-weight: 600; font-family: var(--font-sans)">Bob</text>
  <text x="126" y="64" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Email</text>
  <text x="148" y="64" style="fill: var(--color-text-secondary); font-size: 6px; font-family: var(--font-sans)">b@c.co</text>
  <!-- Strategies -->
  <text x="100" y="86" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">3 strategies: scroll, cards, or hide columns</text>
</svg>`,

};
