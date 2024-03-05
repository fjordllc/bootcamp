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
  if (!response.ok) {
    throw new Error(`${response.status} ${response.statusText}`);
  }
  const commentId = await response.json()
  return commentId
}

const deleteReaction = async(id) => {
  const response = await fetch(`/api/reactions/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
  if (!response.ok) {
    throw new Error(`${response.status} ${response.statusText}`);
  }
}

export { createReaction, deleteReaction }
