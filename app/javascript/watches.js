import { unWatch } from './watch-toggle'

document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const editToggle = document.getElementById('card-list-tools__action')
  const deleteButtons = document.querySelectorAll('.a-watch-button')

  if (!editToggle) {
    window.addEventListener('beforeunload', function () {
      localStorage.removeItem('watchs-delete-mode')
    })
    return
  }

  if (localStorage.getItem('watchs-delete-mode') === 'on') {
    editToggle.checked = true
    deleteButtons.forEach((button) => {
      button.classList.remove('hidden')
    })
  } else {
    editToggle.checked = false
    deleteButtons.forEach((button) => {
      button.classList.add('hidden')
    })
  }

  editToggle.addEventListener('change', () => {
    if (editToggle.checked) {
      localStorage.setItem('watchs-delete-mode', 'on')
      deleteButtons.forEach((button) => {
        button.classList.remove('hidden')
      })
    } else {
      localStorage.removeItem('watchs-delete-mode')
      deleteButtons.forEach((button) => {
        button.classList.add('hidden')
      })
    }
  })

  const hiddenData = document.getElementById('hidden-watch-data')
  const perPage = hiddenData.dataset.default_per_page
  const pageNum = hiddenData.dataset.page_num
  const ids = hiddenData.dataset.all_ids.match(/\d+/g).map(Number)

  deleteButtons.forEach((button) => {
    button.addEventListener('click', () => {
      unWatch(button)
      fetchWatch(perPage, pageNum, ids)
    })
  })
})

async function fetchWatch(perPage, pageNum, ids) {
  const nextWatchIndex = pageNum ? perPage * pageNum : perPage
  if (ids.length < nextWatchIndex) {
    return
  }

  const nextWatchId = ids[nextWatchIndex]
  try {
    const response = await fetch(`/api/watches/${nextWatchId}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })

    if (response.ok) {
      ids.splice(nextWatchIndex, 1)
      const html = await response.text()
      const watchsList = document.querySelector('.card-list', '.a-card')
      watchsList.insertAdjacentHTML('beforeend', html)

      const nextWatch = document.getElementById(nextWatchId)
      const deleteButton = nextWatch.querySelector('.a-watch-button')
      deleteButton.classList.remove('hidden')
      deleteButton.addEventListener('click', () => {
        unWatch(deleteButton)
        fetchWatch(perPage, pageNum, ids)
      })
    }
  } catch (error) {
    console.warn(error)
    return false
  }
}
