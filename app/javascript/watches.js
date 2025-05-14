import CSRF from 'csrf'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const editToggle = document.getElementById('card-list-tools__action')
  const deleteButtonContainers = document.querySelectorAll(
    '.card-list-item__option'
  )

  if (!editToggle) {
    window.addEventListener('beforeunload', function () {
      localStorage.removeItem('watches-delete-mode')
    })
    return
  }

  if (localStorage.getItem('watches-delete-mode') === 'on') {
    editToggle.checked = true
    deleteButtonContainers.forEach((container) => {
      container.classList.remove('hidden')
    })
  } else {
    editToggle.checked = false
    deleteButtonContainers.forEach((container) => {
      container.classList.add('hidden')
    })
  }

  editToggle.addEventListener('change', () => {
    if (editToggle.checked) {
      localStorage.setItem('watches-delete-mode', 'on')
      deleteButtonContainers.forEach((container) => {
        container.classList.remove('hidden')
      })
    } else {
      localStorage.removeItem('watches-delete-mode')
      deleteButtonContainers.forEach((container) => {
        container.classList.add('hidden')
      })
    }
  })

  const currentPage = parseInt(
    document.querySelector('.card-list').dataset.current_page
  )
  const WatchList = document.querySelector('.container.is-md')
  WatchList.addEventListener('click', async (event) => {
    if (event.target.matches('.a-watch-button')) {
      await unWatch(event.target)
      getWatches(currentPage)
    }
  })
})

export async function unWatch(element) {
  const watchId = element.dataset.watch_id
  try {
    const response = await fetch(`/api/watches/${watchId}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
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
    const response = await fetch(`/api/watches?page=${currentPage}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })

    if (!response.ok) {
      throw new Error(`${response.error}`)
    }

    const html = await response.text()
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
