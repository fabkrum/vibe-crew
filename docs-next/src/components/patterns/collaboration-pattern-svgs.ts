/** SVG illustrations for Collaboration & Real-time Patterns */
export const collaborationPatternSvgs: Record<string, string> = {

'Online Status Indicator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="20" style="fill: var(--color-accent)" opacity="0.15" stroke="var(--color-border)" stroke-width="1"/>
  <circle cx="50" cy="50" r="12" style="fill: var(--color-accent)" opacity="0.25"/>
  <circle cx="64" cy="64" r="6" fill="#22c55e" stroke="var(--color-surface)" stroke-width="2"/>
  <circle cx="110" cy="50" r="20" style="fill: var(--color-accent)" opacity="0.15" stroke="var(--color-border)" stroke-width="1"/>
  <circle cx="110" cy="50" r="12" style="fill: var(--color-accent)" opacity="0.25"/>
  <circle cx="124" cy="64" r="6" fill="#eab308" stroke="var(--color-surface)" stroke-width="2"/>
  <circle cx="170" cy="50" r="20" style="fill: var(--color-accent)" opacity="0.15" stroke="var(--color-border)" stroke-width="1"/>
  <circle cx="170" cy="50" r="12" style="fill: var(--color-accent)" opacity="0.25"/>
  <circle cx="184" cy="64" r="6" fill="#9ca3af" stroke="var(--color-surface)" stroke-width="2"/>
  <text x="50" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="9" font-family="sans-serif">Online</text>
  <text x="110" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="9" font-family="sans-serif">Away</text>
  <text x="170" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="9" font-family="sans-serif">Offline</text>
</svg>`,

'Avatar Stack': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="55" cy="55" r="22" style="fill: #8b5cf6" opacity="0.3" stroke="var(--color-surface)" stroke-width="3"/>
  <circle cx="55" cy="55" r="14" style="fill: #8b5cf6" opacity="0.4"/>
  <circle cx="80" cy="55" r="22" style="fill: #3b82f6" opacity="0.3" stroke="var(--color-surface)" stroke-width="3"/>
  <circle cx="80" cy="55" r="14" style="fill: #3b82f6" opacity="0.4"/>
  <circle cx="105" cy="55" r="22" style="fill: #10b981" opacity="0.3" stroke="var(--color-surface)" stroke-width="3"/>
  <circle cx="105" cy="55" r="14" style="fill: #10b981" opacity="0.4"/>
  <circle cx="130" cy="55" r="22" style="fill: var(--color-accent)" opacity="0.15" stroke="var(--color-surface)" stroke-width="3"/>
  <text x="130" y="59" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="11" font-weight="600" font-family="sans-serif">+4</text>
</svg>`,

'Participant List': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="8" width="140" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="50" y="26" style="fill: var(--color-text)" font-size="10" font-weight="700" font-family="sans-serif">Participants</text>
  <text x="145" y="26" style="fill: var(--color-text-muted)" font-size="9" font-family="sans-serif">4</text>
  <line x1="38" y1="32" x2="162" y2="32" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <circle cx="50" cy="47" r="8" style="fill: #3b82f6" opacity="0.3"/>
  <rect x="64" y="42" width="50" height="5" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <circle cx="155" cy="47" r="4" fill="#22c55e"/>
  <circle cx="50" cy="67" r="8" style="fill: #8b5cf6" opacity="0.3"/>
  <rect x="64" y="62" width="42" height="5" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <circle cx="155" cy="67" r="4" fill="#22c55e"/>
  <circle cx="50" cy="87" r="8" style="fill: #10b981" opacity="0.3"/>
  <rect x="64" y="82" width="55" height="5" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <circle cx="155" cy="87" r="4" fill="#eab308"/>
  <circle cx="50" cy="102" r="6" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="64" y="99" width="38" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="155" cy="102" r="3" fill="#9ca3af"/>
</svg>`,

'Typing Indicator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="30" width="160" height="55" rx="8" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="48" cy="50" r="10" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="66" y="44" width="80" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="66" y="54" width="55" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="35" y="66" width="90" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.08"/>
  <text x="42" y="75" style="fill: var(--color-text-muted)" font-size="8" font-style="italic" font-family="sans-serif">Alice is typing</text>
  <circle cx="108" cy="72" r="2" style="fill: var(--color-accent)" opacity="0.4"/>
  <circle cx="114" cy="72" r="2" style="fill: var(--color-accent)" opacity="0.6"/>
  <circle cx="120" cy="72" r="2" style="fill: var(--color-accent)" opacity="0.8"/>
</svg>`,

'User Cursor': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="25" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="35" width="130" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="45" width="110" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="55" width="140" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="65" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="75" width="120" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <polygon points="80,40 80,58 86,52 94,52" fill="#3b82f6"/>
  <rect x="88" y="50" width="28" height="12" rx="3" fill="#3b82f6"/>
  <text x="96" y="59" fill="white" font-size="7" font-family="sans-serif">Alice</text>
  <polygon points="130,60 130,78 136,72 144,72" fill="#ef4444"/>
  <rect x="138" y="70" width="24" height="12" rx="3" fill="#ef4444"/>
  <text x="144" y="79" fill="white" font-size="7" font-family="sans-serif">Bob</text>
</svg>`,

'Collaborative Text Editing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="15" y="10" width="170" height="22" rx="6" style="fill: var(--color-accent)" opacity="0.08"/>
  <rect x="25" y="17" width="8" height="8" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="37" y="17" width="8" height="8" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="49" y="17" width="8" height="8" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="25" y="42" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="25" y="52" width="140" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="25" y="62" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="78" y="58" width="30" height="12" rx="2" fill="#3b82f6" opacity="0.2"/>
  <rect x="78" y="62" width="30" height="4" rx="2" fill="#3b82f6" opacity="0.4"/>
  <rect x="115" y="62" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="25" y="72" width="120" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="55" y="68" width="35" height="12" rx="2" fill="#ef4444" opacity="0.2"/>
  <rect x="55" y="72" width="35" height="4" rx="2" fill="#ef4444" opacity="0.4"/>
  <rect x="25" y="82" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <circle cx="165" cy="42" r="6" fill="#3b82f6" opacity="0.3"/>
  <circle cx="165" cy="56" r="6" fill="#ef4444" opacity="0.3"/>
</svg>`,

'Selection Highlighting': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="30" width="130" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="42" width="150" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="60" y="38" width="70" height="13" rx="2" fill="#3b82f6" opacity="0.15"/>
  <rect x="60" y="42" width="70" height="5" rx="2" fill="#3b82f6" opacity="0.3"/>
  <rect x="55" y="36" width="22" height="8" rx="2" fill="#3b82f6"/>
  <text x="60" y="42" fill="white" font-size="5" font-family="sans-serif">Alice</text>
  <rect x="25" y="54" width="140" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="66" width="110" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="80" y="62" width="50" height="13" rx="2" fill="#ef4444" opacity="0.15"/>
  <rect x="80" y="66" width="50" height="5" rx="2" fill="#ef4444" opacity="0.3"/>
  <rect x="75" y="60" width="18" height="8" rx="2" fill="#ef4444"/>
  <text x="79" y="66" fill="white" font-size="5" font-family="sans-serif">Bob</text>
  <rect x="25" y="78" width="120" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="90" width="90" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
</svg>`,

'Conflict Resolution Dialog': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="20" rx="6" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="100" y="24" text-anchor="middle" style="fill: var(--color-text)" font-size="9" font-weight="700" font-family="sans-serif">Conflict Detected</text>
  <line x1="100" y1="35" x2="100" y2="85" style="stroke: var(--color-border)" stroke-width="1" stroke-dasharray="3,3"/>
  <text x="55" y="42" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Your version</text>
  <rect x="20" y="48" width="70" height="4" rx="2" fill="#22c55e" opacity="0.3"/>
  <rect x="20" y="56" width="55" height="4" rx="2" fill="#22c55e" opacity="0.3"/>
  <rect x="20" y="64" width="65" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <text x="145" y="42" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Their version</text>
  <rect x="110" y="48" width="70" height="4" rx="2" fill="#ef4444" opacity="0.3"/>
  <rect x="110" y="56" width="60" height="4" rx="2" fill="#ef4444" opacity="0.3"/>
  <rect x="110" y="64" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="20" y="82" width="50" height="18" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="45" y="94" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">Keep mine</text>
  <rect x="75" y="82" width="50" height="18" rx="4" style="fill: var(--color-border-subtle)"/>
  <text x="100" y="94" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-weight="600" font-family="sans-serif">Keep theirs</text>
  <rect x="130" y="82" width="50" height="18" rx="4" style="fill: var(--color-border-subtle)"/>
  <text x="155" y="94" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-weight="600" font-family="sans-serif">Merge</text>
</svg>`,

'Optimistic Update with Rollback': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="25" width="55" height="70" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="37" y="40" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Action</text>
  <rect x="18" y="48" width="40" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.2"/>
  <text x="38" y="56" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-family="sans-serif">Click</text>
  <path d="M 65 60 L 85 60" style="stroke: var(--color-accent)" stroke-width="1.5" marker-end="url(#arrow-collab)"/>
  <rect x="85" y="25" width="55" height="70" rx="6" style="fill: var(--color-surface); stroke: #22c55e" stroke-width="1.5"/>
  <text x="112" y="40" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Instant UI</text>
  <rect x="93" y="48" width="40" height="10" rx="3" fill="#22c55e" opacity="0.2"/>
  <text x="113" y="56" text-anchor="middle" fill="#22c55e" font-size="7" font-family="sans-serif">Done!</text>
  <path d="M 112 70 L 112 82" style="stroke: var(--color-text-muted)" stroke-width="1" stroke-dasharray="3,3"/>
  <text x="112" y="90" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Server sync</text>
  <rect x="140" y="25" width="55" height="70" rx="6" style="fill: var(--color-surface); stroke: #ef4444" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="167" y="40" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Rollback</text>
  <path d="M 160 55 L 170 50 M 170 55 L 160 50" stroke="#ef4444" stroke-width="1.5"/>
  <text x="167" y="70" text-anchor="middle" style="fill: #ef4444" font-size="6" font-family="sans-serif">Reverted</text>
  <defs><marker id="arrow-collab" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto"><path d="M 0 0 L 6 3 L 0 6" style="fill: var(--color-accent)"/></marker></defs>
</svg>`,

'Locking & Editing Permissions': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="28" width="70" height="30" rx="4" style="fill: var(--color-accent)" opacity="0.08" stroke="var(--color-accent)" stroke-width="1" opacity="0.3"/>
  <rect x="30" y="34" width="55" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="30" y="42" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="80" y="32" width="10" height="14" rx="2" fill="#22c55e" opacity="0.2"/>
  <text x="85" y="42" text-anchor="middle" fill="#22c55e" font-size="8" font-family="sans-serif">&#9998;</text>
  <rect x="105" y="28" width="70" height="30" rx="4" style="fill: var(--color-border-subtle)" stroke="var(--color-border)" stroke-width="1"/>
  <rect x="110" y="34" width="55" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="110" y="42" width="40" height="4" rx="2" style="fill: var(--color-text)" opacity="0.12"/>
  <rect x="160" y="32" width="10" height="14" rx="2" fill="#ef4444" opacity="0.2"/>
  <text x="165" y="42" text-anchor="middle" fill="#ef4444" font-size="8" font-family="sans-serif">&#128274;</text>
  <rect x="25" y="68" width="150" height="14" rx="3" fill="#eab308" opacity="0.1"/>
  <text x="100" y="78" text-anchor="middle" style="fill: #eab308" font-size="7" font-weight="600" font-family="sans-serif">Locked by Alice - editing disabled</text>
  <rect x="25" y="88" width="70" height="12" rx="3" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="60" y="97" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-family="sans-serif">Editable</text>
  <rect x="105" y="88" width="70" height="12" rx="3" style="fill: var(--color-border-subtle)"/>
  <text x="140" y="97" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Read-only</text>
</svg>`,

'Inline Comments': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="120" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="20" y="25" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="35" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="50" y="31" width="40" height="12" rx="2" fill="#eab308" opacity="0.15"/>
  <rect x="50" y="35" width="40" height="4" rx="2" fill="#eab308" opacity="0.3"/>
  <rect x="20" y="45" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="55" width="95" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="20" y="65" width="70" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="61" width="45" height="12" rx="2" fill="#eab308" opacity="0.15"/>
  <rect x="25" y="65" width="45" height="4" rx="2" fill="#eab308" opacity="0.3"/>
  <rect x="140" y="28" width="55" height="40" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1"/>
  <path d="M 130 37 L 140 37" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="2,2"/>
  <circle cx="150" cy="38" r="5" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="158" y="36" width="28" height="4" rx="1" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="148" y="48" width="38" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="148" y="54" width="30" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="148" y="60" width="20" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="152" y="66" style="fill: var(--color-accent)" font-size="5" font-family="sans-serif">Reply</text>
</svg>`,

'@Mention Autocomplete': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="60" width="160" height="30" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="32" y="79" style="fill: var(--color-text)" font-size="10" font-family="sans-serif">Hey </text>
  <text x="56" y="79" style="fill: var(--color-accent)" font-size="10" font-weight="600" font-family="sans-serif">@Ali</text>
  <rect x="56" y="81" width="1" height="2" style="fill: var(--color-accent)"/>
  <rect x="40" y="15" width="100" height="42" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1" filter="drop-shadow(0 2px 4px rgba(0,0,0,0.08))"/>
  <circle cx="55" cy="28" r="6" style="fill: #3b82f6" opacity="0.3"/>
  <rect x="66" y="25" width="50" height="5" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="40" y="15" width="100" height="20" rx="6" style="fill: var(--color-accent)" opacity="0.08"/>
  <circle cx="55" cy="45" r="6" style="fill: #8b5cf6" opacity="0.3"/>
  <rect x="66" y="42" width="42" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
</svg>`,

'Emoji Reactions': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="45" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="40" cy="32" r="10" style="fill: var(--color-accent)" opacity="0.2"/>
  <rect x="56" y="26" width="100" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="56" y="35" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="56" y="44" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="30" y="68" width="36" height="22" rx="11" style="fill: var(--color-accent)" opacity="0.1" stroke="var(--color-accent)" stroke-width="1" opacity="0.3"/>
  <text x="40" y="82" font-size="10" font-family="sans-serif">&#128077;</text>
  <text x="54" y="83" style="fill: var(--color-accent)" font-size="9" font-weight="600" font-family="sans-serif">5</text>
  <rect x="72" y="68" width="36" height="22" rx="11" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="82" y="82" font-size="10" font-family="sans-serif">&#10084;</text>
  <text x="96" y="83" style="fill: var(--color-text-muted)" font-size="9" font-family="sans-serif">3</text>
  <rect x="114" y="68" width="36" height="22" rx="11" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="124" y="82" font-size="10" font-family="sans-serif">&#127881;</text>
  <text x="138" y="83" style="fill: var(--color-text-muted)" font-size="9" font-family="sans-serif">1</text>
  <circle cx="162" cy="79" r="10" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="162" y="83" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="12" font-family="sans-serif">+</text>
</svg>`,

'Activity Feed': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="5" width="150" height="110" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <line x1="47" y1="22" x2="47" y2="100" style="stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="47" cy="25" r="5" style="fill: #3b82f6" opacity="0.4"/>
  <rect x="58" y="20" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="58" y="28" width="60" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="47" cy="45" r="5" style="fill: #10b981" opacity="0.4"/>
  <rect x="58" y="40" width="70" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="58" y="48" width="50" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="47" cy="65" r="5" style="fill: #8b5cf6" opacity="0.4"/>
  <rect x="58" y="60" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="58" y="68" width="65" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="47" cy="85" r="5" style="fill: #eab308" opacity="0.4"/>
  <rect x="58" y="80" width="75" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="58" y="88" width="55" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <text x="155" y="28" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">2m ago</text>
  <text x="155" y="48" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">5m ago</text>
  <text x="155" y="68" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">1h ago</text>
</svg>`,

'Threaded Replies': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="35" cy="28" r="8" style="fill: #3b82f6" opacity="0.3"/>
  <rect x="48" y="22" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <rect x="48" y="30" width="110" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="48" y="40" width="40" height="10" rx="3" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="56" y="48" style="fill: var(--color-accent)" font-size="7" font-family="sans-serif">3 replies</text>
  <line x1="40" y1="55" x2="170" y2="55" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="40" y="58" width="2" height="46" rx="1" style="fill: var(--color-accent)" opacity="0.2"/>
  <circle cx="55" cy="68" r="6" style="fill: #10b981" opacity="0.3"/>
  <rect x="66" y="64" width="70" height="3" rx="1" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="66" y="71" width="90" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="55" cy="88" r="6" style="fill: #8b5cf6" opacity="0.3"/>
  <rect x="66" y="84" width="60" height="3" rx="1" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="66" y="91" width="80" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
</svg>`,

'Version History': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="8" width="150" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="45" y="24" style="fill: var(--color-text)" font-size="9" font-weight="700" font-family="sans-serif">Version History</text>
  <line x1="33" y1="30" x2="167" y2="30" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="33" y="35" width="134" height="18" rx="3" style="fill: var(--color-accent)" opacity="0.08"/>
  <circle cx="42" cy="44" r="4" style="fill: var(--color-accent)" opacity="0.3"/>
  <rect x="50" y="39" width="60" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <text x="155" y="43" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Now</text>
  <rect x="50" y="47" width="40" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="42" cy="64" r="4" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="50" y="59" width="55" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <text x="155" y="63" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">2h ago</text>
  <rect x="50" y="67" width="35" height="3" rx="1" style="fill: var(--color-text)" opacity="0.1"/>
  <circle cx="42" cy="82" r="4" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="50" y="77" width="65" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <text x="155" y="81" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Yesterday</text>
  <circle cx="42" cy="98" r="4" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="50" y="93" width="48" height="4" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <text x="155" y="97" text-anchor="end" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Mar 3</text>
</svg>`,

'Diff Visualization': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="18" y="22" width="164" height="10" rx="2" fill="#22c55e" opacity="0.1"/>
  <text x="22" y="30" fill="#22c55e" font-size="8" font-family="monospace">+ Added line of text here</text>
  <rect x="18" y="35" width="164" height="10" rx="2" fill="#ef4444" opacity="0.1"/>
  <text x="22" y="43" fill="#ef4444" font-size="8" font-family="monospace">- Removed old content</text>
  <rect x="18" y="48" width="164" height="10" rx="2"/>
  <text x="22" y="56" style="fill: var(--color-text)" opacity="0.4" font-size="8" font-family="monospace">  Unchanged context line</text>
  <rect x="18" y="61" width="164" height="10" rx="2"/>
  <text x="22" y="69" style="fill: var(--color-text)" opacity="0.4" font-size="8" font-family="monospace">  Another unchanged line</text>
  <rect x="18" y="74" width="164" height="10" rx="2" fill="#22c55e" opacity="0.1"/>
  <text x="22" y="82" fill="#22c55e" font-size="8" font-family="monospace">+ New addition below</text>
  <rect x="18" y="92" width="60" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="48" y="102" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">+2 -1</text>
  <rect x="84" y="92" width="50" height="14" rx="4" style="fill: var(--color-border-subtle)"/>
  <text x="109" y="102" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Next diff</text>
</svg>`,

'Undo/Redo Stack': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 45 55 A 20 20 0 1 1 45 65" style="stroke: var(--color-accent)" stroke-width="2" fill="none"/>
  <polygon points="41,52 45,60 49,52" style="fill: var(--color-accent)"/>
  <text x="45" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">Undo</text>
  <text x="45" y="105" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Ctrl+Z</text>
  <rect x="75" y="30" width="50" height="60" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="83" y="38" width="34" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="83" y="50" width="34" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.1"/>
  <rect x="83" y="62" width="34" height="8" rx="2" style="fill: var(--color-accent)" opacity="0.06"/>
  <rect x="83" y="74" width="34" height="8" rx="2" style="fill: var(--color-text)" opacity="0.04"/>
  <path d="M 155 55 A 20 20 0 1 0 155 65" style="stroke: var(--color-text-muted)" stroke-width="2" fill="none"/>
  <polygon points="151,68 155,60 159,68" style="fill: var(--color-text-muted)"/>
  <text x="155" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">Redo</text>
  <text x="155" y="105" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Ctrl+Y</text>
</svg>`,

'Audit Log': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="180" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="10" width="180" height="18" rx="6" style="fill: var(--color-accent)" opacity="0.06"/>
  <text x="30" y="23" style="fill: var(--color-text)" font-size="7" font-weight="700" font-family="sans-serif">Time</text>
  <text x="70" y="23" style="fill: var(--color-text)" font-size="7" font-weight="700" font-family="sans-serif">User</text>
  <text x="115" y="23" style="fill: var(--color-text)" font-size="7" font-weight="700" font-family="sans-serif">Action</text>
  <text x="160" y="23" style="fill: var(--color-text)" font-size="7" font-weight="700" font-family="sans-serif">Resource</text>
  <line x1="18" y1="28" x2="182" y2="28" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <text x="30" y="40" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">14:32</text>
  <text x="70" y="40" style="fill: var(--color-text)" font-size="7" font-family="sans-serif">Alice</text>
  <text x="115" y="40" style="fill: #22c55e" font-size="7" font-family="sans-serif">created</text>
  <text x="160" y="40" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Doc-42</text>
  <text x="30" y="55" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">14:28</text>
  <text x="70" y="55" style="fill: var(--color-text)" font-size="7" font-family="sans-serif">Bob</text>
  <text x="115" y="55" style="fill: #3b82f6" font-size="7" font-family="sans-serif">updated</text>
  <text x="160" y="55" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Doc-38</text>
  <text x="30" y="70" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">14:15</text>
  <text x="70" y="70" style="fill: var(--color-text)" font-size="7" font-family="sans-serif">Carol</text>
  <text x="115" y="70" style="fill: #ef4444" font-size="7" font-family="sans-serif">deleted</text>
  <text x="160" y="70" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Doc-35</text>
  <text x="30" y="85" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">14:02</text>
  <text x="70" y="85" style="fill: var(--color-text)" font-size="7" font-family="sans-serif">Alice</text>
  <text x="115" y="85" style="fill: #8b5cf6" font-size="7" font-family="sans-serif">shared</text>
  <text x="160" y="85" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Doc-42</text>
  <rect x="60" y="95" width="80" height="10" rx="3" style="fill: var(--color-border-subtle)"/>
  <text x="100" y="103" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Export CSV</text>
</svg>`,

'Restore Point': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <line x1="30" y1="60" x2="170" y2="60" style="stroke: var(--color-border)" stroke-width="2"/>
  <circle cx="50" cy="60" r="6" style="fill: var(--color-text)" opacity="0.2" stroke="var(--color-border)" stroke-width="1"/>
  <circle cx="90" cy="60" r="6" style="fill: var(--color-text)" opacity="0.2" stroke="var(--color-border)" stroke-width="1"/>
  <circle cx="130" cy="60" r="10" style="fill: var(--color-accent)" opacity="0.2" stroke="var(--color-accent)" stroke-width="2"/>
  <text x="130" y="63" text-anchor="middle" style="fill: var(--color-accent)" font-size="10" font-family="sans-serif">&#9733;</text>
  <circle cx="160" cy="60" r="6" style="fill: var(--color-text)" opacity="0.2" stroke="var(--color-border)" stroke-width="1"/>
  <text x="50" y="78" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">v1</text>
  <text x="90" y="78" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">v2</text>
  <text x="130" y="82" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">Pre-launch</text>
  <text x="160" y="78" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">v4</text>
  <rect x="95" y="28" width="70" height="18" rx="4" style="fill: var(--color-accent)" opacity="0.1"/>
  <text x="130" y="40" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">Restore point</text>
  <path d="M 130 46 L 130 50" style="stroke: var(--color-accent)" stroke-width="1" stroke-dasharray="2,2"/>
  <rect x="55" y="92" width="90" height="16" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="100" y="103" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">Restore this version</text>
</svg>`,

'WebSocket Connection': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="30" width="60" height="60" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="45" y="52" text-anchor="middle" style="fill: var(--color-text)" font-size="9" font-weight="600" font-family="sans-serif">Client</text>
  <rect x="32" y="62" width="26" height="6" rx="2" style="fill: #22c55e" opacity="0.3"/>
  <circle cx="30" cy="65" r="3" fill="#22c55e"/>
  <rect x="125" y="30" width="60" height="60" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="155" y="52" text-anchor="middle" style="fill: var(--color-text)" font-size="9" font-weight="600" font-family="sans-serif">Server</text>
  <rect x="142" y="62" width="26" height="6" rx="2" style="fill: var(--color-accent)" opacity="0.3"/>
  <path d="M 75 50 L 125 50" style="stroke: var(--color-accent)" stroke-width="1.5" marker-end="url(#ws-arrow)"/>
  <path d="M 125 70 L 75 70" style="stroke: #22c55e" stroke-width="1.5" marker-end="url(#ws-arrow-back)"/>
  <text x="100" y="46" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-family="sans-serif">send</text>
  <text x="100" y="82" text-anchor="middle" fill="#22c55e" font-size="7" font-family="sans-serif">receive</text>
  <path d="M 80 58 C 90 54, 110 66, 120 62" style="stroke: var(--color-text-muted)" stroke-width="1" stroke-dasharray="3,3" fill="none"/>
  <text x="100" y="18" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">WebSocket (wss://)</text>
  <defs>
    <marker id="ws-arrow" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto"><path d="M 0 0 L 6 3 L 0 6" style="fill: var(--color-accent)"/></marker>
    <marker id="ws-arrow-back" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto"><path d="M 0 0 L 6 3 L 0 6" fill="#22c55e"/></marker>
  </defs>
</svg>`,

'Reconnection Strategy': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="15" width="180" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="10" y="15" width="180" height="22" rx="6" fill="#ef4444" opacity="0.08"/>
  <circle cx="28" cy="26" r="5" fill="#ef4444" opacity="0.4"/>
  <text x="38" y="29" style="fill: #ef4444" font-size="8" font-weight="600" font-family="sans-serif">Connection lost - reconnecting...</text>
  <line x1="25" y1="50" x2="175" y2="50" style="stroke: var(--color-border)" stroke-width="1"/>
  <circle cx="40" cy="50" r="4" fill="#ef4444" opacity="0.4"/>
  <text x="40" y="62" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">1s</text>
  <circle cx="70" cy="50" r="4" fill="#ef4444" opacity="0.3"/>
  <text x="70" y="62" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">2s</text>
  <circle cx="105" cy="50" r="4" fill="#eab308" opacity="0.4"/>
  <text x="105" y="62" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">4s</text>
  <circle cx="145" cy="50" r="4" fill="#eab308" opacity="0.3"/>
  <text x="145" y="62" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">8s</text>
  <circle cx="175" cy="50" r="5" fill="#22c55e" opacity="0.5"/>
  <text x="175" y="62" text-anchor="middle" fill="#22c55e" font-size="6" font-weight="600" font-family="sans-serif">OK</text>
  <text x="100" y="78" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">Exponential backoff + jitter</text>
  <rect x="55" y="85" width="90" height="14" rx="4" fill="#22c55e" opacity="0.1"/>
  <text x="100" y="95" text-anchor="middle" fill="#22c55e" font-size="7" font-weight="600" font-family="sans-serif">Reconnected</text>
</svg>`,

'Offline Mode': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="10" width="170" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="15" y="10" width="170" height="20" rx="6" fill="#eab308" opacity="0.1"/>
  <text x="100" y="24" text-anchor="middle" fill="#eab308" font-size="8" font-weight="600" font-family="sans-serif">You're offline - changes saved locally</text>
  <rect x="25" y="38" width="145" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="42" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="30" y="48" width="40" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="160" cy="46" r="5" style="fill: #eab308" opacity="0.3"/>
  <text x="160" y="49" text-anchor="middle" fill="#eab308" font-size="6" font-family="sans-serif">&#8593;</text>
  <rect x="25" y="58" width="145" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="62" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="30" y="68" width="50" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <circle cx="160" cy="66" r="5" style="fill: #eab308" opacity="0.3"/>
  <text x="160" y="69" text-anchor="middle" fill="#eab308" font-size="6" font-family="sans-serif">&#8593;</text>
  <rect x="25" y="78" width="145" height="16" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="82" width="70" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <circle cx="160" cy="86" r="5" fill="#22c55e" opacity="0.3"/>
  <text x="160" y="89" text-anchor="middle" fill="#22c55e" font-size="6" font-family="sans-serif">&#10003;</text>
</svg>`,

'Event Sourcing': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="30" width="45" height="60" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="32" y="48" text-anchor="middle" style="fill: var(--color-text)" font-size="7" font-weight="600" font-family="sans-serif">Events</text>
  <rect x="16" y="54" width="33" height="6" rx="2" style="fill: #3b82f6" opacity="0.2"/>
  <rect x="16" y="63" width="33" height="6" rx="2" style="fill: #10b981" opacity="0.2"/>
  <rect x="16" y="72" width="33" height="6" rx="2" style="fill: #8b5cf6" opacity="0.2"/>
  <rect x="16" y="81" width="33" height="6" rx="2" style="fill: #eab308" opacity="0.2"/>
  <path d="M 55 60 L 78 60" style="stroke: var(--color-accent)" stroke-width="1.5" marker-end="url(#es-arrow)"/>
  <rect x="78" y="30" width="45" height="60" rx="4" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="100" y="48" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">Replay</text>
  <path d="M 90 58 A 8 8 0 1 1 90 68" style="stroke: var(--color-accent)" stroke-width="1.5" fill="none"/>
  <polygon points="88,55 90,62 94,55" style="fill: var(--color-accent)"/>
  <path d="M 123 60 L 145 60" style="stroke: var(--color-accent)" stroke-width="1.5" marker-end="url(#es-arrow)"/>
  <rect x="145" y="30" width="45" height="60" rx="4" style="fill: var(--color-surface); stroke: #22c55e" stroke-width="1.5"/>
  <text x="167" y="48" text-anchor="middle" fill="#22c55e" font-size="7" font-weight="600" font-family="sans-serif">State</text>
  <rect x="153" y="56" width="28" height="8" rx="2" fill="#22c55e" opacity="0.15"/>
  <rect x="153" y="68" width="28" height="8" rx="2" fill="#22c55e" opacity="0.15"/>
  <text x="100" y="18" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">Append-only event log</text>
  <defs><marker id="es-arrow" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto"><path d="M 0 0 L 6 3 L 0 6" style="fill: var(--color-accent)"/></marker></defs>
</svg>`,

'Broadcast Updates': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="25" y="28" width="150" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="33" width="80" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="30" y="40" width="50" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <rect x="25" y="50" width="150" height="18" rx="4" fill="#eab308" opacity="0.08" stroke="#eab308" stroke-width="1" opacity="0.3"/>
  <rect x="30" y="55" width="90" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="30" y="62" width="60" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
  <text x="163" y="60" style="fill: #eab308" font-size="7" font-weight="600" font-family="sans-serif">NEW</text>
  <rect x="25" y="72" width="150" height="18" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="30" y="77" width="70" height="4" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="30" y="84" width="45" height="3" rx="1" style="fill: var(--color-text)" opacity="0.15"/>
</svg>`,

'Role-Based Access Control': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="50" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-accent)" stroke-width="1.5"/>
  <text x="40" y="30" text-anchor="middle" style="fill: var(--color-accent)" font-size="8" font-weight="700" font-family="sans-serif">Owner</text>
  <rect x="22" y="36" width="36" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="22" y="44" width="36" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="22" y="52" width="36" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="22" y="60" width="36" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="22" y="68" width="36" height="5" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <rect x="75" y="15" width="50" height="90" rx="6" style="fill: var(--color-surface); stroke: #3b82f6" stroke-width="1.5"/>
  <text x="100" y="30" text-anchor="middle" fill="#3b82f6" font-size="8" font-weight="700" font-family="sans-serif">Editor</text>
  <rect x="82" y="36" width="36" height="5" rx="2" fill="#3b82f6" opacity="0.15"/>
  <rect x="82" y="44" width="36" height="5" rx="2" fill="#3b82f6" opacity="0.15"/>
  <rect x="82" y="52" width="36" height="5" rx="2" fill="#3b82f6" opacity="0.15"/>
  <rect x="82" y="60" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="82" y="68" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="135" y="15" width="50" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="160" y="30" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-weight="700" font-family="sans-serif">Viewer</text>
  <rect x="142" y="36" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.08"/>
  <rect x="142" y="44" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="142" y="52" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="142" y="60" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <rect x="142" y="68" width="36" height="5" rx="2" style="fill: var(--color-text)" opacity="0.06"/>
  <text x="40" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Full access</text>
  <text x="100" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Read + Write</text>
  <text x="160" y="95" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="6" font-family="sans-serif">Read only</text>
</svg>`,

'Share Dialog': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="160" height="104" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="100" y="24" text-anchor="middle" style="fill: var(--color-text)" font-size="10" font-weight="700" font-family="sans-serif">Share</text>
  <rect x="30" y="32" width="105" height="14" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="38" y="42" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Add people by email...</text>
  <rect x="140" y="32" width="32" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="156" y="42" text-anchor="middle" style="fill: var(--color-accent)" font-size="7" font-weight="600" font-family="sans-serif">Invite</text>
  <line x1="30" y1="52" x2="170" y2="52" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <circle cx="42" cy="64" r="6" style="fill: #3b82f6" opacity="0.3"/>
  <rect x="54" y="60" width="50" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <text x="155" y="64" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Editor &#9662;</text>
  <circle cx="42" cy="80" r="6" style="fill: #10b981" opacity="0.3"/>
  <rect x="54" y="76" width="45" height="4" rx="2" style="fill: var(--color-text)" opacity="0.3"/>
  <text x="155" y="80" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Viewer &#9662;</text>
  <line x1="30" y1="90" x2="170" y2="90" style="stroke: var(--color-border)" stroke-width="0.5"/>
  <rect x="30" y="94" width="10" height="10" rx="2" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="46" y="102" style="fill: var(--color-text)" font-size="7" font-family="sans-serif">Anyone with link can view</text>
</svg>`,

'Permission Indicator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="15" y="15" width="170" height="26" rx="6" style="fill: var(--color-accent)" opacity="0.06"/>
  <rect x="25" y="22" width="50" height="12" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="50" y="31" text-anchor="middle" style="fill: var(--color-accent)" font-size="8" font-weight="600" font-family="sans-serif">Editing</text>
  <rect x="80" y="22" width="60" height="12" rx="4" style="fill: var(--color-border-subtle)"/>
  <text x="110" y="31" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">Suggesting</text>
  <rect x="145" y="22" width="32" height="12" rx="4" style="fill: var(--color-border-subtle)"/>
  <text x="161" y="31" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="8" font-family="sans-serif">View</text>
  <rect x="25" y="50" width="130" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="25" y="60" width="145" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="25" y="70" width="110" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
  <rect x="25" y="80" width="135" height="5" rx="2" style="fill: var(--color-text)" opacity="0.25"/>
</svg>`,

'Guest Access': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="15" y="15" width="170" height="90" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="15" y="15" width="170" height="22" rx="6" fill="#3b82f6" opacity="0.08"/>
  <text x="100" y="30" text-anchor="middle" fill="#3b82f6" font-size="8" font-weight="600" font-family="sans-serif">Viewing as guest - Sign in for full access</text>
  <rect x="25" y="45" width="130" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="55" width="145" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="65" width="110" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="25" y="75" width="135" height="5" rx="2" style="fill: var(--color-text)" opacity="0.2"/>
  <rect x="65" y="88" width="70" height="14" rx="4" style="fill: #3b82f6" opacity="0.15"/>
  <text x="100" y="98" text-anchor="middle" fill="#3b82f6" font-size="8" font-weight="600" font-family="sans-serif">Sign in</text>
</svg>`,

'Access Request': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="25" y="10" width="150" height="100" rx="6" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <rect x="90" y="20" width="20" height="20" rx="10" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="100" y="34" text-anchor="middle" style="fill: var(--color-accent)" font-size="12" font-family="sans-serif">&#128274;</text>
  <text x="100" y="52" text-anchor="middle" style="fill: var(--color-text)" font-size="9" font-weight="700" font-family="sans-serif">You need access</text>
  <text x="100" y="64" text-anchor="middle" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Ask the owner for permission</text>
  <rect x="40" y="72" width="120" height="14" rx="4" style="fill: var(--color-surface); stroke: var(--color-border)" stroke-width="1"/>
  <text x="50" y="82" style="fill: var(--color-text-muted)" font-size="7" font-family="sans-serif">Why do you need access?</text>
  <rect x="60" y="92" width="80" height="14" rx="4" style="fill: var(--color-accent)" opacity="0.15"/>
  <text x="100" y="102" text-anchor="middle" style="fill: var(--color-accent)" font-size="8" font-weight="600" font-family="sans-serif">Request access</text>
</svg>`,

};
