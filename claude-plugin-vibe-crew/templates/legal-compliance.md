# Legal Compliance Reference

Agent-facing reference for legal and regulatory compliance patterns.
Use during Tier 1 (TDR) and Tier 2 feature development for user-facing projects.
Each section: **When required / What to implement / Risk if missing**.

## 1. Impressum (Legal Notice)

### When Required
- Germany: Telemediengesetz (TMG) Section 5 — all commercial websites and apps.
- Austria: E-Commerce-Gesetz (ECG) Section 5.
- Switzerland: Bundesgesetz gegen den unlauteren Wettbewerb (UWG) Art. 3.
- Applies to any site that is not purely personal with no commercial intent.

### What to Implement
- Dedicated `/impressum` or `/legal-notice` page.
- Must be reachable within 2 clicks from every page (standard: footer link labeled "Impressum").
- Required contents:
  - Full legal entity name (for individuals: full real name — no pseudonyms).
  - Postal address (no P.O. boxes — physical street address mandatory).
  - Email address and phone number.
  - VAT ID (Umsatzsteuer-Identifikationsnummer) if applicable.
  - Trade register number and registering court (Handelsregister) if applicable.
  - Responsible person for editorial content (Section 18 Abs. 2 MStV) if journalistic content.
- Multi-language sites: provide Impressum in each available language.
- Apps: accessible from within the app (e.g., Settings > Legal).

### Risk if Missing
- Abmahnung (cease-and-desist) from competitors or consumer protection organizations.
- Fines up to EUR 50,000. Competitors can seek injunctive relief.

## 2. Privacy Policy (Datenschutzerklaerung)

### When Required
- GDPR Art. 13 (data collected directly from user) and Art. 14 (data from third parties).
- Any site processing personal data: analytics, cookies, forms, accounts, IP logging, newsletters.

### What to Implement
- Separate page at `/privacy` or `/datenschutz`, linked from every page footer.
- Required contents:
  - Identity and contact details of the data controller.
  - DPO contact details if one is designated.
  - Categories of personal data collected.
  - Legal basis per processing activity (GDPR Art. 6(1) — consent, contract, legitimate interest, legal obligation, vital interest, public task).
  - Purpose of each processing activity.
  - Recipients or categories of recipients (third parties receiving data).
  - Data retention periods (or criteria for determining them).
  - User rights: access (Art. 15), rectification (Art. 16), erasure (Art. 17), restriction (Art. 18), portability (Art. 20), objection (Art. 21).
  - Right to lodge a complaint with a supervisory authority.
  - Automated decision-making and profiling (Art. 22) if applicable.
  - International transfer safeguards (adequacy decisions, SCCs, BCRs).
- Written in clear, plain language — no jargon a reasonable person would not understand.
- Update whenever new processing activities are introduced.

### Risk if Missing
- GDPR fines up to EUR 20 million or 4% of global annual turnover (whichever is higher).
- Supervisory authority investigations and enforcement orders.

## 3. Cookie Consent

### When Required
- GDPR + ePrivacy Directive 2002/58/EC. Germany: TTDSG.
- Any site using non-essential cookies, localStorage, fingerprinting, or tracking pixels.

### What to Implement
- **Prior consent**: block all non-essential cookies and scripts BEFORE user interaction. No tracking on first page load.
- Consent banner requirements:
  - "Accept All" button.
  - "Reject All" button — same visual weight, size, and click-count as "Accept All".
  - "Manage Preferences" link to granular category selection.
  - No pre-checked checkboxes for non-essential categories.
- Granular consent categories:
  - **Necessary** (always on): session cookies, CSRF tokens, load balancing.
  - **Analytics**: Google Analytics, Plausible, Mixpanel, Hotjar.
  - **Marketing**: Meta Pixel, Google Ads, LinkedIn Insight, retargeting.
  - **Functional**: chat widgets, embedded videos, personalization.
- Gate ALL third-party scripts behind their consent category. Scripts must not load until granted.
- Re-consent interval: 6 to 12 months.
- Consent logging: timestamp, consent version, categories accepted/rejected, anonymized user ID.
- Banner must not obscure critical page content on mobile.
- Persistent "Cookie Settings" link in footer for preference changes.

### Risk if Missing
- GDPR fines (see Section 2). TTDSG fines up to EUR 300,000.
- French CNIL and Austrian DSB have issued EUR 100M+ fines for consent violations.

## 4. Terms of Service (AGB)

### When Required
- B2C: AGB-Recht (Sections 305-310 BGB) governs fairness and transparency.
- B2B: more flexibility but still subject to unfair terms review.
- Required for any commercial site offering products, services, or SaaS.

### What to Implement
- Dedicated `/terms` page linked from footer and referenced during signup flow.
- Required contents:
  - Scope of services and service description.
  - User obligations and acceptable use.
  - Payment terms, pricing, and billing cycles.
  - Liability limitations (cannot exclude liability for intent/gross negligence in DACH).
  - Cancellation and withdrawal right:
    - 14-day Widerrufsrecht for EU consumers (Directive 2011/83/EU).
    - Provide a model withdrawal form.
    - Digital content: right expires once download/streaming begins with explicit consent.
  - Dispute resolution: link EU ODR platform (ec.europa.eu/consumers/odr) for B2C.
- SaaS additions:
  - SLA or availability commitments.
  - Data ownership and portability upon termination.
  - Account termination procedures and data retention post-termination.
  - Price change notice period (30+ days recommended).
  - Acceptable use policy and enforcement actions.
- Term changes require advance notification, reasonable notice period, re-acceptance for material changes.

### Risk if Missing
- Unfair terms void under AGB-Recht — courts apply statutory defaults favoring consumers.
- Consumer protection orgs can sue for injunctive relief.
- Inability to enforce liability caps or dispute resolution clauses.

## 5. Accessibility (European Accessibility Act / BFSG)

### When Required
- European Accessibility Act (EAA) — Directive (EU) 2019/882, enforceable June 28, 2025.
- Germany: Barrierefreiheitsstaerkungsgesetz (BFSG).
- Applies to: e-commerce, banking, telecom, transport, e-books, and associated websites/apps.
- Micro-enterprise exemption (< 10 employees AND < EUR 2M revenue) varies by member state.
- B2B exemption exists for some services, but best practice is universal compliance.

### What to Implement
- Conform to EN 301 549, which maps to WCAG 2.1 AA (moving to 2.2).
- Key technical requirements:
  - Semantic HTML (heading hierarchy, landmark regions, form labels).
  - Keyboard navigation for all interactive elements.
  - Color contrast: 4.5:1 for normal text, 3:1 for large text.
  - Alt text for meaningful images; empty alt for decorative images.
  - ARIA attributes only when native HTML semantics are insufficient.
  - Focus management for dynamic content (modals, notifications, SPAs).
  - Captions and transcripts for audio/video content.
  - No content flashing more than 3 times per second.
- Accessibility statement page (`/accessibility`):
  - Conformance level (full, partial, or non-conformant).
  - Known issues and remediation timeline.
  - Feedback mechanism for reporting barriers.
  - Referenced standard (EN 301 549 / WCAG version).
- Automated testing (axe-core) in CI pipeline. Manual screen reader testing for critical flows.

### Risk if Missing
- Penalties up to EUR 100,000 or 4% of annual revenue (varies by member state).
- Market surveillance can prohibit non-compliant products/services.
- Legal action from disability rights organizations.

## 6. Data Processing

### When Required
- GDPR Art. 28: DPA required with every third-party data processor.
- Applies when sharing personal data with: hosting, analytics, email, payments, CRM, CDNs.

### What to Implement
- **DPAs**: sign with every processor. Major providers (AWS, Vercel, Supabase, Stripe, Google) offer standard DPAs — ensure signed and filed.
- **Data minimization** (Art. 5(1)(c)): collect only what is strictly necessary for the stated purpose.
- **Breach notification** (Art. 33/34):
  - Notify supervisory authority within 72 hours of becoming aware of a breach.
  - Notify affected users "without undue delay" if high risk to rights and freedoms.
  - Maintain a breach register for all incidents regardless of notification obligation.
- **Right to erasure** (Art. 17):
  - Account deletion removing or irreversibly anonymizing all personal data.
  - Cascading deletion across all systems and third-party processors.
  - Document and communicate retention exceptions (legal obligations, disputes).
- **Consent logging**: store what, when, how (UI interaction), which policy version. Retain for duration of processing.
- **Data portability** (Art. 20): machine-readable export (JSON/CSV) within 30 days of request.
- **DPIA** (Art. 35): required for high-risk processing (profiling, large-scale sensitive data, systematic monitoring).

### Risk if Missing
- GDPR fines (see Section 2). Missing DPA is a direct violation — both controller and processor liable.
- Cannot demonstrate compliance (accountability principle, Art. 5(2)).

## 7. Regional Variations

### When Required
- Products serving users outside EU/DACH must comply with local laws.
- Default: implement GDPR as baseline, layer region-specific requirements on top.

### United States
- **CCPA/CPRA** (California): opt-out of sale/sharing, "Do Not Sell or Share My Personal Information" link required.
- State laws: VCDPA (Virginia), CPA (Colorado), CTDPA (Connecticut), UCPA (Utah), TIPA (Texas), MTCDPA (Montana), OCDPA (Oregon), TDPSA (Tennessee) — each with distinct thresholds and timelines.
- No federal omnibus privacy law — compliance requires per-state analysis.
- **ADA** Title III increasingly applied to websites. WCAG 2.1 AA is the de facto standard.

### United Kingdom
- **UK GDPR** (Data Protection Act 2018): mirrors EU GDPR, supervised by ICO.
- EU adequacy decision currently in effect (reviewed periodically).
- Cookie consent per PECR (Privacy and Electronic Communications Regulations).

### Canada
- **PIPEDA** (federal). **Quebec Law 25** (2024): GDPR-like provisions including PIAs, consent, breach notification.
- Provincial laws in Alberta and BC with substantially similar legislation.
- Consent must be meaningful — no buried consent or overbroad purposes.

### Australia
- **Privacy Act 1988** + Australian Privacy Principles (APPs).
- 2024 reforms: enhanced consent, children's privacy, right to erasure, direct right of action.
- Notifiable Data Breaches scheme (OAIC). No cookie consent law, but APP 5 requires collection notice.

### Brazil
- **LGPD**: GDPR-inspired, supervised by ANPD. DPA-equivalent required with processors.
- Legal bases mirror GDPR Art. 6. International transfers need adequacy, SCCs, or BCRs.

### Multi-Region Strategy
- Implement GDPR as baseline — strictest comprehensive framework.
- Layer region-specific opt-outs (CCPA "Do Not Sell" link, state-specific disclosures).
- Geo-detection for appropriate consent mechanisms and legal pages.
- Maintain compliance matrix per processing activity per jurisdiction. Review annually.

## Usage Notes for Agents
- **Tier 1 (TDR)**: flag applicable sections by target market and product type. Record in TDR under "Legal & Compliance".
- **Tier 2 (Features)**: cross-reference when implementing forms, analytics, auth, payments. Include compliance requirements in feature plans.
- **During /wrap**: verify new data processing is reflected in privacy policy and cookie consent.
- This is a reference guide, not legal advice. Recommend users consult qualified legal counsel.
