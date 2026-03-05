export interface NavLink {
  title: string;
  slug: string;
}

export interface NavGroup {
  label: string;
  collapsed?: boolean;
  links: NavLink[];
}

export const navigation: NavGroup[] = [
  {
    label: 'Get Started',
    links: [
      { title: 'Home', slug: 'index' },
      { title: 'Setup in Detail', slug: 'setup-detail' },
      { title: 'Project Planning', slug: 'project-planning' },
      { title: 'Warp Integration', slug: 'warp' },
      { title: 'FAQ', slug: 'faq' },
    ],
  },
  {
    label: 'Workflows',
    links: [
      { title: 'Daily Workflow', slug: 'workflow' },
      { title: 'Advanced Features', slug: 'advanced-features' },
    ],
  },
  {
    label: 'How It Works',
    collapsed: true,
    links: [
      { title: 'Overview', slug: 'architecture' },
      { title: 'Bash Scripts', slug: 'scripts' },
      { title: 'Gamification', slug: 'gamification' },
      { title: 'Hooks', slug: 'hooks' },
      { title: 'MCP Servers', slug: 'mcp-servers' },
      { title: 'Companion Skills', slug: 'companion-skills' },
      { title: 'Permissions & Safety', slug: 'safety' },
      { title: 'Personalization', slug: 'personalization' },
      { title: 'Plugin Structure', slug: 'plugin' },
      { title: 'Runtime State', slug: 'runtime' },
      { title: 'Self-Improving System', slug: 'self-improving' },
      { title: 'Skills Reference', slug: 'skills' },
      { title: 'Slash Commands', slug: 'command-flow' },
      { title: 'Status Line', slug: 'status-line' },
      { title: 'Sub-Agents', slug: 'agents' },
      { title: 'Templates', slug: 'templates' },
      { title: 'Testing Strategy', slug: 'testing' },
      { title: 'Vibe Dashboard', slug: 'dashboard' },
    ],
  },
  {
    label: 'Reference',
    collapsed: true,
    links: [
      { title: 'UI Pattern Guide', slug: 'ui-patterns' },
      { title: 'Business Patterns', slug: 'business-patterns' },
      { title: 'Animation Patterns', slug: 'animation-patterns' },
      { title: 'Glossary', slug: 'glossary' },
    ],
  },
  {
    label: 'Changelog',
    links: [
      { title: 'Changelog', slug: 'releases' },
    ],
  },
];

/** Flat ordered list of all pages (for prev/next navigation) */
export const pageOrder: NavLink[] = navigation.flatMap((g) => g.links);

/** Look up section label for a given slug */
export function getSectionLabel(slug: string): string | undefined {
  const group = navigation.find((g) => g.links.some((l) => l.slug === slug));
  return group?.label;
}

/** Get prev/next pages for a given slug */
export function getPrevNext(slug: string): { prev?: NavLink; next?: NavLink } {
  const idx = pageOrder.findIndex((p) => p.slug === slug);
  return {
    prev: idx > 0 ? pageOrder[idx - 1] : undefined,
    next: idx < pageOrder.length - 1 ? pageOrder[idx + 1] : undefined,
  };
}
