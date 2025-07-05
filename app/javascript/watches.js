import { get, destroy } from '@rails/request.js'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const editToggle = document.getElementById('card-list-tools__action')
  if (!editToggle) {
    window.addEventListener('beforeunload', function () {
      localStorage.removeItem('watches-delete-mode')
    })
    return
  }

  const deleteMode = localStorage.getItem('watches-delete-mode') === 'on'
  editToggle.checked = deleteMode
  toggleDeleteButtonsVisibility(!deleteMode)

  editToggle.addEventListener('change', () => {
    if (editToggle.checked) {
      toggleDeleteButtonsVisibility(false)
      localStorage.setItem('watches-delete-mode', 'on')
    } else {
      toggleDeleteButtonsVisibility(true)
      localStorage.removeItem('watches-delete-mode')
    }
  })

  const currentPage = parseInt(
    document.querySelector('.card-list').dataset.current_page
  )
  const WatchList = document.querySelector('.container.is-md')
  WatchList.addEventListener('click', async (event) => {
    if (event.target.matches('.a-watch-button')) {
      await unWatchInList(event.target)
      getWatches(currentPage)
    }
  })
})

function toggleDeleteButtonsVisibility(shouldHide) {
  const deleteButtonContainers = document.querySelectorAll(
    '.card-list-item__option'
  )
  deleteButtonContainers.forEach((container) => {
    container.classList.toggle('hidden', shouldHide)
  })
}

async function unWatchInList(element) {
  const watchId = element.dataset.watch_id
  try {
    const response = await destroy(`/api/watches/${watchId}`, {
      headers: { 'Content-Type': 'application/json; charset=utf-8' },
      redirect: 'manual'
    })

    if (!response.ok) {
      throw new Error(`${response.error}`)
    }
    const deleteWatch = document.getElementById(watchId)
    deleteWatch.remove()
    toast('Watchを外しました')
  } catch (error) {
    console.warn(error)
  }
}

async function getWatches(currentPage) {
  try {
    const response = await get(`/api/watches?page=${currentPage}`, {
      redirect: 'manual'
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
