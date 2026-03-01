import { describe, it, expect, vi, beforeEach } from 'vitest'
import { useBacklogApi } from '../composables/useBacklogApi'

describe('useBacklogApi', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  describe('fetchBacklog', () => {
    it('returns data on success', async () => {
      const mockData = { schema_version: '1.0.0', columns: [], features: [] }
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockData),
      }))

      const { fetchBacklog, loading, error } = useBacklogApi()
      const result = await fetchBacklog()

      expect(result).toEqual(mockData)
      expect(loading.value).toBe(false)
      expect(error.value).toBeNull()
    })

    it('sets error on non-ok response', async () => {
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: false,
        json: () => Promise.resolve({ error: 'Not found' }),
      }))

      const { fetchBacklog, error } = useBacklogApi()
      const result = await fetchBacklog()

      expect(result).toBeNull()
      expect(error.value).toBe('Not found')
    })

    it('sets error on network failure', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Network error')))

      const { fetchBacklog, error } = useBacklogApi()
      const result = await fetchBacklog()

      expect(result).toBeNull()
      expect(error.value).toBe('Network error')
    })
  })

  describe('addIdea', () => {
    it('returns feature on success', async () => {
      const mockFeature = { id: 'new-1', name: 'Test' }
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ feature: mockFeature }),
      }))

      const { addIdea, loading, error } = useBacklogApi()
      const result = await addIdea({ name: 'Test' })

      expect(result).toEqual(mockFeature)
      expect(loading.value).toBe(false)
      expect(error.value).toBeNull()
    })

    it('sets error on non-ok response', async () => {
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: false,
        json: () => Promise.resolve({ error: 'Validation failed' }),
      }))

      const { addIdea, error } = useBacklogApi()
      const result = await addIdea({ name: 'Test' })

      expect(result).toBeNull()
      expect(error.value).toBe('Validation failed')
    })

    it('sets error on network failure', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Connection refused')))

      const { addIdea, error } = useBacklogApi()
      const result = await addIdea({ name: 'Test' })

      expect(result).toBeNull()
      expect(error.value).toBe('Connection refused')
    })
  })

  describe('moveCard', () => {
    it('returns feature on success', async () => {
      const mockFeature = { id: '1', column: 'done' }
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ feature: mockFeature }),
      }))

      const { moveCard } = useBacklogApi()
      const result = await moveCard('1', 'done')

      expect(result).toEqual(mockFeature)
    })

    it('sets error on non-ok response', async () => {
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: false,
        json: () => Promise.resolve({ error: 'WIP limit exceeded' }),
      }))

      const { moveCard, error } = useBacklogApi()
      const result = await moveCard('1', 'in-progress')

      expect(result).toBeNull()
      expect(error.value).toBe('WIP limit exceeded')
    })

    it('sets error on network failure', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Timeout')))

      const { moveCard, error } = useBacklogApi()
      const result = await moveCard('1', 'done')

      expect(result).toBeNull()
      expect(error.value).toBe('Timeout')
    })
  })

  describe('updateCard', () => {
    it('returns feature on success', async () => {
      const mockFeature = { id: '1', name: 'Updated' }
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ feature: mockFeature }),
      }))

      const { updateCard } = useBacklogApi()
      const result = await updateCard({ id: '1', name: 'Updated' })

      expect(result).toEqual(mockFeature)
    })

    it('sets error on non-ok response', async () => {
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: false,
        json: () => Promise.resolve({ error: 'Not found' }),
      }))

      const { updateCard, error } = useBacklogApi()
      const result = await updateCard({ id: '1', name: 'X' })

      expect(result).toBeNull()
      expect(error.value).toBe('Not found')
    })

    it('sets error on network failure', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Offline')))

      const { updateCard, error } = useBacklogApi()
      const result = await updateCard({ id: '1', name: 'X' })

      expect(result).toBeNull()
      expect(error.value).toBe('Offline')
    })
  })

  describe('launchWarp', () => {
    it('returns launch result on success', async () => {
      const mockResult = { warp_url: 'warp://test', command_text: 'claude', feature_name: 'feat' }
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockResult),
      }))

      const { launchWarp } = useBacklogApi()
      const result = await launchWarp({ feature_id: '1' })

      expect(result).toEqual(mockResult)
    })

    it('sets error on non-ok response', async () => {
      vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
        ok: false,
        json: () => Promise.resolve({ error: 'Failed to launch' }),
      }))

      const { launchWarp, error } = useBacklogApi()
      const result = await launchWarp({ command: 'test' })

      expect(result).toBeNull()
      expect(error.value).toBe('Failed to launch')
    })

    it('sets error on network failure', async () => {
      vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('DNS failed')))

      const { launchWarp, error } = useBacklogApi()
      const result = await launchWarp({})

      expect(result).toBeNull()
      expect(error.value).toBe('DNS failed')
    })
  })

  describe('loading/error reactive state', () => {
    it('loading is true during request and false after', async () => {
      let resolvePromise: (value: any) => void
      const pending = new Promise(resolve => { resolvePromise = resolve })
      vi.stubGlobal('fetch', vi.fn().mockReturnValue(pending))

      const { fetchBacklog, loading } = useBacklogApi()
      expect(loading.value).toBe(false)

      const resultPromise = fetchBacklog()
      expect(loading.value).toBe(true)

      resolvePromise!({ ok: true, json: () => Promise.resolve({}) })
      await resultPromise

      expect(loading.value).toBe(false)
    })

    it('error is cleared on new request', async () => {
      vi.stubGlobal('fetch', vi.fn()
        .mockRejectedValueOnce(new Error('First error'))
        .mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({}) }))

      const { fetchBacklog, error } = useBacklogApi()

      await fetchBacklog()
      expect(error.value).toBe('First error')

      await fetchBacklog()
      expect(error.value).toBeNull()
    })
  })
})
