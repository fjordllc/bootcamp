import CSRF from 'csrf'

export function setWatchable(watchableId, watchableType) {
  fetch(
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
    .then((response) => {
      return response.json()
    })
    .then((data) => {
      const watch = document.getElementById('watch-button')
      watch.classList.remove('is-inactive', 'is-muted')
      watch.classList.add('is-active', 'is-main')
      watch.setAttribute('data-watch_id', data[0].id)
      watch.innerHTML = 'Watch中'
    })
}
