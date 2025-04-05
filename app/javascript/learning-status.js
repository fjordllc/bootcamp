import 'whatwg-fetch'
import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.practice-status-buttons__button')
  const practice = document.querySelector('#practice')

  const updateButtonsStates = (buttons, clickedButton) => {
    buttons.forEach((button) => {
      button.classList.toggle('is-active', button === clickedButton);
      button.classList.toggle('is-inactive', button !== clickedButton);
    });
  };

  const pushStatus = (name, clickedButton) => {
    const params = new FormData()
    params.append('status', name)

    fetch(`/api/practices/${practice.dataset.id}/learning.json`, {
      method: 'PATCH',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: params
    }).then((response) => {
      if (response.ok) {
        updateButtonsStates(buttons, clickedButton)
      } else {
        response.json().then((data) => {
          alert(data.error)
        })
      }
    })
  }

  buttons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const clickedButton = event.target

      if (clickedButton.classList.contains('js-not-complete')) {
        pushStatus('unstarted', clickedButton)
      } else if (clickedButton.classList.contains('js-started')) {
        pushStatus('started', clickedButton)
      } else if (clickedButton.classList.contains('js-submitted')) {
        pushStatus('submitted', clickedButton)
      } else if (clickedButton.classList.contains('js-complete')) {
        pushStatus('complete', clickedButton)
      }
    })
  })
})
