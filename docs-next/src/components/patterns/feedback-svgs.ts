/** SVG illustrations for "Feedback & Status" patterns */
export const feedbackSvgs: Record<string, string> = {

'Alert': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="12" y="10" width="176" height="40" rx="8" style="fill: var(--color-blue-dim); stroke: var(--color-blue)" stroke-width="1"/>
  <circle cx="30" cy="30" r="9" style="stroke: var(--color-blue); fill: none" stroke-width="1.5"/>
  <text x="27" y="34" style="fill: var(--color-blue); font-size: 11px; font-weight: 700; font-family: var(--font-sans)">i</text>
  <text x="46" y="28" style="fill: var(--color-blue); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Info: Your trial expires soon</text>
  <text x="46" y="40" style="fill: var(--color-blue); font-size: 9px; font-family: var(--font-sans)">Upgrade to keep access</text>
  <rect x="12" y="58" width="176" height="24" rx="6" style="fill: var(--color-red-dim); stroke: var(--color-red)" stroke-width="1"/>
  <text x="26" y="74" style="fill: var(--color-red); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Error: Invalid email address</text>
  <rect x="12" y="90" width="176" height="24" rx="6" style="fill: var(--color-green-dim); stroke: var(--color-green)" stroke-width="1"/>
  <text x="26" y="106" style="fill: var(--color-green); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Success: Profile updated</text>
</svg>`,

'Alert Dialog': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-bg); opacity: 0.5"/>
  <rect x="24" y="16" width="152" height="88" rx="10" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="48" cy="42" r="10" style="fill: var(--color-amber-dim)"/>
  <text x="44" y="46" style="fill: var(--color-amber); font-size: 13px; font-weight: 700; font-family: var(--font-sans)">!</text>
  <text x="64" y="46" style="fill: var(--color-text); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">Are you sure?</text>
  <text x="40" y="64" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">This action cannot be undone.</text>
  <rect x="40" y="78" width="60" height="20" rx="5" style="stroke: var(--color-border); fill: var(--color-surface-2)" stroke-width="1"/>
  <text x="56" y="92" style="fill: var(--color-text-secondary); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Cancel</text>
  <rect x="106" y="78" width="60" height="20" rx="5" style="fill: var(--color-red)"/>
  <text x="122" y="92" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Delete</text>
</svg>`,

'Sonner (Toast)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="4" width="184" height="112" rx="8" style="fill: var(--color-surface); stroke: var(--color-border-subtle)" stroke-width="1" opacity="0.3"/>
  <rect x="40" y="8" width="148" height="46" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="60" cy="26" r="10" style="fill: var(--color-green-dim)"/>
  <polyline points="55,26 59,30 66,22" style="stroke: var(--color-green); fill: none" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="76" y="24" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Changes saved</text>
  <text x="76" y="38" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Your profile was updated.</text>
  <rect x="44" y="46" width="140" height="3" rx="1.5" style="fill: var(--color-surface-2)"/>
  <rect x="44" y="46" width="90" height="3" rx="1.5" style="fill: var(--color-green)"/>
  <rect x="50" y="62" width="140" height="42" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" opacity="0.6"/>
  <text x="66" y="80" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans); opacity: 0.6">Email sent successfully</text>
  <rect x="58" y="108" width="128" height="8" rx="4" style="fill: var(--color-surface-2); opacity: 0.3"/>
</svg>`,

'Empty State': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="16" y="6" width="168" height="108" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="6 4"/>
  <circle cx="100" cy="38" r="16" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5"/>
  <rect x="92" y="30" width="16" height="16" rx="2" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.2"/>
  <line x1="96" y1="50" x2="104" y2="42" style="stroke: var(--color-text-muted)" stroke-width="1.2"/>
  <text x="100" y="68" text-anchor="middle" style="fill: var(--color-text); font-size: 11px; font-weight: 600; font-family: var(--font-sans)">No projects yet</text>
  <text x="100" y="82" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Create your first project to get started.</text>
  <rect x="64" y="92" width="72" height="20" rx="5" style="fill: var(--color-accent)"/>
  <text x="100" y="106" text-anchor="middle" style="fill: #fff; font-size: 9px; font-weight: 600; font-family: var(--font-sans)">New Project</text>
</svg>`,

};
