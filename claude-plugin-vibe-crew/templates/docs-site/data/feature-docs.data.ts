import { readdirSync, existsSync } from 'node:fs'
import { resolve, dirname, basename } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

export default {
  watch: ['../../docs/features/*.md'],

  load(): string[] {
    const featuresDir = resolve(__dir, '../../docs/features')

    if (!existsSync(featuresDir)) {
      return []
    }

    return readdirSync(featuresDir)
      .filter(f => f.endsWith('.md'))
      .map(f => basename(f, '.md'))
  }
}

export declare const data: string[]
