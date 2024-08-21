import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { toast } from 'toast_react'

document.addEventListener('DOMContentLoaded', () => {
  const answer = document.querySelector('.answer')
  if(answer) {
    TextareaInitializer.initialize('.a-markdown-input__textarea')
    const markdownInitializer = new MarkdownInitializer()
    const questionId = answer.dataset.question_id
    let savedAnswer = ''

    const answerEditor = answer.querySelector('.answer-editor')
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
      );
      saveButton.disabled = editorTextarea.value.length === 0
    });

    saveButton.addEventListener('click', () => {
      savedAnswer = editorTextarea.value
      createAnswer(savedAnswer, questionId)
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

function createAnswer(description, questionId) {
  if (description.length < 1) {
    return null
  }
  const params = {
    question_id: questionId,
    answer: {
      description: description
    }
  }
  fetch('/api/answers', {
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
    .then(() => {
      toast('回答を投稿しました！')
      location.reload()
      })
      .catch((error) => {
        console.warn(error)
      })
}

function toggleVisibility(elements, className){
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}
