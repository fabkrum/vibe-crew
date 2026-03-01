<script setup>
import { computed } from 'vue'

const props = defineProps({
  data: { type: Object, required: true },
  featureDocs: { type: Array, default: () => [] }
})

const completedFeatures = computed(() => {
  return (props.data.features || [])
    .filter(f => f.column === 'done' || f.column === 'review')
    .sort((a, b) => {
      const dateA = a.completed_at || a.updated_at || ''
      const dateB = b.completed_at || b.updated_at || ''
      return dateB.localeCompare(dateA)
    })
})

const groupedFeatures = computed(() => {
  const groups = {}
  for (const feature of completedFeatures.value) {
    const label = (feature.labels && feature.labels.length > 0)
      ? feature.labels[0]
      : 'Uncategorized'
    if (!groups[label]) groups[label] = []
    groups[label].push(feature)
  }

  return Object.entries(groups).sort(([a], [b]) => {
    if (a === 'Uncategorized') return 1
    if (b === 'Uncategorized') return -1
    return a.localeCompare(b)
  })
})

function getDescription(feature) {
  return feature.description
    || feature.spec?.ui_description
    || feature.spec?.problem_statement
    || ''
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return d.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

function hasDocPage(featureId) {
  return props.featureDocs.includes(featureId)
}
</script>

<template>
  <div class="product-features">
    <div v-if="completedFeatures.length === 0" class="pf-empty">
      <p>No completed features yet.</p>
      <p>Features will appear here once they reach the Review or Done stage.</p>
    </div>

    <template v-else>
      <div class="pf-summary">
        <span class="pf-count">{{ completedFeatures.length }}</span>
        {{ completedFeatures.length === 1 ? 'feature' : 'features' }} shipped
      </div>

      <div v-for="[label, features] in groupedFeatures" :key="label" class="pf-group">
        <h2 class="pf-group-title">{{ label }}</h2>
        <div class="pf-grid">
          <div v-for="feature in features" :key="feature.id" class="pf-card">
            <div class="pf-card-header">
              <h3 class="pf-card-title">{{ feature.name }}</h3>
              <span v-if="feature.completed_at" class="pf-card-date">
                {{ formatDate(feature.completed_at) }}
              </span>
            </div>

            <p v-if="getDescription(feature)" class="pf-card-desc">
              {{ getDescription(feature) }}
            </p>

            <div class="pf-card-footer">
              <div class="pf-card-labels">
                <span v-for="l in feature.labels" :key="l" class="pf-label">{{ l }}</span>
              </div>
              <a
                v-if="hasDocPage(feature.id)"
                :href="`/features/${feature.id}`"
                class="pf-details-link"
              >
                Details &rarr;
              </a>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.product-features {
  padding: 1rem 0;
}

.pf-empty {
  text-align: center;
  color: var(--vp-c-text-3);
  padding: 3rem 1rem;
}

.pf-empty p {
  margin: 0.5rem 0;
}

.pf-summary {
  margin-bottom: 1.5rem;
  padding: 0.75rem 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  font-size: 0.95rem;
  color: var(--vp-c-text-2);
}

.pf-count {
  font-weight: 700;
  font-size: 1.1rem;
  color: var(--vp-c-brand-1);
}

.pf-group {
  margin-bottom: 2rem;
}

.pf-group-title {
  margin: 0 0 1rem;
  font-size: 1.15rem;
  font-weight: 600;
  border-bottom: 1px solid var(--vp-c-divider);
  padding-bottom: 0.5rem;
}

.pf-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1rem;
}

.pf-card {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.pf-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.5rem;
}

.pf-card-title {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
}

.pf-card-date {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
  white-space: nowrap;
}

.pf-card-desc {
  margin: 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.5;
}

.pf-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.pf-card-labels {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.pf-label {
  font-size: 0.75rem;
  padding: 0.15rem 0.5rem;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  border-radius: 4px;
}

.pf-details-link {
  font-size: 0.85rem;
  color: var(--vp-c-brand-1);
  text-decoration: none;
  font-weight: 500;
  white-space: nowrap;
}

.pf-details-link:hover {
  text-decoration: underline;
}
</style>
