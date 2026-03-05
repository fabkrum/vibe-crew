<script setup>
import { computed } from "vue";

const props = defineProps({
  session: { type: Object, required: true },
  score: { type: Object, default: null },
});

const AGENT_COLORS = {
  "session-startup": "#6b7280",
  "workflow-orchestrator": "#8b5cf6",
  "stack-scout": "#3b82f6",
  builder: "#22c55e",
  verifier: "#f97316",
  "performance-coach": "#ec4899",
  "code-auditor": "#06b6d4",
  "doc-generator": "#eab308",
  "security-auditor": "#f43f5e",
  "code-simplifier": "#14b8a6",
  "ci-healer": "#a855f7",
  "opponent-processor": "#ef4444",
  "code-reviewer": "#0ea5e9",
  "system-reviewer": "#64748b",
};

function scoreColor(score) {
  if (score >= 90) return "#22c55e";
  if (score >= 70) return "#3b82f6";
  if (score >= 50) return "#eab308";
  return "#ef4444";
}

function formatTokens(n) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "M";
  if (n >= 1_000) return (n / 1_000).toFixed(1) + "K";
  return String(n);
}

const cacheHitRate = computed(() => {
  const t = props.session.tokens;
  if (!t) return null;
  const total = (t.input || 0) + (t.cache_read || 0);
  if (total === 0) return null;
  return Math.round(((t.cache_read || 0) / total) * 100);
});

const contextPeak = computed(() => {
  const ctx = props.session.context_window;
  if (!ctx) return null;
  return ctx.peak_percentage || ctx.peak_pct || null;
});

const agentsWithMetrics = computed(() => {
  const agents = props.session.agents || [];
  return agents.filter((a) => a.metrics && a.metrics.total_tool_calls > 0);
});

function barWidth(agent, type) {
  const m = agent.metrics;
  const total = m.total_tool_calls || 1;
  const count = type === "progress" ? m.progress_calls : type === "exploration" ? m.exploration_calls : m.neutral_calls;
  return (count / total) * 100 + "%";
}

function effColor(ratio) {
  if (ratio >= 0.35) return "#22c55e";
  if (ratio >= 0.20) return "#eab308";
  return "#ef4444";
}
</script>

<template>
  <div class="logbook-entry">
    <!-- Task Summary -->
    <div v-if="session.task_summary" class="entry-section">
      <h4>Task Summary</h4>
      <p class="entry-text">{{ session.task_summary }}</p>
    </div>

    <!-- Vibe Score Breakdown -->
    <div class="entry-section">
      <h4>Vibe Score Breakdown</h4>
      <div v-if="score" class="score-breakdown">
        <div class="score-header">
          <span class="score-big" :style="{ color: scoreColor(score.score) }">
            {{ score.score }}
          </span>
          <span class="score-rating">{{ score.rating }}</span>
        </div>
        <div class="score-columns">
          <div v-if="score.deductions?.length" class="score-col">
            <span class="col-label deductions-label">Deductions</span>
            <span
              v-for="d in score.deductions"
              :key="d.category + d.reason"
              class="pill deduction-pill"
            >
              {{ d.category }} ({{ d.points }})
            </span>
          </div>
          <div v-if="score.bonuses?.length" class="score-col">
            <span class="col-label bonuses-label">Bonuses</span>
            <span
              v-for="b in score.bonuses"
              :key="b.category + b.reason"
              class="pill bonus-pill"
            >
              {{ b.category }} (+{{ b.points }})
            </span>
          </div>
        </div>
      </div>
      <p v-else class="entry-muted">Score unavailable</p>
    </div>

    <!-- Token Usage -->
    <div v-if="session.tokens" class="entry-section">
      <h4>Token Usage</h4>
      <div class="token-grid">
        <div class="token-item">
          <span class="token-label">Input</span>
          <span class="token-value">{{ formatTokens(session.tokens.input || 0) }}</span>
        </div>
        <div class="token-item">
          <span class="token-label">Cache Create</span>
          <span class="token-value">{{ formatTokens(session.tokens.cache_creation || 0) }}</span>
        </div>
        <div class="token-item">
          <span class="token-label">Cache Read</span>
          <span class="token-value">{{ formatTokens(session.tokens.cache_read || 0) }}</span>
        </div>
        <div class="token-item">
          <span class="token-label">Output</span>
          <span class="token-value">{{ formatTokens(session.tokens.output || 0) }}</span>
        </div>
        <div class="token-item">
          <span class="token-label">Cost</span>
          <span class="token-value">${{ (session.tokens.estimated_cost_usd || 0).toFixed(2) }}</span>
        </div>
        <div v-if="cacheHitRate !== null" class="token-item">
          <span class="token-label">Cache Hit</span>
          <span class="token-value">{{ cacheHitRate }}%</span>
        </div>
      </div>
    </div>

    <!-- Context Window -->
    <div v-if="contextPeak !== null" class="entry-section">
      <h4>Context Window</h4>
      <div class="token-grid">
        <div class="token-item">
          <span class="token-label">Peak</span>
          <span class="token-value">{{ contextPeak }}%</span>
        </div>
        <div v-if="session.context_window?.compactions" class="token-item">
          <span class="token-label">Compactions</span>
          <span class="token-value">{{ session.context_window.compactions }}</span>
        </div>
      </div>
    </div>

    <!-- Agents Used -->
    <div v-if="session.agents_used?.length" class="entry-section">
      <h4>Agents Used</h4>
      <div class="agent-chips">
        <span
          v-for="agent in session.agents_used"
          :key="agent"
          class="agent-chip"
          :style="{ background: AGENT_COLORS[agent] || '#6b7280' }"
        >
          {{ agent }}
        </span>
      </div>
    </div>

    <!-- Agent Breakdown (from metrics) -->
    <div v-if="agentsWithMetrics.length" class="entry-section">
      <h4>Agent Breakdown</h4>
      <div class="agent-breakdown">
        <div
          v-for="agent in agentsWithMetrics"
          :key="agent.agent"
          class="breakdown-row"
        >
          <span class="breakdown-name" :style="{ color: AGENT_COLORS[agent.agent] || '#6b7280' }">
            {{ agent.agent }}
          </span>
          <div class="breakdown-bar-container">
            <div class="breakdown-bar" :style="{ width: barWidth(agent, 'progress'), background: '#22c55e' }" />
            <div class="breakdown-bar" :style="{ width: barWidth(agent, 'exploration'), background: '#3b82f6' }" />
            <div class="breakdown-bar" :style="{ width: barWidth(agent, 'neutral'), background: '#6b7280' }" />
          </div>
          <span class="breakdown-calls">{{ agent.metrics.total_tool_calls }}</span>
          <span class="breakdown-eff" :style="{ color: effColor(agent.metrics.efficiency_ratio) }">
            {{ (agent.metrics.efficiency_ratio * 100).toFixed(0) }}%
          </span>
        </div>
        <div class="breakdown-legend">
          <span class="legend-item"><span class="legend-dot" style="background:#22c55e" /> progress</span>
          <span class="legend-item"><span class="legend-dot" style="background:#3b82f6" /> exploration</span>
          <span class="legend-item"><span class="legend-dot" style="background:#6b7280" /> neutral</span>
        </div>
      </div>
    </div>

    <!-- Test Results -->
    <div v-if="session.test_results" class="entry-section">
      <h4>Test Results</h4>
      <div class="token-grid">
        <div class="token-item">
          <span class="token-label">Total</span>
          <span class="token-value">{{ session.test_results.total || 0 }}</span>
        </div>
        <div class="token-item">
          <span class="token-label">Passed</span>
          <span class="token-value" style="color: #22c55e">{{ session.test_results.passed || 0 }}</span>
        </div>
        <div v-if="session.test_results.failed" class="token-item">
          <span class="token-label">Failed</span>
          <span class="token-value" style="color: #ef4444">{{ session.test_results.failed }}</span>
        </div>
        <div v-if="session.test_results.coverage_pct != null" class="token-item">
          <span class="token-label">Coverage</span>
          <span class="token-value">{{ session.test_results.coverage_pct }}%</span>
        </div>
      </div>
    </div>

    <!-- Files Modified -->
    <div v-if="session.files_modified?.length" class="entry-section">
      <h4>Files Modified ({{ session.files_modified.length }})</h4>
      <details class="files-details">
        <summary>Show files</summary>
        <div class="files-list">
          <div v-for="f in session.files_modified" :key="f.path" class="file-row">
            <code class="file-path">{{ f.path }}</code>
            <span v-if="f.insertions || f.deletions" class="file-diff">
              <span v-if="f.insertions" class="diff-add">+{{ f.insertions }}</span>
              <span v-if="f.deletions" class="diff-del">-{{ f.deletions }}</span>
            </span>
          </div>
        </div>
      </details>
    </div>

    <!-- Commits -->
    <div v-if="session.commits?.length" class="entry-section">
      <h4>Commits ({{ session.commits.length }})</h4>
      <div class="commits-list">
        <div v-for="c in session.commits" :key="c.hash" class="commit-row">
          <code class="commit-hash">{{ (c.hash || '').slice(0, 7) }}</code>
          <span class="commit-msg">{{ c.message }}</span>
        </div>
      </div>
    </div>

    <!-- Coaching -->
    <div v-if="score?.coaching?.suggestions?.length" class="entry-section">
      <h4>Coaching</h4>
      <ul class="coaching-list">
        <li v-for="(s, i) in score.coaching.suggestions" :key="i">{{ s }}</li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.logbook-entry {
  padding: 0 0.5rem;
}

.entry-section {
  margin-bottom: 1.25rem;
}

.entry-section h4 {
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--vp-c-text-2);
  margin: 0 0 0.5rem 0;
}

.entry-text {
  margin: 0;
  font-size: 0.875rem;
  color: var(--vp-c-text-1);
  line-height: 1.5;
}

.entry-muted {
  margin: 0;
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
}

.score-breakdown {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.score-header {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
}

.score-big {
  font-size: 1.5rem;
  font-weight: 700;
}

.score-rating {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  text-transform: capitalize;
}

.score-columns {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.score-col {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.col-label {
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  margin-bottom: 0.15rem;
}

.deductions-label { color: #ef4444; }
.bonuses-label { color: #22c55e; }

.pill {
  font-size: 0.7rem;
  padding: 0.15rem 0.5rem;
  border-radius: 9999px;
  white-space: nowrap;
}

.deduction-pill {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.bonus-pill {
  background: rgba(34, 197, 94, 0.1);
  color: #22c55e;
}

.token-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.token-item {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
}

.token-label {
  font-size: 0.65rem;
  color: var(--vp-c-text-3);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.token-value {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.agent-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
}

.agent-chip {
  font-size: 0.65rem;
  color: #fff;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
}

.files-details summary {
  font-size: 0.8rem;
  color: var(--vp-c-brand-1);
  cursor: pointer;
}

.files-list {
  margin-top: 0.5rem;
}

.file-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.2rem 0;
  font-size: 0.75rem;
}

.file-path {
  font-size: 0.7rem;
  color: var(--vp-c-text-2);
}

.file-diff {
  display: flex;
  gap: 0.25rem;
}

.diff-add { color: #22c55e; font-size: 0.7rem; }
.diff-del { color: #ef4444; font-size: 0.7rem; }

.commits-list {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.commit-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.8rem;
}

.commit-hash {
  font-size: 0.7rem;
  font-family: var(--vp-font-family-mono);
  color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
  padding: 0.1rem 0.35rem;
  border-radius: 3px;
}

.commit-msg {
  color: var(--vp-c-text-1);
}

.coaching-list {
  margin: 0;
  padding-left: 1.25rem;
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
}

.agent-breakdown {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.breakdown-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.breakdown-name {
  font-size: 0.7rem;
  font-weight: 600;
  min-width: 110px;
  text-align: right;
}

.breakdown-bar-container {
  flex: 1;
  height: 12px;
  display: flex;
  background: var(--vp-c-bg-soft);
  border-radius: 3px;
  overflow: hidden;
}

.breakdown-bar {
  height: 100%;
}

.breakdown-calls {
  font-size: 0.65rem;
  color: var(--vp-c-text-3);
  min-width: 24px;
  text-align: right;
}

.breakdown-eff {
  font-size: 0.65rem;
  font-weight: 600;
  min-width: 28px;
  text-align: right;
}

.breakdown-legend {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.25rem;
  justify-content: flex-end;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.2rem;
  font-size: 0.6rem;
  color: var(--vp-c-text-3);
}

.legend-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  display: inline-block;
}
</style>
