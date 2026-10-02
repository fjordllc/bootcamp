import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'

export default class extends Controller {
  static targets = [
    'inputTab',
    'inputPanel',
    'inputBody',
    'previewTab',
    'previewPanel'
  ]

  connect() {
    TextareaInitializer.initialize(`#${this.inputBodyTarget.id}`)
  }

  openInputTab() {
    this.#showTab('input')
  }

  openPreviewTab() {
    this.#showTab('preview')
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
