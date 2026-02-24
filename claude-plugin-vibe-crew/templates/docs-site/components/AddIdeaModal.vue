<script setup>
import { ref, reactive } from 'vue'
import { useBacklogApi } from '../composables/useBacklogApi'

const emit = defineEmits(['close', 'added'])
const { loading, error, addIdea } = useBacklogApi()

const form = reactive({
  name: '',
  description: '',
  priority: 999,
  labels: [],
})
const labelInput = ref('')

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

function onLabelKeydown(e) {
  if (e.key === 'Enter') {
    e.preventDefault()
    addLabel()
  }
}

async function onSubmit() {
  if (!form.name.trim()) return
  const feature = await addIdea({
    name: form.name.trim(),
    description: form.description.trim() || undefined,
    priority: form.priority !== 999 ? form.priority : undefined,
    labels: form.labels.length > 0 ? form.labels : undefined,
  })
  if (feature) {
    emit('added', feature)
    emit('close')
  }
}

function onOverlayClick(e) {
  if (e.target === e.currentTarget) emit('close')
}

function onKeydown(e) {
  if (e.key === 'Escape') emit('close')
}
</script>

<template>
  <Teleport to="body">
    <div class="modal-overlay" @click="onOverlayClick" @keydown="onKeydown" tabindex="-1">
      <div class="modal-content" role="dialog" aria-labelledby="add-idea-title">
        <div class="modal-header">
          <h2 id="add-idea-title">Add New Idea</h2>
          <button class="close-btn" @click="emit('close')" aria-label="Close">&times;</button>
        </div>

        <form @submit.prevent="onSubmit" class="modal-body">
          <div class="field">
            <label for="idea-name">Name <span class="required">*</span></label>
            <input
              id="idea-name"
              v-model="form.name"
              type="text"
              maxlength="200"
              placeholder="e.g. User Authentication"
              required
              autofocus
            />
          </div>

          <div class="field">
            <label for="idea-desc">Description</label>
            <textarea
              id="idea-desc"
              v-model="form.description"
              maxlength="5000"
              placeholder="Brief description of the feature..."
              rows="3"
            />
          </div>

          <div class="field">
            <label for="idea-priority">Priority</label>
            <select id="idea-priority" v-model.number="form.priority">
              <option :value="999">Default</option>
              <option :value="1">High (1)</option>
              <option :value="2">Medium (2)</option>
              <option :value="3">Low (3)</option>
            </select>
          </div>

          <div class="field">
            <label>Labels</label>
            <div class="label-input-row">
              <input
                v-model="labelInput"
                type="text"
                maxlength="50"
                placeholder="Add label..."
                @keydown="onLabelKeydown"
              />
              <button type="button" class="add-label-btn" @click="addLabel">Add</button>
            </div>
            <div v-if="form.labels.length" class="label-tags">
              <span v-for="label in form.labels" :key="label" class="label-tag">
                {{ label }}
                <button type="button" @click="removeLabel(label)" class="remove-label">&times;</button>
              </span>
            </div>
          </div>

          <div v-if="error" class="error-msg">{{ error }}</div>

          <div class="modal-actions">
            <button type="button" class="btn-secondary" @click="emit('close')">Cancel</button>
            <button type="submit" class="btn-primary" :disabled="loading || !form.name.trim()">
              {{ loading ? 'Adding...' : 'Add Idea' }}
            </button>
          </div>
        </form>
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
  max-width: 480px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.2rem;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--vp-c-text-2);
  padding: 0.25rem;
  line-height: 1;
}

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.field label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.required {
  color: #ef4444;
}

.field input[type="text"],
.field textarea,
.field select {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
  font-family: inherit;
}

.field textarea {
  resize: vertical;
}

.label-input-row {
  display: flex;
  gap: 0.5rem;
}

.label-input-row input {
  flex: 1;
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  font-size: 0.9rem;
}

.add-label-btn {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-size: 0.85rem;
}

.label-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  margin-top: 0.35rem;
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

.remove-label {
  background: none;
  border: none;
  cursor: pointer;
  color: inherit;
  font-size: 0.85rem;
  padding: 0;
  line-height: 1;
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
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

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
