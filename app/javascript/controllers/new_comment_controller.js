import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import autosize from 'autosize'

export default class extends Controller {
  static targets = [
    'inputTab',
    'inputPanel',
    'inputBody',
    'previewTab',
    'previewPanel',
    'previewBody',
    'submitButton',
    'submitAndCheckButton'
  ]

  connect() {
    this.setSubmitButtonState()
    TextareaInitializer.initialize(`#${this.inputBodyTarget.id}`)
  }

  openInputTab() {
    this.#showTab('input')
  }

  openPreviewTab() {
    this.#showTab('preview')
  }

  setSubmitButtonState() {
    const isEmpty = this.inputBodyTarget.value.length === 0

    this.submitButtonTarget.disabled = isEmpty
    if (this.hasSubmitAndCheckButtonTarget) {
      this.submitAndCheckButtonTarget.disabled = isEmpty
    }
  }

  #resetForm() {
    this.openInputTab()
    this.inputBodyTarget.value = ''
    autosize.update(this.inputBodyTarget)
    this.previewBodyTarget.innerHTML = ''
    this.setSubmitButtonState()
  }

  #showTab(tabName) {
    const showInput = tabName === 'input'
    const showPreview = tabName === 'preview'

    this.inputTabTarget.classList.toggle('is-active', showInput)
    this.inputPanelTarget.classList.toggle('is-active', showInput)
    this.previewTabTarget.classList.toggle('is-active', showPreview)
    this.previewPanelTarget.classList.toggle('is-active', showPreview)
  }
}
