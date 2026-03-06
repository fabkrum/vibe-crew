# Dark Patterns Prevention Guide

Agent-facing reference for identifying and preventing deceptive design patterns.
The Builder reads this during the Design Phase to flag dark pattern risks before
code is written. The Code Reviewer checks against it during review.

Each pattern entry includes:
- **What it looks like**: How this dark pattern manifests in UI
- **How to detect it in code**: Concrete code signals to grep for
- **Ethical alternative**: What to build instead
- **Legal risk**: Applicable regulations and enforcement precedents (if any)

---

## 1. Pressure & Urgency

### Fake Scarcity
- **What it looks like**: "Only 2 left in stock!" or "3 people viewing this" when inventory is not actually limited or numbers are fabricated.
- **How to detect it in code**: Static strings like "Only X left", hardcoded low numbers, random number generators near stock/availability text, countdown displays without real inventory API backing.
- **Ethical alternative**: Show real inventory counts from a database. If stock is genuinely low, display it. Never fabricate or exaggerate scarcity.
- **Legal risk**: FTC enforcement (misleading advertising). EU Unfair Commercial Practices Directive Art. 6.

### Fake Urgency
- **What it looks like**: Countdown timers that reset on refresh, "Deal expires in 00:14:32" with no real deadline, pulsing "Act now!" banners.
- **How to detect it in code**: `setInterval`/`setTimeout` countdown timers without server-side deadline validation, client-side-only expiry timestamps, timers that reset on page load.
- **Ethical alternative**: If a deadline is real (flash sale, limited-time offer), show it with a server-backed timestamp. When the timer expires, the offer genuinely ends. No fake countdowns.
- **Legal risk**: FTC enforcement. EU Omnibus Directive (Dec 2022) explicitly bans fake urgency.

### Confirmshaming
- **What it looks like**: Decline options written to guilt the user — "No thanks, I don't want to save money" or "I'll stay uninformed" instead of a neutral "No thanks."
- **How to detect it in code**: Modal/dialog decline buttons with negative self-referential language ("I don't want", "I'll miss out", "No, I prefer"). Asymmetric tone between accept and decline options.
- **Ethical alternative**: Use neutral, respectful language for both options. "Accept" / "No thanks" or "Subscribe" / "Skip". The user's choice should never be framed as a mistake.
- **Legal risk**: None specific, but damages brand trust. NNGroup research: confirmshaming increases short-term opt-ins but decreases long-term trust.

### Nagging
- **What it looks like**: Repeated permission requests, recurring modals after dismissal, "Rate this app" every session, push notification prompts that reappear after decline.
- **How to detect it in code**: Missing persistence of dismissal state (no `localStorage`/cookie/DB flag after decline), modals triggered on every page load without checking prior dismissal, notification permission re-prompts without user-initiated action.
- **Ethical alternative**: Ask once. Store the user's decline. Offer the option again only in a settings page or after a natural trigger (e.g., user completes a milestone). Respect "Don't ask again."
- **Legal risk**: GDPR recital 32 (freely given consent). Apple App Store and Google Play guidelines restrict repetitive permission prompts.

---

## 2. Deception & Misdirection

### Trick Wording
- **What it looks like**: Double negatives in opt-out checkboxes ("Uncheck to not unsubscribe"), confusing toggle labels where "on" means "disabled."
- **How to detect it in code**: Checkbox labels containing "not", "un-", double negatives. Toggle/switch components where `checked=true` maps to an opt-out action. Inverted boolean logic in consent forms.
- **Ethical alternative**: Use positive, direct language. "Send me marketing emails" (checked = yes). Single negation only. Labels describe what happens when enabled.
- **Legal risk**: GDPR Art. 7 (clear and plain language for consent). CCPA requires clear opt-out mechanisms.

### Disguised Ads
- **What it looks like**: Advertisements styled to look like content, navigation, or system UI. "Download" buttons that are ads. Sponsored content without disclosure.
- **How to detect it in code**: Ad components without "Sponsored" or "Ad" labels, affiliate links without disclosure, promotional content in content feeds without visual differentiation.
- **Ethical alternative**: Clearly label all advertising and sponsored content. Use visual differentiation (background color, border, "Sponsored" badge). Follow FTC endorsement guidelines.
- **Legal risk**: FTC Endorsement Guidelines (16 CFR Part 255). EU Unfair Commercial Practices Directive. Fines up to $50K per violation.

### Fake Social Proof
- **What it looks like**: Fabricated testimonials, fake review counts, manufactured "12,847 people signed up today" counters, stock photos for "real users."
- **How to detect it in code**: Hardcoded testimonial objects without real user data source, static review counts not from a database, random number generators for "users online" or "recent signups."
- **Ethical alternative**: Use real testimonials with attribution. Show genuine metrics from your database. If you don't have social proof yet, omit it rather than fabricate it.
- **Legal risk**: FTC enforcement (Amazon $30M fine for fake reviews, 2023). EU Omnibus Directive bans fake reviews.

### Visual Interference
- **What it looks like**: Making the preferred option (for the business) visually dominant while hiding alternatives — large colorful "Accept All" button with tiny gray "Manage preferences" link.
- **How to detect it in code**: Button pairs where one is `primary`/`filled` and the other is `text`/`link`/unstyled. Significant size asymmetry between accept and reject actions. Different visual hierarchy for options that should have equal weight.
- **Ethical alternative**: Give all options equal visual weight. Accept and Reject buttons should be the same size, similar prominence. Use secondary variant (outlined) for both, or primary for both.
- **Legal risk**: GDPR Art. 7 + EDPB Guidelines 05/2020. French CNIL fined Google €150M and Facebook €60M for cookie consent asymmetry (2022).

---

## 3. Hidden Information

### Hidden Costs
- **What it looks like**: Service fees, shipping costs, taxes, or "processing fees" revealed only at the final checkout step. Base price prominently shown, total price buried.
- **How to detect it in code**: Price display components that exclude fees/tax, fee calculations only in the final checkout step, cart/order summaries that add line items only at payment.
- **Ethical alternative**: Show the total price (or price range with "plus tax") from the first moment a price is displayed. Break down all fees early in the flow. No surprises at checkout.
- **Legal risk**: FTC Click-to-Cancel Rule (2024). EU Consumer Rights Directive Art. 6. Epic Games $245M FTC fine included hidden charges.

### Hidden Subscription
- **What it looks like**: Free trial that auto-converts to paid without clear disclosure. "Start free" button that requires credit card with no prominent conversion notice. Cancellation path hidden in account settings maze.
- **How to detect it in code**: Trial signup flows that collect payment info without prominent conversion disclosure, missing "You will be charged $X/mo on [date]" text near the submit button, no pre-charge reminder email logic.
- **Ethical alternative**: Clearly state conversion terms next to the signup button: "After 14 days, you'll be charged $X/month. Cancel anytime." Send a reminder email 3 days before conversion. Provide one-click cancellation.
- **Legal risk**: FTC Click-to-Cancel Rule (2024). Amazon FTC settlement ($30M) for Prime subscription practices. GDPR Art. 7.

### Comparison Prevention
- **What it looks like**: Making it intentionally difficult to compare products or plans — different units, missing features in comparison tables, no side-by-side view.
- **How to detect it in code**: Pricing components without feature comparison tables, plan cards that show different feature sets without alignment, missing "Compare plans" functionality.
- **Ethical alternative**: Provide a clear feature comparison table. Use consistent units. Show all plans side-by-side with aligned feature rows and checkmarks/crosses.
- **Legal risk**: EU Consumer Rights Directive (transparency obligation). No specific fine precedent, but contributes to unfair commercial practices claims.

---

## 4. Obstruction

### Hard to Cancel
- **What it looks like**: Cancellation requires calling a phone number, navigating a multi-step retention flow, or finding a hidden settings page. Signup takes 1 click, cancellation takes 15 minutes.
- **How to detect it in code**: No cancellation route/page in the app, cancellation behind "Contact us" links, multi-step cancellation flows with more than 2 confirmation steps, retention offers that block the cancel button.
- **Ethical alternative**: Cancellation must be as easy as signup. Provide a clear "Cancel subscription" button in account settings. Maximum 2 steps: click Cancel → Confirm. Optional: ask for feedback (but don't block cancellation on it).
- **Legal risk**: FTC Click-to-Cancel Rule (2024, effective 2025). EU Consumer Rights Directive Art. 11. California AB-390 auto-renewal law.

### Forced Action
- **What it looks like**: Requiring users to create an account to view content, forcing app downloads to access mobile content, requiring social media sharing to unlock features.
- **How to detect it in code**: Auth guards on content pages that don't require personalization, app-download interstitials blocking mobile web content, feature gates tied to social sharing actions.
- **Ethical alternative**: Let users access content without accounts where possible. Offer account creation as optional enhancement. Never gate content behind social sharing.
- **Legal risk**: None specific, but violates GDPR data minimization (Art. 5) if account creation collects unnecessary data for the service provided.

### Sneaking
- **What it looks like**: Items silently added to cart during checkout. Pre-selected add-ons or insurance. Automatically opted into marketing emails during purchase.
- **How to detect it in code**: Cart logic that adds items programmatically without user action, pre-checked addon checkboxes in checkout flows, default-selected upsell options, marketing consent checkboxes that default to checked.
- **Ethical alternative**: Cart contains only what the user explicitly added. Add-ons and upsells are presented but never pre-selected. All optional checkboxes start unchecked.
- **Legal risk**: GDPR Art. 7 (pre-ticked boxes don't constitute valid consent — Planet49 ruling). FTC enforcement. EU Consumer Rights Directive.

---

## 5. Preselection

### Preselection
- **What it looks like**: Non-essential options pre-checked during signup or checkout — newsletter subscription, data sharing consent, premium plan pre-selected over free tier.
- **How to detect it in code**: Checkbox components with `defaultChecked={true}` or `checked` for optional/consent items, radio groups defaulting to the most expensive option, `<select>` defaulting to paid tiers.
- **Ethical alternative**: All optional checkboxes start unchecked. Plan selection defaults to the free/lowest tier or shows no default. Let the user make an affirmative choice.
- **Legal risk**: GDPR Art. 7(2) + Planet49 ruling (2019): pre-ticked boxes do NOT constitute valid consent. TTDSG §25 (Germany). EU Consumer Rights Directive Art. 22.

### Consent Asymmetry
- **What it looks like**: "Accept All" is a large, colorful button. "Manage preferences" is a small, gray text link. Accepting is 1 click; rejecting requires navigating multiple screens.
- **How to detect it in code**: Cookie/consent banners where accept and reject have different component variants (Button vs Link), different sizes, different colors, or different click depth (accept = 1 click, reject = 2+ clicks through a settings panel).
- **Ethical alternative**: Accept and Reject buttons must have equal visual weight — same size, same prominence, same click depth. Use Button component for both. Offer granular controls in an optional third path.
- **Legal risk**: GDPR Art. 7 + EDPB Guidelines 05/2020. CNIL fined Google €150M and Facebook €60M (2022). German TTDSG §25.

---

## Cognitive Biases Exploited by Dark Patterns

Understanding why dark patterns work helps you build ethical alternatives:

| Bias | Dark Pattern Exploitation | Ethical Application |
|------|--------------------------|---------------------|
| Loss aversion | Fake scarcity, confirmshaming | Genuine limited offers, honest risk communication |
| Authority bias | Fake social proof, disguised ads | Real testimonials, transparent sponsorship |
| Default effect | Preselection, sneaking | Smart defaults that serve the user's interest |
| Anchoring | Hidden costs (low anchor, high total) | Show total price upfront (anchor to real cost) |
| Sunk cost | Hard to cancel (invested effort) | Easy cancellation (earned loyalty > trapped users) |
| Status quo bias | Consent asymmetry (accept is easier) | Equal-weight options (user chooses freely) |

---

## Legal Context Summary

| Regulation | Scope | Key Requirements | Max Penalty |
|-----------|-------|-----------------|-------------|
| GDPR (EU) | Consent, data processing | Freely given consent, no pre-ticked boxes, clear language | 4% global revenue or €20M |
| TTDSG (DE) | Cookie consent | Accept/reject equal prominence | €300,000 per violation |
| FTC (US) | Consumer protection | No deceptive practices, Click-to-Cancel rule | Varies; $245M (Epic), $30M (Amazon) |
| CCPA (CA) | Privacy, opt-out | Clear opt-out, no dark patterns in opt-out flows | $7,500 per intentional violation |
| EU Omnibus Directive | Consumer rights | Ban on fake reviews, fake urgency, hidden costs | Member state penalties |
| EU Consumer Rights Directive | E-commerce | Price transparency, easy cancellation, no sneaking | Member state penalties |

---

## Quick Reference: Detection Checklist

Before shipping any feature involving consent, checkout, subscriptions, or user decisions:

1. **Equal weight test**: Do all options (accept/reject, subscribe/skip, buy/cancel) have equal visual prominence?
2. **No surprises test**: Is the total cost visible from the first price display? Are all fees disclosed?
3. **One-click reversal test**: Can the user undo their action (unsubscribe, cancel, opt out) as easily as they did it?
4. **Neutral language test**: Are decline options written in neutral tone without guilt or shame?
5. **Real data test**: Are all numbers (stock counts, user counts, reviews, timers) backed by real data?
6. **Respect decline test**: When a user says "no," does the system remember and stop asking?
7. **Transparency test**: Would you be comfortable if a regulator reviewed this UI flow?
