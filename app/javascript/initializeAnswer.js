import CSRF from 'csrf'
import updateAnswerCount from './updateAnswerCount'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'

export default function initializeAnswer(answer) {
  const questionId = answer.dataset.question_id
  const answerId = answer.dataset.answer_id
  const answerDescription = answer.dataset.answer_description
  let savedAnswer = ''
  TextareaInitializer.initialize(`#js-comment-${answerId}`)
  const markdownInitializer = new MarkdownInitializer()

  const answerDisplay = answer.querySelector('.answer-display')
  const answerEditor = answer.querySelector('.answer-editor')
  const answerDisplayContent = answerDisplay.querySelector('.answer-text')

  const answerEditorPreview = answerEditor.querySelector('.markdown-preview')
  const editorTextarea = answerEditor.querySelector('.markdown-textarea')

  if (answerDescription) {
    answerDisplayContent.innerHTML =
      markdownInitializer.render(answerDescription)
    answerEditorPreview.innerHTML =
      markdownInitializer.render(answerDescription)
  }

  const editButton = answerDisplay.querySelector('.edit-button')
  const modalElements = [answerDisplay, answerEditor]
  if (editButton) {
    editButton.addEventListener('click', () => {
      if (!savedAnswer) {
        savedAnswer = editorTextarea.value
      }
      toggleVisibility(modalElements, 'is-hidden')
    })
  }

  const saveButton = answerEditor.querySelector('.save-button')
  if (saveButton) {
    saveButton.addEventListener('click', () => {
      toggleVisibility(modalElements, 'is-hidden')
      savedAnswer = editorTextarea.value
      updateAnswer(answerId, savedAnswer)
      answerDisplayContent.innerHTML = markdownInitializer.render(savedAnswer)
    })
  }

  const cancelButton = answerEditor.querySelector('.cancel-button')
  cancelButton.addEventListener('click', () => {
    toggleVisibility(modalElements, 'is-hidden')
    editorTextarea.value = savedAnswer
    answerEditorPreview.innerHTML = markdownInitializer.render(savedAnswer)
  })

  editorTextarea.addEventListener('input', () => {
    answerEditorPreview.innerHTML = markdownInitializer.render(
      editorTextarea.value
    )
  })

  const makeBestAnswerButton = answerDisplay.querySelector('.make-best-answer')
  const cancelBestAnswerButton = answerDisplay.querySelector(
    '.cancel-best-answer'
  )
  const answerBadgeElement = answerDisplay.querySelector('.best-answer-badge')
  if (makeBestAnswerButton) {
    makeBestAnswerButton.addEventListener('click', () => {
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
    })
  }
  if (cancelBestAnswerButton) {
    cancelBestAnswerButton.addEventListener('click', () => {
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
    })
  }

  const deleteButton = answerDisplay.querySelector('.delete-button')
  if (deleteButton) {
    deleteButton.addEventListener('click', () => {
      if (window.confirm('本当に宜しいですか？')) {
        deleteAnswer(answerId)
        if (answerBadgeElement.classList.contains('correct-answer')) {
          cancelBestAnswer(answerId, questionId)
          const otherCancelBestAnswerButtons = document.querySelectorAll(
            '.make-best-answer-button'
          )
          otherCancelBestAnswerButtons.forEach((button) => {
            if (button.closest('.answer').dataset.answer_id !== answerId) {
              button.classList.remove('is-hidden')
            }
          })
        }
      }
    })
  }

  const editTab = answerEditor.querySelector('.edit-answer-tab')
  const editorTabContent = answerEditor.querySelector('.is-editor')
  const previewTab = answerEditor.querySelector('.answer-preview-tab')
  const previewTabContent = answerEditor.querySelector('.preview-content')

  const tabElements = [editTab, editorTabContent, previewTab, previewTabContent]
  editTab.addEventListener('click', () =>
    toggleVisibility(tabElements, 'is-active')
  )

  previewTab.addEventListener('click', () =>
    toggleVisibility(tabElements, 'is-active')
  )

  const createdAtElement = answer.querySelector('.created-at')
  if (createdAtElement && navigator.clipboard) {
    createdAtElement.addEventListener('click', () => {
      const answerURL = location.href.split('#')[0] + '#answer_' + answerId
      navigator.clipboard
        .writeText(answerURL)
        .then(() => {
          createdAtElement.classList.add('is-active')
          setTimeout(() => {
            createdAtElement.classList.remove('is-active')
          }, 4000)
        })
        .catch((error) => {
          console.error(error)
        })
    })
  }

  function toggleVisibility(elements, className) {
    elements.forEach((element) => {
      element.classList.toggle(className)
    })
  }

  function updateAnswer(answerId, description) {
    if (description.length < 1) {
      return null
    }
    const params = {
      id: answerId,
      answer: { description: description }
    }
    fetch(`/api/answers/${answerId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    }).catch((error) => {
      console.warn(error)
    })
  }

  function deleteAnswer(answerId) {
    fetch(`/api/answers/${answerId}.json`, {
      method: 'DELETE',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then(() => {
        const deletedAnswer = document.querySelector(
          `.thread-comment.answer[data-answer_id='${answerId}']`
        )

        if (deletedAnswer) {
          deletedAnswer.parentNode.removeChild(deletedAnswer)
        }

        updateAnswerCount(false)
      })
      .catch((error) => {
        console.warn(error)
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
