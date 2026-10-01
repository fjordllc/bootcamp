import CSRF from 'csrf'
import MarkdownInitializer from 'markdown-initializer'

function initializeComment(comment) {
  const commentId = comment.dataset.comment_id

  const commentEditor = comment.querySelector('.js-comment-editor')
  if (!commentEditor) return

  const commentEditorPreview = commentEditor.querySelector(
    '.a-markdown-input__preview'
  )
  const editorTextarea = commentEditor.querySelector(
    '.a-markdown-input__textarea'
  )
  if (!commentEditorPreview || !editorTextarea) return

  let savedComment = ''
  const markdownInitializer = new MarkdownInitializer()

  const commentDisplay = comment.querySelector('.js-comment-display')
  const commentDisplayContent =
    commentDisplay?.querySelector('.js-comment-html')
  const modalElements = [commentDisplay, commentEditor]
  const saveButton = commentEditor.querySelector('.js-comment-save-button')
  if (saveButton) {
    saveButton.addEventListener('click', () => {
      toggleVisibility(modalElements, 'is-hidden')
      savedComment = editorTextarea.value
      updateComment(commentId, savedComment)
      commentDisplayContent.innerHTML = markdownInitializer.render(savedComment)
    })
  }
}

function toggleVisibility(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}

function updateComment(commentId, description) {
  if (description.length < 1) {
    return null
  }
  const params = {
    id: commentId,
    comment: { description }
  }
  fetch(`/api/comments/${commentId}`, {
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

export { initializeComment, toggleVisibility }
