/** Legacy hash redirects — old tab-based architecture page split into sub-pages */
export const architectureRedirects: Record<string, string> = {
  '#plugin': 'plugin.html',
  '#agents': 'agents.html',
  '#hooks': 'hooks.html',
  '#commands': 'command-flow.html',
  '#skills': 'skills.html',
  '#scripts': 'scripts.html',
  '#runtime': 'runtime.html',
  '#safety': 'safety.html',
  '#dashboard': 'dashboard.html',
};

/** Hash redirects from the old workflow.html page (sections split to sub-pages) */
export const workflowRedirects: Record<string, string> = {
  '#advanced': 'advanced-features.html#advanced',
  '#replay': 'advanced-features.html#replay',
  '#simplify': 'advanced-features.html#simplify',
  '#heal': 'advanced-features.html#heal',
  '#opponent': 'advanced-features.html#opponent',
  '#cost-system': 'advanced-features.html#cost-system',
  '#cost-dashboard': 'advanced-features.html#cost-dashboard',
  '#cost-guardrails': 'advanced-features.html#cost-guardrails',
  '#safety-hooks': 'advanced-features.html#safety-hooks',
  '#multi-lang': 'advanced-features.html#multi-lang',
  '#profile': 'personalization.html#profile',
  '#gamification': 'gamification.html#overview',
  '#xp-leveling': 'gamification.html#xp-leveling',
  '#badges-section': 'gamification.html#badges',
  '#skill-tree': 'gamification.html#skill-tree',
  '#streaks': 'gamification.html#streaks',
  '#challenges': 'gamification.html#challenges',
  '#quizzes': 'gamification.html#quizzes',
  '#achievements-dashboard': 'gamification.html#achievements-dashboard',
  '#efficiency': 'faq.html#faq',
  '#system-review': 'self-improving.html',
  '#troubleshooting': 'faq.html#troubleshooting',
};
