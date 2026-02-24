<script setup lang="ts">
import { computed } from "vue";
import { data } from "../data/agents.data";

const sessions = computed(() => data.sessions);
const agentSummary = computed(() => data.agentSummary);
const totalTokens = computed(() => data.totalTokens);

const agentColors: Record<string, string> = {
  "session-startup": "#6b7280",
  "workflow-orchestrator": "#8b5cf6",
  "stack-scout": "#3b82f6",
  builder: "#22c55e",
  verifier: "#f97316",
  "performance-coach": "#ec4899",
  "code-auditor": "#06b6d4",
  "doc-generator": "#eab308",
};

function formatDuration(seconds: number): string {
  if (seconds < 60) return `${seconds}s`;
  if (seconds < 3600) return `${Math.round(seconds / 60)}m`;
  return `${(seconds / 3600).toFixed(1)}h`;
}

function formatTokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`;
  return String(n);
}

const maxInvocations = computed(() => {
  return Math.max(...agentSummary.value.map((a) => a.invocations), 1);
});
</script>

<template>
  <div class="agent-activity">
    <h3>Agent Activity</h3>

    <div v-if="agentSummary.length === 0" class="empty">
      No agent activity recorded yet.
    </div>

    <template v-else>
      <!-- Agent summary bars -->
      <div class="agent-bars">
        <div
          v-for="agent in agentSummary"
          :key="agent.agent"
          class="agent-row"
        >
          <div class="agent-name">{{ agent.agent }}</div>
          <div class="bar-container">
            <div
              class="bar"
              :style="{
                width: `${(agent.invocations / maxInvocations) * 100}%`,
                backgroundColor: agentColors[agent.agent] || '#6b7280',
              }"
            />
          </div>
          <div class="agent-stats">
            {{ agent.invocations }}x &middot; {{ formatDuration(agent.totalDuration) }}
          </div>
        </div>
      </div>

      <!-- Session timeline -->
      <h4>Recent Sessions</h4>
      <div class="timeline">
        <div
          v-for="session in sessions.slice(-10)"
          :key="session.session_id"
          class="timeline-entry"
        >
          <div class="session-label">
            {{ session.session_id.replace('session-', '').slice(0, 10) }}
          </div>
          <div class="agent-chips">
            <span
              v-for="agent in session.agents"
              :key="agent.agent"
              class="chip"
              :style="{ backgroundColor: agentColors[agent.agent] || '#6b7280' }"
              :title="agent.agent"
            >
              {{ agent.agent.slice(0, 2).toUpperCase() }}
            </span>
          </div>
          <div class="session-meta">
            {{ formatDuration(session.duration_seconds) }}
            &middot; {{ formatTokens(session.tokens.input + session.tokens.cache_read + session.tokens.output) }}
            &middot; {{ session.context.peak_usage_percent }}% ctx
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.agent-activity {
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 16px;
}
.agent-activity h3 {
  margin: 0 0 12px 0;
  font-size: 16px;
}
.agent-activity h4 {
  margin: 16px 0 8px 0;
  font-size: 14px;
  color: var(--vp-c-text-2);
}
.agent-bars {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.agent-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.agent-name {
  width: 120px;
  font-size: 12px;
  color: var(--vp-c-text-2);
  text-align: right;
  flex-shrink: 0;
}
.bar-container {
  flex: 1;
  height: 16px;
  background: var(--vp-c-bg-soft);
  border-radius: 4px;
  overflow: hidden;
}
.bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
  min-width: 2px;
}
.agent-stats {
  width: 100px;
  font-size: 11px;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
}
.timeline {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.timeline-entry {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 0;
  border-bottom: 1px solid var(--vp-c-divider);
}
.timeline-entry:last-child {
  border-bottom: none;
}
.session-label {
  width: 80px;
  font-size: 11px;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
}
.agent-chips {
  display: flex;
  gap: 3px;
  flex: 1;
}
.chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 18px;
  border-radius: 3px;
  font-size: 9px;
  font-weight: 700;
  color: white;
}
.session-meta {
  font-size: 11px;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
  white-space: nowrap;
}
.empty {
  text-align: center;
  color: var(--vp-c-text-2);
  padding: 40px 0;
}
</style>
