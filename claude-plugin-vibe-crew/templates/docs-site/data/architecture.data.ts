import { readFileSync, existsSync, readdirSync } from 'node:fs'
import { resolve, dirname, basename } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

interface Diagram {
  name: string
  type: string
  description: string
  content: string
}

const DIAGRAM_META: Record<string, { name: string; description: string }> = {
  system: {
    name: 'System Architecture',
    description: 'Infrastructure topology — services, databases, and external integrations.'
  },
  schema: {
    name: 'Database Schema',
    description: 'Entity-relationship diagram showing data models and their connections.'
  },
  'state-flows': {
    name: 'State & User Flows',
    description: 'Authentication states and user journey transitions.'
  },
  'api-sequences': {
    name: 'API Sequences',
    description: 'Request/response patterns between client, server, and external services.'
  },
  'component-tree': {
    name: 'Component Tree',
    description: 'Component hierarchy with data flow between UI elements.'
  }
}

export default {
  watch: ['../../.vibecrew/architecture/*.mmd'],

  load(): Diagram[] {
    const projectRoot = resolve(__dir, '../..')
    const archDir = resolve(projectRoot, '.vibecrew/architecture')

    if (!existsSync(archDir)) {
      return []
    }

    const files = readdirSync(archDir).filter(f => f.endsWith('.mmd'))

    return files.map(file => {
      const type = basename(file, '.mmd')
      const meta = DIAGRAM_META[type] || { name: type, description: '' }
      const content = readFileSync(resolve(archDir, file), 'utf-8')
      return { name: meta.name, type, description: meta.description, content }
    })
  }
}

export declare const data: ReturnType<typeof import('./architecture.data.ts').default.load>
