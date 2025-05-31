import CSRF from 'csrf'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const watchToggle = document.querySelector('.watch-toggle')
  if (!watchToggle) {
    return
  }

  watchToggle.addEventListener('click', () => {
    if (watchToggle.classList.contains('is-inactive')) {
      watch(watchToggle)
    } else if (watchToggle.classList.contains('is-active')) {
      unWatch(watchToggle)
    }
  })
})

async function watch(element) {
  const watchableType = element.dataset.watchable_type
  const watchableId = element.dataset.watchable_id
  const params = {
    watchable_type: watchableType,
    watchable_id: watchableId
  }

  try {
    const response = await fetch(`/api/watches`, {
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

    if (!response.ok) {
      throw new Error(`${response.error}`)
    }

    const json = await response.json()
    if (json.message) {
      toast(json.message, 'error')
    } else {
      toast('Watchしました！')
      element.classList.remove('is-inactive', 'is-muted')
      element.classList.add('is-active', 'is-main')
      element.setAttribute('data-watch_id', json.id)
      element.innerHTML = 'Watch中'
    }
  } catch (error) {
    console.warn(error)
  }
}

async function unWatch(element) {
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
    element.classList.remove('is-active', 'is-main')
    element.classList.add('is-inactive', 'is-muted')
    element.removeAttribute('data-watch_id')
    element.innerHTML = 'Watch'
    toast('Watchを外しました')
  } catch (error) {
    console.warn(error)
  }
}
