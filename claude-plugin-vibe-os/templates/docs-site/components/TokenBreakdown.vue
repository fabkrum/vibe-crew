<script setup lang="ts">
import { computed } from "vue";
import { data } from "../data/agents.data";

const sessions = computed(() => data.sessions);
const totalTokens = computed(() => data.totalTokens);

const maxTokens = computed(() => {
  if (sessions.value.length === 0) return 1;
  return Math.max(
    ...sessions.value.map(
      (s) => s.tokens.input + s.tokens.cache_read + s.tokens.output,
    ),
    1,
  );
});

const barHeight = 24;
const chartWidth = 600;
const padding = 40;

function formatTokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`;
  return String(n);
}

function formatCost(n: number): string {
  return `$${n.toFixed(2)}`;
}
</script>

<template>
  <div class="token-breakdown">
    <div class="header">
      <h3>Token Usage</h3>
      <div class="total-cost">
        Total: {{ formatTokens(totalTokens.input + totalTokens.cache_read + totalTokens.output) }}
        tokens ({{ formatCost(totalTokens.cost) }})
      </div>
    </div>

    <div v-if="sessions.length === 0" class="empty">
      No session data yet.
    </div>

    <div v-else class="bars">
      <div
        v-for="(s, i) in sessions"
        :key="i"
        class="bar-row"
      >
        <div class="label">{{ s.session_id.replace('session-', '').slice(0, 10) }}</div>
        <div class="bar-container">
          <div
            class="bar input"
            :style="{ width: `${(s.tokens.input / maxTokens) * 100}%` }"
            :title="`Input: ${formatTokens(s.tokens.input)}`"
          />
          <div
            class="bar cache"
            :style="{ width: `${(s.tokens.cache_read / maxTokens) * 100}%` }"
            :title="`Cache: ${formatTokens(s.tokens.cache_read)}`"
          />
          <div
            class="bar output"
            :style="{ width: `${(s.tokens.output / maxTokens) * 100}%` }"
            :title="`Output: ${formatTokens(s.tokens.output)}`"
          />
        </div>
        <div class="cost">{{ formatCost(s.tokens.estimated_cost_usd) }}</div>
      </div>
    </div>

    <div class="legend">
      <span class="legend-item"><span class="dot input" /> Input</span>
      <span class="legend-item"><span class="dot cache" /> Cache Read</span>
      <span class="legend-item"><span class="dot output" /> Output</span>
    </div>
  </div>
</template>

<style scoped>
.token-breakdown {
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 16px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.header h3 {
  margin: 0;
  font-size: 16px;
}
.total-cost {
  font-size: 13px;
  color: var(--vp-c-text-2);
}
.bars {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.bar-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.label {
  width: 80px;
  font-size: 11px;
  color: var(--vp-c-text-3);
  text-align: right;
  flex-shrink: 0;
}
.bar-container {
  flex: 1;
  display: flex;
  height: 18px;
  background: var(--vp-c-bg-soft);
  border-radius: 4px;
  overflow: hidden;
}
.bar {
  height: 100%;
  transition: width 0.3s ease;
}
.bar.input {
  background: #3b82f6;
}
.bar.cache {
  background: #22c55e;
}
.bar.output {
  background: #f97316;
}
.cost {
  width: 50px;
  font-size: 11px;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
}
.legend {
  display: flex;
  gap: 16px;
  margin-top: 12px;
  font-size: 12px;
  color: var(--vp-c-text-2);
}
.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
}
.dot {
  width: 10px;
  height: 10px;
  border-radius: 2px;
  display: inline-block;
}
.dot.input {
  background: #3b82f6;
}
.dot.cache {
  background: #22c55e;
}
.dot.output {
  background: #f97316;
}
.empty {
  text-align: center;
  color: var(--vp-c-text-2);
  padding: 40px 0;
}
</style>
