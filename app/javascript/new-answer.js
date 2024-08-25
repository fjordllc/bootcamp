import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { toast } from 'toast_react'
import { initializeAnswer } from './answer.js'

document.addEventListener('DOMContentLoaded', () => {
  const answer = document.querySelector('.new-answer')
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
      editorTextarea.value = ''
      answerEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      );
      saveButton.disabled = true
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
    return null;
  }
  const params = {
    question_id: questionId,
    answer: {
      description: description
    }
  };
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
    .then(response => {
      if (response.ok) {
        return response.text();
      } else {
        return response.json().then(data => {
          throw new Error(data.errors.join(', '));
        });
      }
    })
    .then(html => {
      const answersList = document.querySelector('.answers-list');
      const answerDiv = document.createElement('div');
      answerDiv.innerHTML = html;
      const newAnswerElement = answerDiv.firstElementChild
      answersList.appendChild(newAnswerElement);
      initializeAnswer(newAnswerElement)
      updateAnswerCount();
      toast('回答を投稿しました！');
    })
    .catch(error => {
      console.warn(error);
    });
}



function toggleVisibility(elements, className){
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}

function updateAnswerCount(){
  const answerCountElement = document.querySelector('.js-answer-count')
  const currentCount = parseInt(answerCountElement.textContent, 10);
  if(currentCount === 0){
    answerCountElement.classList.remove('is-zero')
  }
  const newCount = currentCount + 1

  answerCountElement.textContent = newCount
}
