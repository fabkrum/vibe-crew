<script setup>
import { computed } from 'vue'

const props = defineProps({
  sessions: { type: Array, required: true }
})

const stats = computed(() => {
  const sessions = props.sessions || []
  const totalSessions = sessions.length

  const scores = sessions
    .map(s => s.vibe_score)
    .filter(v => v != null)
  const averageVibeScore = scores.length > 0
    ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length)
    : 0

  let totalTokens = 0
  let totalCost = 0
  for (const s of sessions) {
    if (s.tokens) {
      totalTokens += (s.tokens.input || 0)
        + (s.tokens.cache_creation || 0)
        + (s.tokens.cache_read || 0)
        + (s.tokens.output || 0)
      totalCost += (s.tokens.estimated_cost_usd || 0)
    }
  }

  return { totalSessions, averageVibeScore, totalTokens, totalCost }
})

function formatTokens(n) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + 'M'
  if (n >= 1_000) return (n / 1_000).toFixed(1) + 'K'
  return String(n)
}

function formatCost(n) {
  return '$' + n.toFixed(2)
}
</script>

<template>
  <div class="stats-page">
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-label">Total Sessions</div>
        <div class="stat-value">{{ stats.totalSessions }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Average Vibe Score</div>
        <div class="stat-value">{{ stats.averageVibeScore }}<span class="stat-unit">/100</span></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Tokens Used</div>
        <div class="stat-value">{{ formatTokens(stats.totalTokens) }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Estimated Total Cost</div>
        <div class="stat-value">{{ formatCost(stats.totalCost) }}</div>
      </div>
    </div>
    <p v-if="stats.totalSessions === 0" class="stats-empty">
      No sessions recorded yet. Run <code>/wrap</code> to save session data.
    </p>
  </div>
</template>

<style scoped>
.stats-page {
  padding: 1rem 0;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
}

.stat-card {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 1.5rem;
  text-align: center;
}

.stat-label {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
}

.stat-unit {
  font-size: 0.875rem;
  font-weight: 400;
  color: var(--vp-c-text-2);
}

.stats-empty {
  color: var(--vp-c-text-3);
  text-align: center;
  margin-top: 2rem;
}
</style>
