import { describe, it, expect, vi, beforeEach } from 'vitest'
import { existsSync, readFileSync } from 'node:fs'

vi.mock('node:fs')

import backlogLoader from '../data/backlog.data'

describe('backlog.data', () => {
  beforeEach(() => {
    vi.mocked(existsSync).mockReset()
    vi.mocked(readFileSync).mockReset()
  })

  it('returns default backlog when file does not exist', () => {
    vi.mocked(existsSync).mockReturnValue(false)

    const result = backlogLoader.load()
    expect(result.schema_version).toBe('1.0.0')
    expect(result.columns).toHaveLength(7)
    expect(result.features).toEqual([])
    expect(result.columns[0].id).toBe('idea')
    expect(result.columns[6].id).toBe('done')
  })

  it('returns parsed JSON when file exists', () => {
    const mockBacklog = {
      schema_version: '1.0.0',
      columns: [{ id: 'idea', title: 'Ideas', wip_limit: null }],
      features: [{ id: 'feat-1', name: 'Auth', column: 'idea' }],
    }

    vi.mocked(existsSync).mockReturnValue(true)
    vi.mocked(readFileSync).mockReturnValue(JSON.stringify(mockBacklog) as any)

    const result = backlogLoader.load()
    expect(result).toEqual(mockBacklog)
    expect(result.features).toHaveLength(1)
    expect(result.features[0].name).toBe('Auth')
  })
})
