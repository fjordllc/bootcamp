import 'whatwg-fetch'
import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.practice-status-buttons__button')
  const practiceId = document.querySelector('#practice').dataset.id

  const updateButtonsStates = (buttons, clickedButton) => {
    buttons.forEach((button) => {
      const isClicked = button === clickedButton
      button.classList.toggle('is-active', isClicked)
      button.classList.toggle('is-inactive', !isClicked)
      button.disabled = isClicked
    })
  }

  const pushStatus = (statusName, clickedButton) => {
    const params = new FormData()
    params.append('status', statusName)

    fetch(`/api/practices/${practiceId}/learning.json`, {
      method: 'PATCH',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: params
    })
      .then((response) => {
        if (response.ok) {
          updateButtonsStates(buttons, clickedButton)
        } else {
          response.json().then((data) => {
            alert(data.error)
          })
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  buttons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const clickedButton = event.target
      const statusName = clickedButton.dataset.status
      pushStatus(statusName, clickedButton)
    })
  })
})
