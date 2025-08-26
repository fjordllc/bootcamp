import { get } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  loadCheckStamp()
})

const loadCheckStamp = () => {
  const checkStamp = document.getElementById('js-check-stamp')
  if (!checkStamp) return

  const checkableType = checkStamp.getAttribute('data-checkable-type')
  const checkableId = checkStamp.getAttribute('data-checkable-id')
  get(
    `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`
  )
    .then((response) => {
      return response.json
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

export default loadCheckStamp
