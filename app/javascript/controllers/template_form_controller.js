import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'actions',
    'container',
    'description',
    'destroy',
    'preview',
    'status',
    'submission'
  ]

  connect() {
    this.description = this.descriptionTarget.value
    this.toggleSubmission()
  }

  toggle() {
    if (this.destroyTarget.checked) {
      this.description = this.descriptionTarget.value
    }

    this.update()
  }

  cancelDeletion() {
    this.destroyTarget.checked = false
    this.destroyTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  update() {
    if (!this.hasDestroyTarget || !this.destroyTarget.checked) {
      this.descriptionTarget.disabled = false
      this.descriptionTarget.value = this.description
      this.statusTarget.classList.add('hidden')
      if (this.hasActionsTarget) {
        this.actionsTarget.classList.add('hidden')
      }
      this.descriptionTarget.dispatchEvent(
        new Event('input', { bubbles: true })
      )
      return
    }

    this.descriptionTarget.disabled = true
    this.statusTarget.classList.remove('hidden')
    this.actionsTarget.classList.remove('hidden')
    this.previewTarget.textContent = ''
  }

  toggleSubmission() {
    if (!this.submissionTarget.checked) {
      this.description = this.descriptionTarget.value
      this.containerTarget.hidden = true
      this.descriptionTarget.disabled = true
      return
    }
    this.containerTarget.hidden = false
    this.update()
  }
}
