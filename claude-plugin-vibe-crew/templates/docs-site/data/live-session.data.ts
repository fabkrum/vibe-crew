import { readFileSync, existsSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

const defaultSession = { active: false }

export default {
  watch: ['../../.vibecrew/live-session.json'],

  load() {
    const projectRoot = resolve(__dir, '../..')
    const sessionPath = resolve(projectRoot, '.vibecrew/live-session.json')

    if (!existsSync(sessionPath)) {
      return defaultSession
    }

    try {
      const raw = readFileSync(sessionPath, 'utf-8')
      const data = JSON.parse(raw)
      return { active: true, ...data }
    } catch {
      return defaultSession
    }
  }
}

export declare const data: { active: boolean; [key: string]: any }
