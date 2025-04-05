import 'whatwg-fetch'
import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const statusMap = {
    'js-not-complete': 'unstarted',
    'js-started': 'started',
    'js-submitted': 'submitted',
    'js-complete': 'complete'
  }

  const buttons = document.querySelectorAll('.practice-status-buttons__button')
  const practice = document.querySelector('#practice')

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

    fetch(`/api/practices/${practice.dataset.id}/learning.json`, {
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

      if (clickedButton) {
        const matchingClass = Object.keys(statusMap).find((className) =>
          clickedButton.classList.contains(className)
        )
        const statusName = statusMap[matchingClass]
        pushStatus(statusName, clickedButton)
      }
    })
  })
})
