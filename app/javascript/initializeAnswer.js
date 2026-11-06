import CSRF from 'csrf'
import MarkdownInitializer from 'markdown-initializer'

export default function initializeAnswer(answer) {
  const events = new AbortController()
  const copyTimeouts = new Set()
  const listen = (element, event, callback) => {
    element.addEventListener(event, callback, { signal: events.signal })
  }
  const questionId = answer.dataset.question_id
  const answerId = answer.dataset.answer_id
  const answerDescription = answer.dataset.answer_description
  const answerDisplay = answer.querySelector('.answer-display')
  const answerDisplayContent = answerDisplay.querySelector('.answer-text')
  if (answerDescription) {
    answerDisplayContent.innerHTML = new MarkdownInitializer().render(
      answerDescription
    )
  }

  listen(answerDisplay, 'click', (event) => {
    const makeBestAnswerButton =
      answerDisplay.querySelector('.make-best-answer')
    const cancelBestAnswerButton = answerDisplay.querySelector(
      '.cancel-best-answer'
    )
    const answerBadgeElement = answerDisplay.querySelector('.best-answer-badge')
    if (event.target.closest('.make-best-answer')) {
      if (window.confirm('本当に宜しいですか？')) {
        makeToBestAnswer(answerId, questionId)
        answerBadgeElement.classList.remove('is-hidden')
        answerBadgeElement.classList.add('correct-answer')
        const parentElements = [
          makeBestAnswerButton.parentNode,
          cancelBestAnswerButton.parentNode
        ]
        toggleVisibility(parentElements, 'is-hidden')
        const otherMakeBestAnswerButtons = document.querySelectorAll(
          '.make-best-answer-button'
        )
        otherMakeBestAnswerButtons.forEach((button) => {
          if (button.closest('.answer').dataset.answer_id !== answerId) {
            button.classList.add('is-hidden')
          }
        })
      }
    }
    if (event.target.closest('.cancel-best-answer')) {
      if (window.confirm('本当に宜しいですか？')) {
        cancelBestAnswer(answerId, questionId)
        answerBadgeElement.classList.remove('correct-answer')
        answerBadgeElement.classList.add('is-hidden')
        const parentElements = [
          makeBestAnswerButton.parentNode,
          cancelBestAnswerButton.parentNode
        ]
        toggleVisibility(parentElements, 'is-hidden')
        const otherMakeBestAnswerButtons = document.querySelectorAll(
          '.make-best-answer-button'
        )
        otherMakeBestAnswerButtons.forEach((button) => {
          if (button.closest('.answer').dataset.answer_id !== answerId) {
            button.classList.remove('is-hidden')
          }
        })
      }
    }
  })

  const createdAtElement = answer.querySelector('.created-at')
  if (createdAtElement && navigator.clipboard) {
    listen(createdAtElement, 'click', () => {
      const answerURL = answer.dataset.answerUrl
      navigator.clipboard
        .writeText(answerURL)
        .then(() => {
          if (events.signal.aborted) return
          createdAtElement.classList.add('is-active')
          const copyTimeout = setTimeout(() => {
            createdAtElement.classList.remove('is-active')
            copyTimeouts.delete(copyTimeout)
          }, 4000)
          copyTimeouts.add(copyTimeout)
        })
        .catch((error) => {
          console.error(error)
        })
    })
  }

  return () => {
    events.abort()
    copyTimeouts.forEach((timeout) => clearTimeout(timeout))
    copyTimeouts.clear()
  }

  function toggleVisibility(elements, className) {
    elements.forEach((element) => {
      element.classList.toggle(className)
    })
  }

  function makeToBestAnswer(answerId, questionId) {
    requestSolveQuestion(answerId, questionId, false)
      .then(() => {
        solveQuestion()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  function cancelBestAnswer(answerId, questionId) {
    requestSolveQuestion(answerId, questionId, true)
      .then(() => {
        cancelSolveQuestion()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  function requestSolveQuestion(answerId, questionId, isCancel) {
    const params = {
      question_id: questionId
    }

    return fetch(`/api/answers/${answerId}/correct_answer`, {
      method: isCancel ? 'PATCH' : 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
  }

  function solveQuestion() {
    const statusLabel = document.querySelector('.js-solved-status')
    statusLabel.classList.remove('is-danger')
    statusLabel.classList.add('is-success')
    statusLabel.textContent = '解決済'
  }

  function cancelSolveQuestion() {
    const statusLabel = document.querySelector('.js-solved-status')
    statusLabel.classList.remove('is-success')
    statusLabel.classList.add('is-danger')
    statusLabel.textContent = '未解決'
  }
}
