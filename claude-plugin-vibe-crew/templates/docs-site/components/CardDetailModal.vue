<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useBacklogApi } from '../composables/useBacklogApi'

const props = defineProps({
  feature: { type: Object, required: true }
})
const emit = defineEmits(['close', 'updated'])

const { loading, error, updateCard, launchWarp } = useBacklogApi()

const editing = ref(false)
const form = reactive({
  name: '',
  description: '',
  priority: 999,
  labels: [],
  spec: {
    problem_statement: '',
    acceptance_criteria: [],
    ui_description: '',
    business_logic: [],
    technical_notes: '',
  },
})
const labelInput = ref('')
const criterionInput = ref('')
const logicInput = ref('')

function resetForm() {
  form.name = props.feature.name || ''
  form.description = props.feature.description || ''
  form.priority = props.feature.priority || 999
  form.labels = [...(props.feature.labels || [])]
  form.spec = {
    problem_statement: props.feature.spec?.problem_statement || '',
    acceptance_criteria: [...(props.feature.spec?.acceptance_criteria || [])],
    ui_description: props.feature.spec?.ui_description || '',
    business_logic: [...(props.feature.spec?.business_logic || [])],
    technical_notes: props.feature.spec?.technical_notes || '',
  }
}

watch(() => props.feature, resetForm, { immediate: true })

function startEdit() {
  resetForm()
  editing.value = true
}

function cancelEdit() {
  editing.value = false
  error.value = null
}

function addLabel() {
  const label = labelInput.value.trim()
  if (label && !form.labels.includes(label) && form.labels.length < 20) {
    form.labels.push(label)
    labelInput.value = ''
  }
}

function removeLabel(label) {
  form.labels = form.labels.filter(l => l !== label)
}

function addCriterion() {
  const text = criterionInput.value.trim()
  if (text) {
    form.spec.acceptance_criteria.push(text)
    criterionInput.value = ''
  }
}

function removeCriterion(idx) {
  form.spec.acceptance_criteria.splice(idx, 1)
}

function addLogic() {
  const text = logicInput.value.trim()
  if (text) {
    form.spec.business_logic.push(text)
    logicInput.value = ''
  }
}

function removeLogic(idx) {
  form.spec.business_logic.splice(idx, 1)
}

async function onSave() {
  const result = await updateCard({
    id: props.feature.id,
    name: form.name.trim(),
    description: form.description.trim(),
    priority: form.priority,
    labels: form.labels,
    spec: {
      problem_statement: form.spec.problem_statement.trim() || null,
      acceptance_criteria: form.spec.acceptance_criteria,
      ui_description: form.spec.ui_description.trim() || null,
      business_logic: form.spec.business_logic,
      technical_notes: form.spec.technical_notes.trim() || null,
    },
  })
  if (result) {
    editing.value = false
    emit('updated', result)
  }
}

async function onLaunch() {
  const result = await launchWarp({ feature_id: props.feature.id })
  if (result?.warp_url) {
    window.open(result.warp_url, '_blank')
  }
}

const columnLabel = computed(() => {
  const map = {
    idea: 'Ideas',
    planning: 'Planning',
    planned: 'Planned',
    'in-progress': 'In Development',
    testing: 'Testing',
    review: 'Review',
    done: 'Done',
  }
  return map[props.feature.column] || props.feature.column
})

const priorityLabel = computed(() => {
  if (props.feature.priority === 1) return 'High'
  if (props.feature.priority === 2) return 'Medium'
  if (props.feature.priority === 3) return 'Low'
  return 'Default'
})

function onOverlayClick(e) {
  if (e.target === e.currentTarget) emit('close')
}

function onKeydown(e) {
  if (e.key === 'Escape') emit('close')
}

function formatDate(iso) {
  if (!iso) return '-'
  return new Date(iso).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}
</script>

<template>
  <Teleport to="body">
    <div class="modal-overlay" @click="onOverlayClick" @keydown="onKeydown" tabindex="-1">
      <div class="modal-content" role="dialog" aria-labelledby="card-detail-title">
        <div class="modal-header">
          <div class="header-left">
            <span class="feature-id">{{ feature.id }}</span>
            <h2 v-if="!editing" id="card-detail-title">{{ feature.name }}</h2>
            <input v-else v-model="form.name" class="edit-name" maxlength="200" />
          </div>
          <button class="close-btn" @click="emit('close')" aria-label="Close">&times;</button>
        </div>

        <div class="modal-body">
          <!-- Metadata -->
          <div class="metadata-row">
            <span class="badge column-badge">{{ columnLabel }}</span>
            <span v-if="!editing" class="badge" :class="'priority-' + (feature.priority <= 3 ? feature.priority : 'default')">
              Priority: {{ priorityLabel }}
            </span>
            <select v-else v-model.number="form.priority" class="edit-select">
              <option :value="1">High (1)</option>
              <option :value="2">Medium (2)</option>
              <option :value="3">Low (3)</option>
              <option :value="999">Default</option>
            </select>
          </div>

          <!-- Labels -->
          <div class="section">
            <h3>Labels</h3>
            <div v-if="!editing" class="label-list">
              <span v-for="label in feature.labels" :key="label" class="label-tag">{{ label }}</span>
              <span v-if="!feature.labels?.length" class="muted">No labels</span>
            </div>
            <div v-else class="label-edit">
              <div class="label-input-row">
                <input v-model="labelInput" placeholder="Add label..." maxlength="50" @keydown.enter.prevent="addLabel" />
                <button type="button" @click="addLabel" class="btn-sm">Add</button>
              </div>
              <div class="label-tags">
                <span v-for="label in form.labels" :key="label" class="label-tag">
                  {{ label }}
                  <button type="button" @click="removeLabel(label)" class="remove-label">&times;</button>
                </span>
              </div>
            </div>
          </div>

          <!-- Description -->
          <div class="section">
            <h3>Description</h3>
            <p v-if="!editing" class="description-text">{{ feature.description || 'No description' }}</p>
            <textarea v-else v-model="form.description" rows="3" maxlength="5000" placeholder="Feature description..." />
          </div>

          <!-- Spec -->
          <div class="section">
            <h3>Spec</h3>

            <div class="spec-field">
              <h4>Problem Statement</h4>
              <p v-if="!editing">{{ feature.spec?.problem_statement || 'Not defined' }}</p>
              <textarea v-else v-model="form.spec.problem_statement" rows="2" placeholder="What problem does this feature solve?" />
            </div>

            <div class="spec-field">
              <h4>Acceptance Criteria</h4>
              <template v-if="!editing">
                <ul v-if="feature.spec?.acceptance_criteria?.length">
                  <li v-for="(c, i) in feature.spec.acceptance_criteria" :key="i">{{ c }}</li>
                </ul>
                <span v-else class="muted">Not defined</span>
              </template>
              <template v-else>
                <div class="list-editor">
                  <div v-for="(c, i) in form.spec.acceptance_criteria" :key="i" class="list-item">
                    <span>{{ c }}</span>
                    <button type="button" @click="removeCriterion(i)" class="remove-label">&times;</button>
                  </div>
                  <div class="label-input-row">
                    <input v-model="criterionInput" placeholder="Add criterion..." @keydown.enter.prevent="addCriterion" />
                    <button type="button" @click="addCriterion" class="btn-sm">Add</button>
                  </div>
                </div>
              </template>
            </div>

            <div class="spec-field">
              <h4>UI Description</h4>
              <p v-if="!editing">{{ feature.spec?.ui_description || 'Not defined' }}</p>
              <textarea v-else v-model="form.spec.ui_description" rows="2" placeholder="UI description..." />
            </div>

            <div class="spec-field">
              <h4>Business Logic</h4>
              <template v-if="!editing">
                <ul v-if="feature.spec?.business_logic?.length">
                  <li v-for="(b, i) in feature.spec.business_logic" :key="i">{{ b }}</li>
                </ul>
                <span v-else class="muted">Not defined</span>
              </template>
              <template v-else>
                <div class="list-editor">
                  <div v-for="(b, i) in form.spec.business_logic" :key="i" class="list-item">
                    <span>{{ b }}</span>
                    <button type="button" @click="removeLogic(i)" class="remove-label">&times;</button>
                  </div>
                  <div class="label-input-row">
                    <input v-model="logicInput" placeholder="Add logic requirement..." @keydown.enter.prevent="addLogic" />
                    <button type="button" @click="addLogic" class="btn-sm">Add</button>
                  </div>
                </div>
              </template>
            </div>

            <div class="spec-field">
              <h4>Technical Notes</h4>
              <p v-if="!editing">{{ feature.spec?.technical_notes || 'Not defined' }}</p>
              <textarea v-else v-model="form.spec.technical_notes" rows="2" placeholder="Technical notes..." />
            </div>
          </div>

          <!-- Timeline -->
          <div class="section">
            <h3>Timeline</h3>
            <div class="timeline-row">
              <span class="muted">Created:</span> {{ formatDate(feature.created_at) }}
            </div>
            <div class="timeline-row">
              <span class="muted">Updated:</span> {{ formatDate(feature.updated_at) }}
            </div>
            <div v-if="feature.completed_at" class="timeline-row">
              <span class="muted">Completed:</span> {{ formatDate(feature.completed_at) }}
            </div>
            <div v-if="feature.phases_completed?.length" class="phases-row">
              <span class="muted">Phases:</span>
              <span v-for="phase in feature.phases_completed" :key="phase" class="phase-badge">{{ phase }}</span>
            </div>
          </div>

          <div v-if="error" class="error-msg">{{ error }}</div>

          <!-- Actions -->
          <div class="modal-actions">
            <button v-if="feature.column !== 'done'" type="button" class="btn-secondary" @click="onLaunch">
              Open in Warp
            </button>
            <div class="spacer" />
            <template v-if="!editing">
              <button type="button" class="btn-primary" @click="startEdit">Edit</button>
            </template>
            <template v-else>
              <button type="button" class="btn-secondary" @click="cancelEdit">Cancel</button>
              <button type="button" class="btn-primary" :disabled="loading || !form.name.trim()" @click="onSave">
                {{ loading ? 'Saving...' : 'Save' }}
              </button>
            </template>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--vp-c-bg);
  border-radius: 12px;
  padding: 1.5rem;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
  min-width: 0;
}

.feature-id {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
  text-transform: uppercase;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.2rem;
  word-break: break-word;
}

.edit-name {
  padding: 0.4rem 0.6rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 1.1rem;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--vp-c-text-2);
  padding: 0.25rem;
  line-height: 1;
  flex-shrink: 0;
}

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.metadata-row {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  align-items: center;
}

.badge {
  font-size: 0.75rem;
  padding: 0.2rem 0.6rem;
  border-radius: 4px;
  font-weight: 600;
}

.column-badge {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
}

.priority-1 { background: rgba(239, 68, 68, 0.15); color: #ef4444; }
.priority-2 { background: rgba(249, 115, 22, 0.15); color: #f97316; }
.priority-3 { background: rgba(16, 185, 129, 0.15); color: #10b981; }
.priority-default { background: var(--vp-c-bg-soft); color: var(--vp-c-text-2); }

.edit-select {
  padding: 0.3rem 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
}

.section {
  border-top: 1px solid var(--vp-c-divider);
  padding-top: 0.75rem;
}

.section h3 {
  margin: 0 0 0.5rem;
  font-size: 0.9rem;
  font-weight: 600;
}

.section h4 {
  margin: 0.5rem 0 0.25rem;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--vp-c-text-2);
}

.description-text {
  margin: 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-1);
}

.muted {
  color: var(--vp-c-text-3);
  font-size: 0.85rem;
}

.label-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
}

.label-tag {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.75rem;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
}

.label-edit {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.label-input-row {
  display: flex;
  gap: 0.5rem;
}

.label-input-row input {
  flex: 1;
  padding: 0.4rem 0.6rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
}

.label-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
}

.remove-label {
  background: none;
  border: none;
  cursor: pointer;
  color: inherit;
  font-size: 0.85rem;
  padding: 0;
  line-height: 1;
}

.btn-sm {
  padding: 0.4rem 0.6rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-size: 0.8rem;
  white-space: nowrap;
}

.list-editor {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.list-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  font-size: 0.85rem;
  padding: 0.25rem 0.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 4px;
}

.spec-field ul {
  margin: 0.25rem 0;
  padding-left: 1.2rem;
}

.spec-field li {
  font-size: 0.85rem;
  margin-bottom: 0.15rem;
}

.spec-field p {
  margin: 0;
  font-size: 0.85rem;
}

.spec-field textarea {
  width: 100%;
  padding: 0.4rem 0.6rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  font-family: inherit;
  resize: vertical;
}

.timeline-row {
  font-size: 0.85rem;
  margin-bottom: 0.2rem;
}

.phases-row {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  flex-wrap: wrap;
  font-size: 0.85rem;
}

.phase-badge {
  font-size: 0.7rem;
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
  background: rgba(16, 185, 129, 0.15);
  color: #10b981;
  font-weight: 600;
}

.error-msg {
  color: #ef4444;
  font-size: 0.85rem;
  padding: 0.5rem;
  background: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
}

.modal-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.spacer { flex: 1; }

.btn-secondary {
  padding: 0.5rem 1rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-size: 0.9rem;
}

.btn-primary {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  background: var(--vp-c-brand-1);
  color: var(--vp-c-bg);
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
