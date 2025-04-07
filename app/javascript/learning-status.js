import 'whatwg-fetch'
import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.practice-status-buttons__button')
  const practiceId = document.querySelector('#practice').dataset.id

  const updateButtonsStates = (clickedButton) => {
    buttons.forEach((button) => {
      const isClicked = button === clickedButton
      button.classList.toggle('is-active', isClicked)
      button.classList.toggle('is-inactive', !isClicked)
      button.disabled = isClicked
    })
  }

  const updatePracticesStatus = async (statusName) => {
    const params = new FormData()
    params.append('status', statusName)

    const response = await fetch(`/api/practices/${practiceId}/learning.json`, {
      method: 'PATCH',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: params
    })

    if (!response.ok) {
      const data = await response.json()
      throw new Error(data.error)
    }
  }

  const pushStatus = async (statusName, clickedButton) => {
    try {
      await updatePracticesStatus(statusName)
      updateButtonsStates(clickedButton)
    } catch (error) {
      console.error(error)
      alert(error.message)
    }
  }

  buttons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const clickedButton = event.target
      const statusName = clickedButton.dataset.status
      pushStatus(statusName, clickedButton)
    })
  })
})
