import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'editor']
  static values = { cancelUrl: String }

  edit(event) {
    if (!this.normalClick(event)) return
    event.preventDefault()
    this.displayTarget.classList.add('is-hidden')
    this.editorTarget.classList.remove('is-hidden')
  }

  cancel(event) {
    if (!this.normalClick(event)) return
    const url = new URL(location.href)
    const destination = new URL(this.cancelUrlValue, location.href)
    if (
      url.pathname !== destination.pathname ||
      url.searchParams.has('edit_answer_id')
    )
      return

    event.preventDefault()
    this.editorTarget.querySelector('form').reset()
    const textarea = this.editorTarget.querySelector('textarea')
    textarea.value = this.element.dataset.answer_description
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
    this.editorTarget.dispatchEvent(new CustomEvent('answer-editor:cancel'))
    this.editorTarget.querySelector('.errors')?.remove()
    this.displayTarget.classList.remove('is-hidden')
    this.editorTarget.classList.add('is-hidden')
  }

  submitEnd({ detail: { success, error, fetchResponse } }) {
    if (!success && fetchResponse?.statusCode !== 422) {
      console.warn(error || fetchResponse)
    }
  }

  normalClick(event) {
    return (
      event.button === 0 &&
      !event.metaKey &&
      !event.ctrlKey &&
      !event.shiftKey &&
      !event.altKey
    )
  }
}
