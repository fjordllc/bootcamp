import store from 'check-store.js'
import CSRF from 'csrf'
import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  setCheckStamp()
})

export const setCheckStamp = () => {
  const checkStamp = document.getElementById('js-check-stamp')
  if (!checkStamp) return

  const checkableType = checkStamp.getAttribute('data-checkable-type')
  const checkableId = checkStamp.getAttribute('data-checkable-id')
  store.dispatch('setCheckable', {
    checkableId: checkableId,
    checkableType: checkableType
  })
  fetch(
    `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`,
    {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin'
    }
  )
    .then((response) => {
      return response.json()
    })
    .then((json) => {
      const notChecked = !json[0]
      const checkStampElement = document.querySelector('.stamp-approve')

      checkStampElement.classList.toggle('is-hidden', notChecked)
      if (notChecked) return

      const checkedUserName = document.querySelector('.stamp__content-inner')
      const checkedCreatedAt = document.querySelector('.is-created-at')
      checkedUserName.textContent = json[0].user.login_name
      checkedCreatedAt.textContent = json[0].created_at
    })
    .catch((error) => {
      console.warn(error)
    })
}
