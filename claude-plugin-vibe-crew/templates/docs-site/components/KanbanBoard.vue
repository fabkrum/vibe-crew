<script setup>
import { ref, computed, watch } from 'vue'
import { useBacklogApi } from '../composables/useBacklogApi'
import { useVibecrewUpdates } from '../composables/useVibecrewUpdates'
import AddIdeaModal from './AddIdeaModal.vue'
import CardDetailModal from './CardDetailModal.vue'
import WarpLaunchToast from './WarpLaunchToast.vue'

const props = defineProps({
  data: { type: Object, required: true }
})

const { moveCard: apiMoveCard, launchWarp, fetchBacklog } = useBacklogApi()

// --- Local state ---
const localData = ref(structuredClone(props.data))
const showAddIdea = ref(false)
const detailFeature = ref(null)
const toast = ref(null)
const draggedFeature = ref(null)
const dropTargetColumn = ref(null)

// Sync when props change (HMR / data loader reload)
watch(() => props.data, (newData) => {
  localData.value = structuredClone(newData)
}, { deep: true })

// Listen for real-time file changes
useVibecrewUpdates(async (event) => {
  if (event.updateType === 'backlog_changed' || event.updateType === 'poll') {
    const fresh = await fetchBacklog()
    if (fresh) {
      localData.value = fresh
    }
  }
})

// --- Computed ---
const boardColumns = computed(() => {
  if (!localData.value?.columns) return []
  return localData.value.columns.map(col => ({
    ...col,
    features: (localData.value.features || [])
      .filter(f => f.column === col.id)
      .sort((a, b) => (a.priority || 99) - (b.priority || 99))
  }))
})

// --- Helpers ---
function priorityClass(priority) {
  if (priority === 1) return 'priority-high'
  if (priority === 2) return 'priority-medium'
  return 'priority-low'
}

function getWipLimit(columnId) {
  const col = (localData.value?.columns || []).find(c => c.id === columnId)
  return col?.wip_limit ?? null
}

function getColumnCount(columnId) {
  return (localData.value?.features || []).filter(f => f.column === columnId).length
}

// --- Drag and Drop ---
function onDragStart(e, feature) {
  draggedFeature.value = feature
  e.dataTransfer.effectAllowed = 'move'
  e.dataTransfer.setData('text/plain', feature.id)
}

function onDragEnd() {
  draggedFeature.value = null
  dropTargetColumn.value = null
}

function onDragOver(e, columnId) {
  e.preventDefault()
  dropTargetColumn.value = columnId
}

function onDragLeave(e, columnId) {
  if (dropTargetColumn.value === columnId) {
    dropTargetColumn.value = null
  }
}

async function onDrop(e, columnId) {
  e.preventDefault()
  dropTargetColumn.value = null

  if (!draggedFeature.value || draggedFeature.value.column === columnId) {
    draggedFeature.value = null
    return
  }

  // Check WIP limits client-side
  const wipLimit = getWipLimit(columnId)
  if (wipLimit !== null) {
    const currentCount = getColumnCount(columnId)
    if (currentCount >= wipLimit) {
      toast.value = {
        featureName: `WIP limit reached for ${columnId} (max ${wipLimit})`,
        command: 'Move another card out first',
      }
      draggedFeature.value = null
      return
    }
  }

  // Optimistic update
  const feature = draggedFeature.value
  const previousColumn = feature.column
  const featureIdx = (localData.value.features || []).findIndex(f => f.id === feature.id)
  if (featureIdx !== -1) {
    localData.value.features[featureIdx].column = columnId
  }

  // API call
  const result = await apiMoveCard(feature.id, columnId)
  if (!result) {
    // Revert on failure
    if (featureIdx !== -1) {
      localData.value.features[featureIdx].column = previousColumn
    }
  }

  draggedFeature.value = null
}

// --- Card interactions ---
function openDetail(feature) {
  detailFeature.value = feature
}

function onDetailUpdated(updated) {
  const idx = (localData.value.features || []).findIndex(f => f.id === updated.id)
  if (idx !== -1) {
    localData.value.features[idx] = updated
  }
}

function onIdeaAdded() {
  // Data loader will pick up the change via file watcher
}

// --- Action buttons ---
const actionButtons = {
  planning: { label: 'Open in Warp', icon: '' },
  planned: { label: 'Start Building', icon: '' },
  'in-progress': { label: 'View Status', icon: '' },
  testing: { label: 'Run Tests', icon: '' },
  review: { label: 'Open Review', icon: '' },
}

async function onActionClick(feature) {
  const result = await launchWarp({ feature_id: feature.id })
  if (result) {
    if (result.warp_url) {
      window.open(result.warp_url, '_blank')
    }
    toast.value = {
      featureName: result.feature_name || feature.name,
      command: result.command_text,
    }
  }
}
</script>

<template>
  <div class="kanban-board">
    <div
      v-for="column in boardColumns"
      :key="column.id"
      class="kanban-column"
      :class="{ 'drop-target': dropTargetColumn === column.id }"
      @dragover="onDragOver($event, column.id)"
      @dragleave="onDragLeave($event, column.id)"
      @drop="onDrop($event, column.id)"
    >
      <div class="column-header">
        <h3>{{ column.title }}</h3>
        <span class="card-count" :class="{ 'wip-exceeded': column.wip_limit && column.features.length >= column.wip_limit }">
          {{ column.features.length }}
          <span v-if="column.wip_limit" class="wip-limit">/ {{ column.wip_limit }}</span>
        </span>
        <button
          v-if="column.id === 'idea'"
          class="add-idea-btn"
          title="Add new idea"
          @click="showAddIdea = true"
        >+</button>
      </div>

      <div class="column-body">
        <div
          v-for="feature in column.features"
          :key="feature.id"
          class="kanban-card"
          :class="[
            priorityClass(feature.priority),
            { dragging: draggedFeature?.id === feature.id }
          ]"
          draggable="true"
          @dragstart="onDragStart($event, feature)"
          @dragend="onDragEnd"
          @click="openDetail(feature)"
        >
          <div class="card-title">{{ feature.name }}</div>
          <div v-if="feature.labels?.length" class="card-labels">
            <span v-for="label in feature.labels" :key="label" class="label">
              {{ label }}
            </span>
          </div>
          <div v-if="actionButtons[column.id]" class="card-action">
            <button
              class="action-btn"
              @click.stop="onActionClick(feature)"
            >
              {{ actionButtons[column.id].label }}
            </button>
          </div>
        </div>

        <div v-if="column.features.length === 0" class="empty-column">
          <template v-if="column.id === 'idea'">
            Click + to add an idea
          </template>
          <template v-else>
            No items
          </template>
        </div>
      </div>
    </div>
  </div>

  <!-- Modals -->
  <AddIdeaModal
    v-if="showAddIdea"
    @close="showAddIdea = false"
    @added="onIdeaAdded"
  />

  <CardDetailModal
    v-if="detailFeature"
    :feature="detailFeature"
    @close="detailFeature = null"
    @updated="onDetailUpdated"
  />

  <WarpLaunchToast
    v-if="toast"
    :feature-name="toast.featureName"
    :command="toast.command"
    @dismiss="toast = null"
  />
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
  transition: border-color 0.15s ease;
  border: 2px solid transparent;
}

.kanban-column.drop-target {
  border-color: var(--vp-c-brand-1);
  border-style: dashed;
}

.column-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
  gap: 0.5rem;
}

.column-header h3 {
  margin: 0;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  flex: 1;
}

.card-count {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
}

.card-count.wip-exceeded {
  color: #ef4444;
  font-weight: 600;
}

.wip-limit {
  color: var(--vp-c-text-3);
}

.add-idea-btn {
  width: 24px;
  height: 24px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-brand-1);
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
  padding: 0;
  flex-shrink: 0;
}

.add-idea-btn:hover {
  background: var(--vp-c-brand-soft);
}

.kanban-card {
  background: var(--vp-c-bg);
  border-radius: 6px;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  border-left: 3px solid var(--vp-c-divider);
  cursor: pointer;
  transition: opacity 0.15s ease, box-shadow 0.15s ease;
}

.kanban-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.kanban-card.dragging {
  opacity: 0.4;
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

.card-action {
  margin-top: 0.5rem;
}

.action-btn {
  width: 100%;
  padding: 0.3rem 0.5rem;
  border: 1px solid var(--vp-c-brand-soft);
  border-radius: 4px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  font-size: 0.7rem;
  font-weight: 600;
  cursor: pointer;
  text-align: center;
}

.action-btn:hover {
  background: var(--vp-c-brand-1);
  color: var(--vp-c-bg);
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
