import initializeAnswer from './initializeAnswer'

document.addEventListener('DOMContentLoaded', () => {
  const answerAnchor = location.hash
  if (answerAnchor) {
    setTimeout(() => {
      const anchorElement = document.querySelector(answerAnchor)
      if (anchorElement) {
        anchorElement.scrollIntoView({ behavior: 'instant' })
      }
    }, 300)
  }

  const answers = document.querySelectorAll('.answer')
  const loadingContent = document.querySelector('.loading-content')
  const answerContent = document.querySelector('.answer-content')
  if (answers) {
    loadingContent.style.display = 'none'
    answerContent.style.display = 'block'

    answers.forEach((answer) => {
      initializeAnswer(answer)
    })
  }
})
