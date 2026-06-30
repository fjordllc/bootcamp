import initializeMemo from './initializeMentorMemo'
import initializeNewMemo from './initializeNewMentorMemo'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.mentor-memos')
  if (!mentorMemo) return

  const userId = mentorMemo.dataset.user_id

  const memos = mentorMemo.querySelectorAll('.mentor-memo')
  const emptyMessage = mentorMemo.querySelector('.o-empty-message')
  if (memos.length) {
    memos.forEach((memo) => {
      initializeMemo(memo, userId)
    })
  } else {
    emptyMessage.classList.remove('is-hidden')
  }

  initializeNewMemo(userId)
})
