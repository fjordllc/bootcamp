import CSRF from '../../csrf'

const createResponsibleMentor = async ({ productId, currentUserId }) => {
  const params = {
    product_id: productId,
    current_user_id: currentUserId
  }

  const response = await fetch('/api/products/checker', {
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
  return response.json()
}

const deleteResponsibleMentor = async ({ productId }) => {
  const params = {
    product_id: productId
  }

  const response = await fetch('/api/products/checker', {
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
  return response.json()
}

export { createResponsibleMentor, deleteResponsibleMentor }
