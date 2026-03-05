/** SVG illustrations for Form Patterns */
export const formPatternSvgs: Record<string, string> = {

'Inline Validation': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">john@example.com</text>
  <circle cx="168" cy="24" r="7" style="fill: hsl(142, 71%, 45%)"/>
  <text x="168" y="28" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">&#x2713;</text>
  <rect x="20" y="50" width="160" height="28" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="68" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">bad-email</text>
  <text x="20" y="94" style="fill: hsl(0, 84%, 60%); font-size: 9px; font-family: var(--font-sans)">Enter a valid email address</text>
</svg>`,

'Error Summary': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="55" rx="6" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="28" style="fill: hsl(0, 84%, 60%); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">Please fix 2 errors:</text>
  <text x="32" y="44" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">&#x2192; Email is required</text>
  <text x="32" y="58" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">&#x2192; Password too short</text>
  <rect x="20" y="75" width="160" height="22" rx="5" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="20" y="100" width="160" height="14" rx="3" style="fill: var(--color-surface-2)"/>
</svg>`,

'Focus on First Error': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="24" rx="5" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="2"/>
  <rect x="24" y="19" width="152" height="16" rx="3" style="stroke: var(--color-accent); fill: none" stroke-width="1.5" stroke-dasharray="3 2"/>
  <text x="32" y="31" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">Email &#x2190; focus here</text>
  <rect x="20" y="50" width="160" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="20" y="85" width="160" height="24" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
</svg>`,

'Autocomplete Tokens': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">John Doe</text>
  <rect x="130" y="14" width="45" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="152" y="26" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">autofill</text>
  <rect x="20" y="48" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="66" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">john@example.com</text>
  <rect x="130" y="52" width="45" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="152" y="64" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">autofill</text>
  <rect x="20" y="86" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="104" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">+1 555-123-4567</text>
  <rect x="130" y="90" width="45" height="16" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="152" y="102" text-anchor="middle" style="fill: var(--color-accent); font-size: 8px; font-weight: 600; font-family: var(--font-sans)">autofill</text>
</svg>`,

'Address Autocomplete': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">123 Main St</text>
  <rect x="20" y="42" width="160" height="60" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="26" y="48" width="148" height="20" rx="3" style="fill: var(--color-accent-bg)"/>
  <text x="36" y="62" style="fill: var(--color-accent); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">123 Main St, New York, NY</text>
  <text x="36" y="82" style="fill: var(--color-text-secondary); font-size: 9px; font-family: var(--font-sans)">123 Main St, Boston, MA</text>
</svg>`,

'Password Strength': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="28" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;</text>
  <rect x="20" y="46" width="40" height="6" rx="3" style="fill: hsl(0, 84%, 60%)"/>
  <rect x="64" y="46" width="40" height="6" rx="3" style="fill: hsl(38, 92%, 50%)"/>
  <rect x="108" y="46" width="40" height="6" rx="3" style="fill: hsl(142, 71%, 45%)"/>
  <rect x="152" y="46" width="28" height="6" rx="3" style="fill: var(--color-surface-2)"/>
  <text x="20" y="68" style="fill: hsl(142, 71%, 45%); font-size: 9px; font-family: var(--font-sans)">&#x2713; 8+ characters</text>
  <text x="20" y="82" style="fill: hsl(142, 71%, 45%); font-size: 9px; font-family: var(--font-sans)">&#x2713; One uppercase</text>
  <text x="20" y="96" style="fill: hsl(0, 84%, 60%); font-size: 9px; font-family: var(--font-sans)">&#x2717; One number</text>
</svg>`,

'Password Reveal': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="160" height="32" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="40" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;</text>
  <circle cx="162" cy="36" r="8" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5"/>
  <circle cx="162" cy="36" r="3" style="fill: var(--color-text-muted)"/>
  <rect x="20" y="68" width="160" height="32" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="88" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">MyP@ss123</text>
  <circle cx="162" cy="84" r="8" style="stroke: var(--color-accent); fill: none" stroke-width="1.5"/>
  <line x1="155" y1="84" x2="169" y2="84" style="stroke: var(--color-accent)" stroke-width="1.5"/>
</svg>`,

'Character Counter': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="60" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="30" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">This is my bio text</text>
  <text x="32" y="46" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">with multiple lines</text>
  <text x="152" y="82" text-anchor="end" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">42/280</text>
  <rect x="20" y="90" width="160" height="4" rx="2" style="fill: var(--color-surface-2)"/>
  <rect x="20" y="90" width="24" height="4" rx="2" style="fill: var(--color-accent)"/>
</svg>`,

'Input Masking': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="25" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">User types:</text>
  <rect x="20" y="30" width="160" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="48" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">5551234567</text>
  <text x="20" y="78" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">On blur:</text>
  <rect x="20" y="82" width="160" height="28" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="32" y="100" style="fill: var(--color-text); font-size: 11px; font-family: var(--font-sans)">(555) 123-4567</text>
</svg>`,

'Multi-Step Form': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="45" cy="20" r="12" style="fill: var(--color-accent)"/>
  <text x="45" y="24" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">1</text>
  <line x1="57" y1="20" x2="83" y2="20" style="stroke: var(--color-accent)" stroke-width="2"/>
  <circle cx="95" cy="20" r="12" style="fill: var(--color-accent)"/>
  <text x="95" y="24" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">2</text>
  <line x1="107" y1="20" x2="133" y2="20" style="stroke: var(--color-border)" stroke-width="2"/>
  <circle cx="145" cy="20" r="12" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="145" y="24" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-weight: 700; font-family: var(--font-sans)">3</text>
  <rect x="30" y="42" width="130" height="20" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="30" y="68" width="130" height="20" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <rect x="100" y="96" width="60" height="22" rx="5" style="fill: var(--color-accent)"/>
  <text x="130" y="111" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Next &#x2192;</text>
</svg>`,

'Conditional Fields': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="26" rx="5" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="28" y="16" width="14" height="14" rx="3" style="fill: var(--color-accent)"/>
  <text x="28" y="27" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)"> &#x2713;</text>
  <text x="48" y="27" style="fill: var(--color-text); font-size: 10px; font-family: var(--font-sans)">Ship to different address</text>
  <rect x="35" y="44" width="145" height="22" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="44" y="59" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">Street address</text>
  <rect x="35" y="70" width="145" height="22" rx="4" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1"/>
  <text x="44" y="85" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">City, State, ZIP</text>
  <text x="35" y="108" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">&#x21B3; shown when checkbox is checked</text>
</svg>`,

'Fieldset Grouping': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="12" width="170" height="48" rx="6" style="stroke: var(--color-border); fill: none" stroke-width="1.5"/>
  <rect x="25" y="5" width="70" height="14" rx="3" style="fill: var(--color-surface)"/>
  <text x="30" y="15" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Personal Info</text>
  <rect x="25" y="24" width="150" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="25" y="42" width="150" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="15" y="70" width="170" height="44" rx="6" style="stroke: var(--color-border); fill: none" stroke-width="1.5"/>
  <rect x="25" y="63" width="50" height="14" rx="3" style="fill: var(--color-surface)"/>
  <text x="30" y="73" style="fill: var(--color-accent); font-size: 9px; font-weight: 700; font-family: var(--font-sans)">Address</text>
  <rect x="25" y="82" width="150" height="12" rx="3" style="fill: var(--color-surface-2)"/>
  <rect x="25" y="98" width="150" height="12" rx="3" style="fill: var(--color-surface-2)"/>
</svg>`,

'Required/Optional Marking': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="20" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Email <tspan style="fill: hsl(0, 84%, 60%)">*</tspan></text>
  <rect x="20" y="25" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="20" y="66" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Name <tspan style="fill: hsl(0, 84%, 60%)">*</tspan></text>
  <rect x="20" y="71" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="20" y="110" style="fill: var(--color-text); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Company <tspan style="fill: var(--color-text-muted); font-size: 8px">(optional)</tspan></text>
</svg>`,

'Auto-Save Draft': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="60" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="28" y="20" width="120" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="28" y="34" width="90" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="28" y="48" width="60" height="8" rx="2" style="fill: var(--color-accent-bg)"/>
  <rect x="60" y="82" width="80" height="24" rx="6" style="fill: var(--color-accent-bg); stroke: var(--color-accent)" stroke-width="1"/>
  <text x="100" y="98" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">&#x2713; Saved</text>
</svg>`,

'Form Recovery': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="30" rx="6" style="fill: hsl(38, 92%, 50%)" opacity="0.15"/>
  <rect x="20" y="10" width="160" height="30" rx="6" style="stroke: hsl(38, 92%, 50%); fill: none" stroke-width="1.5"/>
  <text x="100" y="29" text-anchor="middle" style="fill: hsl(38, 92%, 50%); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Draft recovered. Continue or discard?</text>
  <rect x="20" y="50" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="65" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">john@example.com</text>
  <rect x="20" y="78" width="160" height="22" rx="4" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1"/>
  <text x="28" y="93" style="fill: var(--color-text); font-size: 9px; font-family: var(--font-sans)">My project description...</text>
</svg>`,

};
