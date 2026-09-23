import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['editTab', 'editContent', 'previewTab', 'previewContent']

  openEditTab() {
    this.#showTab('edit')
  }

  openPreviewTab() {
    this.#showTab('preview')
  }

  toggleRaw(event) {
    const isRawVisible = !event.currentTarget.classList.contains('is-active')
    this.#setRawMode(isRawVisible)
  }

  #showTab(tabName) {
    const showEdit = tabName === 'edit'
    const showPreview = tabName === 'preview'

    this.editTabTarget.classList.toggle('is-active', showEdit)
    this.editContentTarget.classList.toggle('is-active', showEdit)
    this.previewTabTarget.classList.toggle('is-active', showPreview)
    this.previewContentTarget.classList.toggle('is-active', showPreview)
  }

  #setRawMode(isRawVisible) {
    const rawMarkdownElement = this.element.querySelector('.js-comment-raw')
    const renderedHtmlElement = this.element.querySelector('.js-comment-html')
    const rawButton = this.element.querySelector('.js-raw-button')
    const editorTextarea = this.element.querySelector(
      '.a-markdown-input__textarea'
    )

    if (isRawVisible) {
      rawMarkdownElement.textContent = editorTextarea.value
    }

    rawMarkdownElement.classList.toggle('is-hidden', !isRawVisible)
    renderedHtmlElement.classList.toggle('is-hidden', isRawVisible)
    rawButton.classList.toggle('is-active', isRawVisible)
  }
}
