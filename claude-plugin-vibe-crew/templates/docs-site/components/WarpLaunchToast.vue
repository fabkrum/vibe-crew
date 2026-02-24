<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  featureName: { type: String, default: '' },
  command: { type: String, default: '' },
})
const emit = defineEmits(['dismiss'])

const visible = ref(true)
const copied = ref(false)
let timer = null

onMounted(() => {
  timer = setTimeout(() => {
    visible.value = false
    emit('dismiss')
  }, 8000)
})

onUnmounted(() => {
  if (timer) clearTimeout(timer)
})

async function copyCommand() {
  try {
    await navigator.clipboard.writeText(props.command)
    copied.value = true
    setTimeout(() => { copied.value = false }, 2000)
  } catch {
    // Clipboard API not available
  }
}

function dismiss() {
  visible.value = false
  if (timer) clearTimeout(timer)
  emit('dismiss')
}
</script>

<template>
  <Teleport to="body">
    <Transition name="slide-up">
      <div v-if="visible" class="toast-container">
        <div class="toast">
          <div class="toast-header">
            <span class="toast-title">Warp Tab Opening</span>
            <button class="toast-close" @click="dismiss" aria-label="Dismiss">&times;</button>
          </div>
          <div v-if="featureName" class="toast-feature">{{ featureName }}</div>
          <div class="toast-command">
            <code>{{ command }}</code>
            <button class="copy-btn" @click="copyCommand">
              {{ copied ? 'Copied!' : 'Copy' }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.toast-container {
  position: fixed;
  bottom: 1.5rem;
  right: 1.5rem;
  z-index: 1001;
}

.toast {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 10px;
  padding: 1rem;
  min-width: 280px;
  max-width: 380px;
  box-shadow: 0 6px 24px rgba(0, 0, 0, 0.25);
}

.toast-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.toast-title {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-brand-1);
}

.toast-close {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  color: var(--vp-c-text-2);
  padding: 0;
  line-height: 1;
}

.toast-feature {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  margin-bottom: 0.5rem;
}

.toast-command {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
  padding: 0.5rem 0.75rem;
}

.toast-command code {
  flex: 1;
  font-size: 0.8rem;
  color: var(--vp-c-text-1);
  word-break: break-all;
}

.copy-btn {
  padding: 0.25rem 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  cursor: pointer;
  font-size: 0.75rem;
  white-space: nowrap;
}

.slide-up-enter-active {
  transition: all 0.3s ease-out;
}

.slide-up-leave-active {
  transition: all 0.3s ease-in;
}

.slide-up-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.slide-up-leave-to {
  opacity: 0;
  transform: translateY(20px);
}
</style>
