import { Controller } from '@hotwired/stimulus'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'

export default class extends Controller {
  #markdownInitializer = new MarkdownInitializer()
  #savedMemo = ''

  static values = {
    editorTextareaSelector: String
  }

  static targets = [
    'display',
    'displayWithMemo',
    'displayWithoutMemo',
    'displayContent',
    'editor',
    'editorTextarea',
    'editorTextareaContent',
    'editorTextareaTab',
    'editorPreview',
    'editorPreviewContent',
    'editorPreviewTab',
    'editorControl'
  ]

  connect() {
    this.#savedMemo = this.editorTextareaContentTarget.value
    this.#renderMemo(this.#savedMemo)
    TextareaInitializer.initialize(this.editorTextareaSelectorValue)
  }

  submitStart() {
    this.#setFormDisabled(true)
  }

  submitEnd(event) {
    if (event.detail.success) {
      toast('保存しました！')
    } else {
      toast('メモの保存に失敗しました', 'error')
      this.#setFormDisabled(false)
    }
  }

  handleClickEditButton() {
    this.#showEditor()
  }

  handleClickCancelButton() {
    this.editorTextareaContentTarget.value = this.#savedMemo
    this.#renderMemo(this.#savedMemo)
    this.#showDisplay()
    TextareaInitializer.initialize(this.editorTextareaSelectorValue)
  }

  showEditorTextarea() {
    this.editorTextareaTarget.classList.add('is-active')
    this.editorTextareaTabTarget.classList.add('is-active')
    this.editorPreviewTarget.classList.remove('is-active')
    this.editorPreviewTabTarget.classList.remove('is-active')
  }

  showEditorPreview() {
    this.editorTextareaTarget.classList.remove('is-active')
    this.editorTextareaTabTarget.classList.remove('is-active')
    this.editorPreviewTarget.classList.add('is-active')
    this.editorPreviewTabTarget.classList.add('is-active')
  }

  updateEditorPreviewContent() {
    this.editorPreviewContentTarget.innerHTML =
      this.#markdownInitializer.render(this.editorTextareaContentTarget.value)
  }

  #renderMemo(memo) {
    const renderedMemo = this.#markdownInitializer.render(memo)

    this.displayContentTarget.innerHTML = renderedMemo
    this.editorPreviewContentTarget.innerHTML = renderedMemo
  }

  #showDisplay() {
    const hasMemo = this.#savedMemo !== ''

    this.displayWithMemoTarget.classList.toggle('is-hidden', !hasMemo)
    this.displayWithoutMemoTarget.classList.toggle('is-hidden', hasMemo)
    this.displayTarget.classList.remove('is-hidden')
    this.editorTarget.classList.add('is-hidden')
  }

  #showEditor() {
    this.displayTarget.classList.add('is-hidden')
    this.editorTarget.classList.remove('is-hidden')
  }

  #setFormDisabled(isDisabled) {
    this.editorControlTargets.forEach((control) => {
      control.disabled = isDisabled
    })
  }
}
