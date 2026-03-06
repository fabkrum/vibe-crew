/** SVG illustrations for Authentication Patterns */
export const authPatternSvgs: Record<string, string> = {

'Login Form': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="8" width="120" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="18" width="90" height="8" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="55" y="34" width="30" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="55" y="42" width="90" height="14" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="60" y="47" width="50" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="55" y="62" width="30" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="55" y="70" width="90" height="14" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="63" cy="77" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <circle cx="70" cy="77" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <circle cx="77" cy="77" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <circle cx="84" cy="77" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <circle cx="91" cy="77" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="55" y="90" width="90" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="82" y="95" width="36" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Social OAuth Login': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="8" width="120" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="18" width="90" height="14" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
  <circle cx="75" cy="25" r="4" style="fill: var(--color-text-muted)" opacity="0.6"/>
  <rect x="82" y="23" width="50" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="55" y="36" width="90" height="14" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
  <circle cx="75" cy="43" r="4" style="fill: var(--color-text-muted)" opacity="0.6"/>
  <rect x="82" y="41" width="50" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="55" y="54" width="90" height="14" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
  <circle cx="75" cy="61" r="4" style="fill: var(--color-text-muted)" opacity="0.6"/>
  <rect x="82" y="59" width="50" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <line x1="55" y1="76" x2="145" y2="76" style="stroke: var(--color-border)" stroke-width="1"/>
  <rect x="90" y="72" width="20" height="8" rx="2" style="fill: var(--color-surface)"/>
  <text x="95" y="78" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">or</text>
  <rect x="55" y="84" width="90" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="60" y="88" width="40" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="55" y="100" width="90" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
</svg>`,

'Single Sign-On (SSO)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="20" width="75" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="30" width="55" height="6" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="20" y="42" width="55" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="46" width="35" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="20" y="60" width="55" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="35" y="63" width="25" height="4" rx="1" fill="white" opacity="0.8"/>
  <text x="23" y="82" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">SSO detected</text>
  <path d="M95 60 L115 60" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="3 2"/>
  <polygon points="115,57 121,60 115,63" style="fill: var(--color-accent)"/>
  <rect x="125" y="20" width="65" height="80" rx="6" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <rect x="135" y="35" width="45" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="135" y="50" width="45" height="10" rx="2" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="135" y="66" width="45" height="10" rx="2" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="135" y="82" width="45" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <text x="142" y="89" style="fill: white; font-size: 5px; font-family: var(--font-sans)">Sign In</text>
</svg>`,

'Remember Me': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="15" width="120" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="30" width="90" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="48" width="90" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="66" width="10" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
  <path d="M58 71 L60 73 L63 69" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="70" y="68" width="50" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="55" y="82" width="90" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="82" y="87" width="36" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Login Error Handling': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="8" width="120" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="16" width="100" height="18" rx="3" style="fill: #fee2e2; stroke: #fca5a5" stroke-width="1"/>
  <circle cx="60" cy="25" r="4" fill="#ef4444" opacity="0.7"/>
  <text x="58" y="27" fill="white" font-size="6" font-weight="bold" font-family="var(--font-sans)">!</text>
  <rect x="68" y="21" width="70" height="4" rx="1" fill="#ef4444" opacity="0.6"/>
  <rect x="68" y="27" width="50" height="3" rx="1" fill="#ef4444" opacity="0.4"/>
  <rect x="50" y="42" width="100" height="12" rx="3" style="fill: var(--color-surface); stroke: #fca5a5" stroke-width="1"/>
  <rect x="50" y="60" width="100" height="12" rx="3" style="fill: var(--color-surface); stroke: #fca5a5" stroke-width="1"/>
  <rect x="50" y="80" width="100" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="50" y="96" width="60" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
</svg>`,

'Signup Form': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="5" width="120" height="110" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="14" width="70" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="55" y="26" width="90" height="11" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="42" width="90" height="11" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="56" width="90" height="4" rx="2" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="55" y="56" width="60" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="55" y="64" width="6" height="6" rx="1" style="fill: #22c55e" opacity="0.6"/>
  <rect x="64" y="65" width="50" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="55" y="73" width="6" height="6" rx="1" style="fill: #22c55e" opacity="0.6"/>
  <rect x="64" y="74" width="40" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="55" y="82" width="6" height="6" rx="1" style="fill: var(--color-border)" opacity="0.4"/>
  <rect x="64" y="83" width="45" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="55" y="94" width="90" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="77" y="98" width="46" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Email Verification': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="15" width="120" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="70" y="25" width="60" height="8" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="75" y="40" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <path d="M80 48 L100 58 L120 48" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.6"/>
  <rect x="88" y="52" width="24" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="92" y="58" width="16" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="70" y="78" width="60" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="80" y="88" width="40" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="88" y="95" style="fill: var(--color-accent); font-size: 5px; font-family: var(--font-sans)">Resend</text>
</svg>`,

'Progressive Registration': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="15" width="150" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="25" width="120" height="4" rx="2" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="40" y="25" width="60" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.7"/>
  <circle cx="60" cy="27" r="6" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="100" cy="27" r="6" style="fill: var(--color-accent)" opacity="0.7"/>
  <text x="98" y="29" style="fill: white; font-size: 6px; font-family: var(--font-sans)">2</text>
  <circle cx="140" cy="27" r="6" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="40" y="40" width="50" height="6" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="40" y="52" width="120" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="70" width="120" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="40" y="88" width="55" height="10" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="105" y="88" width="55" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
</svg>`,

'Terms & Consent': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="15" width="120" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="25" width="70" height="7" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="55" y="40" width="10" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
  <path d="M58 45 L60 47 L63 43" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="70" y="42" width="75" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="70" y="48" width="30" height="3" rx="1" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="55" y="58" width="10" height="10" rx="2" style="fill: var(--color-border)" opacity="0.3" stroke-width="1" style="stroke: var(--color-border)"/>
  <rect x="70" y="60" width="60" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="55" y="76" width="10" height="10" rx="2" style="fill: var(--color-border)" opacity="0.3" stroke-width="1" style="stroke: var(--color-border)"/>
  <rect x="70" y="78" width="55" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="55" y="92" width="90" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
</svg>`,

'Account Linking': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="60" cy="50" r="20" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <rect x="50" y="43" width="20" height="6" rx="2" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="48" y="52" width="24" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <circle cx="140" cy="50" r="20" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <circle cx="140" cy="45" r="7" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="132" y="55" width="16" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <path d="M82 50 L118 50" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <circle cx="100" cy="50" r="8" style="fill: var(--color-accent)" opacity="0.2"/>
  <path d="M96 50 L100 50 M100 46 L100 54" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="55" y="85" width="90" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="62" y="90" width="55" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="62" y="96" width="35" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
</svg>`,

'TOTP Authenticator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="70" height="70" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="25" width="50" height="50" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <g opacity="0.5">
    <rect x="30" y="30" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="37" y="30" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="30" y="37" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="44" y="30" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="51" y="30" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="58" y="30" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="30" y="44" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="44" y="44" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="51" y="44" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="37" y="51" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="58" y="51" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="30" y="58" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="44" y="58" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="58" y="58" width="5" height="5" style="fill: var(--color-text)"/>
    <rect x="51" y="37" width="5" height="5" style="fill: var(--color-text)"/>
  </g>
  <text x="34" y="95" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Scan QR</text>
  <rect x="105" y="25" width="80" height="70" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="115" y="35" width="60" height="8" rx="2" style="fill: var(--color-text)" opacity="0.5"/>
  <g>
    <rect x="115" y="50" width="16" height="18" rx="2" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
    <rect x="135" y="50" width="16" height="18" rx="2" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
    <rect x="155" y="50" width="16" height="18" rx="2" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
    <text x="120" y="63" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans); font-weight: 600">4</text>
    <text x="140" y="63" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans); font-weight: 600">2</text>
    <text x="160" y="63" style="fill: var(--color-accent); font-size: 10px; font-family: var(--font-sans); font-weight: 600">8</text>
  </g>
  <rect x="115" y="76" width="60" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
</svg>`,

'SMS / Email OTP': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="15" width="150" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="60" y="25" width="80" height="8" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="55" y="38" width="90" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <g>
    <rect x="45" y="52" width="22" height="26" rx="3" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
    <rect x="72" y="52" width="22" height="26" rx="3" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
    <rect x="99" y="52" width="22" height="26" rx="3" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1.5" style="stroke: var(--color-accent)"/>
    <rect x="126" y="52" width="22" height="26" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
    <text x="52" y="70" style="fill: var(--color-text); font-size: 14px; font-family: var(--font-sans); font-weight: 600">7</text>
    <text x="79" y="70" style="fill: var(--color-text); font-size: 14px; font-family: var(--font-sans); font-weight: 600">3</text>
    <line x1="106" y1="62" x2="116" y2="62" style="stroke: var(--color-accent)" stroke-width="2" opacity="0.5"/>
  </g>
  <rect x="70" y="86" width="60" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.4"/>
  <text x="70" y="100" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Resend in 28s</text>
</svg>`,

'MFA Enrollment': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="10" width="150" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="18" width="100" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="40" y="32" width="50" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <circle cx="52" cy="42" r="5" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="60" y="39" width="22" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="60" y="46" width="18" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <circle cx="82" cy="55" r="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="110" y="32" width="50" height="30" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="122" cy="42" r="5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="130" y="39" width="22" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="130" y="46" width="18" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="40" y="70" width="50" height="30" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="52" cy="80" r="5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="60" y="77" width="22" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="60" y="84" width="18" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="110" y="70" width="50" height="30" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="122" cy="80" r="5" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="130" y="77" width="22" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="130" y="84" width="18" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
</svg>`,

'Backup Recovery Codes': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="10" width="140" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="18" width="90" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <g opacity="0.6">
    <rect x="45" y="32" width="50" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
    <text x="52" y="40" style="fill: var(--color-text); font-size: 6px; font-family: monospace">a4f2-8c3e</text>
    <rect x="105" y="32" width="50" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
    <text x="112" y="40" style="fill: var(--color-text); font-size: 6px; font-family: monospace">k9m1-7b5d</text>
    <rect x="45" y="46" width="50" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
    <text x="52" y="54" style="fill: var(--color-text); font-size: 6px; font-family: monospace">p3n6-2j8f</text>
    <rect x="105" y="46" width="50" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
    <text x="112" y="54" style="fill: var(--color-text); font-size: 6px; font-family: monospace">r7t4-5h9g</text>
    <rect x="45" y="60" width="50" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
    <text x="52" y="68" style="fill: var(--color-text); font-size: 6px; font-family: monospace">w2x8-1c6v</text>
    <rect x="105" y="60" width="50" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
    <text x="112" y="68" style="fill: var(--color-text); font-size: 6px; font-family: monospace">z5y3-4d0q</text>
  </g>
  <rect x="45" y="78" width="45" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <text x="52" y="85" style="fill: white; font-size: 5px; font-family: var(--font-sans)">Copy all</text>
  <rect x="95" y="78" width="55" height="10" rx="3" style="fill: var(--color-border)" opacity="0.4"/>
  <text x="102" y="85" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Download</text>
  <rect x="45" y="94" width="110" height="10" rx="2" style="fill: #fef3c7"/>
  <text x="50" y="101" style="fill: #92400e; font-size: 5px; font-family: var(--font-sans)">Save these codes securely</text>
</svg>`,

'Magic Link': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="65" y="25" width="70" height="8" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="60" y="40" width="80" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <path d="M90 48 L100 56 L110 48" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.5"/>
  <rect x="85" y="56" width="30" height="4" rx="1" style="fill: var(--color-accent)" opacity="0.4"/>
  <rect x="90" y="62" width="20" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="55" y="78" width="90" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="70" y="88" width="60" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.3"/>
  <text x="82" y="95" style="fill: var(--color-accent); font-size: 5px; font-family: var(--font-sans)">Resend link</text>
</svg>`,

'Passkeys / WebAuthn': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="60" y="24" width="80" height="8" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <circle cx="100" cy="55" r="18" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1.5" style="stroke: var(--color-accent)" opacity="0.4"/>
  <path d="M93 55 C93 50 97 46 102 46 C107 46 111 50 111 55" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.6"/>
  <circle cx="102" cy="55" r="3" style="fill: var(--color-accent)" opacity="0.5"/>
  <line x1="102" y1="58" x2="102" y2="64" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.5"/>
  <line x1="102" y1="62" x2="106" y2="60" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.5"/>
  <rect x="60" y="80" width="80" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="72" y="85" width="56" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Biometric Authentication': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="50" y="10" width="100" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="100" cy="50" r="22" style="fill: var(--color-accent)" opacity="0.06"/>
  <circle cx="100" cy="50" r="16" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.3"/>
  <path d="M92 42 C92 38 96 34 100 34 C104 34 108 38 108 42 L108 48 C108 52 104 56 100 56 C96 56 92 52 92 48 Z" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.5"/>
  <path d="M95 46 C95 44 97 42 100 42 C103 42 105 44 105 46 L105 50 C105 52 103 54 100 54 C97 54 95 52 95 50 Z" style="fill: var(--color-accent)" opacity="0.15"/>
  <line x1="100" y1="48" x2="100" y2="52" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.5"/>
  <circle cx="100" cy="50" r="1" style="fill: var(--color-accent)" opacity="0.6"/>
  <rect x="65" y="78" width="70" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="70" y="88" width="60" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="82" y="92" width="36" height="4" rx="1" fill="white" opacity="0.8"/>
</svg>`,

'One-Time Password (Email)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="20" width="70" height="50" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <path d="M20 28 L50 44 L80 28" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.4"/>
  <text x="35" y="50" style="fill: var(--color-accent); font-size: 14px; font-family: var(--font-sans); font-weight: 700" opacity="0.7">847293</text>
  <path d="M90 50 L110 50" style="stroke: var(--color-accent)" stroke-width="1.5" stroke-dasharray="3 2"/>
  <polygon points="110,47 116,50 110,53" style="fill: var(--color-accent)"/>
  <rect x="120" y="20" width="70" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="130" y="30" width="50" height="6" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <g>
    <rect x="126" y="44" width="14" height="18" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)"/>
    <text x="130" y="57" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">8</text>
    <rect x="143" y="44" width="14" height="18" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)"/>
    <text x="147" y="57" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">4</text>
    <rect x="160" y="44" width="14" height="18" rx="2" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1" style="stroke: var(--color-accent)"/>
    <text x="164" y="57" style="fill: var(--color-accent); font-size: 9px; font-family: var(--font-sans)">7</text>
  </g>
  <rect x="130" y="72" width="50" height="8" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="130" y="86" width="50" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
</svg>`,

'Session Timeout Warning': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" opacity="0.4"/>
  <rect x="10" y="10" width="180" height="80" rx="6" fill="black" opacity="0.03"/>
  <rect x="35" y="20" width="130" height="70" rx="6" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <rect x="50" y="28" width="100" height="6" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <circle cx="100" cy="50" r="10" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" opacity="0.5"/>
  <line x1="100" y1="44" x2="100" y2="50" style="stroke: var(--color-accent)" stroke-width="1.5" opacity="0.6"/>
  <line x1="100" y1="50" x2="105" y2="53" style="stroke: var(--color-accent)" stroke-width="1" opacity="0.5"/>
  <text x="87" y="68" style="fill: var(--color-text-muted); font-size: 6px; font-family: var(--font-sans)">2:00 remaining</text>
  <rect x="50" y="74" width="40" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="100" y="74" width="50" height="10" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
</svg>`,

'Re-Authentication': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="80" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" opacity="0.3"/>
  <rect x="40" y="25" width="120" height="75" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1.5"/>
  <circle cx="100" cy="40" r="8" style="fill: var(--color-accent)" opacity="0.1" stroke-width="1.5" style="stroke: var(--color-accent)" opacity="0.4"/>
  <rect x="96" y="37" width="8" height="5" rx="1" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="94" y="42" width="12" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="55" y="55" width="90" height="5" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="55" y="65" width="90" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="63" cy="71" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <circle cx="70" cy="71" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <circle cx="77" cy="71" r="2" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="55" y="82" width="90" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="78" y="86" width="44" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Active Sessions / Device Management': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="18" width="80" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="25" y="30" width="160" height="22" rx="4" style="fill: var(--color-accent)" opacity="0.06" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <circle cx="38" cy="41" r="6" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="48" y="36" width="60" height="4" rx="1" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="48" y="43" width="40" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="148" y="37" width="28" height="8" rx="2" style="fill: #22c55e" opacity="0.2"/>
  <text x="152" y="43" style="fill: #16a34a; font-size: 5px; font-family: var(--font-sans)">Current</text>
  <rect x="25" y="56" width="160" height="22" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="38" cy="67" r="6" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="48" y="62" width="50" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="48" y="69" width="35" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="148" y="63" width="28" height="8" rx="2" style="fill: #ef4444" opacity="0.15"/>
  <text x="153" y="69" style="fill: #ef4444; font-size: 5px; font-family: var(--font-sans)">Revoke</text>
  <rect x="25" y="82" width="160" height="22" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="38" cy="93" r="6" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="48" y="88" width="55" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="48" y="95" width="30" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="148" y="89" width="28" height="8" rx="2" style="fill: #ef4444" opacity="0.15"/>
  <text x="153" y="95" style="fill: #ef4444; font-size: 5px; font-family: var(--font-sans)">Revoke</text>
</svg>`,

'Trusted Devices': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="45" y="24" width="70" height="7" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="45" y="38" width="110" height="20" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <circle cx="56" cy="48" r="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <path d="M53 48 L55 50 L59 46" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <rect x="65" y="43" width="50" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="65" y="50" width="30" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="45" y="64" width="110" height="20" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="56" cy="74" r="5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="65" y="69" width="45" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="65" y="76" width="25" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="120" y="70" width="30" height="8" rx="2" style="fill: var(--color-border)" opacity="0.3"/>
  <text x="125" y="76" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Remove</text>
</svg>`,

'Password Reset Flow': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="30" width="55" height="60" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="12" y="38" width="40" height="5" rx="1" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="12" y="48" width="40" height="10" rx="2" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="12" y="64" width="40" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.7"/>
  <text x="15" y="38" style="fill: var(--color-text-muted); font-size: 4px; font-family: var(--font-sans)">1</text>
  <path d="M65 60 L75 60" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="2 2"/>
  <polygon points="75,58 79,60 75,62" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="80" y="30" width="55" height="60" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <path d="M97 42 L107 50 L117 42" style="stroke: var(--color-accent)" stroke-width="1" fill="none" opacity="0.4"/>
  <rect x="98" y="52" width="20" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="92" y="60" width="30" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.5"/>
  <text x="90" y="38" style="fill: var(--color-text-muted); font-size: 4px; font-family: var(--font-sans)">2</text>
  <path d="M140 60 L150 60" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="2 2"/>
  <polygon points="150,58 154,60 150,62" style="fill: var(--color-accent)" opacity="0.5"/>
  <rect x="155" y="30" width="40" height="60" rx="5" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="162" y="38" width="26" height="5" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="162" y="48" width="26" height="8" rx="2" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="162" y="60" width="26" height="4" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="162" y="68" width="26" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.7"/>
  <text x="162" y="38" style="fill: var(--color-text-muted); font-size: 4px; font-family: var(--font-sans)">3</text>
</svg>`,

'Account Recovery Options': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="10" width="140" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="55" y="18" width="90" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="55" y="28" width="60" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="42" y="38" width="116" height="18" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke-width="1" style="stroke: var(--color-accent)" opacity="0.3"/>
  <circle cx="54" cy="47" r="5" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="63" y="43" width="60" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="63" y="49" width="40" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="42" y="60" width="116" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="54" cy="69" r="5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="63" y="65" width="55" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="63" y="71" width="35" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="42" y="82" width="116" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="54" cy="91" r="5" style="fill: var(--color-text-muted)" opacity="0.2"/>
  <rect x="63" y="87" width="50" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="63" y="93" width="30" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
</svg>`,

'Account Lockout': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="35" y="10" width="130" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="100" cy="40" r="14" style="fill: #ef4444" opacity="0.08"/>
  <rect x="94" y="30" width="12" height="10" rx="2" style="stroke: #ef4444" stroke-width="1.5" fill="none" opacity="0.5"/>
  <rect x="92" y="40" width="16" height="12" rx="2" style="fill: #ef4444" opacity="0.15" stroke-width="1" style="stroke: #ef4444" opacity="0.4"/>
  <circle cx="100" cy="45" r="2" style="fill: #ef4444" opacity="0.5"/>
  <line x1="100" y1="47" x2="100" y2="50" style="stroke: #ef4444" stroke-width="1" opacity="0.5"/>
  <rect x="55" y="60" width="90" height="5" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="60" y="68" width="80" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="60" y="80" width="80" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.6"/>
  <text x="72" y="87" style="fill: white; font-size: 5px; font-family: var(--font-sans)">Unlock via email</text>
  <text x="72" y="100" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Try again in 28 min</text>
</svg>`,

'Password Change': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="35" y="8" width="130" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="16" width="80" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="50" y="28" width="40" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="50" y="34" width="100" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="52" width="40" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.4"/>
  <rect x="50" y="58" width="100" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="74" width="100" height="4" rx="2" style="fill: var(--color-border)" opacity="0.3"/>
  <rect x="50" y="74" width="75" height="4" rx="2" style="fill: #22c55e" opacity="0.5"/>
  <text x="50" y="86" style="fill: #16a34a; font-size: 5px; font-family: var(--font-sans)">Strong</text>
  <rect x="50" y="92" width="100" height="14" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="68" y="97" width="64" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Rate Limiting Feedback': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="45" y="25" width="110" height="22" rx="4" style="fill: #fef3c7; stroke: #fbbf24" stroke-width="1"/>
  <circle cx="56" cy="36" r="5" fill="#f59e0b" opacity="0.6"/>
  <text x="54" y="38" fill="white" font-size="6" font-weight="bold" font-family="var(--font-sans)">!</text>
  <rect x="66" y="31" width="70" height="4" rx="1" fill="#92400e" opacity="0.6"/>
  <rect x="66" y="38" width="50" height="3" rx="1" fill="#92400e" opacity="0.3"/>
  <rect x="45" y="55" width="110" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" opacity="0.5"/>
  <rect x="45" y="73" width="110" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" opacity="0.5"/>
  <rect x="45" y="90" width="110" height="10" rx="3" style="fill: var(--color-border)" opacity="0.3"/>
  <text x="80" y="97" style="fill: var(--color-text-muted); font-size: 5px; font-family: var(--font-sans)">Wait 45s</text>
</svg>`,

'CAPTCHA / Bot Detection': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="45" y="25" width="110" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="45" y="43" width="110" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="45" y="62" width="110" height="20" rx="4" style="fill: var(--color-border)" opacity="0.1" stroke-width="1" style="stroke: var(--color-border)"/>
  <rect x="52" y="67" width="10" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.15" stroke-width="1" style="stroke: var(--color-accent)"/>
  <path d="M55 72 L57 74 L60 70" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="68" y="69" width="50" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.5"/>
  <rect x="45" y="88" width="110" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.8"/>
  <rect x="78" y="92" width="44" height="4" rx="1" fill="white" opacity="0.9"/>
</svg>`,

'Security Event Notifications': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="35" y="18" width="80" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="30" y="30" width="140" height="22" rx="4" style="fill: #fef2f2; stroke: #fca5a5" stroke-width="1"/>
  <circle cx="42" cy="41" r="5" fill="#ef4444" opacity="0.5"/>
  <rect x="52" y="36" width="70" height="4" rx="1" fill="#991b1b" opacity="0.6"/>
  <rect x="52" y="43" width="50" height="3" rx="1" fill="#991b1b" opacity="0.3"/>
  <rect x="128" y="37" width="34" height="8" rx="2" fill="#ef4444" opacity="0.15"/>
  <text x="131" y="43" style="fill: #ef4444; font-size: 5px; font-family: var(--font-sans)">Not me!</text>
  <rect x="30" y="56" width="140" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="42" cy="65" r="4" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="52" y="61" width="65" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="52" y="67" width="40" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="30" y="78" width="140" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="42" cy="87" r="4" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="52" y="83" width="60" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="52" y="89" width="45" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
</svg>`,

'Credential Stuffing Defense': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="15" width="140" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="24" width="100" height="6" rx="2" style="fill: var(--color-text)" opacity="0.6"/>
  <rect x="50" y="36" width="100" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="52" width="100" height="18" rx="4" style="fill: #fef2f2; stroke: #fca5a5" stroke-width="1"/>
  <circle cx="60" cy="61" r="4" fill="#ef4444" opacity="0.5"/>
  <path d="M58 61 L60 61 M60 59 L60 63" style="stroke: white" stroke-width="1.5" stroke-linecap="round"/>
  <rect x="68" y="56" width="70" height="4" rx="1" fill="#991b1b" opacity="0.6"/>
  <rect x="68" y="63" width="50" height="3" rx="1" fill="#991b1b" opacity="0.3"/>
  <rect x="50" y="76" width="100" height="12" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="50" y="92" width="100" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.7"/>
</svg>`,

'Security Settings Page': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="8" width="180" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="15" y="14" width="40" height="96" rx="4" style="fill: var(--color-border)" opacity="0.1"/>
  <rect x="20" y="20" width="30" height="5" rx="1" style="fill: var(--color-accent)" opacity="0.7"/>
  <rect x="20" y="30" width="30" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="20" y="38" width="30" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="20" y="46" width="30" height="4" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="20" y="54" width="30" height="4" rx="1" style="fill: #ef4444" opacity="0.4"/>
  <rect x="65" y="14" width="120" height="96" rx="4" style="fill: var(--color-surface)"/>
  <rect x="72" y="20" width="60" height="7" rx="2" style="fill: var(--color-text)" opacity="0.7"/>
  <rect x="72" y="34" width="105" height="18" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="80" y="39" width="40" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="80" y="46" width="25" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="152" y="40" width="18" height="8" rx="4" style="fill: var(--color-accent)" opacity="0.5"/>
  <circle cx="165" cy="44" r="3" fill="white" opacity="0.8"/>
  <rect x="72" y="56" width="105" height="18" rx="3" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="80" y="61" width="50" height="4" rx="1" style="fill: var(--color-text)" opacity="0.5"/>
  <rect x="80" y="68" width="30" height="3" rx="1" style="fill: var(--color-text-muted)" opacity="0.3"/>
  <rect x="72" y="80" width="105" height="24" rx="3" style="fill: #fef2f2; stroke: #fca5a5" stroke-width="1"/>
  <rect x="80" y="86" width="45" height="4" rx="1" fill="#991b1b" opacity="0.5"/>
  <rect x="80" y="93" width="30" height="3" rx="1" fill="#991b1b" opacity="0.3"/>
  <rect x="140" y="88" width="30" height="10" rx="2" fill="#ef4444" opacity="0.2"/>
  <text x="145" y="95" style="fill: #ef4444; font-size: 5px; font-family: var(--font-sans)">Delete</text>
</svg>`,

};
