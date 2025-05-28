import CSRF from 'csrf'

export async function setWatchable(watchableId, watchableType) {
  try {
    const response = await fetch(
      `/api/watches/toggle?watchable_id=${watchableId}&watchable_type=${watchableType}`,
      {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin'
      }
    )

    if (!response.ok) {
      throw new Error(`${response.error}`)
    }

    const json = await response.json()
    const watch = document.querySelector('.watch-toggle')
    watch.classList.remove('is-inactive', 'is-muted')
    watch.classList.add('is-active', 'is-main')
    watch.setAttribute('data-watch_id', json[0].id)
    watch.innerHTML = 'Watch中'
  } catch (error) {
    console.warn(error)
  }
}
