export interface DarkPattern {
  name: string;
  category: 'pressure' | 'deception' | 'hidden' | 'obstruction' | 'preselection';
  description: string;
  howToDetect: string;
  ethicalAlternative: string;
  legalRisk: string | null;
  source: string;
}

export const categoryLabels: Record<DarkPattern['category'], string> = {
  pressure: 'Pressure & Urgency',
  deception: 'Deception & Misdirection',
  hidden: 'Hidden Information',
  obstruction: 'Obstruction',
  preselection: 'Preselection',
};

export const categoryOrder: DarkPattern['category'][] = [
  'pressure', 'deception', 'hidden', 'obstruction', 'preselection',
];

export const darkPatterns: DarkPattern[] = [
  // --- Pressure & Urgency ---
  {
    name: 'Fake Scarcity',
    category: 'pressure',
    description: '"Only 2 left in stock!" or "3 people viewing this" when inventory is not actually limited or numbers are fabricated.',
    howToDetect: 'Static strings like "Only X left", hardcoded low numbers, random number generators near stock/availability text, countdown displays without real inventory API backing.',
    ethicalAlternative: 'Show real inventory counts from a database. If stock is genuinely low, display it. Never fabricate or exaggerate scarcity.',
    legalRisk: 'FTC enforcement (misleading advertising). EU Unfair Commercial Practices Directive Art. 6.',
    source: 'deceptive.design',
  },
  {
    name: 'Fake Urgency',
    category: 'pressure',
    description: 'Countdown timers that reset on refresh, "Deal expires in 00:14:32" with no real deadline, pulsing "Act now!" banners.',
    howToDetect: 'setInterval/setTimeout countdown timers without server-side deadline validation, client-side-only expiry timestamps, timers that reset on page load.',
    ethicalAlternative: 'If a deadline is real (flash sale, limited offer), show it with a server-backed timestamp. When the timer expires, the offer genuinely ends.',
    legalRisk: 'FTC enforcement. EU Omnibus Directive (2022) explicitly bans fake urgency.',
    source: 'deceptive.design',
  },
  {
    name: 'Confirmshaming',
    category: 'pressure',
    description: 'Decline options written to guilt the user — "No thanks, I don\'t want to save money" instead of a neutral "No thanks."',
    howToDetect: 'Modal/dialog decline buttons with negative self-referential language ("I don\'t want", "I\'ll miss out"). Asymmetric tone between accept and decline options.',
    ethicalAlternative: 'Use neutral, respectful language for both options: "Accept" / "No thanks" or "Subscribe" / "Skip". The user\'s choice should never be framed as a mistake.',
    legalRisk: null,
    source: 'NNGroup / deceptive.design',
  },
  {
    name: 'Nagging',
    category: 'pressure',
    description: 'Repeated permission requests, recurring modals after dismissal, "Rate this app" every session, push notification prompts that reappear after decline.',
    howToDetect: 'Missing persistence of dismissal state (no localStorage/cookie flag after decline), modals triggered on every page load without checking prior dismissal.',
    ethicalAlternative: 'Ask once. Store the decline. Offer the option again only in settings or after a natural trigger. Respect "Don\'t ask again."',
    legalRisk: 'GDPR recital 32 (freely given consent). App Store/Play Store guidelines.',
    source: 'deceptive.design',
  },

  // --- Deception & Misdirection ---
  {
    name: 'Trick Wording',
    category: 'deception',
    description: 'Double negatives in opt-out checkboxes ("Uncheck to not unsubscribe"), confusing toggle labels where "on" means "disabled."',
    howToDetect: 'Checkbox labels containing "not", "un-", double negatives. Toggle components where checked=true maps to an opt-out action.',
    ethicalAlternative: 'Use positive, direct language. "Send me marketing emails" (checked = yes). Single negation only.',
    legalRisk: 'GDPR Art. 7 (clear and plain language for consent). CCPA requires clear opt-out.',
    source: 'deceptive.design',
  },
  {
    name: 'Disguised Ads',
    category: 'deception',
    description: 'Advertisements styled to look like content, navigation, or system UI. "Download" buttons that are ads. Sponsored content without disclosure.',
    howToDetect: 'Ad components without "Sponsored" or "Ad" labels, affiliate links without disclosure, promotional content without visual differentiation.',
    ethicalAlternative: 'Clearly label all advertising and sponsored content. Use visual differentiation (background, border, "Sponsored" badge).',
    legalRisk: 'FTC Endorsement Guidelines (16 CFR Part 255). EU Unfair Commercial Practices Directive. Up to $50K/violation.',
    source: 'FTC / deceptive.design',
  },
  {
    name: 'Fake Social Proof',
    category: 'deception',
    description: 'Fabricated testimonials, fake review counts, manufactured "12,847 people signed up today" counters, stock photos for "real users."',
    howToDetect: 'Hardcoded testimonial objects without real data source, static review counts not from a database, random number generators for user/signup counts.',
    ethicalAlternative: 'Use real testimonials with attribution. Show genuine metrics from your database. If you don\'t have social proof yet, omit it.',
    legalRisk: 'FTC enforcement (Amazon $30M fine, 2023). EU Omnibus Directive bans fake reviews.',
    source: 'FTC / deceptive.design',
  },
  {
    name: 'Visual Interference',
    category: 'deception',
    description: 'Making the business-preferred option visually dominant while hiding alternatives — large "Accept All" button with tiny "Manage preferences" link.',
    howToDetect: 'Button pairs where one is primary/filled and the other is text/link/unstyled. Significant size asymmetry between accept and reject actions.',
    ethicalAlternative: 'Give all options equal visual weight. Accept and Reject should be the same size and prominence.',
    legalRisk: 'GDPR Art. 7 + EDPB Guidelines. CNIL fined Google \u20ac150M and Facebook \u20ac60M (2022).',
    source: 'EDPB / deceptive.design',
  },

  // --- Hidden Information ---
  {
    name: 'Hidden Costs',
    category: 'hidden',
    description: 'Service fees, shipping costs, or "processing fees" revealed only at the final checkout step. Base price prominent, total price buried.',
    howToDetect: 'Price display components that exclude fees/tax, fee calculations only in the final checkout step, cart summaries that add items only at payment.',
    ethicalAlternative: 'Show the total price from the first moment a price is displayed. Break down all fees early. No surprises at checkout.',
    legalRisk: 'FTC Click-to-Cancel Rule (2024). EU Consumer Rights Directive Art. 6. Epic Games $245M FTC fine.',
    source: 'FTC / deceptive.design',
  },
  {
    name: 'Hidden Subscription',
    category: 'hidden',
    description: 'Free trial auto-converts to paid without clear disclosure. "Start free" requires credit card with no prominent conversion notice.',
    howToDetect: 'Trial signup flows that collect payment without conversion disclosure, missing "You will be charged $X on [date]" near submit, no pre-charge reminder logic.',
    ethicalAlternative: 'State conversion terms next to signup: "After 14 days, $X/month. Cancel anytime." Send reminder email 3 days before charge.',
    legalRisk: 'FTC Click-to-Cancel Rule (2024). Amazon FTC settlement ($30M). GDPR Art. 7.',
    source: 'FTC / deceptive.design',
  },
  {
    name: 'Comparison Prevention',
    category: 'hidden',
    description: 'Making it intentionally difficult to compare products or plans — different units, missing features in comparison tables.',
    howToDetect: 'Pricing components without feature comparison tables, plan cards with non-aligned feature sets, missing "Compare plans" functionality.',
    ethicalAlternative: 'Provide a clear feature comparison table with consistent units and aligned rows.',
    legalRisk: 'EU Consumer Rights Directive (transparency obligation).',
    source: 'deceptive.design',
  },

  // --- Obstruction ---
  {
    name: 'Hard to Cancel',
    category: 'obstruction',
    description: 'Cancellation requires calling a phone number, navigating multi-step retention flows, or finding a hidden settings page.',
    howToDetect: 'No cancellation route in the app, cancellation behind "Contact us", multi-step flows with 3+ confirmation steps, retention offers blocking cancel.',
    ethicalAlternative: 'Maximum 2 steps: click Cancel then Confirm. Optional feedback form that doesn\'t block cancellation.',
    legalRisk: 'FTC Click-to-Cancel Rule (2025). EU Consumer Rights Directive Art. 11. California AB-390.',
    source: 'FTC / deceptive.design',
  },
  {
    name: 'Forced Action',
    category: 'obstruction',
    description: 'Requiring account creation to view content, forcing app downloads for mobile access, requiring social sharing to unlock features.',
    howToDetect: 'Auth guards on content pages that don\'t need personalization, app-download interstitials, feature gates tied to social sharing.',
    ethicalAlternative: 'Let users access content without accounts where possible. Offer account creation as optional enhancement.',
    legalRisk: 'GDPR data minimization (Art. 5) if accounts collect unnecessary data.',
    source: 'deceptive.design',
  },
  {
    name: 'Sneaking',
    category: 'obstruction',
    description: 'Items silently added to cart. Pre-selected add-ons or insurance. Automatically opted into marketing during purchase.',
    howToDetect: 'Cart logic adding items programmatically, pre-checked addon checkboxes, default-selected upsells, marketing consent defaulting to checked.',
    ethicalAlternative: 'Cart contains only what the user explicitly added. Add-ons are presented but never pre-selected. All optional checkboxes start unchecked.',
    legalRisk: 'GDPR Art. 7 (Planet49 ruling). FTC enforcement. EU Consumer Rights Directive.',
    source: 'deceptive.design',
  },

  // --- Preselection ---
  {
    name: 'Preselection',
    category: 'preselection',
    description: 'Non-essential options pre-checked during signup or checkout — newsletter, data sharing consent, premium plan pre-selected over free.',
    howToDetect: 'Checkbox components with defaultChecked={true} for optional/consent items, radio groups defaulting to most expensive option, selects defaulting to paid tiers.',
    ethicalAlternative: 'All optional checkboxes start unchecked. Plan selection defaults to free/lowest tier or shows no default.',
    legalRisk: 'GDPR Art. 7(2) + Planet49 ruling (2019). TTDSG \u00a725 (Germany). EU Consumer Rights Directive Art. 22.',
    source: 'CJEU Planet49 / deceptive.design',
  },
  {
    name: 'Consent Asymmetry',
    category: 'preselection',
    description: '"Accept All" is a large colorful button. "Manage preferences" is a small gray link. Accepting is 1 click; rejecting requires multiple screens.',
    howToDetect: 'Consent banners where accept and reject have different component variants, sizes, colors, or click depth.',
    ethicalAlternative: 'Accept and Reject must have equal visual weight — same size, same prominence, same click depth.',
    legalRisk: 'GDPR Art. 7 + EDPB Guidelines. CNIL fined Google \u20ac150M, Facebook \u20ac60M (2022). German TTDSG \u00a725.',
    source: 'EDPB / CNIL',
  },
];
