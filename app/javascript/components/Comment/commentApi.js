import CSRF from '../../csrf'

const createComment = async (description, commentableType, commentableId) => {
  if (description.length < 1) {
    return null
  }

  const params = {
    comment: { description: description },
    commentable_type: commentableType,
    commentable_id: commentableId
  }

  const response = await fetch(`/api/comments`, {
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
  return response.json()
}

const deleteComment = async (id) => {
  const response = await fetch(`/api/comments/${id}.json`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
  return response
}

const updateComment = async (id, description) => {
  const params = {
    comment: { description: description }
  }

  const response = await fetch(`/api/comments/${id}.json`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual',
    body: JSON.stringify(params)
  })
  return response
}

export { createComment, updateComment, deleteComment }
