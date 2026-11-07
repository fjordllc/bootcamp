import { Controller } from '@hotwired/stimulus'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'
import { replaceLinkToCard } from 'replace-link-to-card'

export default class extends Controller {
  #markdownInitializer = new MarkdownInitializer()
  #savedMemo

  static values = {
    textareaSelector: String,
    hasMemo: Boolean
  }

  static targets = [
    'display',
    'displayWithMemo',
    'displayWithoutMemo',
    'displayContent',
    'editor',
    'inputPanel',
    'textarea',
    'inputTab',
    'previewPanel',
    'previewContent',
    'previewTab',
    'editorControl'
  ]

  connect() {
    this.#savedMemo = this.textareaTarget.defaultValue
    this.#renderMemo(this.#savedMemo)
    TextareaInitializer.initialize(this.textareaSelectorValue)
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
    this.textareaTarget.value = this.#savedMemo
    this.#renderMemo(this.#savedMemo)
    this.#showDisplay()
    replaceLinkToCard()
  }

  showInputPanel() {
    this.#setActiveTab('input')
  }

  showPreviewPanel() {
    this.#setActiveTab('preview')
  }

  updatePreviewContent() {
    this.previewContentTarget.innerHTML = this.#markdownInitializer.render(
      this.textareaTarget.value
    )
  }

  #renderMemo(memo) {
    this.displayContentTarget.innerHTML = this.#markdownInitializer.render(memo)
    this.updatePreviewContent()
  }

  #showDisplay() {
    this.displayWithMemoTarget.classList.toggle('is-hidden', !this.hasMemoValue)
    this.displayWithoutMemoTarget.classList.toggle(
      'is-hidden',
      this.hasMemoValue
    )
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

  #setActiveTab(tab) {
    const isInputActive = tab === 'input'
    const isPreviewActive = tab === 'preview'

    this.inputTabTarget.classList.toggle('is-active', isInputActive)
    this.inputPanelTarget.classList.toggle('is-active', isInputActive)
    this.previewTabTarget.classList.toggle('is-active', isPreviewActive)
    this.previewPanelTarget.classList.toggle('is-active', isPreviewActive)
  }
}
