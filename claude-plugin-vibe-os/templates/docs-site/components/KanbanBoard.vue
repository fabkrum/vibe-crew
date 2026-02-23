<script setup>
import { computed } from 'vue'

const props = defineProps({
  data: { type: Object, required: true }
})

const boardColumns = computed(() => {
  if (!props.data?.columns) return []
  return props.data.columns.map(col => ({
    ...col,
    features: (props.data.features || [])
      .filter(f => f.column === col.id)
      .sort((a, b) => (a.priority || 99) - (b.priority || 99))
  }))
})

function priorityClass(priority) {
  if (priority === 1) return 'priority-high'
  if (priority === 2) return 'priority-medium'
  return 'priority-low'
}
</script>

<template>
  <div class="kanban-board">
    <div v-for="column in boardColumns" :key="column.id" class="kanban-column">
      <div class="column-header">
        <h3>{{ column.title }}</h3>
        <span class="card-count">
          {{ column.features.length }}
          <span v-if="column.wip_limit" class="wip-limit">/ {{ column.wip_limit }}</span>
        </span>
      </div>
      <div class="column-body">
        <div
          v-for="feature in column.features"
          :key="feature.id"
          class="kanban-card"
          :class="priorityClass(feature.priority)"
        >
          <div class="card-title">{{ feature.name }}</div>
          <div v-if="feature.labels?.length" class="card-labels">
            <span v-for="label in feature.labels" :key="label" class="label">
              {{ label }}
            </span>
          </div>
        </div>
        <div v-if="column.features.length === 0" class="empty-column">
          No items
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.kanban-board {
  display: flex;
  gap: 0.75rem;
  overflow-x: auto;
  padding: 1rem 0;
}

.kanban-column {
  min-width: 180px;
  flex: 1;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 0.75rem;
}

.column-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.column-header h3 {
  margin: 0;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.card-count {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
}

.wip-limit {
  color: var(--vp-c-text-3);
}

.kanban-card {
  background: var(--vp-c-bg);
  border-radius: 6px;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  border-left: 3px solid var(--vp-c-divider);
}

.kanban-card.priority-high { border-left-color: #ef4444; }
.kanban-card.priority-medium { border-left-color: #f97316; }
.kanban-card.priority-low { border-left-color: #10b981; }

.card-title {
  font-weight: 600;
  font-size: 0.875rem;
  margin-bottom: 0.35rem;
}

.card-labels {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.card-labels .label {
  font-size: 0.65rem;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-2);
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
}

.empty-column {
  color: var(--vp-c-text-3);
  font-size: 0.8rem;
  text-align: center;
  padding: 1rem 0;
}

@media (max-width: 768px) {
  .kanban-board {
    flex-direction: column;
  }
  .kanban-column {
    min-width: auto;
  }
}
</style>
