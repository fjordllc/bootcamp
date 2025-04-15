import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
<<<<<<< HEAD
import { initializeComment, toggleVisibility } from './initializeComment.js'
=======
import initializeComment from './initializeComment.js'
>>>>>>> e10a067bf (コメントを扱うための各種ファイルを追加)
import { initializeReaction } from './reaction.js'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const newComment = document.querySelector('.new-comment')
  if (newComment) {
<<<<<<< HEAD
    const commentableId = newComment.dataset.commentable_id
    const commentableType = newComment.dataset.commentable_type

    let savedComment = ''
    TextareaInitializer.initialize('#js-new-comment')
    const markdownInitializer = new MarkdownInitializer()
=======
    TextareaInitializer.initialize('#js-new-comment')
    const markdownInitializer = new MarkdownInitializer()
    const commentableId = newComment.dataset.commentable_id
    const commentableType = newComment.dataset.commentable_type
    let savedComment = ''
>>>>>>> e10a067bf (コメントを扱うための各種ファイルを追加)

    const commentEditor = newComment.querySelector('.comment-editor')
    const commentEditorPreview = commentEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = commentEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    const editTab = commentEditor.querySelector('.edit-comment-tab')
    const editorTabContent = commentEditor.querySelector('.is-editor')
    const previewTab = commentEditor.querySelector('.comment-preview-tab')
    const previewTabContent = commentEditor.querySelector('.is-preview')
<<<<<<< HEAD
=======

>>>>>>> e10a067bf (コメントを扱うための各種ファイルを追加)
    const tabElements = [
      editTab,
      editorTabContent,
      previewTab,
      previewTabContent
    ]
<<<<<<< HEAD
    editTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )
    previewTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )
=======
>>>>>>> e10a067bf (コメントを扱うための各種ファイルを追加)

    const saveButton = commentEditor.querySelector('.is-primary')
    editorTextarea.addEventListener('input', () => {
      commentEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
      saveButton.disabled = editorTextarea.value.length === 0
    })

    saveButton.addEventListener('click', () => {
      savedComment = editorTextarea.value
      createComment(savedComment, commentableId, commentableType)
      if (previewTab.classList.contains('is-active')) {
        toggleVisibility(tabElements, 'is-active')
      }
      editorTextarea.value = ''
      commentEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
      saveButton.disabled = true
    })
<<<<<<< HEAD
=======

    editTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )

    previewTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )
>>>>>>> e10a067bf (コメントを扱うための各種ファイルを追加)
  }
})

function createComment(description, commentableId, commentableType) {
  if (description.length < 1) {
    return null
  }
  const params = {
    commentable_id: commentableId,
    commentable_type: commentableType,
    comment: {
      description: description
    }
  }
  fetch('/api/comments', {
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
    .then((response) => {
      if (response.ok) {
        return response.text()
      } else {
        return response.json().then((data) => {
          throw new Error(data.errors.join(', '))
        })
      }
    })
    .then((html) => {
      const comments = document.querySelector('.thread-comments__items')
      const commentDiv = document.createElement('div')
      commentDiv.innerHTML = html.replace('style="display: none;', '')
      const newCommentElement = commentDiv.firstElementChild
      comments.appendChild(newCommentElement)
      initializeComment(newCommentElement)
      const reactionElement = newCommentElement.querySelector('.js-reactions')
      initializeReaction(reactionElement)
      toast('コメントを投稿しました！')
    })
    .catch((error) => {
      console.warn(error)
    })
}
<<<<<<< HEAD
=======

function toggleVisibility(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}
>>>>>>> e10a067bf (コメントを扱うための各種ファイルを追加)
