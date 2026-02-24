import { readFileSync, existsSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

const defaultBacklog = {
  schema_version: '1.0.0',
  columns: [
    { id: 'idea', title: 'Ideas', wip_limit: null },
    { id: 'planned', title: 'Planned', wip_limit: 5 },
    { id: 'ready', title: 'Ready', wip_limit: 3 },
    { id: 'in-progress', title: 'In Development', wip_limit: 1 },
    { id: 'testing', title: 'Testing', wip_limit: 1 },
    { id: 'review', title: 'Review', wip_limit: 2 },
    { id: 'done', title: 'Done', wip_limit: null }
  ],
  features: []
}

export default {
  watch: ['../../.vibecrew/backlog.json'],

  load() {
    const projectRoot = resolve(__dir, '../..')
    const backlogPath = resolve(projectRoot, '.vibecrew/backlog.json')

    if (!existsSync(backlogPath)) {
      return defaultBacklog
    }

    const raw = readFileSync(backlogPath, 'utf-8')
    return JSON.parse(raw)
  }
}

export declare const data: typeof defaultBacklog
