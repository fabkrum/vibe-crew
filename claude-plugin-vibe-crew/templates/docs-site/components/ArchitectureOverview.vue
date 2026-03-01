<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import { useData } from 'vitepress'

const props = defineProps({
  diagrams: { type: Array, required: true }
})

const { isDark } = useData()
const rendered = ref(false)
const containerRefs = ref([])
let renderGeneration = 0

function setContainerRef(el, index) {
  if (el) containerRefs.value[index] = el
}

async function renderDiagrams() {
  if (!props.diagrams.length) return

  const gen = ++renderGeneration
  const mermaid = (await import('mermaid')).default
  mermaid.initialize({
    startOnLoad: false,
    theme: isDark.value ? 'dark' : 'default',
    securityLevel: 'loose'
  })

  for (let i = 0; i < props.diagrams.length; i++) {
    if (gen !== renderGeneration) return // stale render
    const el = containerRefs.value[i]
    if (!el) continue

    try {
      const id = `mermaid-${gen}-${i}`
      const { svg } = await mermaid.render(id, props.diagrams[i].content)
      el.innerHTML = svg
    } catch {
      el.innerHTML = '<p class="diagram-error">Failed to render diagram.</p>'
    }
  }

  rendered.value = true
}

onMounted(() => {
  nextTick(renderDiagrams)
})

watch([isDark, () => props.diagrams], async () => {
  rendered.value = false
  await nextTick()
  renderDiagrams()
})
</script>

<template>
  <div class="architecture-overview">
    <div v-if="diagrams.length === 0" class="arch-empty">
      <p>No architecture diagrams found yet.</p>
      <p>Run the Tier 1 foundation workflow to generate your project's architecture diagrams.</p>
    </div>
    <div v-else class="arch-grid">
      <div v-for="(diagram, index) in diagrams" :key="diagram.type" class="arch-card">
        <div class="arch-card-header">
          <h3 class="arch-card-title">{{ diagram.name }}</h3>
          <p class="arch-card-desc">{{ diagram.description }}</p>
        </div>
        <div class="arch-card-body" :ref="el => setContainerRef(el, index)">
          <div v-if="!rendered" class="arch-loading">Rendering diagram...</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.architecture-overview {
  padding: 1rem 0;
}

.arch-empty {
  text-align: center;
  color: var(--vp-c-text-3);
  padding: 3rem 1rem;
}

.arch-empty p {
  margin: 0.5rem 0;
}

.arch-grid {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.arch-card {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  overflow: hidden;
}

.arch-card-header {
  padding: 1.25rem 1.5rem 0.75rem;
}

.arch-card-title {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.arch-card-desc {
  margin: 0.25rem 0 0;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}

.arch-card-body {
  padding: 1rem 1.5rem 1.5rem;
  overflow-x: auto;
}

.arch-card-body :deep(svg) {
  max-width: 100%;
  height: auto;
}

.arch-loading {
  color: var(--vp-c-text-3);
  font-size: 0.85rem;
}

.diagram-error {
  color: var(--vp-c-danger-1);
  font-size: 0.85rem;
}
</style>
