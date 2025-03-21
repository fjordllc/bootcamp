import CSRF from 'csrf'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const hiddenData = document.getElementById('data-for-watch')
  const watchToggle = document.getElementById('watch-button')

  if (!hiddenData) {
    return
  }

  const watchableType = hiddenData.dataset.watchable_type
  const watchableId = hiddenData.dataset.watchable_id
  const watchId = hiddenData.dataset.watch_id

  watchToggle.addEventListener('click', () => {
    if (watchToggle.classList.contains('is-inactive')) {
      watch(watchableType, watchableId)
    }
    if (watchToggle.classList.contains('is-active')) {
      unWatch(watchId)
    }
  })

  function watch(watchableType, watchableId) {
    const params = {
      watchable_type: watchableType,
      watchable_id: watchableId
    }
    fetch(`/api/watches/toggle`, {
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
          watchToggle.classList.remove('is-inactive', 'is-muted')
          watchToggle.classList.add('is-active', 'is-main')
          watchToggle.innerHTML = 'watch中'
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  function unWatch(watchId) {
    fetch(`/api/watches/toggle/${watchId}`, {
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
        watchToggle.classList.remove('is-active', 'is-main')
        watchToggle.classList.add('is-inactive', 'is-muted')
        watchToggle.innerHTML = 'watch'
      })
      .catch((error) => {
        console.warn(error)
      })
  }
})
