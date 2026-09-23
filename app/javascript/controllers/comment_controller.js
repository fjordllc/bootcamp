import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['editTab', 'editContent', 'previewTab', 'previewContent']

  openEditTab() {
    this.#showTab('edit')
  }

  openPreviewTab() {
    this.#showTab('preview')
  }

  #showTab(tabName) {
    const showEdit = tabName === 'edit'
    const showPreview = tabName === 'preview'

    this.editTabTarget.classList.toggle('is-active', showEdit)
    this.editContentTarget.classList.toggle('is-active', showEdit)
    this.previewTabTarget.classList.toggle('is-active', showPreview)
    this.previewContentTarget.classList.toggle('is-active', showPreview)
  }

}
