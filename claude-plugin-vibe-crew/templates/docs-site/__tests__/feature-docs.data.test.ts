import { describe, it, expect, vi, beforeEach } from 'vitest'
import { existsSync, readdirSync } from 'node:fs'

vi.mock('node:fs')

import featureDocsLoader from '../data/feature-docs.data'

describe('feature-docs.data', () => {
  beforeEach(() => {
    vi.mocked(existsSync).mockReset()
    vi.mocked(readdirSync).mockReset()
  })

  it('returns empty array when directory does not exist', () => {
    vi.mocked(existsSync).mockReturnValue(false)

    const result = featureDocsLoader.load()
    expect(result).toEqual([])
  })

  it('returns basenames without .md extension for .md files', () => {
    vi.mocked(existsSync).mockReturnValue(true)
    vi.mocked(readdirSync).mockReturnValue([
      'auth-login.md',
      'user-profile.md',
      'dashboard.md',
    ] as any)

    const result = featureDocsLoader.load()
    expect(result).toEqual(['auth-login', 'user-profile', 'dashboard'])
  })

  it('filters out non-.md files', () => {
    vi.mocked(existsSync).mockReturnValue(true)
    vi.mocked(readdirSync).mockReturnValue([
      'feature.md',
      'readme.txt',
      'index.html',
      '.DS_Store',
    ] as any)

    const result = featureDocsLoader.load()
    expect(result).toEqual(['feature'])
  })

  it('returns empty array when directory exists but has no .md files', () => {
    vi.mocked(existsSync).mockReturnValue(true)
    vi.mocked(readdirSync).mockReturnValue(['image.png', 'data.json'] as any)

    const result = featureDocsLoader.load()
    expect(result).toEqual([])
  })
})
