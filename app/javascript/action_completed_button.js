import CSRF from 'csrf'
import { toast } from './vanillaToast'

document.addEventListener('DOMContentLoaded', function () {
  const buttons = document.querySelectorAll('.check-button')

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
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
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
          const newMessage = isActionCompleted
            ? '返信が完了し次は相談者からのアクションの待ちの状態になったとき、もしくは、相談者とのやりとりが一通り完了した際は、このボタンをクリックして対応済のステータスに変更してください。'
            : 'お疲れ様でした！相談者から次のアクションがあった際は、自動で未対応のステータスに変更されます。再度このボタンをクリックすると、未対応にステータスに戻ります。'

          button.innerHTML = `<i class="fas ${iconClass}"></i> ${newButtonText}`
          button.classList.toggle('is-warning', isActionCompleted)
          button.classList.toggle('is-muted-borderd', !isActionCompleted)

          const description = button
            .closest('.thread-comment-form')
            .querySelector('.action-completed__description p')
          if (description) {
            description.innerHTML = newMessage
          }

          const tostMessage = isActionCompleted
            ? '未対応にしました'
            : '対応済みにしました'
          toast(tostMessage, 'success')
        })
        .catch((error) => {
          console.error('エラーが発生しました:', error)
          alert('エラーが発生しました。再読み込みしてください。')
        })
    })
  })
})
