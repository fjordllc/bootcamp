import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'

export default function setComment(comment) {
  const commentId = comment.dataset.comment_id
  let savedComment = ''
  TextareaInitializer.initialize(`#js-comment-${commentId}`)
  const markdownInitializer = new MarkdownInitializer()

  const commentDisplay = comment.querySelector('.comment-display')
  const commentEditor = comment.querySelector('.comment-editor')
  const commentDisplayContent = commentDisplay.querySelector('.a-long-text')
  const commentDescription = commentDisplayContent.innerHTML
  if (commentDescription) {
    commentDisplayContent.innerHTML =
      markdownInitializer.render(commentDescription)
  }

  const editButton = commentDisplay.querySelector('.card-main-actions__action')
  const modalElements = [commentDisplay, commentEditor]
  if (editButton) {
    editButton.addEventListener('click', () => {
      if (!savedComment) {
        savedComment = editorTextarea.value
      }
      toggleVisibility(modalElements, 'is-hidden')
    })
  }

  const saveButton = commentEditor.querySelector('.is-primary')
  if (saveButton) {
    saveButton.addEventListener('click', () => {
      toggleVisibility(modalElements, 'is-hidden')
      savedComment = editorTextarea.value
      updateComment(commentId, savedComment)
      commentDisplayContent.innerHTML = markdownInitializer.render(savedComment)
    })
  }

  const commentEditorPreview = commentEditor.querySelector(
    '.a-markdown-input__preview'
  )
  const editorTextarea = commentEditor.querySelector(
    '.a-markdown-input__textarea'
  )

  const cancelButton = commentEditor.querySelector('.is-secondary')
  cancelButton.addEventListener('click', () => {
    toggleVisibility(modalElements, 'is-hidden')
    editorTextarea.value = savedComment
    commentEditorPreview.innerHTML = markdownInitializer.render(savedComment)
  })

  editorTextarea.addEventListener('input', () => {
    commentEditorPreview.innerHTML = markdownInitializer.render(
      editorTextarea.value
    )
  })

  const deleteButton = comment.querySelector('.card-main-actions__muted-action')
  if (deleteButton) {
    deleteButton.addEventListener('click', () => {
      if (window.confirm('本当に宜しいですか？')) {
        deleteComment(commentId)
      }
    })
  }

  function deleteComment(commentId) {
    fetch(`/api/comments/${commentId}.json`, {
      method: 'DELETE',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then(() => {
        const deletedComment = document.querySelector(
          `.thread-comment.comment[data-comment_id='${commentId}']`
        )
        if (deletedComment) {
          deletedComment.remove()
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  const editTab = commentEditor.querySelector('.edit-comment-tab')
  const editorTabContent = commentEditor.querySelector('.is-editor')
  const previewTab = commentEditor.querySelector('.comment-preview-tab')
  const previewTabContent = commentEditor.querySelector('.is-preview')

  const tabElements = [editTab, editorTabContent, previewTab, previewTabContent]
  editTab.addEventListener('click', () =>
    toggleVisibility(tabElements, 'is-active')
  )

  previewTab.addEventListener('click', () =>
    toggleVisibility(tabElements, 'is-active')
  )

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
      comment: { description: description }
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
}
