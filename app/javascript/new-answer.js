import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { toast } from './vanillaToast.js'
import updateAnswerCount from './updateAnswerCount.js'
import initializeAnswer from './initializeAnswer.js'
import { initializeReaction } from './reaction.js'
import { setWatchable } from './setWatchable.js'

document.addEventListener('DOMContentLoaded', () => {
  const newAnswer = document.querySelector('.new-answer')
  if (newAnswer) {
    TextareaInitializer.initialize('#js-new-comment')
    const defaultTextareaSize =
      document.getElementById('js-new-comment').scrollHeight
    const markdownInitializer = new MarkdownInitializer()
    const questionId = newAnswer.dataset.question_id
    let savedAnswer = ''

    const answerEditor = newAnswer.querySelector('.answer-editor')
    const answerEditorPreview = answerEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = answerEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    const saveButton = answerEditor.querySelector('.is-primary')
    editorTextarea.addEventListener('input', () => {
      answerEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
      saveButton.disabled = editorTextarea.value.length === 0
    })

    saveButton.addEventListener('click', async () => {
      savedAnswer = editorTextarea.value
      const answerCreated = await createAnswer(savedAnswer, questionId)
      if (answerCreated) {
        editorTextarea.value = ''
        answerEditorPreview.innerHTML = markdownInitializer.render(
          editorTextarea.value
        )
        saveButton.disabled = true
        updateAnswerCount(true)
        setWatchable(questionId, 'Question')
        if (previewTab.classList.contains('is-active')) {
          toggleVisibility(tabElements, 'is-active')
        }
        resizeTextarea(editorTextarea, defaultTextareaSize)
      }
    })

    const editTab = answerEditor.querySelector('.edit-answer-tab')
    const editorTabContent = answerEditor.querySelector('.is-editor')
    const previewTab = answerEditor.querySelector('.answer-preview-tab')
    const previewTabContent = answerEditor.querySelector('.is-preview')

    const tabElements = [
      editTab,
      editorTabContent,
      previewTab,
      previewTabContent
    ]
    editTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )

    previewTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )
  }
})

async function createAnswer(description, questionId) {
  if (description.length < 1) {
    return false
  }
  const params = {
    question_id: questionId,
    answer: {
      description: description
    }
  }
  try {
    const response = await fetch('/api/answers', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })

    if (response.ok) {
      const html = await response.text()
      initializeNewAnswer(html)
      toast('回答を投稿しました！')
      return true
    } else {
      const data = await response.json()
      throw new Error(data.errors.join(', '))
    }
  } catch (error) {
    console.warn(error)
    return false
  }
}

function toggleVisibility(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}

function resizeTextarea(textarea, defaultTextareaSize) {
  textarea.style.height = `${defaultTextareaSize}px`
}

function initializeNewAnswer(html) {
  const answersList = document.querySelector('.answers-list')
  const answerDiv = document.createElement('div')
  answerDiv.innerHTML = html
  const newAnswerElement = answerDiv.firstElementChild
  answersList.appendChild(newAnswerElement)
  initializeAnswer(newAnswerElement)
  const reactionElement = newAnswerElement.querySelector('.js-reactions')
  initializeReaction(reactionElement)
}
