import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['editTab', 'editPanel', 'previewTab', 'previewPanel']

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
    this.editPanelTarget.classList.toggle('is-active', showEdit)
    this.previewTabTarget.classList.toggle('is-active', showPreview)
    this.previewPanelTarget.classList.toggle('is-active', showPreview)
  }
}
