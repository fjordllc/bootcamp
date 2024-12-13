import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { toast } from './vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const comment = document.querySelector('.new-comment')
  if (comment) {
    TextareaInitializer.initialize('.a-markdown-input__textarea')
    const markdownInitializer = new MarkdownInitializer()
    const commentableId = comment.dataset.commentable_id
    const commentableType = comment.dataset.commentable_type
    let savedComment = ''

    const commentEditor = comment.querySelector('.comment-editor')
    const commentEditorPreview = commentEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = commentEditor.querySelector(
      '.a-markdown-input__textarea'
    )

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
    })

    const editTab = commentEditor.querySelector('.edit-comment-tab')
    const editorTabContent = commentEditor.querySelector('.is-editor')
    const previewTab = commentEditor.querySelector('.comment-preview-tab')
    const previewTabContent = commentEditor.querySelector('.is-preview')

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

// commentableIdとCommentableTypeの取得タイミングは後ほど整理すること
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
    .then(() => {
      // コメント送信後にtextareaにdescriptionが残る現象を修正すること
      // 読み込み前にトーストが出現してしまう、リロードが遅い原因を調べること
      location.reload()
      toast('コメントを投稿しました！')
    })
    .catch((error) => {
      console.warn(error)
    })
}

function toggleVisibility(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}
