# Business Success Patterns

Agent-facing reference for conversion, trust, and user engagement patterns.
The Builder reads this during the Design Phase to proactively recommend
business-aligned UI decisions. The Code Reviewer checks against it.

Each pattern entry includes:
- **When to apply**: Trigger condition to check against the feature spec
- **What to do**: Concrete UI recommendation
- **Why it works**: Research-backed reasoning (include in explanations to the user)
- **Example**: Reference implementation or known product example

---

## 1. Landing & Marketing Pages

### Hero Section Formula
- **When to apply**: Any landing page, marketing page, or homepage
- **What to do**: Structure the hero as: headline (outcome, not feature) + subheadline (how it works in one sentence) + primary CTA + supporting visual. Keep above the fold.
- **Why it works**: Users form opinions in 50ms (Lindgaard et al.). StoryBrand framework: lead with the transformation, not the product. CXL research shows outcome-focused headlines outperform feature-focused by 28%.
- **Example**: Stripe — "Financial infrastructure for the internet" + clear CTA.

### Social Proof Placement
- **When to apply**: Any page with a conversion action (signup, purchase, subscribe)
- **What to do**: Place social proof (logos, testimonials, user counts) directly above or below the primary CTA. Use real numbers ("12,847 teams" not "thousands"). Show logos of recognizable customers in a row.
- **Why it works**: Cialdini's social proof principle. Baymard Institute: 60% of users actively look for reviews/trust signals before committing. Proximity to the action point maximizes impact.
- **Example**: Notion — customer logos bar between hero and features.

### CTA Hierarchy
- **When to apply**: Any page with more than one possible user action
- **What to do**: One primary CTA per viewport. Use Button primary variant for the main action, secondary/ghost for alternatives. Repeat the primary CTA after every 2-3 content sections on long pages.
- **Why it works**: Hick's Law — more choices increase decision time. CXL research: pages with a single clear CTA convert 13-28% better than pages with competing CTAs.
- **Example**: Linear — single "Start building" CTA, repeated at hero and page bottom.

### Pricing Page Psychology
- **When to apply**: Any pricing page or plan comparison
- **What to do**: Show 3 tiers (decoy effect). Highlight the recommended tier visually (border, "Most Popular" badge, slight scale-up). Put the recommended tier in the center. Show annual/monthly toggle with savings percentage. Include a brief FAQ below pricing.
- **Why it works**: Von Restorff isolation effect — visually distinct items are remembered. Decoy effect (Ariely): the third option makes the target option look better. Unbounce data: showing savings percentage increases annual plan adoption 20-30%.
- **Example**: Vercel — 3 tiers, Pro highlighted center, annual savings shown.

### FAQ Structure
- **When to apply**: Landing pages, pricing pages, onboarding pages
- **What to do**: Use Accordion component. Lead with objection-handling questions ("Is my data secure?", "Can I cancel anytime?"). Order by frequency of actual user concerns, not feature descriptions.
- **Why it works**: Addresses buying objections at the point of decision. Baymard: 21% of users abandon due to unanswered questions. Accordion reduces cognitive load per Hick's Law.
- **Example**: Stripe — FAQ section addresses security and compliance concerns first.

### Above-the-Fold Framework
- **When to apply**: Every page, but especially landing and signup pages
- **What to do**: Above the fold must answer three questions: (1) What is this? (2) What can I do here? (3) Why should I care? No scrolling required to understand the value proposition.
- **Why it works**: NNGroup: users spend 57% of viewing time above the fold. Krug's "Don't Make Me Think" — if users can't understand the page purpose instantly, they leave.
- **Example**: Slack — headline, subheadline, and CTA all visible without scrolling.

---

## 2. Onboarding & Activation

### First-Run Experience
- **When to apply**: Any feature that has a first-time state for new users
- **What to do**: Show a guided first action, not a feature tour. Lead the user to their activation moment (from VISION.md) within 3 clicks. Use a progress checklist (3-5 items) that persists across sessions until complete.
- **Why it works**: Fogg Behavior Model: Motivation is highest at signup — reduce friction to capitalize on it. Chameleon research: onboarding checklists increase activation rates by 30-40%.
- **Example**: Notion — immediately prompts creating a first page, not a product tour.

### Activation Moment
- **When to apply**: Core onboarding flow and empty states for primary features
- **What to do**: Design the shortest path from signup to the user experiencing core value. If `spec.expected_action` exists, the activation moment is that action. Remove every unnecessary step between signup and activation.
- **Why it works**: Product-led growth principle (Wes Bush): time-to-value is the #1 predictor of conversion from free to paid. Every extra step loses 20% of users (Heap Analytics).
- **Example**: Canva — users create their first design within 60 seconds of signing up.

### Progressive Profiling
- **When to apply**: Signup flows that need more than 3 fields of user data
- **What to do**: Ask only email (or OAuth) at signup. Collect additional profile data after the user has experienced value, spread across natural touchpoints.
- **Why it works**: Baymard Institute: every additional form field reduces conversion by ~3%. Collect data when users have motivation to continue (post-activation), not at the gate.
- **Example**: Spotify — signs up with email only, asks genre preferences after first play.

### Contextual Help vs Tutorials
- **When to apply**: Any feature with non-obvious interaction patterns
- **What to do**: Prefer contextual tooltips and inline hints over modal tutorials. Show help at the moment of need, not upfront. Use Tooltip for simple hints, Popover for richer guidance.
- **Why it works**: Krug: users don't read instructions. NNGroup: contextual help is 3x more effective than upfront tutorials because it arrives at the moment of relevance.
- **Example**: Figma — contextual tooltips appear on first interaction with each tool.

---

## 3. Forms & Data Collection

### Single-Column Layout
- **When to apply**: Every form with 3+ fields
- **What to do**: Stack all fields in a single column. Left-align labels above fields. Never use multi-column form layouts.
- **Why it works**: Baymard Institute: multi-column forms cause 28% more errors because users miss fields. Eye-tracking shows single-column creates a clear vertical flow.
- **Example**: Stripe Checkout — single column with labels above every field.

### Inline Validation
- **When to apply**: Every form with validation requirements
- **What to do**: Validate on blur (not on keystroke). Show success checkmarks for valid fields. Show error messages inline below the field via `aria-describedby`. Never clear the field on error.
- **Why it works**: Baymard: sites with inline validation see 22% higher completion rates. Validate on blur (not on type) avoids frustrating users mid-input. Luke Wroblewski's research confirms inline validation reduces errors by 47%.
- **Example**: GitHub signup — validates username availability on blur with inline feedback.

### Smart Defaults
- **When to apply**: Any form with predictable common values
- **What to do**: Pre-fill fields with the most common or contextually relevant values. Use browser autofill attributes (`autocomplete`). Default to the most popular option in select fields.
- **Why it works**: Fogg Behavior Model: reducing effort increases completion. NNGroup: smart defaults reduce form completion time by 25-40%.
- **Example**: Stripe — auto-detects country from IP, pre-fills currency.

### Error Message Clarity
- **When to apply**: Every form validation error
- **What to do**: Error messages must say what went wrong AND how to fix it. Use specific language ("Password must be at least 8 characters") not generic ("Invalid input"). Red color + icon, not color alone.
- **Why it works**: NNGroup: specific error messages reduce retry attempts by 50%. Accessibility: 8% of men are colorblind — icon + color ensures visibility for everyone.
- **Example**: Mailchimp — "Please enter a valid email address (e.g., name@example.com)".

### Field Count Optimization
- **When to apply**: Every form during design
- **What to do**: Audit every field — remove any that aren't strictly required for the action. If a field can be derived later (e.g., full name from first+last), skip it. Target 3-5 fields for signup forms.
- **Why it works**: Unbounce: reducing form fields from 11 to 4 increased conversions by 120%. Each field is a decision point that can cause abandonment.
- **Example**: Dropbox — email, password, and agreement checkbox. Three fields.

---

## 4. Trust & Credibility Signals

### Placement Rules
- **When to apply**: Any page where users take a commitment action (signup, payment, data submission)
- **What to do**: Place trust signals within visual proximity (within 200px) of the commitment action. Stack trust elements vertically below or beside the CTA button.
- **Why it works**: CXL Institute: trust signals placed near CTAs increase conversions by 11-42% depending on context. Proximity creates an implicit association between the action and the reassurance.
- **Example**: Shopify — trust badges directly below the "Start free trial" button.

### Social Proof Types (by context)
- **When to apply**: Based on what's available and the action's commitment level
- **What to do**: Match proof type to commitment level:
  - Low commitment (newsletter, free trial): user count, logo bar
  - Medium commitment (signup, data sharing): testimonials with photos and roles
  - High commitment (payment, contract): case studies, named testimonials, security badges
- **Why it works**: Cialdini: proof must be relevant and proportional to the ask. A user count suffices for a newsletter; payment needs explicit security assurance.
- **Example**: Basecamp — named testimonials with photos for signup, generic count for homepage.

### Risk Reversal
- **When to apply**: Any paid conversion point or high-commitment action
- **What to do**: State the guarantee explicitly near the payment CTA: "30-day money-back guarantee", "Cancel anytime", "No credit card required". Use Badge or inline text, not buried in terms.
- **Why it works**: Pedro Cortes / Flux Academy: risk reversal is the #1 conversion lever for SaaS. Removes the last psychological barrier. Baymard: 18% of users abandon checkout due to unclear return/refund policy.
- **Example**: Basecamp — "Cancel anytime. No questions asked." directly below CTA.

### Security Indicators
- **When to apply**: Payment forms, data collection forms, account settings
- **What to do**: Show lock icon + "Secure" text near sensitive fields. Display SSL/encryption badges near payment forms. Show "Your data is encrypted" near data collection.
- **Why it works**: Baymard: 18% of users abandon checkout due to security concerns. Visual security indicators reduce perceived risk even when the underlying security is identical.
- **Example**: Stripe Checkout — lock icon and "Powered by Stripe" near card fields.

---

## 5. Pricing & Payment

### Three-Tier Structure
- **When to apply**: Any pricing page or plan selection
- **What to do**: Offer exactly 3 tiers. The middle tier should be the target conversion plan. Include a clear feature comparison table below the tier cards.
- **Why it works**: Decoy effect (Dan Ariely): the lowest tier makes the middle tier look like better value. Three options satisfy comparison shoppers without causing choice paralysis. CXL: 3 tiers outperform 2 or 4+ in most SaaS contexts.
- **Example**: Vercel — Hobby / Pro / Enterprise. Pro is visually highlighted.

### Recommended Tier Highlighting
- **When to apply**: Pricing tiers display
- **What to do**: Visually distinguish the recommended tier: add a "Most Popular" Badge, use a contrasting border or background, optionally scale the card slightly larger. Place it in the center position.
- **Why it works**: Von Restorff isolation effect — the visually distinct item receives disproportionate attention. Center position bias (Rodway et al.): people prefer center-positioned items.
- **Example**: GitHub — Pro plan has "Most popular" badge and distinct border.

### Annual/Monthly Toggle
- **When to apply**: Any subscription pricing with both billing cycles
- **What to do**: Show both options with a Toggle or Switch. Display the savings percentage for annual ("Save 20%"). Default to annual to anchor on the lower per-month price.
- **Why it works**: Anchoring effect — seeing the annual price first makes monthly feel expensive. Showing savings as a percentage (not absolute) is more persuasive for lower price points (CXL research).
- **Example**: Notion — toggle defaults to annual, shows "Save 20%" badge.

---

## 6. Empty States & First Use

### Value Explanation
- **When to apply**: Every zero-data state in the application
- **What to do**: Never show a blank page. Show: (1) illustration or icon, (2) brief explanation of what will appear here, (3) primary action Button to create the first item. Optionally show sample data.
- **Why it works**: Krug: blank screens create uncertainty. Users don't know if it's broken or empty. A guided empty state converts first-time viewers into first-time users. Chameleon research: guided empty states increase feature adoption by 25%.
- **Example**: Notion — empty page shows "Press Enter to start writing" with template suggestions.

### Guided First Action
- **When to apply**: The primary feature's empty state
- **What to do**: Make the first-action CTA the most prominent element on the page. Use primary Button variant, large size. If possible, pre-fill or scaffold the first item to reduce effort.
- **Why it works**: Fogg Behavior Model: B = MAP (Behavior = Motivation + Ability + Prompt). The empty state IS the prompt — make the action easy and obvious.
- **Example**: Trello — empty board shows "Add a list" prompt, pre-creates a starter list.

### Sample Data
- **When to apply**: Features where the value is hard to visualize without data (dashboards, analytics, reports)
- **What to do**: Show realistic sample data with a clear "This is sample data — [Create your first X] to see your own" banner. Let users interact with the sample to understand the feature.
- **Why it works**: NNGroup: users understand features 3x faster when they can see them working with real-looking data. Removes the "chicken and egg" problem of needing data to see value.
- **Example**: Plausible Analytics — shows demo dashboard with real traffic data before signup.

---

## 7. Retention & Engagement

### Habit Loops
- **When to apply**: Features designed for repeated daily/weekly use
- **What to do**: Design for Cue → Routine → Reward. Make the trigger visible (notification badge, dashboard counter), the action effortless (one-click), and the reward immediate (visible progress, confirmation).
- **Why it works**: Nir Eyal's Hook Model. Habit formation requires consistent trigger-action-reward cycles. Products with daily habits have 2.5x higher retention (Mixpanel benchmark).
- **Example**: Duolingo — streak counter (cue) → daily lesson (routine) → XP animation (reward).

### Progress Mechanics
- **When to apply**: Multi-step processes, onboarding, learning paths, achievement systems
- **What to do**: Show progress visually (Progress bar, step counter, checklist). Use the endowed progress effect: start the bar at 20% instead of 0%.
- **Why it works**: Endowed progress effect (Nunes & Dreze): people given artificial advancement toward a goal show greater persistence. Progress bars increase completion by 40% (ConversionXL).
- **Example**: LinkedIn — profile completeness bar starts at 25% (photo counts as progress).

### Re-engagement
- **When to apply**: Users who haven't completed onboarding or haven't returned in 7+ days
- **What to do**: Design re-entry points that show what changed since last visit. Use a "Welcome back" state that surfaces new content or pending items rather than dumping the user on a stale page.
- **Why it works**: NNGroup: returning users need context restoration, not repetition. Showing "what's new" reduces re-learning friction and creates curiosity.
- **Example**: GitHub — "You missed X notifications" on return, not a blank dashboard.

---

## 8. Navigation & Information Architecture

### 5-7 Navigation Items
- **When to apply**: Primary navigation design (sidebar, top nav, or mobile nav)
- **What to do**: Limit top-level navigation to 5-7 items. Group secondary items under parent categories. If more than 7, audit for items that can be moved to settings, profile, or contextual menus.
- **Why it works**: Miller's Law — working memory holds 7 plus/minus 2 items. NNGroup research: navigation with 5-7 items has the fastest task completion times. More items = more scanning = slower decisions.
- **Example**: Linear — 6 top-level nav items, everything else in contextual menus.

### Trunk Test
- **When to apply**: Every page during design review
- **What to do**: Apply Krug's Trunk Test: if a user lands on any page without context, can they identify (1) what site this is, (2) what page they're on, (3) what the main sections are, (4) what they can do here? If any answer is unclear, improve navigation cues.
- **Why it works**: Krug's "Don't Make Me Think" — users arrive from search, shared links, and bookmarks. Every page must be self-orienting. Breadcrumbs, clear headings, and persistent nav solve this.
- **Example**: Every page has: logo (site identity), breadcrumb or page title (location), persistent nav (sections).

### F-Pattern Scanning
- **When to apply**: Content-heavy pages, landing pages, feature listings
- **What to do**: Place the most important content in the top-left area. Use strong left-aligned headings. Place CTAs in the natural scan path (after heading, after key content block, in right column on desktop).
- **Why it works**: NNGroup eye-tracking: users scan in an F-pattern — two horizontal stripes at top, then a vertical stripe down the left side. Content outside this pattern gets 60% less attention.
- **Example**: Medium articles — title and author at top-left, content follows the F-pattern.

---

## 9. Feedback & Completion

### Peak-End Rule
- **When to apply**: Multi-step flows (checkout, onboarding, wizards) and task completion moments
- **What to do**: Design the peak moment (most valuable step) and the end moment (completion) to be emotionally positive. Use animations, congratulatory copy, or celebratory UI at completion. Keep the lowest-friction steps at the beginning.
- **Why it works**: Kahneman's Peak-End Rule: people judge experiences by the peak intensity and the ending, not the average. A great completion moment colors the entire experience positively.
- **Example**: Stripe — successful payment shows a satisfying checkmark animation.

### Success Celebrations
- **When to apply**: Completion of primary actions (first item created, goal reached, purchase complete)
- **What to do**: Minor actions: Sonner toast with checkmark. Major milestones: full-screen moment with animation, congratulatory copy, and next-step suggestion. Match celebration intensity to action significance.
- **Why it works**: Variable reward theory (B.J. Fogg): positive feedback after action strengthens the habit loop. Dopamine release from visual reward increases likelihood of repeat behavior.
- **Example**: Duolingo — lesson complete shows confetti + XP animation + streak update.

### Next-Step Suggestions
- **When to apply**: Every task completion state
- **What to do**: After any completed action, suggest the logical next action. Use a Card or inline prompt: "Great, you created your project. Next: invite your team." Never show a dead-end success screen.
- **Why it works**: Zeigarnik effect — people remember incomplete tasks better than complete ones. Providing the next step keeps momentum and reduces drop-off between features.
- **Example**: Notion — after creating a page, suggests adding content blocks or sharing.

### Progress Indicators
- **When to apply**: Any multi-step process (checkout, onboarding, form wizard)
- **What to do**: Show a step indicator at the top: numbered steps or progress bar. Show current step, completed steps, and remaining steps. Keep step count visible throughout.
- **Why it works**: NNGroup: progress indicators reduce abandonment by up to 28% in multi-step forms. Users need to know how much effort remains before they commit to continuing.
- **Example**: Stripe Checkout — step indicator shows "Shipping → Payment → Review".
