import { toast } from '../toast_react'

export const check = ({
  checkableType,
  checkableId,
  url,
  method,
  token,
  checkId,
  updateState
}) => {
  const params = {
    checkable_type: checkableType,
    checkable_id: checkableId
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
      if (!response.ok) {
        return response.json()
      } else {
        return response
      }
    })
    .then((json) => {
      if (json.message) {
        toast(json.message, 'error')
      } else {
        if (!checkId) {
          if (checkableType === 'Product') {
            toast('提出物を確認済みにしました。')
          } else if (checkableType === 'Report') {
            toast('日報を確認済みにしました。')
          }
        }
        updateState({
          checkableType: checkableType,
          checkableId: checkableId
        })
      }
    })
    .catch((error) => {
      console.warn(error)
    })
}

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
        alert(json.message)
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
