import { ref } from 'vue'

export interface BacklogFeature {
  id: string
  name: string
  description: string
  column: string
  priority: number
  labels: string[]
  spec: {
    acceptance_criteria: string[]
    ui_description: string | null
    business_logic: string[]
    technical_notes: string | null
  }
  worktree: string | null
  phases_completed: string[]
  sessions: string[]
  created_at: string
  updated_at: string
  completed_at: string | null
}

export interface BacklogColumn {
  id: string
  title: string
  wip_limit: number | null
}

export interface BacklogData {
  schema_version: string
  columns: BacklogColumn[]
  features: BacklogFeature[]
}

export interface LaunchResult {
  warp_url: string
  command_text: string
  feature_name: string
}

export function useBacklogApi() {
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchBacklog(): Promise<BacklogData | null> {
    loading.value = true
    error.value = null
    try {
      const res = await fetch('/api/backlog')
      if (!res.ok) {
        error.value = (await res.json()).error || 'Failed to fetch backlog'
        return null
      }
      return await res.json()
    } catch (err: any) {
      error.value = err.message || 'Network error'
      return null
    } finally {
      loading.value = false
    }
  }

  async function addIdea(data: {
    name: string
    description?: string
    labels?: string[]
    priority?: number
  }): Promise<BacklogFeature | null> {
    loading.value = true
    error.value = null
    try {
      const res = await fetch('/api/backlog/add-idea', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      if (!res.ok) {
        error.value = (await res.json()).error || 'Failed to add idea'
        return null
      }
      const result = await res.json()
      return result.feature
    } catch (err: any) {
      error.value = err.message || 'Network error'
      return null
    } finally {
      loading.value = false
    }
  }

  async function moveCard(
    id: string,
    column: string,
  ): Promise<BacklogFeature | null> {
    loading.value = true
    error.value = null
    try {
      const res = await fetch('/api/backlog/move', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id, column }),
      })
      if (!res.ok) {
        error.value = (await res.json()).error || 'Failed to move card'
        return null
      }
      const result = await res.json()
      return result.feature
    } catch (err: any) {
      error.value = err.message || 'Network error'
      return null
    } finally {
      loading.value = false
    }
  }

  async function updateCard(data: {
    id: string
    name?: string
    description?: string
    priority?: number
    labels?: string[]
    spec?: Partial<BacklogFeature['spec']>
  }): Promise<BacklogFeature | null> {
    loading.value = true
    error.value = null
    try {
      const res = await fetch('/api/backlog/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      if (!res.ok) {
        error.value = (await res.json()).error || 'Failed to update card'
        return null
      }
      const result = await res.json()
      return result.feature
    } catch (err: any) {
      error.value = err.message || 'Network error'
      return null
    } finally {
      loading.value = false
    }
  }

  async function launchWarp(data: {
    feature_id?: string
    command?: string
  }): Promise<LaunchResult | null> {
    loading.value = true
    error.value = null
    try {
      const res = await fetch('/api/launch-warp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      if (!res.ok) {
        error.value = (await res.json()).error || 'Failed to launch'
        return null
      }
      return await res.json()
    } catch (err: any) {
      error.value = err.message || 'Network error'
      return null
    } finally {
      loading.value = false
    }
  }

  return { loading, error, fetchBacklog, addIdea, moveCard, updateCard, launchWarp }
}
