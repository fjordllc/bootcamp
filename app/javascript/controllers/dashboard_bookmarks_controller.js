import { Controller } from '@hotwired/stimulus'
import { get, destroy } from '@rails/request.js'
import { toast } from 'vanillaToast'

const EDIT_MODE_KEY = 'dashboard_bookmark_edit_mode'

export default class extends Controller {
  static targets = ['editToggle']

  connect() {
    const savedMode = sessionStorage.getItem(EDIT_MODE_KEY) === 'true'
    this.applyEditMode(savedMode)
  }

  toggleEdit() {
    sessionStorage.setItem(EDIT_MODE_KEY, this.editToggleTarget.checked)
    this.applyEditMode(this.editToggleTarget.checked)
  }

  pageShow(event) {
    if (event?.persisted) {
      this.refresh()
    }
  }

  async refresh() {
    if (this.refreshingFromDelete) return
    try {
      const response = await get('/current_user/bookmarks/dashboard', {
        responseKind: 'html'
      })
      const html = await response.text
      if (html.trim().length === 0) {
        this.element.remove()
      } else {
        this.replaceBookmarks(html)
        const savedMode = sessionStorage.getItem(EDIT_MODE_KEY) === 'true'
        this.applyEditMode(savedMode)
      }
    } catch (error) {
      console.warn(error)
    }
  }

  async delete(event) {
    const deleteButton = event.target.closest('.dashboard-bookmark-delete-button')
    if (!deleteButton) return

    const url = deleteButton.dataset.url
    try {
      const response = await destroy(url)
      if (response.ok) {
        toast('ブックマークを削除しました。')
      } else {
        throw new Error('Failed to delete')
      }
    } catch (error) {
      console.warn(error)
    }

    this.refreshingFromDelete = true
    await this.refresh()
    this.refreshingFromDelete = false
    window.dispatchEvent(new CustomEvent('bookmark:changed'))
  }

  applyEditMode(editMode = false) {
    if (!this.hasEditToggleTarget) return

    this.editToggleTarget.checked = editMode
    const displayStyle = editMode ? 'block' : 'none'
    const deleteButtons = this.element.querySelectorAll('.js-bookmark-delete-button')
    for (const button of deleteButtons) {
      button.style.display = displayStyle
    }
  }

  replaceBookmarks(html) {
    const tempContainer = document.createElement('div')
    tempContainer.innerHTML = html
    const newList = tempContainer.querySelector('.card-list')
    const newFooter = tempContainer.querySelector('.card-footer')

    this.element.querySelector('.card-list').replaceWith(newList)
    this.element.querySelector('.card-footer').replaceWith(newFooter)
  }
}
