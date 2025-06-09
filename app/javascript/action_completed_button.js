import CSRF from 'csrf'
import { toast } from './vanillaToast'

document.addEventListener('DOMContentLoaded', function () {
  const button = document.querySelector('.check-button')
  if (!button) {
    return
  }
  const commentableId = button.dataset.commentableId
  button.addEventListener('click', function () {
    const isInitialActionCompleted =
      button.classList.contains('is-muted-borderd')
    const isActionCompleted = !isInitialActionCompleted

    fetch(`/api/talks/${commentableId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      body: JSON.stringify({
        talk: { action_completed: isActionCompleted }
      })
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
      })
      .then(() => {
        const newButtonText = isActionCompleted ? '対応済です' : '対応済にする'
        const iconClass = isActionCompleted ? 'fa-check' : 'fa-redo'
        const newMessage = isActionCompleted
          ? 'お疲れ様でした！相談者から次のアクションがあった際は、自動で未対応のステータスに変更されます。再度このボタンをクリックすると、未対応にステータスに戻ります。'
          : '返信が完了し次は相談者からのアクションの待ちの状態になったとき、もしくは、相談者とのやりとりが一通り完了した際は、このボタンをクリックして対応済のステータスに変更してください。'
        button.innerHTML = `<i class="fas ${iconClass}"></i> ${newButtonText}`
        button.classList.toggle('is-warning', !isActionCompleted)
        button.classList.toggle('is-muted-borderd', isActionCompleted)

        const description = button
          .closest('.thread-comment-form')
          .querySelector('.action-completed__description p')
        if (description) {
          description.innerHTML = newMessage
        }

        const tostMessage = isActionCompleted
          ? '対応済みにしました'
          : '未対応にしました'
        toast(tostMessage, 'success')
      })
      .catch((error) => {
        console.warn(error)
      })
  })
})
