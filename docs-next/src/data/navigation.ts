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
    label: 'Workflows',
    links: [
      { title: 'Core Workflow', slug: 'workflow' },
      { title: 'Advanced Features', slug: 'advanced-features' },
      { title: 'Personalization', slug: 'personalization' },
      { title: 'Gamification', slug: 'gamification' },
      { title: 'Tips & Troubleshooting', slug: 'tips' },
      { title: 'Example Session', slug: 'example-session' },
    ],
  },
  {
    label: 'How It Works',
    collapsed: true,
    links: [
      { title: 'Overview', slug: 'architecture' },
      { title: 'Plugin Structure', slug: 'plugin' },
      { title: 'Sub-Agents', slug: 'agents' },
      { title: 'Hooks', slug: 'hooks' },
      { title: 'MCP Servers', slug: 'mcp-servers' },
      { title: 'Slash Commands', slug: 'command-flow' },
      { title: 'Skills Reference', slug: 'skills' },
      { title: 'Bash Scripts', slug: 'scripts' },
      { title: 'Templates', slug: 'templates' },
      { title: 'Runtime State', slug: 'runtime' },
      { title: 'Permissions & Safety', slug: 'safety' },
      { title: 'Self-Improving System', slug: 'self-improving' },
      { title: 'User Profiles', slug: 'profile-system' },
      { title: 'Warp Integration', slug: 'warp' },
      { title: 'Vibe Dashboard', slug: 'dashboard' },
    ],
  },
  {
    label: 'Reference',
    collapsed: true,
    links: [
      { title: 'Slash Commands', slug: 'commands' },
      { title: 'UI Pattern Guide', slug: 'ui-patterns' },
      { title: 'Business Patterns', slug: 'business-patterns' },
      { title: 'Glossary', slug: 'glossary' },
      { title: 'FAQ', slug: 'faq' },
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
