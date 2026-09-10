import { Controller } from '@hotwired/stimulus'
import { get, destroy } from '@rails/request.js'
import { toast } from 'vanillaToast'

export default class extends Controller {
  static targets = ['editModeToggle']
  static values = {
    currentPage: Number
  }

  connect() {
    if (!this.hasEditModeToggleTarget) return

    this.#restoreEditMode()
  }

  disconnect() {
    if (!this.hasEditModeToggleTarget) {
      localStorage.removeItem('watches-delete-mode')
    }
  }

  toggleEditMode() {
    if (this.editModeToggleTarget.checked) {
      this.#toggleDeleteButtonsVisibility(false)
      localStorage.setItem('watches-delete-mode', 'on')
    } else {
      this.#toggleDeleteButtonsVisibility(true)
      localStorage.removeItem('watches-delete-mode')
    }
  }

  async unwatch({ currentTarget }) {
    try {
      await this.#destroyWatch(currentTarget)
      await this.#refreshWatches()
      toast('Watchを外しました')
    } catch (error) {
      console.warn(error)
      toast(
        'Watchを外せませんでした。時間をおいてもう一度実行してください',
        'error'
      )
    }
  }

  #restoreEditMode() {
    const deleteMode = localStorage.getItem('watches-delete-mode') === 'on'

    this.editModeToggleTarget.checked = deleteMode
    this.#toggleDeleteButtonsVisibility(!deleteMode)
  }

  #toggleDeleteButtonsVisibility(shouldHide) {
    const deleteButtonContainers = document.querySelectorAll(
      '.card-list-item__option'
    )
    deleteButtonContainers.forEach((container) => {
      container.classList.toggle('hidden', shouldHide)
    })
  }

  async #destroyWatch(element) {
    const watchId = element.dataset.watch_id
    const response = await destroy(`/watches/${watchId}`)

    if (!response.ok) {
      throw new Error(`${response.error}`)
    }

    document.getElementById(watchId).remove()
  }

  async #refreshWatches() {
    try {
      const response = await get('/api/watches', {
        query: {
          page: this.currentPageValue
        }
      })

      if (!response.ok) {
        throw new Error(`${response.error}`)
      }

      const html = await response.text
      const watchesContainer = document.querySelector('#watches')
      watchesContainer.innerHTML = html
      const deleteButtonContainers = watchesContainer.querySelectorAll(
        '.card-list-item__option'
      )
      deleteButtonContainers.forEach((container) => {
        container.classList.remove('hidden')
      })
    } catch (error) {
      console.warn(error)
    }
  }
}
