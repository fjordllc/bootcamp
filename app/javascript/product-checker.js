import CSRF from 'csrf'
import { toast } from 'vanillaToast'

function checkInCharge(event, productId, currentUserId) {
  event.preventDefault()
  const token = CSRF.getToken()
  const url = '/api/products/checker'

  const params = {
    product_id: productId,
    current_user_id: currentUserId
  }

  const query = new URLSearchParams(params)
  fetch(url + `?${query}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
    .then((response) => {
      return response.json()
    })
    .then((json) => {
      return json.checker_id ? 'DELETE' : 'PATCH'
    })
    .then((method) => {
      fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
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
            alert(json.message)
          } else {
            const id = json.checker_id
            if (id !== null) {
              toast('担当になりました。')
            } else {
              toast('担当から外れました。')
            }
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    })

  if (
    event.currentTarget.className === 'product-checker a-button is-block is-sm'
  ) {
    event.currentTarget.className =
      'product-checker a-button is-block is-warning is-sm'
    event.currentTarget.children[0].className = 'fas fa-times'
    event.currentTarget.children[0].textContent = '担当から外れる'
  } else {
    event.currentTarget.className = 'product-checker a-button is-block is-sm'
    event.currentTarget.children[0].className = 'fas fa-hand-paper'
    event.currentTarget.children[0].textContent = '担当する'
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.product-checker')
  buttons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const productId = event.currentTarget.dataset.productId
      const currentUserId = event.currentTarget.dataset.currentUserId
      checkInCharge(event, productId, currentUserId)
    })
  })
})
