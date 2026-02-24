<script setup>
import { ref, onMounted, computed } from 'vue'
import { useVibecrewUpdates } from '../composables/useVibecrewUpdates'

const session = ref({ active: false })

async function fetchSession() {
  try {
    const res = await fetch('/api/live-session')
    if (res.ok) {
      session.value = await res.json()
    }
  } catch {
    session.value = { active: false }
  }
}

onMounted(fetchSession)

useVibecrewUpdates((event) => {
  if (event.updateType === 'live_session_changed' || event.updateType === 'poll') {
    fetchSession()
  }
})

const modelName = computed(() => {
  return session.value.model?.display_name || session.value.model?.name || ''
})

const contextPct = computed(() => {
  const pct = session.value.context_window?.used_percentage
  if (pct == null) return null
  return Math.round(pct)
})

const contextColor = computed(() => {
  const pct = contextPct.value
  if (pct == null) return ''
  if (pct <= 45) return '#10b981'
  if (pct <= 60) return '#f59e0b'
  return '#ef4444'
})

const costUsd = computed(() => {
  const cost = session.value.cost?.total_cost_usd
  if (cost == null) return null
  return `$${Number(cost).toFixed(2)}`
})

const duration = computed(() => {
  const ms = session.value.cost?.total_duration_ms
  if (ms == null) return null
  const min = Math.floor(ms / 60000)
  if (min < 1) return '<1m'
  return `${min}m`
})
</script>

<template>
  <div class="live-session-panel" :class="{ inactive: !session.active }">
    <template v-if="session.active">
      <div class="stat-cell">
        <span class="stat-label">Model</span>
        <span class="stat-value">{{ modelName }}</span>
      </div>
      <div class="stat-cell">
        <span class="stat-label">Context</span>
        <div class="context-bar-wrapper">
          <div class="context-bar">
            <div
              class="context-bar-fill"
              :style="{ width: (contextPct || 0) + '%', background: contextColor }"
            />
          </div>
          <span class="stat-value" :style="{ color: contextColor }">{{ contextPct ?? '--' }}%</span>
        </div>
      </div>
      <div class="stat-cell">
        <span class="stat-label">Cost</span>
        <span class="stat-value">{{ costUsd || '$-.--' }}</span>
      </div>
      <div class="stat-cell">
        <span class="stat-label">Duration</span>
        <span class="stat-value">{{ duration || '--m' }}</span>
      </div>
    </template>
    <template v-else>
      <span class="no-session">No active session</span>
    </template>
  </div>
</template>

<style scoped>
.live-session-panel {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 0.6rem 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  margin-bottom: 1rem;
  min-height: 40px;
}

.live-session-panel.inactive {
  justify-content: center;
}

.stat-cell {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.stat-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--vp-c-text-3);
  font-weight: 600;
}

.stat-value {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.context-bar-wrapper {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.context-bar {
  width: 60px;
  height: 6px;
  background: var(--vp-c-bg);
  border-radius: 3px;
  overflow: hidden;
}

.context-bar-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.3s ease, background 0.3s ease;
}

.no-session {
  color: var(--vp-c-text-3);
  font-size: 0.85rem;
}

@media (max-width: 640px) {
  .live-session-panel {
    flex-wrap: wrap;
    gap: 0.75rem;
  }
}
</style>
