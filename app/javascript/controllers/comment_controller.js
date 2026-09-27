import { Controller } from '@hotwired/stimulus'
import MarkdownInitializer from 'markdown-initializer'

export default class extends Controller {
  static targets = [
    'commentCard',
    'editCard',
    'editTab',
    'editPanel',
    'editBody',
    'previewTab',
    'previewPanel',
    'previewBody'
  ]

  openEditor() {
    this.savedComment = this.editBodyTarget.value

    this.commentCardTarget.classList.add('is-hidden')
    this.editCardTarget.classList.remove('is-hidden')
    this.#setRawMode(false)
  }

  cancelEditor() {
    this.commentCardTarget.classList.remove('is-hidden')
    this.editCardTarget.classList.add('is-hidden')

    this.editBodyTarget.value = this.savedComment
    const html = new MarkdownInitializer().render(this.savedComment)
    this.previewBodyTarget.innerHTML = html
  }

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

  async copyUrl(event) {
    const createdAtElement = event.currentTarget
    if (!navigator.clipboard) return

    const commentUrl = new URL(window.location.href)
    commentUrl.hash = this.element.id

    try {
      await navigator.clipboard.writeText(commentUrl.toString())
      createdAtElement.classList.add('is-active')
      setTimeout(() => {
        createdAtElement.classList.remove('is-active')
      }, 4000)
    } catch (error) {
      console.error(error)
    }
  }

  #showTab(tabName) {
    const showEdit = tabName === 'edit'
    const showPreview = tabName === 'preview'

    this.editTabTarget.classList.toggle('is-active', showEdit)
    this.editPanelTarget.classList.toggle('is-active', showEdit)
    this.previewTabTarget.classList.toggle('is-active', showPreview)
    this.previewPanelTarget.classList.toggle('is-active', showPreview)
  }

  #setRawMode(isRawVisible) {
    const rawMarkdownElement = this.element.querySelector('.js-comment-raw')
    const renderedHtmlElement = this.element.querySelector('.js-comment-html')
    const rawButton = this.element.querySelector('.js-raw-button')

    if (isRawVisible) {
      rawMarkdownElement.textContent = this.editBodyTarget.value
    }

    rawMarkdownElement.classList.toggle('is-hidden', !isRawVisible)
    renderedHtmlElement.classList.toggle('is-hidden', isRawVisible)
    rawButton.classList.toggle('is-active', isRawVisible)
  }
}
