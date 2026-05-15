document.addEventListener('DOMContentLoaded', () => {
  const statusMap = {
    trialing: 'is-primary',
    active: 'is-success',
    canceled: 'is-danger',
    past_due: 'is-warning'
  }
  const statusLabel = {
    trialing: 'お試し中',
    active: '有効',
    canceled: 'キャンセル',
    past_due: '期日経過'
  }
  const selector = '.subscription-status'
  const statuses = document.querySelectorAll(selector)
  if (statuses.length > 0) {
    let subs = []

    fetch('/api/subscriptions.json', {
      method: 'GET',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        subs = json.subscriptions

        statuses.forEach((status) => {
          const subId = status.getAttribute('data-subscription-id')
          subs.forEach((sub) => {
            if (sub.id === subId) {
              const level = statusMap[sub.status]
              const label = statusLabel[sub.status]
              status.classList.add('a-button')
              status.classList.add('is-sm')
              status.classList.add(level)
              status.innerHTML = label
            }
          })
        })
      })
      .catch((error) => {
        console.warn(error)
      })
  }
})
