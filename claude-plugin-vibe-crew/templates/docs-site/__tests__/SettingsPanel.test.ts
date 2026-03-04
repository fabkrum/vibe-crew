import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import SettingsPanel from '../components/SettingsPanel.vue'
import type { ConfigData } from '../data/config.data'

// structuredClone can't handle Vue reactive proxies in jsdom — stub it
vi.stubGlobal('structuredClone', <T>(val: T): T => JSON.parse(JSON.stringify(val)))

function makeConfig(overrides: Partial<ConfigData> = {}): ConfigData {
  return JSON.parse(JSON.stringify({
    schema_version: '1.4.0',
    terminal: 'default',
    notifications: { enabled: true, sound: 'Submarine', on_permission_prompt: true, on_task_complete: true, on_failure: true },
    concurrency: { max_parallel_agents: 3 },
    mcp_servers: { context7: true, chrome_devtools: true, playwright: true, semgrep: false, sentry: false, supabase: false, stripe: false, vercel: false, figma: false },
    mcp_discovery: { auto_recommend: true, auto_add: false },
    formatting: { auto_format: true, formatter: 'prettier' },
    context_warnings: { warn_at_percent: 60, critical_at_percent: 80 },
    cost_limits: { session_warn_usd: 2.0, session_max_usd: 5.0, daily_warn_usd: 20.0 },
    performance_coach: { enabled: true, min_sessions_for_trends: 3, min_sessions_for_mutations: 5 },
    doc_generator: { auto_changelog: true, auto_feature_docs: true, auto_sidebar_rebuild: true },
    onboarding: { show_hints: true, dismissed_hints: [] },
    audit: { auto_github_issues: false, severity_threshold: 'high' },
    opponent_processor: { enabled: true, auto_invoke_after_tdr: true },
    ci_healing: { enabled: true, max_attempts: 3, auto_checkpoint: true },
    gamification: { enabled: true, streak_reminders: false, quiz_frequency: 'weekly', show_xp_in_status: true },
    user_profile: { interview_completed: false, code_literacy: null, autonomy: null, pr_review: null, verbosity: null, gamification_preference: null, learning: null, risk_tolerance: null, updated_at: null },
    ...overrides,
  }))
}

describe('SettingsPanel', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('dirty is false initially and true after a change', async () => {
    const config = makeConfig()
    const wrapper = mount(SettingsPanel, {
      props: { data: config },
      global: { stubs: { Teleport: true } },
    })
    // Save button disabled initially (dirty = false)
    const saveBtn = wrapper.find('.btn-primary')
    expect(saveBtn.attributes('disabled')).toBeDefined()

    // Change a value
    await wrapper.find('.pill-group button').trigger('click')
    // Now dirty should be true and save button enabled
    expect(wrapper.find('.btn-primary').attributes('disabled')).toBeUndefined()
  })

  it('gamification sync: disabled → all false', async () => {
    const config = makeConfig({
      user_profile: { ...makeConfig().user_profile, gamification_preference: null },
      gamification: { enabled: true, streak_reminders: true, quiz_frequency: 'weekly', show_xp_in_status: true },
    })
    const wrapper = mount(SettingsPanel, {
      props: { data: config },
      global: { stubs: { Teleport: true } },
    })

    // Click the "disabled" pill in gamification preference
    const gamificationRow = wrapper.findAll('.profile-row').find(row => row.text().includes('Gamification'))!
    const disabledPill = gamificationRow.findAll('.pill').find(p => p.text().includes('disabled'))!
    await disabledPill.trigger('click')
    await flushPromises()

    // Check the gamification form state via gamification toggles
    const gamSection = wrapper.findAll('section').find(s => s.attributes('aria-label') === 'Gamification settings')!
    const checkboxes = gamSection.findAll('input[type="checkbox"]')
    // enabled should be false
    expect((checkboxes[0].element as HTMLInputElement).checked).toBe(false)
  })

  it('gamification sync: full → all true', async () => {
    const config = makeConfig({
      user_profile: { ...makeConfig().user_profile, gamification_preference: null },
      gamification: { enabled: false, streak_reminders: false, quiz_frequency: 'weekly', show_xp_in_status: false },
    })
    const wrapper = mount(SettingsPanel, {
      props: { data: config },
      global: { stubs: { Teleport: true } },
    })

    const gamificationRow = wrapper.findAll('.profile-row').find(row => row.text().includes('Gamification'))!
    const fullPill = gamificationRow.findAll('.pill').find(p => p.text().includes('full'))!
    await fullPill.trigger('click')
    await flushPromises()

    const gamSection = wrapper.findAll('section').find(s => s.attributes('aria-label') === 'Gamification settings')!
    const checkboxes = gamSection.findAll('input[type="checkbox"]')
    expect((checkboxes[0].element as HTMLInputElement).checked).toBe(true)    // enabled
    expect((checkboxes[1].element as HTMLInputElement).checked).toBe(true)    // streak_reminders
    expect((checkboxes[2].element as HTMLInputElement).checked).toBe(true)    // show_xp_in_status
  })

  it('resetToDefaults restores defaults', async () => {
    const config = makeConfig({ cost_limits: { session_warn_usd: 99, session_max_usd: 99, daily_warn_usd: 99 } })
    const wrapper = mount(SettingsPanel, {
      props: { data: config },
      global: { stubs: { Teleport: true } },
    })

    await wrapper.find('.btn-secondary').trigger('click')

    // After reset, the save button should be enabled (dirty = true since form differs from prop)
    expect(wrapper.find('.btn-primary').attributes('disabled')).toBeUndefined()
  })

  it('save: fetch called correctly and status transitions', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({}),
    })
    vi.stubGlobal('fetch', mockFetch)

    const config = makeConfig()
    const wrapper = mount(SettingsPanel, {
      props: { data: config },
      global: { stubs: { Teleport: true } },
    })

    // Make dirty
    await wrapper.find('.pill-group button').trigger('click')
    // Click save
    await wrapper.find('.btn-primary').trigger('click')
    await flushPromises()

    expect(mockFetch).toHaveBeenCalledWith('/api/save-config', expect.objectContaining({
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    }))
    expect(wrapper.text()).toContain('Saved')
  })

  it('static mode fallback: 404 shows copy modal', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 404,
      json: () => Promise.resolve({ error: 'Not found' }),
    })
    vi.stubGlobal('fetch', mockFetch)

    const config = makeConfig()
    const wrapper = mount(SettingsPanel, {
      props: { data: config },
      global: { stubs: { Teleport: false } },
    })

    // Make dirty and save
    await wrapper.find('.pill-group button').trigger('click')
    await wrapper.find('.btn-primary').trigger('click')
    await flushPromises()

    // The copy modal should show (rendered via teleport to body)
    expect(document.body.querySelector('.modal')).toBeTruthy()

    // Cleanup: remove teleported elements
    document.body.querySelectorAll('.modal-overlay').forEach(el => el.remove())
  })
})
