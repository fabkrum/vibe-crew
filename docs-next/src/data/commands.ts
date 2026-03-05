export interface Command {
  name: string;
  category: string;
  purpose: string;
  agent: string;
  tier: string;
  args?: string;
}

export const commands: Command[] = [
  { name: '/setup', category: 'Setup', purpose: 'Verify dependencies, detect terminal, initialize .vibecrew/', agent: 'Session Startup', tier: 'Any', args: '' },
  { name: '/new-project', category: 'Setup', purpose: '7-step foundation: VISION, design system, TDR, roadmap, architecture diagrams, CLAUDE.md, commit', agent: 'Orchestrator, Stack Scout, Builder, Opponent', tier: '1', args: '' },
  { name: '/onboard', category: 'Setup', purpose: 'Existing project analysis, convention extraction, CLAUDE.md generation, persistent analysis docs. Use --refresh to update analysis only', agent: 'Code Auditor', tier: '1', args: '' },
  { name: '/plan-features', category: 'Planning', purpose: 'Define backlog specs: problem statement, acceptance criteria, priority, complexity, dependencies', agent: 'Orchestrator', tier: '2', args: '' },
  { name: '/idea', category: 'Planning', purpose: '1-line capture to backlog.json with status "unplanned". Zero context cost', agent: 'None (script only)', tier: 'Any', args: '"text"' },
  { name: '/status', category: 'Planning', purpose: 'Full project dashboard: foundation, backlog, active feature, recent scores', agent: 'None (script only)', tier: 'Any', args: '' },
  { name: '/new-feature', category: 'Development', purpose: 'Branch creation, checkpoint, 6-phase tracking, WIP limit enforcement', agent: 'Builder', tier: '2', args: '"name"' },
  { name: '/run-backlog', category: 'Development', purpose: 'Auto-execute features by priority via fresh-session Agent delegation. Stops on failure for human review. Use --parallel for wave-based parallel execution of independent features', agent: 'Builder, Verifier', tier: '2', args: '--parallel' },
  { name: '/quick', category: 'Development', purpose: 'Fast-track small fixes: code, quality gate, commit. No backlog entry or feature branch', agent: 'None (inline)', tier: '2', args: '"description"' },
  { name: '/check', category: 'Development', purpose: 'Run tests + build + lint + type-check without modifying code', agent: 'Verifier', tier: '2', args: '' },
  { name: '/simplify', category: 'Quality', purpose: 'Read-only analysis: dead code, abstractions, API surface. You approve each change', agent: 'Code Simplifier', tier: '2', args: '' },
  { name: '/apply-simplifications', category: 'Quality', purpose: 'Apply approved changes from /simplify analysis', agent: 'Code Simplifier', tier: '2', args: '' },
  { name: '/reconsider', category: 'Quality', purpose: "Devil's advocate analysis of TDR decisions, debate matrices, risk assessments", agent: 'Opponent Processor', tier: '1', args: '' },
  { name: '/replay', category: 'Quality', purpose: 'Create, list, or apply workflow templates from high-scoring sessions', agent: 'None (script only)', tier: '2', args: '' },
  { name: '/cost', category: 'Safety', purpose: 'Real-time cost dashboard: session, daily, weekly, monthly aggregates + pricing table', agent: 'None (script only)', tier: 'Any', args: '' },
  { name: '/undo', category: 'Safety', purpose: 'List checkpoints and recent commits, safely revert or reset', agent: 'None (script only)', tier: 'Any', args: '' },
  { name: '/audit', category: 'Safety', purpose: 'OWASP Top 10 scan: injection, auth, XSS, secrets, dependencies', agent: 'Security Auditor', tier: '2', args: '' },
  { name: '/heal', category: 'Safety', purpose: 'Fetch CI logs, diagnose failure, apply fix (max 3 attempts)', agent: 'CI Healer', tier: '2', args: '' },
  { name: '/wrap', category: 'Session', purpose: 'Quality gate, Vibe Score, coaching, commit, session log, gamification pipeline', agent: 'Verifier, Performance Coach, Doc Generator', tier: '2', args: '' },
  { name: '/handoff', category: 'Session', purpose: 'Generate structured context transfer document for next session', agent: 'None (script only)', tier: '2', args: '' },
  { name: '/recover-state', category: 'Session', purpose: 'Clear lock files and repair corrupted JSON state', agent: 'None (script only)', tier: 'Any', args: '' },
  { name: '/achievements', category: 'Gamification', purpose: 'Level, badges, skill tree, streaks, challenges + visual dashboard link', agent: 'None (script only)', tier: 'Any', args: '' },
  { name: '/quiz', category: 'Gamification', purpose: 'Interactive knowledge checks with educational explanations (Level 3+)', agent: 'None (inline)', tier: 'Any', args: '' },
  { name: '/review', category: 'Testing & Review', purpose: 'Code review against feature spec, TDR compliance, conventions. Findings by severity', agent: 'Code Reviewer', tier: '2', args: '' },
  { name: '/tdd', category: 'Testing & Review', purpose: 'Test-driven development cycle: write failing test, implement, verify green', agent: 'Verifier', tier: '2', args: '' },
  { name: '/e2e', category: 'Testing & Review', purpose: 'Generate Playwright E2E tests with Page Object Model', agent: 'Verifier', tier: '2', args: '' },
  { name: '/perf-test', category: 'Testing & Review', purpose: 'Generate k6 load/stress/spike/soak test suites', agent: 'Verifier', tier: '2', args: '' },
  { name: '/a11y', category: 'Testing & Review', purpose: 'WCAG 2.1 AA accessibility audit via axe-core', agent: 'Verifier', tier: '2', args: '' },
  { name: '/debug', category: 'Development', purpose: 'Structured debugging workflow with hypothesis testing', agent: 'Builder', tier: '2', args: '' },
  { name: '/release', category: 'Session', purpose: 'Generate release notes from git history and session logs', agent: 'Doc Generator', tier: '2', args: '' },
  { name: '/profile', category: 'Setup', purpose: 'Interview or preset selection for personalization', agent: 'None (inline)', tier: 'Any', args: '' },
  { name: '/fix-issue', category: 'Development', purpose: 'Fix an issue (GitHub/GitLab) — fetch, diagnose, implement, test, PR/MR with auto-close', agent: 'Builder, Verifier, Code Reviewer', tier: '2', args: '<number>' },
  { name: '/sync-issues', category: 'Planning', purpose: 'Import open issues by label into the VibeCrew backlog', agent: 'None (script only)', tier: '2', args: '--label <name> --limit <n>' },
  { name: '/system-review', category: 'Quality', purpose: 'Plugin meta-analysis, cross-project telemetry, ecosystem research', agent: 'System Reviewer', tier: 'Any', args: '' },
  { name: '/validate-skills', category: 'Quality', purpose: 'Evaluate skill schema quality, model-version tracking, A/B test recommendations', agent: 'None (script only)', tier: 'Any', args: '' },
  { name: '/install-skill', category: 'Setup', purpose: 'Install companion skills from GitHub repos, local paths, or company-internal sources with safety validation', agent: 'None (script only)', tier: 'Any', args: '<source>' },
  { name: '/pause', category: 'Session', purpose: 'Commit WIP, create handoff, store paused state, optionally clean up worktree', agent: 'None (script only)', tier: '2', args: '' },
  { name: '/resume', category: 'Session', purpose: 'Restore paused feature state, recreate worktree from preserved branch, continue work', agent: 'None (script only)', tier: '2', args: '' },
];

export const categories = [...new Set(commands.map((c) => c.category))];
