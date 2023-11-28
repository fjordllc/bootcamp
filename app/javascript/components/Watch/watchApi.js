import CSRF from '../../csrf'

const createWatch = async (watchableType, watchableId) => {
  const params = {
    watchable_type: watchableType,
    watchable_id: watchableId,
  };

  const response = await fetch(`/api/watches/toggle`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken(),
    },
    credentials: 'same-origin',
    redirect: 'manual',
    body: JSON.stringify(params),
  })
  return response.json()
}

const deleteWatch = async (watchId) => {
  await fetch(`/api/watches/toggle/${watchId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken(),
    },
    credentials: 'same-origin',
    redirect: 'manual',
  })
}

export { createWatch, deleteWatch }
