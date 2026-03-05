<script setup>
import { computed } from "vue";
import { data } from "../data/agent-logs.data";

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

function efficiencyColor(ratio) {
  if (ratio >= 0.35) return "#22c55e";
  if (ratio >= 0.20) return "#eab308";
  return "#ef4444";
}

function trendIcon(trend) {
  switch (trend) {
    case "improving": return "^";
    case "declining": return "v";
    case "stable": return "=";
    default: return "-";
  }
}

const allTools = computed(() => {
  const tools = new Set();
  for (const entry of data.heatmap) {
    for (const tool of Object.keys(entry.tools)) {
      tools.add(tool);
    }
  }
  return Array.from(tools).sort();
});

const maxToolCount = computed(() => {
  let max = 1;
  for (const entry of data.heatmap) {
    for (const count of Object.values(entry.tools)) {
      if (count > max) max = count;
    }
  }
  return max;
});

function heatmapOpacity(count) {
  if (!count) return 0;
  return 0.15 + (count / maxToolCount.value) * 0.85;
}
</script>

<template>
  <div class="agent-insights">
    <!-- Empty state -->
    <div v-if="!data.agentSummaries.length" class="empty-state">
      <p>No agent metrics available yet. Complete a session with <code>/wrap</code> to start collecting data.</p>
    </div>

    <template v-else>
      <!-- Section 1: Agent Efficiency Bars -->
      <div class="insights-section">
        <h3>Agent Efficiency</h3>
        <p class="section-desc">Efficiency ratio = progress calls / total calls. Higher is better for write-heavy agents.</p>
        <div class="efficiency-bars">
          <div
            v-for="agent in data.agentSummaries"
            :key="agent.agent"
            class="efficiency-row"
          >
            <span class="agent-name" :style="{ color: AGENT_COLORS[agent.agent] || '#6b7280' }">
              {{ agent.agent }}
            </span>
            <div class="bar-container">
              <div
                class="bar-fill"
                :style="{
                  width: Math.min(agent.avgEfficiency * 100, 100) + '%',
                  background: efficiencyColor(agent.avgEfficiency),
                }"
              />
            </div>
            <span class="efficiency-value">{{ (agent.avgEfficiency * 100).toFixed(0) }}%</span>
            <span class="trend-badge" :title="agent.trend">{{ trendIcon(agent.trend) }}</span>
            <span class="session-count">{{ agent.sessions }}s</span>
          </div>
        </div>
      </div>

      <!-- Section 2: Tool Usage Heatmap -->
      <div class="insights-section">
        <h3>Tool Usage Heatmap</h3>
        <div class="heatmap-scroll">
          <table class="heatmap-table">
            <thead>
              <tr>
                <th>Agent</th>
                <th v-for="tool in allTools" :key="tool" class="tool-header">{{ tool }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="entry in data.heatmap" :key="entry.agent">
                <td class="heatmap-agent" :style="{ color: AGENT_COLORS[entry.agent] || '#6b7280' }">
                  {{ entry.agent }}
                </td>
                <td
                  v-for="tool in allTools"
                  :key="tool"
                  class="heatmap-cell"
                  :style="{
                    background: entry.tools[tool]
                      ? `rgba(59, 130, 246, ${heatmapOpacity(entry.tools[tool])})`
                      : 'transparent',
                  }"
                >
                  {{ entry.tools[tool] || '' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Section 3: Inefficiency Alerts -->
      <div v-if="data.inefficiencyPatterns.length" class="insights-section">
        <h3>Inefficiency Alerts</h3>
        <div class="alert-cards">
          <div
            v-for="(pattern, i) in data.inefficiencyPatterns"
            :key="i"
            class="alert-card"
          >
            <div class="alert-header">
              <span class="alert-agent" :style="{ color: AGENT_COLORS[pattern.agent] || '#6b7280' }">
                {{ pattern.agent }}
              </span>
              <span class="alert-badge">{{ pattern.pattern.replace(/_/g, ' ') }}</span>
            </div>
            <p class="alert-desc">{{ pattern.description }}</p>
            <span class="alert-sessions">Detected in {{ pattern.sessions_detected }} sessions</span>
          </div>
        </div>
      </div>

      <!-- Section 4: Recent Activity -->
      <div v-if="data.recentToolCalls.length" class="insights-section">
        <h3>Recent Tool Calls</h3>
        <details>
          <summary>Last {{ data.recentToolCalls.length }} calls</summary>
          <div class="recent-calls">
            <div
              v-for="(call, i) in data.recentToolCalls.slice(-20).reverse()"
              :key="i"
              class="call-row"
            >
              <span class="call-agent" :style="{ color: AGENT_COLORS[call.agent] || '#6b7280' }">
                {{ call.agent }}
              </span>
              <span class="call-tool">{{ call.tool }}</span>
              <span :class="['call-class', 'class-' + call.class]">{{ call.class }}</span>
              <code v-if="call.target" class="call-target">{{ call.target.split('/').pop() }}</code>
            </div>
          </div>
        </details>
      </div>
    </template>
  </div>
</template>

<style scoped>
.agent-insights {
  max-width: 900px;
}

.empty-state {
  text-align: center;
  padding: 2rem;
  color: var(--vp-c-text-3);
}

.insights-section {
  margin-bottom: 2rem;
}

.insights-section h3 {
  font-size: 1rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
  color: var(--vp-c-text-1);
}

.section-desc {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  margin: 0 0 0.75rem 0;
}

/* --- Efficiency Bars --- */
.efficiency-bars {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.efficiency-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.agent-name {
  font-size: 0.7rem;
  font-weight: 600;
  min-width: 130px;
  text-align: right;
}

.bar-container {
  flex: 1;
  height: 14px;
  background: var(--vp-c-bg-soft);
  border-radius: 3px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.3s ease;
}

.efficiency-value {
  font-size: 0.7rem;
  font-weight: 600;
  min-width: 32px;
  text-align: right;
  color: var(--vp-c-text-2);
}

.trend-badge {
  font-size: 0.7rem;
  min-width: 12px;
  text-align: center;
  color: var(--vp-c-text-3);
}

.session-count {
  font-size: 0.65rem;
  color: var(--vp-c-text-3);
  min-width: 20px;
}

/* --- Heatmap --- */
.heatmap-scroll {
  overflow-x: auto;
}

.heatmap-table {
  border-collapse: collapse;
  font-size: 0.7rem;
  width: 100%;
}

.heatmap-table th,
.heatmap-table td {
  padding: 0.25rem 0.4rem;
  border: 1px solid var(--vp-c-divider);
  text-align: center;
}

.tool-header {
  font-size: 0.6rem;
  font-weight: 600;
  color: var(--vp-c-text-2);
  white-space: nowrap;
}

.heatmap-agent {
  font-weight: 600;
  text-align: left !important;
  white-space: nowrap;
}

.heatmap-cell {
  font-size: 0.65rem;
  color: var(--vp-c-text-1);
  min-width: 30px;
}

/* --- Alert Cards --- */
.alert-cards {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.alert-card {
  padding: 0.6rem 0.75rem;
  background: rgba(239, 68, 68, 0.06);
  border: 1px solid rgba(239, 68, 68, 0.15);
  border-radius: 6px;
}

.alert-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.25rem;
}

.alert-agent {
  font-size: 0.75rem;
  font-weight: 600;
}

.alert-badge {
  font-size: 0.6rem;
  padding: 0.1rem 0.4rem;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border-radius: 9999px;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.alert-desc {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  margin: 0;
}

.alert-sessions {
  font-size: 0.65rem;
  color: var(--vp-c-text-3);
}

/* --- Recent Calls --- */
.recent-calls {
  margin-top: 0.5rem;
}

.call-row {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.15rem 0;
  font-size: 0.7rem;
}

.call-agent {
  font-weight: 600;
  min-width: 100px;
}

.call-tool {
  font-weight: 500;
  min-width: 50px;
  color: var(--vp-c-text-1);
}

.call-class {
  font-size: 0.6rem;
  padding: 0.05rem 0.35rem;
  border-radius: 3px;
}

.class-progress { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
.class-exploration { background: rgba(59, 130, 246, 0.15); color: #3b82f6; }
.class-neutral { background: rgba(107, 114, 128, 0.15); color: #6b7280; }

.call-target {
  font-size: 0.6rem;
  color: var(--vp-c-text-3);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 200px;
}

details summary {
  font-size: 0.8rem;
  color: var(--vp-c-brand-1);
  cursor: pointer;
}
</style>
