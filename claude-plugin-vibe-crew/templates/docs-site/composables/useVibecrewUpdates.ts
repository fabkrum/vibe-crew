import { ref, onMounted, onUnmounted } from 'vue'

export interface VibecrewUpdateEvent {
  updateType: string
  filename: string
  timestamp: number
}

export function useVibecrewUpdates(
  onUpdate?: (event: VibecrewUpdateEvent) => void,
) {
  const connected = ref(false)
  let pollTimer: ReturnType<typeof setInterval> | null = null

  onMounted(() => {
    // Use Vite HMR WebSocket in dev mode
    if (import.meta.hot) {
      connected.value = true
      import.meta.hot.on('vibecrew:update', (data: VibecrewUpdateEvent) => {
        onUpdate?.(data)
      })
    } else {
      // Fallback: poll every 5 seconds in static/preview mode
      pollTimer = setInterval(() => {
        onUpdate?.({
          updateType: 'poll',
          filename: '',
          timestamp: Date.now(),
        })
      }, 5000)
      connected.value = true
    }
  })

  onUnmounted(() => {
    if (pollTimer) {
      clearInterval(pollTimer)
      pollTimer = null
    }
  })

  return { connected }
}
