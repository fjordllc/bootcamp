import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'

export default class extends Controller {
  static targets = [
    'textarea',
    'submit',
    'editTab',
    'previewTab',
    'editor',
    'previewPanel',
    'previewContent'
  ]

  connect() {
    this.submitting = false
    this.markdown = new MarkdownInitializer()
    this.cleanup = TextareaInitializer.initialize(`#${this.textareaTarget.id}`)
    this.input()
  }

  disconnect() {
    this.cleanup?.()
  }

  input() {
    this.previewContentTarget.innerHTML = this.markdown.render(
      this.textareaTarget.value
    )
    this.submitTarget.disabled =
      this.submitting || this.textareaTarget.value.length === 0
  }

  submitStart() {
    this.submitting = true
  }

  submitEnd() {
    this.submitting = false
    this.input()
  }

  edit() {
    this.showPreview(false)
  }

  preview() {
    this.input()
    this.showPreview(true)
  }

  showPreview(preview) {
    this.editTabTarget.classList.toggle('is-active', !preview)
    this.editorTarget.classList.toggle('is-active', !preview)
    this.previewTabTarget.classList.toggle('is-active', preview)
    this.previewPanelTarget.classList.toggle('is-active', preview)
  }
}
