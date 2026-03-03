import { readFileSync, existsSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))

export interface ConfigData {
  schema_version: string
  terminal: string
  claude_command: string
  notifications: {
    enabled: boolean
    sound: string
    on_permission_prompt: boolean
    on_task_complete: boolean
    on_failure: boolean
  }
  concurrency: {
    max_parallel_agents: number
  }
  mcp_servers: Record<string, boolean>
  mcp_discovery: {
    auto_recommend: boolean
    auto_add: boolean
  }
  formatting: {
    auto_format: boolean
    formatter: string
  }
  context_warnings: {
    warn_at_percent: number
    critical_at_percent: number
  }
  cost_limits: {
    session_warn_usd: number
    session_max_usd: number
    daily_warn_usd: number
  }
  performance_coach: {
    enabled: boolean
    min_sessions_for_trends: number
    min_sessions_for_mutations: number
  }
  doc_generator: {
    auto_changelog: boolean
    auto_feature_docs: boolean
    auto_sidebar_rebuild: boolean
  }
  onboarding: {
    show_hints: boolean
    dismissed_hints: string[]
  }
  audit: {
    auto_github_issues: boolean
    severity_threshold: string
  }
  opponent_processor: {
    enabled: boolean
    auto_invoke_after_tdr: boolean
  }
  ci_healing: {
    enabled: boolean
    max_attempts: number
    auto_checkpoint: boolean
  }
  gamification: {
    enabled: boolean
    streak_reminders: boolean
    quiz_frequency: string
    show_xp_in_status: boolean
  }
  user_profile: {
    interview_completed: boolean
    role: string | null
    code_literacy: string | null
    autonomy: string | null
    pr_review: string | null
    verbosity: string | null
    gamification_preference: string | null
    learning: string | null
    risk_tolerance: string | null
    updated_at: string | null
  }
}

const defaultConfig: ConfigData = {
  schema_version: '1.4.0',
  terminal: 'default',
  claude_command: 'claude',
  notifications: {
    enabled: true,
    sound: 'Submarine',
    on_permission_prompt: true,
    on_task_complete: true,
    on_failure: true
  },
  concurrency: {
    max_parallel_agents: 3
  },
  mcp_servers: {
    context7: true,
    chrome_devtools: true,
    playwright: true,
    semgrep: false,
    sentry: false,
    supabase: false,
    stripe: false,
    vercel: false,
    figma: false
  },
  mcp_discovery: {
    auto_recommend: true,
    auto_add: false
  },
  formatting: {
    auto_format: true,
    formatter: 'prettier'
  },
  context_warnings: {
    warn_at_percent: 60,
    critical_at_percent: 80
  },
  cost_limits: {
    session_warn_usd: 2.00,
    session_max_usd: 5.00,
    daily_warn_usd: 20.00
  },
  performance_coach: {
    enabled: true,
    min_sessions_for_trends: 3,
    min_sessions_for_mutations: 5
  },
  doc_generator: {
    auto_changelog: true,
    auto_feature_docs: true,
    auto_sidebar_rebuild: true
  },
  onboarding: {
    show_hints: true,
    dismissed_hints: []
  },
  audit: {
    auto_github_issues: false,
    severity_threshold: 'high'
  },
  opponent_processor: {
    enabled: true,
    auto_invoke_after_tdr: true
  },
  ci_healing: {
    enabled: true,
    max_attempts: 3,
    auto_checkpoint: true
  },
  gamification: {
    enabled: true,
    streak_reminders: false,
    quiz_frequency: 'weekly',
    show_xp_in_status: true
  },
  user_profile: {
    interview_completed: false,
    role: null,
    code_literacy: null,
    autonomy: null,
    pr_review: null,
    verbosity: null,
    gamification_preference: null,
    learning: null,
    risk_tolerance: null,
    updated_at: null
  }
}

export default {
  watch: ['../../.vibecrew/config.json'],

  load(): ConfigData {
    const projectRoot = resolve(__dir, '../..')
    const configPath = resolve(projectRoot, '.vibecrew/config.json')

    if (!existsSync(configPath)) {
      return defaultConfig
    }

    try {
      const raw = readFileSync(configPath, 'utf-8')
      const parsed = JSON.parse(raw)
      // Deep merge with defaults to ensure all fields exist
      return deepMerge(defaultConfig, parsed) as ConfigData
    } catch {
      return defaultConfig
    }
  }
}

function deepMerge(defaults: Record<string, any>, overrides: Record<string, any>): Record<string, any> {
  const result: Record<string, any> = { ...defaults }
  for (const key of Object.keys(overrides)) {
    if (
      overrides[key] !== null &&
      typeof overrides[key] === 'object' &&
      !Array.isArray(overrides[key]) &&
      typeof defaults[key] === 'object' &&
      defaults[key] !== null &&
      !Array.isArray(defaults[key])
    ) {
      result[key] = deepMerge(defaults[key], overrides[key])
    } else {
      result[key] = overrides[key]
    }
  }
  return result
}

export declare const data: ConfigData
