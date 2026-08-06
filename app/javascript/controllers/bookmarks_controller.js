import { Controller } from '@hotwired/stimulus'
import { get, destroy } from '@rails/request.js'

const EDIT_MODE_KEY = 'bookmark_edit_mode'

export default class extends Controller {
  static targets = ['editToggle', 'pageBody']

  connect() {
    const savedMode = sessionStorage.getItem(EDIT_MODE_KEY) === 'true'
    this.applyEditMode(savedMode)
  }

  toggleEdit() {
    sessionStorage.setItem(EDIT_MODE_KEY, this.editToggleTarget.checked)
    this.applyEditMode(this.editToggleTarget.checked)
  }

  async delete(event) {
    const deleteButton = event.target.closest('.bookmark-delete-button')
    if (!deleteButton) return

    deleteButton.disabled = true

    try {
      const url = deleteButton.dataset.url
      const response = await destroy(url)

      if (!response.ok) {
        throw new Error(`削除に失敗しました。(ステータス: ${response.status})`)
      }

      const params = new URLSearchParams(location.search)
      const currentPage = parseInt(params.get('page') || '1', 10)
      const newPageMain = await this.fetchPageMain(currentPage)

      let pageToShow = newPageMain
      if (currentPage > 1 && newPageMain.querySelector('.o-empty-message')) {
        pageToShow = await this.fetchPageMain(currentPage - 1)
      }
      this.pageBodyTarget.replaceWith(pageToShow)

      window.dispatchEvent(new CustomEvent('bookmark:changed'))
      const savedMode = sessionStorage.getItem(EDIT_MODE_KEY) === 'true'
      this.applyEditMode(savedMode)
    } catch (error) {
      console.warn(error)
      deleteButton.disabled = false
    }
  }

  applyEditMode(editMode) {
    if (!this.hasEditToggleTarget) return

    const deleteButtons =
      this.element.getElementsByClassName('js-bookmark-delete-button')
    if (deleteButtons.length === 0) return

    this.editToggleTarget.checked = editMode
    const displayStyle = editMode ? 'block' : 'none'
    for (const button of deleteButtons) {
      button.style.display = displayStyle
    }
  }

  async fetchPageMain(page) {
    const bookmarkUrl = `/current_user/bookmarks?page=${page}`
    const response = await get(bookmarkUrl, { responseKind: 'html' })
    const html = await response.text
    const parser = new DOMParser()
    const parsedDocument = parser.parseFromString(html, 'text/html')
    return parsedDocument.querySelector('.page-body')
  }
}
