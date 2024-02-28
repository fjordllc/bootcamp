import CSRF from '../../csrf'

const createReaction = async (reactionableId, kind) => {
  const params = {
    reactionable_id: reactionableId,
    kind: kind,
  }

  const response = await fetch(`/api/reactions`, {
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

  const commentId = await response.json()
  return commentId
}

const deleteReaction = (id) => {
  fetch(`/api/reactions/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
}

export { createReaction, deleteReaction }
