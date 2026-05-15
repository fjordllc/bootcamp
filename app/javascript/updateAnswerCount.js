export default function updateAnswerCount(isCreated) {
  const answerCountElement = document.querySelector('.js-answer-count')
  const currentCount = parseInt(answerCountElement.textContent, 10)
  const newCount = currentCount + (isCreated ? 1 : -1)

  answerCountElement.textContent = newCount
  if (currentCount === 0) {
    answerCountElement.classList.remove('is-zero')
  } else if (newCount === 0) {
    answerCountElement.classList.add('is-zero')
  }
}
