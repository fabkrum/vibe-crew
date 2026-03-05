export interface LegalPattern {
  name: string;
  category: 'pages' | 'consent' | 'data' | 'accessibility' | 'regional';
  description: string;
  requirement: string;
  penalty: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<LegalPattern['category'], string> = {
  pages: 'Legal Pages',
  consent: 'Consent Management',
  data: 'Data Rights',
  accessibility: 'Accessibility Compliance',
  regional: 'Regional Requirements',
};

export const categoryOrder: LegalPattern['category'][] = [
  'pages', 'consent', 'data', 'accessibility', 'regional',
];

export const legalPatterns: LegalPattern[] = [
  // --- Legal Pages ---
  {
    name: 'Impressum Page',
    category: 'pages',
    description: 'Legal notice page required in DACH region. Must include legal entity name, address, email, VAT ID, and trade register entry. Accessible within 2 clicks from every page.',
    requirement: 'TMG \u00a75 (DE), ECG \u00a75 (AT)',
    penalty: 'Abmahnung fines up to \u20ac50,000',
    docsUrl: null,
  },
  {
    name: 'Privacy Policy',
    category: 'pages',
    description: 'Data processing disclosure. What data is collected, legal basis, third parties, retention periods, and user rights. Linked from every page footer.',
    requirement: 'GDPR Art. 13/14',
    penalty: 'Up to 4% annual revenue or \u20ac20M',
    docsUrl: null,
  },
  {
    name: 'Terms of Service',
    category: 'pages',
    description: 'Usage terms for the service. Covers scope, payment, liability, and cancellation (14-day Widerrufsrecht for EU consumers). Referenced during signup.',
    requirement: 'AGB-Recht (DACH B2C)',
    penalty: 'Unfair terms are void, potential damages',
    docsUrl: null,
  },

  // --- Consent Management ---
  {
    name: 'Cookie Consent Banner',
    category: 'consent',
    description: 'Consent mechanism for non-essential cookies. Block non-essential cookies before consent. Reject must be as easy as Accept. Granular categories. Log consent for auditing.',
    requirement: 'GDPR + ePrivacy (TTDSG)',
    penalty: 'Up to \u20ac300,000 per violation',
    docsUrl: 'https://gdpr.eu/cookies/',
  },
  {
    name: 'Consent Logging',
    category: 'consent',
    description: 'Auditable record of user consent. Store timestamp, consent version, choices made, and IP address. Retain for duration of processing plus statute of limitations.',
    requirement: 'GDPR Art. 7(1)',
    penalty: 'Unable to prove lawful basis for processing',
    docsUrl: null,
  },
  {
    name: 'Third-Party Script Gating',
    category: 'consent',
    description: 'Block analytics and marketing scripts until consent. No Google Analytics, Meta Pixel, HubSpot, or Intercom before explicit consent. Load scripts dynamically after consent callback.',
    requirement: 'GDPR + TTDSG',
    penalty: 'Up to \u20ac300,000',
    docsUrl: null,
  },

  // --- Data Rights ---
  {
    name: 'Data Deletion Request',
    category: 'data',
    description: 'Mechanism for users to request data erasure. Account deletion flow, data anonymization where deletion is not feasible, confirmation within 30 days.',
    requirement: 'GDPR Art. 17 (Right to Erasure)',
    penalty: 'Up to 4% annual revenue',
    docsUrl: null,
  },

  // --- Accessibility Compliance ---
  {
    name: 'Accessibility Statement',
    category: 'accessibility',
    description: 'Declaration of accessibility conformance. Conformance level (WCAG 2.1 AA), known issues, remediation timeline, and feedback mechanism.',
    requirement: 'EAA/BFSG (June 2025)',
    penalty: 'Up to \u20ac100,000 or 4% revenue',
    docsUrl: 'https://www.w3.org/WAI/planning/statements/',
  },
];
