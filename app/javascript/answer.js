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

  if (loadingContent && answerContent) {
    loadingContent.style.display = 'none'
    answerContent.style.display = 'block'
  }

  if (answers.length > 0) {
    answers.forEach((answer) => {
      initializeAnswer(answer)
    })
  }
})
