import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const completeButton = document.getElementById('js-complete')
  if (completeButton) {
    completeButton.addEventListener('click', function () {
      const practiceId = completeButton.getAttribute('data-practice-id')
      const params = new FormData()
      params.append('status', 'complete')

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
            completeButton.classList.add('is-disabled')
            completeButton.textContent = '修了しています'
            document.getElementById('modal-learning_completion').checked = true // 修了モーダル表示のためのフラグを立てる
          } else {
            response.json().then((data) => {
              alert(data.error)
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    })
  }
})
