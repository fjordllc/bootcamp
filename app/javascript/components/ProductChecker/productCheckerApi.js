import CSRF from '../../csrf'

export const productCheckerClient = (productId, currentUserId) => {
  const params = {
    product_id: productId,
    current_user_id: currentUserId
  }

  const createProductChecker = async () => {
    return fetch('/api/products/checker', {
      method: 'PATCH', // POSTの方がAPIの意味的には正しそう
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
  }

  const deleteProductChecker = async () => {
    return fetch('/api/products/checker', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
  }

  return { createProductChecker, deleteProductChecker }
}
