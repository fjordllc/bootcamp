import { unWatch } from './watch-toggle'

document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const editToggle = document.getElementById('card-list-tools__action')
  const deleteButtonContainers = document.querySelectorAll(
    '.card-list-item__option'
  )

  if (!editToggle) {
    window.addEventListener('beforeunload', function () {
      localStorage.removeItem('watchs-delete-mode')
    })
    return
  }

  if (localStorage.getItem('watchs-delete-mode') === 'on') {
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
      localStorage.setItem('watchs-delete-mode', 'on')
      deleteButtonContainers.forEach((container) => {
        container.classList.remove('hidden')
      })
    } else {
      localStorage.removeItem('watchs-delete-mode')
      deleteButtonContainers.forEach((container) => {
        container.classList.add('hidden')
      })
    }
  })

  const hiddenData = document.getElementById('hidden-watch-data')
  const ids = hiddenData.dataset.all_ids.match(/\d+/g).map(Number)
  const nextWatchIndex = parseInt(hiddenData.dataset.next_watch_index)
  const deleteButtons = document.querySelectorAll('.a-watch-button')

  deleteButtons.forEach((button) => {
    button.addEventListener('click', () => {
      unWatch(button)
      const deleteWatchIndex = ids.indexOf(parseInt(button.dataset.watch_id))
      fetchNextPageWatch(ids, nextWatchIndex, deleteWatchIndex)
    })
  })
})

async function fetchNextPageWatch(ids, nextWatchIndex, deleteWatchIndex) {
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
      ids.splice(deleteWatchIndex, 1)
      const html = await response.text()
      const watchsList = document.querySelector('.card-list', '.a-card')
      watchsList.insertAdjacentHTML('beforeend', html)

      const nextWatch = document.getElementById(nextWatchId)
      const deleteButtonContainer = nextWatch.querySelector(
        '.card-list-item__option'
      )
      deleteButtonContainer.classList.remove('hidden')
      const deleteButton =
        deleteButtonContainer.querySelector('.a-watch-button')
      deleteButton.addEventListener('click', () => {
        unWatch(deleteButton)
        const deleteWatchIndex = ids.indexOf(
          parseInt(deleteButton.dataset.watch_id)
        )
        fetchNextPageWatch(ids, nextWatchIndex, deleteWatchIndex)
      })
    }
  } catch (error) {
    console.warn(error)
    return false
  }
}
