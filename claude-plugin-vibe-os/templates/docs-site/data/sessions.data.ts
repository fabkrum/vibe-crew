import { readFileSync, existsSync, readdirSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

export default {
  watch: ['../../.vibeos/sessions/*.json'],

  load() {
    const projectRoot = resolve(__dir, '../..')
    const sessionsDir = resolve(projectRoot, '.vibeos/sessions')

    if (!existsSync(sessionsDir)) {
      return []
    }

    const files = readdirSync(sessionsDir)
      .filter((f) => f.startsWith('session-') && f.endsWith('.json'))
      .sort()

    return files
      .map((file) => {
        try {
          const raw = readFileSync(resolve(sessionsDir, file), 'utf-8')
          return JSON.parse(raw)
        } catch {
          return null
        }
      })
      .filter(Boolean)
  }
}

export declare const data: Record<string, unknown>[]
