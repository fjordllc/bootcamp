document.addEventListener('DOMContentLoaded', function () {
  const buttons = document.querySelectorAll('.a-button')

  buttons.forEach((button) => {
    button.addEventListener('click', function () {
      const isActionCompleted = button.classList.contains('is-muted-borderd')
      const commentableId = button.dataset.commentableId
      const csrfToken = button.dataset.csrfToken

      if (!commentableId || !csrfToken) {
        console.error('必要なデータがありません')
        return
      }

      fetch(`/api/talks/${commentableId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({
          talk: { action_completed: !isActionCompleted }
        })
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error('Network response was not ok')
          }
          return response.json().catch(() => null)
        })
        .then((data) => {
          if (data) {
            console.log('API Response:', data)
          }
          const newButtonText = isActionCompleted
            ? '対応済にする'
            : '対応済です'
          const iconClass = isActionCompleted ? 'fa-redo' : 'fa-check'

          button.innerHTML = `<i class="fas ${iconClass}"></i> ${newButtonText}`
          button.classList.toggle('is-warning', isActionCompleted)
          button.classList.toggle('is-muted-borderd', !isActionCompleted)
        })
        .catch((error) => {
          console.error('エラーが発生しました:', error)
          alert('エラーが発生しました。再読み込みしてください。')
        })
    })
  })
})
