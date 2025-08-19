import { toast } from './vanillaToast'

export const checkProduct = (productId, currentUserId, url, method, token) => {
  const params = {
    product_id: productId,
    current_user_id: currentUserId
  }
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
        toast(json.message, 'error')
      } else {
        if (json.checker_id !== null) {
          toast('担当になりました。')
        } else {
          toast('担当から外れました。')
        }
      }
    })
    .catch((error) => {
      console.warn(error)
    })
}
