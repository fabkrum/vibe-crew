/** SVG illustrations for Onboarding & Tutorial Patterns */
export const onboardingPatternSvgs: Record<string, string> = {

'Multi-Step Product Tour': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="50" y="30" width="80" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="2"/>
  <rect x="55" y="35" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.4"/>
  <rect x="55" y="42" width="35" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <path d="M90 55 L90 62 L85 62 L90 68 L95 62 L90 62" style="fill: var(--color-accent)" opacity="0.6"/>
  <circle cx="84" cy="78" r="3" style="fill: var(--color-accent)"/>
  <circle cx="93" cy="78" r="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <circle cx="102" cy="78" r="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="140" y="35" width="30" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="145" y="38" width="20" height="4" rx="2" style="fill: var(--color-surface)"/>
</svg>`,

'Segmented Tour Paths': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="60" y="18" width="80" height="10" rx="3" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="70" y="21" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="20" y="38" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.12" stroke="var(--color-accent)" stroke-width="1.5"/>
  <rect x="28" y="44" width="34" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="28" y="53" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="45" cy="63" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="76" y="38" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.12" stroke="var(--color-accent)" stroke-width="1.5"/>
  <rect x="84" y="44" width="34" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="84" y="53" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="101" cy="63" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="132" y="38" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.12" stroke="var(--color-accent)" stroke-width="1.5"/>
  <rect x="140" y="44" width="34" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="140" y="53" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="157" cy="63" r="3" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="70" y="82" width="60" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="80" y="86" width="40" height="4" rx="2" style="fill: var(--color-surface)"/>
</svg>`,

'Delayed Tour Trigger': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="25" width="60" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="35" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="20" y="43" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="140" cy="55" r="18" style="stroke: var(--color-accent); fill: none" stroke-width="2" stroke-dasharray="4 3"/>
  <line x1="140" y1="45" x2="140" y2="55" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <line x1="140" y1="55" x2="149" y2="59" style="stroke: var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
  <rect x="110" y="80" width="60" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.15" stroke="var(--color-accent)" stroke-width="1"/>
  <rect x="118" y="84" width="35" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="118" y="89" width="25" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
</svg>`,

'Tour Resume & Replay': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="70" height="8" rx="3" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="33" cy="46" r="8" style="fill: var(--color-accent)" opacity="0.2"/>
  <path d="M30 43 L37 46 L30 49Z" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="48" y="42" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="48" y="48" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="120" y="70" width="60" height="28" rx="4" style="fill: var(--color-accent)" opacity="0.1" stroke="var(--color-accent)" stroke-width="1"/>
  <rect x="128" y="76" width="44" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="128" y="84" width="20" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="152" y="84" width="20" height="8" rx="3" style="fill: var(--color-text)" opacity="0.12"/>
</svg>`,

'Guided Setup Wizard': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="55" cy="24" r="8" style="fill: var(--color-accent)"/>
  <rect x="53" y="22" width="4" height="4" rx="2" style="fill: var(--color-surface)"/>
  <line x1="63" y1="24" x2="87" y2="24" style="stroke: var(--color-accent)" stroke-width="2"/>
  <circle cx="95" cy="24" r="8" style="fill: var(--color-accent)"/>
  <rect x="93" y="22" width="4" height="4" rx="2" style="fill: var(--color-surface)"/>
  <line x1="103" y1="24" x2="127" y2="24" style="stroke: var(--color-text)" stroke-width="2" opacity="0.2"/>
  <circle cx="135" cy="24" r="8" style="stroke: var(--color-text)" stroke-width="1.5" fill="none" opacity="0.2"/>
  <rect x="30" y="42" width="140" height="8" rx="3" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="30" y="58" width="140" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="38" y="64" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="110" y="88" width="60" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="120" y="92" width="40" height="4" rx="2" style="fill: var(--color-surface)"/>
  <rect x="30" y="88" width="40" height="12" rx="4" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="38" y="92" width="24" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
</svg>`,

'Spotlight Coachmark': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="60" y="40" width="80" height="24" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="2"/>
  <rect x="68" y="46" width="50" height="5" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="68" y="54" width="36" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="55" y="70" width="90" height="30" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <path d="M100 70 L95 64 L105 64Z" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="62" y="76" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="62" y="84" width="45" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="110" y="88" width="28" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
</svg>`,

'Tooltip Hotspot': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="25" width="70" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="40" width="160" height="30" rx="4" style="fill: var(--color-text)" opacity="0.05" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="28" y="48" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="28" y="56" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="155" cy="55" r="5" style="fill: var(--color-accent)"/>
  <circle cx="155" cy="55" r="9" style="stroke: var(--color-accent); fill: none" stroke-width="1" opacity="0.4"/>
  <circle cx="155" cy="55" r="13" style="stroke: var(--color-accent); fill: none" stroke-width="0.5" opacity="0.2"/>
  <rect x="105" y="22" width="70" height="22" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1"/>
  <path d="M150 44 L155 50 L160 44" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1"/>
  <rect x="112" y="27" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="112" y="34" width="35" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
</svg>`,

'Feature Callout Banner': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="26" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="20" y="20" width="3" height="26" rx="1.5" style="fill: var(--color-accent)"/>
  <circle cx="34" cy="33" r="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="33" y="31" width="2" height="4" rx="1" style="fill: var(--color-accent)"/>
  <rect x="44" y="27" width="80" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="44" y="35" width="50" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="150" y="28" width="22" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="20" y="56" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="66" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="76" width="120" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="86" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
</svg>`,

'Contextual Tip': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="40" rx="4" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="28" y="28" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="28" y="38" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="28" y="48" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="20" y="68" width="130" height="24" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke="var(--color-accent)" stroke-width="1"/>
  <circle cx="32" cy="80" r="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="30" y="78" width="4" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="42" y="74" width="90" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="42" y="82" width="50" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="110" y="76" width="30" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.5"/>
</svg>`,

'Beacon Pulse Animation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="18" rx="6" style="fill: var(--color-text)" opacity="0.05"/>
  <rect x="20" y="16" width="30" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="58" y="16" width="25" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="91" y="16" width="35" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="133" cy="18" r="4" style="fill: var(--color-accent)"/>
  <circle cx="133" cy="18" r="7" style="stroke: var(--color-accent); fill: none" stroke-width="1" opacity="0.5"/>
  <circle cx="133" cy="18" r="10" style="stroke: var(--color-accent); fill: none" stroke-width="0.5" opacity="0.25"/>
  <rect x="20" y="38" width="100" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="20" y="50" width="160" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="60" width="140" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="74" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="20" y="86" width="160" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
</svg>`,

'Onboarding Checklist': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="18" width="80" height="6" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="20" y="30" width="160" height="5" rx="2.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="30" width="100" height="5" rx="2.5" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="20" y="44" width="12" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <path d="M23 50 L26 53 L30 47" style="stroke: var(--color-surface)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <rect x="38" y="46" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2" text-decoration="line-through"/>
  <rect x="20" y="62" width="12" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <path d="M23 68 L26 71 L30 65" style="stroke: var(--color-surface)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <rect x="38" y="64" width="70" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="80" width="12" height="12" rx="3" style="stroke: var(--color-border)" stroke-width="1" fill="none"/>
  <rect x="38" y="82" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="140" y="82" width="36" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="146" y="85" width="24" height="4" rx="2" style="fill: var(--color-surface)"/>
</svg>`,

'Progress Milestone Bar': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="40" width="140" height="6" rx="3" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="30" y="40" width="90" height="6" rx="3" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="30" cy="43" r="8" style="fill: var(--color-accent)"/>
  <path d="M27 43 L29 45 L33 41" style="stroke: var(--color-surface)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <circle cx="75" cy="43" r="8" style="fill: var(--color-accent)"/>
  <path d="M72 43 L74 45 L78 41" style="stroke: var(--color-surface)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <circle cx="120" cy="43" r="8" style="fill: var(--color-accent)"/>
  <rect x="118" y="41" width="4" height="4" rx="2" style="fill: var(--color-surface)"/>
  <circle cx="170" cy="43" r="8" style="stroke: var(--color-text)" stroke-width="1" fill="none" opacity="0.2"/>
  <rect x="20" y="60" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="63" y="60" width="24" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="108" y="60" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="157" y="60" width="32" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
</svg>`,

'Gamified Task Completion': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="100" cy="42" r="20" style="fill: var(--color-accent)" opacity="0.12"/>
  <path d="M92 42 L96 36 L100 42 L104 36 L108 42 L104 48 L100 42 L96 48Z" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="60" y="68" width="80" height="6" rx="3" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="60" y="68" width="52" height="6" rx="3" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="70" y="80" width="60" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="85" y="90" width="30" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
</svg>`,

'Persistent Sidebar Checklist': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="130" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="22" width="60" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="34" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="44" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="148" y="10" width="42" height="100" rx="6" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-accent)" stroke-width="1"/>
  <rect x="153" y="20" width="32" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="153" y="30" width="32" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="153" y="30" width="22" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="153" y="40" width="8" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="164" y="42" width="18" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="153" y="52" width="8" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="164" y="54" width="18" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="153" y="64" width="8" height="8" rx="2" style="stroke: var(--color-border); fill: none" stroke-width="1"/>
  <rect x="164" y="66" width="18" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
</svg>`,

'Quick Win Task': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="24" width="120" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="50" y="28" width="80" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="40" y="46" width="120" height="22" rx="4" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="48" y="53" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <line x1="48" y1="61" x2="128" y2="61" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="70" y="76" width="60" height="14" rx="5" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="82" y="80" width="36" height="5" rx="2" style="fill: var(--color-surface)"/>
  <path d="M100 98 L96 94 L104 94Z" style="fill: var(--color-accent)" opacity="0.3"/>
</svg>`,

'What\'s New Modal': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="35" y="18" width="130" height="86" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="45" y="26" width="110" height="35" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="60" y="36" width="80" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="70" y="46" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="45" y="68" width="70" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="45" y="76" width="55" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="85" cy="90" r="3" style="fill: var(--color-accent)"/>
  <circle cx="95" cy="90" r="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <circle cx="105" cy="90" r="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="150" y="22" width="10" height="10" rx="5" style="fill: var(--color-text)" opacity="0.1"/>
  <line x1="153" y1="25" x2="157" y2="29" style="stroke: var(--color-text)" stroke-width="1.5" opacity="0.3"/>
  <line x1="157" y1="25" x2="153" y2="29" style="stroke: var(--color-text)" stroke-width="1.5" opacity="0.3"/>
</svg>`,

'Changelog Feed': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="18" width="60" height="7" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="20" y="32" width="30" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="56" y="32" width="18" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="20" y="40" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="20" y="48" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <line x1="20" y1="58" x2="180" y2="58" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="20" y="64" width="30" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="56" y="64" width="28" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.25"/>
  <rect x="90" y="64" width="20" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="20" y="72" width="120" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="20" y="80" width="90" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.08"/>
  <line x1="20" y1="90" x2="180" y2="90" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="20" y="96" width="30" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="56" y="96" width="22" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
</svg>`,

'In-App Release Banner': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="24" rx="6" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="10" y="28" width="180" height="6" style="fill: var(--color-surface)"/>
  <circle cx="26" cy="22" r="6" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="38" y="18" width="100" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="38" y="25" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="160" y="18" width="20" height="8" rx="3" style="fill: var(--color-text)" opacity="0.08"/>
  <line x1="166" y1="20" x2="174" y2="24" style="stroke: var(--color-text)" stroke-width="1" opacity="0.2"/>
  <line x1="174" y1="20" x2="166" y2="24" style="stroke: var(--color-text)" stroke-width="1" opacity="0.2"/>
  <rect x="20" y="44" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="20" y="56" width="160" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="66" width="140" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="76" width="160" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
</svg>`,

'Announcement Badge': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="40" height="100" rx="6" style="fill: var(--color-text)" opacity="0.03"/>
  <line x1="50" y1="10" x2="50" y2="110" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="16" y="24" width="28" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="16" y="36" width="24" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="16" y="48" width="26" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="44" cy="49" r="4" style="fill: var(--color-accent)"/>
  <rect x="43" y="48" width="2" height="2" rx="1" style="fill: var(--color-surface)"/>
  <rect x="16" y="60" width="20" height="5" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="60" y="22" width="80" height="6" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="60" y="36" width="120" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="60" y="46" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
</svg>`,

'Release Notes Page': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="18" width="70" height="7" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="20" y="32" width="35" height="10" rx="4" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="24" y="35" width="27" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="60" y="35" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="48" width="18" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="42" y="49" width="100" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="57" width="26" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="50" y="58" width="80" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <line x1="20" y1="68" x2="180" y2="68" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="20" y="74" width="35" height="10" rx="4" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="24" y="77" width="27" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="60" y="77" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="90" width="22" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="46" y="91" width="90" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
</svg>`,

'Empty State Onboarding': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="65" y="22" width="70" height="40" rx="4" style="fill: var(--color-accent)" opacity="0.06"/>
  <rect x="80" y="30" width="40" height="24" rx="3" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="88" y="36" width="24" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="92" y="42" width="16" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="60" y="68" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="55" y="78" width="90" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="70" y="90" width="60" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="80" y="94" width="40" height="4" rx="2" style="fill: var(--color-surface)"/>
</svg>`,

'Interactive Demo Sandbox': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="16" rx="6" style="fill: var(--color-accent)" opacity="0.12"/>
  <rect x="10" y="20" width="180" height="6" style="fill: var(--color-surface)"/>
  <rect x="20" y="14" width="50" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="150" y="13" width="30" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="20" y="34" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border-subtle, var(--color-border))" stroke-width="0.5"/>
  <rect x="28" y="40" width="34" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="28" y="48" width="26" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="28" y="54" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="78" y="34" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border-subtle, var(--color-border))" stroke-width="0.5"/>
  <rect x="86" y="40" width="34" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="86" y="48" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="136" y="34" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke="var(--color-border-subtle, var(--color-border))" stroke-width="0.5"/>
  <rect x="144" y="40" width="34" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="144" y="48" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="20" y="72" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="82" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
</svg>`,

'Video Walkthrough': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="20" width="150" height="70" rx="4" style="fill: var(--color-text)" opacity="0.06"/>
  <circle cx="100" cy="52" r="16" style="fill: var(--color-accent)" opacity="0.8"/>
  <path d="M95 44 L110 52 L95 60Z" style="fill: var(--color-surface)"/>
  <rect x="25" y="80" width="150" height="4" rx="2" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="25" y="80" width="60" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <circle cx="85" cy="82" r="3" style="fill: var(--color-accent)"/>
  <rect x="25" y="96" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="140" y="96" width="35" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
</svg>`,

'Inline Help Panel': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="120" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="22" width="60" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="34" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="20" y="44" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="138" y="10" width="52" height="100" rx="6" style="fill: var(--color-accent)" opacity="0.05" stroke="var(--color-accent)" stroke-width="1"/>
  <rect x="144" y="20" width="40" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="144" y="32" width="40" height="18" rx="3" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="148" y="36" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="148" y="42" width="24" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="144" y="56" width="40" height="18" rx="3" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="148" y="60" width="32" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="148" y="66" width="26" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="144" y="80" width="40" height="18" rx="3" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="148" y="84" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="148" y="90" width="22" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
</svg>`,

'Sample Data Seeding': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="160" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="28" y="24" width="80" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="140" y="23" width="32" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="20" y="42" width="75" height="22" rx="4" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <rect x="28" y="48" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="28" y="56" width="30" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="105" y="42" width="75" height="22" rx="4" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <rect x="113" y="48" width="45" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="113" y="56" width="35" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="20" y="72" width="75" height="22" rx="4" style="fill: var(--color-text)" opacity="0.04" stroke="var(--color-border)" stroke-width="0.5" stroke-dasharray="3 2"/>
  <rect x="28" y="78" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="28" y="86" width="28" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
</svg>`,

'Skip & Dismiss Behavior': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="40" y="25" width="120" height="60" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="52" y="34" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="52" y="44" width="60" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="52" y="56" width="45" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="58" y="59" width="33" height="4" rx="2" style="fill: var(--color-surface)"/>
  <rect x="104" y="56" width="45" height="10" rx="3" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="110" y="59" width="33" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="60" y="72" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
</svg>`,

'Completion Persistence': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="20" width="70" height="40" rx="4" style="fill: var(--color-text)" opacity="0.03" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="28" y="26" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="30" cy="38" r="4" style="fill: var(--color-accent)" opacity="0.6"/>
  <circle cx="45" cy="38" r="4" style="fill: var(--color-accent)" opacity="0.6"/>
  <circle cx="60" cy="38" r="4" style="stroke: var(--color-border)" fill="none" stroke-width="1"/>
  <circle cx="75" cy="38" r="4" style="stroke: var(--color-border)" fill="none" stroke-width="1"/>
  <rect x="28" y="48" width="50" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <line x1="100" y1="35" x2="110" y2="35" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="2 2"/>
  <rect x="115" y="20" width="70" height="40" rx="4" style="fill: var(--color-text)" opacity="0.03" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="123" y="26" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <circle cx="125" cy="38" r="4" style="fill: var(--color-accent)" opacity="0.6"/>
  <circle cx="140" cy="38" r="4" style="fill: var(--color-accent)" opacity="0.6"/>
  <circle cx="155" cy="38" r="4" style="stroke: var(--color-border)" fill="none" stroke-width="1"/>
  <circle cx="170" cy="38" r="4" style="stroke: var(--color-border)" fill="none" stroke-width="1"/>
  <rect x="123" y="48" width="50" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="60" y="72" width="80" height="24" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke="var(--color-accent)" stroke-width="0.5"/>
  <rect x="70" y="78" width="60" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="70" y="86" width="40" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
</svg>`,

'Re-Engagement Tour': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="40" y="22" width="120" height="70" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="30" width="90" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="60" y="42" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="65" y="50" width="70" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <rect x="50" y="60" width="100" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="58" y="64" width="60" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="60" y="78" width="80" height="10" rx="4" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="72" y="81" width="56" height="4" rx="2" style="fill: var(--color-surface)"/>
</svg>`,

'Progressive Onboarding': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="22" width="50" height="28" rx="4" style="fill: var(--color-accent)" opacity="0.15" stroke="var(--color-accent)" stroke-width="1"/>
  <rect x="28" y="28" width="34" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="28" y="36" width="26" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="28" y="42" width="20" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.15"/>
  <path d="M78 36 L88 36 M85 33 L88 36 L85 39" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.5"/>
  <rect x="95" y="22" width="50" height="28" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke="var(--color-accent)" stroke-width="1" stroke-dasharray="3 2"/>
  <rect x="103" y="28" width="34" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="103" y="36" width="26" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.1"/>
  <path d="M153 36 L163 36 M160 33 L163 36 L160 39" style="stroke: var(--color-text)" stroke-width="1.5" fill="none" opacity="0.2"/>
  <rect x="20" y="62" width="160" height="4" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="20" y="62" width="55" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="20" y="74" width="90" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke="var(--color-accent)" stroke-width="0.5"/>
  <circle cx="32" cy="84" r="4" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="40" y="80" width="55" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="40" y="86" width="35" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.12"/>
</svg>`,

'Onboarding Analytics Dashboard': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="18" width="60" height="6" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="32" width="75" height="40" rx="4" style="fill: var(--color-text)" opacity="0.03" stroke="var(--color-border)" stroke-width="0.5"/>
  <polyline points="28,62 42,52 56,56 70,42 84,48" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none"/>
  <rect x="105" y="32" width="75" height="40" rx="4" style="fill: var(--color-text)" opacity="0.03" stroke="var(--color-border)" stroke-width="0.5"/>
  <rect x="115" y="40" width="8" height="24" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="128" y="48" width="8" height="16" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="141" y="44" width="8" height="20" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="154" y="52" width="8" height="12" rx="2" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="20" y="80" width="50" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="80" y="80" width="40" height="5" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="130" y="80" width="45" height="5" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="20" y="92" width="160" height="3" rx="1.5" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="20" y="92" width="110" height="3" rx="1.5" style="fill: var(--color-accent)" opacity="0.25"/>
</svg>`,

};
