import CSRF from 'csrf'

const createCheck = async (checkableId, checkableType) => {
  const params = {
    checkable_id: checkableId,
    checkable_type: checkableType,
  }
  const res = await fetch('/api/checks', {
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
  if (!res.ok) {
    throw new Error('確認でエラーが起こりました')
  }
  return res
}

const deleteCheck = async (checkId, checkableId, checkableType) => {
  const params = {
    checkable_id: checkableId,
    checkable_type: checkableType,
  }
  const res = await fetch(`/api/checks/${checkId}`, {
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
  if (!res.ok) {
    throw new Error('確認の取り消しでエラーが起こりました')
  }
  return res
}

export { createCheck, deleteCheck }
