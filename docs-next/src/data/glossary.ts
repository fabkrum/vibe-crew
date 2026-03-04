export interface GlossaryTerm {
  term: string;
  definition: string;
  category: 'agent' | 'workflow' | 'tool' | 'design';
  learnMoreUrl?: string;
  learnMoreLabel?: string;
}

export const glossaryCategories: Record<GlossaryTerm['category'], string> = {
  agent: 'Agents',
  workflow: 'Workflow & Process',
  tool: 'Tools & Infrastructure',
  design: 'Design & Quality',
};

export const glossaryCategoryColors: Record<GlossaryTerm['category'], 'purple' | 'blue' | 'amber' | 'green'> = {
  agent: 'purple',
  workflow: 'blue',
  tool: 'amber',
  design: 'green',
};

export const glossary: GlossaryTerm[] = [
  {
    term: 'Agent',
    category: 'agent',
    definition: 'A specialized AI team member that handles one specific job. VibeCrew has 14 agents &mdash; think of them like departments in a company. One writes code, another reviews it, another handles documentation, and so on. Each agent is tuned for its role, so the right expert always handles the right task.',
    learnMoreUrl: 'https://docs.anthropic.com/en/docs/build-with-claude/agentic-tool-use',
    learnMoreLabel: 'Anthropic: Agentic tool use',
  },
  {
    term: 'Backlog',
    category: 'workflow',
    definition: 'Your project&rsquo;s to-do list, stored as a file (<code>.vibecrew/backlog.json</code>). It contains every feature you want to build, ranked by priority. Each item includes a name, a short description of what it does, how complex it is, and whether it&rsquo;s been started yet. The <code>/run-backlog</code> command works through this list automatically.',
  },
  {
    term: 'Builder',
    category: 'agent',
    definition: 'The agent that actually writes your application code. When it&rsquo;s time to turn a plan into working software, the Builder takes the feature specification and implements it &mdash; creating files, writing functions, and connecting components. It works in an isolated copy of your project so that its work doesn&rsquo;t interfere with your main codebase until it&rsquo;s ready.',
  },
  {
    term: 'CLAUDE.md',
    category: 'tool',
    definition: 'A special instruction file at the root of your project that Claude reads every time a session starts. Think of it as a &ldquo;house rules&rdquo; document &mdash; it tells Claude about your project&rsquo;s conventions, patterns, and hard-won lessons from previous sessions. VibeCrew keeps it under 200 lines so it stays fast to read.',
    learnMoreUrl: 'https://docs.anthropic.com/en/docs/claude-code/memory',
    learnMoreLabel: 'Anthropic: Claude Code memory',
  },
  {
    term: 'Code Auditor',
    category: 'agent',
    definition: 'An agent that examines an existing codebase to understand how it works. When you bring an existing project to VibeCrew (via <code>/onboard</code>), the Code Auditor reads through your code, identifies the patterns and conventions already in use, and creates a CLAUDE.md file so future sessions respect your project&rsquo;s established style.',
  },
  {
    term: 'Code Reviewer',
    category: 'agent',
    definition: 'An agent that reads through newly written code and checks it for problems &mdash; like having a colleague review your work before it ships. It verifies the code matches the feature specification, follows the technology choices in the TDR, and respects the project&rsquo;s coding conventions. Triggered by the <code>/review</code> command.',
  },
  {
    term: 'Code Simplifier',
    category: 'agent',
    definition: 'An agent that finds ways to make your code leaner. It looks for unused code that can be deleted, over-complicated abstractions that can be flattened, and places where the same thing is done in different ways. Think of it as a professional organizer for your codebase. Triggered by <code>/simplify</code>.',
  },
  {
    term: 'Context Window',
    category: 'tool',
    definition: 'The amount of information the AI can &ldquo;hold in its head&rdquo; during a single conversation. Just like a person can only think about so many things at once, the AI has a limit on how much text it can process. VibeCrew carefully manages this &mdash; targeting less than 50% usage and showing warnings at 45% and 60% to prevent slowdowns.',
    learnMoreUrl: 'https://docs.anthropic.com/en/docs/build-with-claude/context-windows',
    learnMoreLabel: 'Anthropic: Context windows',
  },
  {
    term: 'Design Discovery',
    category: 'design',
    definition: 'A guided conversation that happens early in your project to figure out how your app should look and feel. It asks questions in three rounds: first about your product and audience, then about visual style preferences, and finally about specific component choices. The result is a design system file and a brief that all agents reference when building your UI.',
  },
  {
    term: 'Design System',
    category: 'design',
    definition: 'A single CSS file (<code>design-system.css</code>) that defines your project&rsquo;s visual language &mdash; colors, fonts, spacing, button styles, and more. Created during Tier 1 based on your Design Discovery answers. Every component the Builder creates uses these shared values, ensuring your whole app looks consistent without manual styling.',
  },
  {
    term: 'Doc Generator',
    category: 'agent',
    definition: 'The agent responsible for keeping your project&rsquo;s documentation up to date. After features are built, it writes session summaries, updates the changelog, creates feature documentation, and prepares release notes. It runs during the <code>/wrap</code> command to make sure documentation never falls behind the code.',
  },
  {
    term: 'Feature Cycle',
    category: 'workflow',
    definition: 'The six-step process every feature goes through: <strong>Plan</strong> (decide what to build) &rarr; <strong>UI Design</strong> (sketch the interface) &rarr; <strong>Code</strong> (write the software) &rarr; <strong>Test</strong> (verify it works) &rarr; <strong>Review</strong> (check for quality) &rarr; <strong>Docs</strong> (document it). This cycle repeats for each feature, ensuring nothing is shipped half-baked.',
  },
  {
    term: 'Foundation',
    category: 'workflow',
    definition: 'The collection of planning documents created before any code is written. Includes the project vision, design system, technology decisions, architecture diagrams, feature roadmap, and CLAUDE.md. Think of it as the blueprint phase &mdash; you wouldn&rsquo;t start building a house without plans, and VibeCrew won&rsquo;t let you start coding without a foundation.',
  },
  {
    term: 'Gamification',
    category: 'design',
    definition: 'An optional feature that turns your development sessions into a game-like experience. You earn XP for completing tasks, unlock badges for milestones, build skill trees, and maintain streaks for consistent work. It&rsquo;s entirely optional &mdash; you can turn it on, use a lighter version, or disable it completely via the <code>/profile</code> command.',
  },
  {
    term: 'Handoff',
    category: 'workflow',
    definition: 'A summary document generated by the <code>/handoff</code> command when you need to continue work in a new session. It captures what was done, what&rsquo;s in progress, and what comes next &mdash; like leaving detailed notes for yourself (or a colleague) to pick up exactly where you left off without losing context.',
  },
  {
    term: 'Hook',
    category: 'tool',
    definition: 'An automatic safety check that runs behind the scenes at specific moments &mdash; like when you start a session, save a file, or finish a task. Hooks enforce rules without the AI needing to remember them, which makes them faster and more reliable. For example, a hook prevents you from writing code before the project foundation is ready.',
    learnMoreUrl: 'https://docs.anthropic.com/en/docs/claude-code/hooks',
    learnMoreLabel: 'Anthropic: Claude Code hooks',
  },
  {
    term: 'Inline Agent',
    category: 'agent',
    definition: 'An agent that works directly inside your main conversation, sharing the same context window. This is efficient for quick tasks (like running checks or routing decisions) but means its work counts against your session&rsquo;s memory limit. Compare with a <em>Worktree Agent</em>, which works in its own separate space.',
  },
  {
    term: 'MCP',
    category: 'tool',
    definition: 'Short for <strong>Model Context Protocol</strong> &mdash; a standard way for AI to connect to external tools and services. Think of it like USB for AI: a universal plug that lets Claude talk to databases, testing tools, documentation libraries, and more. VibeCrew ships with 9 MCP connections pre-configured.',
    learnMoreUrl: 'https://modelcontextprotocol.io',
    learnMoreLabel: 'Model Context Protocol',
  },
  {
    term: 'MCP Server',
    category: 'tool',
    definition: 'A service that gives Claude access to a specific tool through MCP. Each server adds a capability &mdash; for example, Context7 provides access to library documentation, Playwright lets Claude test web pages, and Supabase connects to your database. You can think of each server as a specialist tool in Claude&rsquo;s toolbox.',
    learnMoreUrl: 'https://modelcontextprotocol.io/examples',
    learnMoreLabel: 'MCP: Example servers',
  },
  {
    term: 'Opponent Processor',
    category: 'agent',
    definition: 'An agent that plays devil&rsquo;s advocate. After technology decisions are made, the Opponent Processor deliberately challenges them &mdash; looking for risks, blind spots, and alternatives that might have been overlooked. It produces a structured debate showing pros and cons for each choice. Triggered by <code>/reconsider</code>.',
  },
  {
    term: 'Performance Coach',
    category: 'agent',
    definition: 'An agent that watches how your sessions go and suggests improvements. It looks for patterns like repeated mistakes, wasted effort, or missed best practices. When it spots a recurring issue, it can propose adding a new rule to your CLAUDE.md &mdash; making the system permanently smarter based on real experience.',
  },
  {
    term: 'Phase Gate',
    category: 'workflow',
    definition: 'A built-in checkpoint that blocks certain actions until prerequisites are met. The most important one prevents any application code from being written until the Tier 1 foundation is complete. This ensures you always have a solid plan before coding begins &mdash; it&rsquo;s like a construction permit that won&rsquo;t be issued until blueprints are approved.',
  },
  {
    term: 'Profile',
    category: 'tool',
    definition: 'Your personal preferences, stored in the project config. It covers eight areas: your technical role, coding experience, how much you want to oversee, PR review style, how detailed you want explanations, gamification preference, learning mode, and risk tolerance. Every agent reads your profile and adapts its behavior &mdash; a founder gets different explanations than a senior developer.',
  },
  {
    term: 'Quality Gate',
    category: 'workflow',
    definition: 'An automatic check that runs every time a task finishes. It scans your modified files for type errors, linting issues, and build failures. If something is broken, it catches it immediately rather than letting problems pile up. Think of it as an automatic quality inspector at the end of every assembly line step.',
  },
  {
    term: 'Roadmap',
    category: 'workflow',
    definition: 'The initial plan of features to build, created during Tier 1. Typically 5&ndash;8 features ranked by how much value they deliver to users. The roadmap becomes the starting point for your backlog and gives the whole project a clear direction from day one.',
  },
  {
    term: 'Session Learning',
    category: 'tool',
    definition: 'A lesson learned from a development session that gets permanently added to your CLAUDE.md. For example, if the Performance Coach notices you keep running into the same issue, it proposes a rule to prevent it in future sessions. The system keeps a maximum of 15 learnings and automatically removes the oldest ones to stay concise.',
  },
  {
    term: 'Stack Scout',
    category: 'agent',
    definition: 'The research agent that evaluates technology options for your project. Before any code is written, Stack Scout searches the web, reads library documentation, and compares alternatives to recommend the best tools for your specific needs. It produces a Technology Decision Record (TDR) explaining what was chosen and why.',
  },
  {
    term: 'TDR',
    category: 'tool',
    definition: 'Short for <strong>Technology Decision Record</strong> &mdash; a document that lists every major technology choice for your project and the reasoning behind it. Framework, database, hosting, authentication &mdash; each decision is recorded with alternatives that were considered. This prevents second-guessing later and keeps all agents aligned on the same tech stack.',
  },
  {
    term: 'Tier 1',
    category: 'workflow',
    definition: 'The first phase of any VibeCrew project: <strong>planning before coding</strong>. It&rsquo;s a one-time, step-by-step process that creates your project vision, design system, technology decisions, architecture diagrams, and feature roadmap. No application code can be written until Tier 1 is complete. Think of it as the architect phase before construction begins.',
  },
  {
    term: 'Tier 2',
    category: 'workflow',
    definition: 'The second phase: <strong>building features</strong>. After the Tier 1 foundation is set, Tier 2 runs the Feature Cycle repeatedly &mdash; one feature at a time, each going through Plan &rarr; UI Design &rarr; Code &rarr; Test &rarr; Review &rarr; Docs. This is the phase where your application actually gets built, feature by feature.',
  },
  {
    term: 'Vibe Dashboard',
    category: 'tool',
    definition: 'A web page you can open in your browser to see your project&rsquo;s status at a glance. It shows a Kanban board of features (planned, in progress, done), session statistics, Vibe Score trends over time, test coverage, and any achievements you&rsquo;ve earned. It&rsquo;s a visual control center for your project.',
  },
  {
    term: 'Vibe Score',
    category: 'design',
    definition: 'A quality rating for each development session, scored from 0 to 130. It measures things like how efficient your prompts were, whether tests were written, if documentation is current, and whether the workflow was followed properly. A high score means the session was clean and productive; deductions highlight areas to improve.',
  },
  {
    term: 'VISION.md',
    category: 'tool',
    definition: 'The first document created in any VibeCrew project. It captures <em>what</em> you&rsquo;re building, <em>who</em> it&rsquo;s for, and <em>what success looks like</em>. Every agent references this document to make sure decisions align with the project&rsquo;s purpose. Think of it as your project&rsquo;s north star.',
  },
  {
    term: 'Worktree Agent',
    category: 'agent',
    definition: 'An agent that works in a completely separate copy of your project, with its own memory space. When VibeCrew needs to do heavy research, review code, or evaluate options, it sends a Worktree Agent so that work happens in isolation. This keeps your main session fast and focused &mdash; like sending a colleague to a library to do research while you keep working at your desk.',
  },
  {
    term: 'WIP Limit',
    category: 'workflow',
    definition: 'Short for <strong>Work-In-Progress Limit</strong> &mdash; a rule that prevents more than 2 features from being actively worked on at the same time. This prevents spreading too thin and ensures each feature gets the attention it needs to be completed properly before starting the next one.',
  },
];
