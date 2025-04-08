import CSRF from 'csrf'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const watchToggle = document.getElementById('watch-button')
  if (!watchToggle) {
    return
  }

  watchToggle.addEventListener('click', () => {
    if (watchToggle.classList.contains('is-inactive')) {
      watch(watchToggle)
    }
    if (watchToggle.classList.contains('is-active')) {
      unWatch(watchToggle)
    }
  })
})

function watch(element) {
  const watchableType = element.dataset.watchable_type
  const watchableId = element.dataset.watchable_id
  const params = {
    watchable_type: watchableType,
    watchable_id: watchableId
  }
  fetch(`/api/watches`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual',
    body: JSON.stringify(params)
  })
    .then((response) => {
      return response.json()
    })
    .then((json) => {
      if (json.message) {
        toast(json.message, 'error')
      } else {
        toast('Watchしました！')
        element.classList.remove('is-inactive', 'is-muted')
        element.classList.add('is-active', 'is-main')
        element.setAttribute('data-watch_id', json.id)
        element.innerHTML = 'Watch中'
      }
    })
    .catch((error) => {
      console.warn(error)
    })
}

export function unWatch(element) {
  const watchId = element.dataset.watch_id

  fetch(`/api/watches/${watchId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
    .then(() => {
      toast('Watchを外しました')
      if (element.innerHTML === 'Watch中') {
        element.classList.remove('is-active', 'is-main')
        element.classList.add('is-inactive', 'is-muted')
        element.removeAttribute('data-watch_id')
        element.innerHTML = 'Watch'
      }
      if (element.innerHTML === '削除') {
        const deleteWatch = document.getElementById(watchId)
        deleteWatch.remove()
      }
    })
    .catch((error) => {
      console.warn(error)
    })
}
