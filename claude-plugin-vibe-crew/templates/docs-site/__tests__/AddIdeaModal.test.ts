import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'

// Mock the composable
const mockAddIdea = vi.fn()
const mockLoading = { value: false }
const mockError = { value: null as string | null }

vi.mock('../composables/useBacklogApi', () => ({
  useBacklogApi: () => ({
    loading: mockLoading,
    error: mockError,
    addIdea: mockAddIdea,
  }),
}))

import AddIdeaModal from '../components/AddIdeaModal.vue'

describe('AddIdeaModal', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockLoading.value = false
    mockError.value = null
    mockAddIdea.mockReset()
    // Clean up any teleported elements
    document.body.querySelectorAll('.modal-overlay').forEach(el => el.remove())
  })

  function mountModal() {
    return mount(AddIdeaModal, {
      global: { stubs: { Teleport: false } },
    })
  }

  function getOverlay() {
    return document.body.querySelector('.modal-overlay')!
  }

  it('adds and removes labels', async () => {
    const wrapper = mountModal()
    const overlay = getOverlay()

    const labelInput = overlay.querySelector('.label-input-row input') as HTMLInputElement
    const addBtn = overlay.querySelector('.add-label-btn') as HTMLButtonElement

    // Add a label
    labelInput.value = 'frontend'
    labelInput.dispatchEvent(new Event('input'))
    await flushPromises()
    addBtn.click()
    await flushPromises()

    expect(overlay.querySelectorAll('.label-tag').length).toBe(1)
    expect(overlay.querySelector('.label-tag')!.textContent).toContain('frontend')

    // Remove it
    const removeBtn = overlay.querySelector('.remove-label') as HTMLButtonElement
    removeBtn.click()
    await flushPromises()

    expect(overlay.querySelectorAll('.label-tag').length).toBe(0)

    wrapper.unmount()
  })

  it('deduplicates labels', async () => {
    const wrapper = mountModal()
    const overlay = getOverlay()

    const labelInput = overlay.querySelector('.label-input-row input') as HTMLInputElement
    const addBtn = overlay.querySelector('.add-label-btn') as HTMLButtonElement

    // Add same label twice
    for (let i = 0; i < 2; i++) {
      labelInput.value = 'auth'
      labelInput.dispatchEvent(new Event('input'))
      await flushPromises()
      addBtn.click()
      await flushPromises()
    }

    expect(overlay.querySelectorAll('.label-tag').length).toBe(1)

    wrapper.unmount()
  })

  it('enforces max 20 labels', async () => {
    const wrapper = mountModal()
    const overlay = getOverlay()

    const labelInput = overlay.querySelector('.label-input-row input') as HTMLInputElement
    const addBtn = overlay.querySelector('.add-label-btn') as HTMLButtonElement

    for (let i = 0; i < 22; i++) {
      labelInput.value = `label-${i}`
      labelInput.dispatchEvent(new Event('input'))
      await flushPromises()
      addBtn.click()
      await flushPromises()
    }

    expect(overlay.querySelectorAll('.label-tag').length).toBe(20)

    wrapper.unmount()
  })

  it('calls addIdea with trimmed data and emits events', async () => {
    const fakeFeature = { id: 'new-1', name: 'Test Feature' }
    mockAddIdea.mockResolvedValue(fakeFeature)

    const wrapper = mountModal()
    const overlay = getOverlay()

    // Fill the name
    const nameInput = overlay.querySelector('#idea-name') as HTMLInputElement
    nameInput.value = '  Test Feature  '
    nameInput.dispatchEvent(new Event('input'))
    await flushPromises()

    // Submit the form
    const form = overlay.querySelector('form')!
    form.dispatchEvent(new Event('submit', { cancelable: true }))
    await flushPromises()

    expect(mockAddIdea).toHaveBeenCalledWith({
      name: 'Test Feature',
      description: undefined,
      priority: undefined,
      labels: undefined,
    })

    expect(wrapper.emitted('added')).toBeTruthy()
    expect(wrapper.emitted('close')).toBeTruthy()

    wrapper.unmount()
  })

  it('empty name prevents submit', async () => {
    const wrapper = mountModal()
    const overlay = getOverlay()

    // Submit with empty name
    const form = overlay.querySelector('form')!
    form.dispatchEvent(new Event('submit', { cancelable: true }))
    await flushPromises()

    expect(mockAddIdea).not.toHaveBeenCalled()

    wrapper.unmount()
  })

  it('emits close on overlay click', async () => {
    const wrapper = mountModal()
    const overlay = getOverlay() as HTMLElement

    // Click directly on the overlay (not the modal content)
    overlay.click()
    await flushPromises()

    expect(wrapper.emitted('close')).toBeTruthy()

    wrapper.unmount()
  })
})
