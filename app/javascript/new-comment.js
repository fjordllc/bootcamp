import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { initializeComment, toggleVisibility } from './initializeComment.js'
import { initializeReaction } from './reaction.js'
import { toast } from './vanillaToast.js'
import commentCheckable from './comment-checkable.js'

document.addEventListener('DOMContentLoaded', () => {
  const newComment = document.querySelector('.new-comment')
  if (newComment) {
    const commentableId = newComment.dataset.commentable_id
    const commentableType = newComment.dataset.commentable_type
    const currentUserId = newComment.dataset.current_user_id
    const isMentor = newComment.dataset.is_mentor === 'true'
    let savedComment = ''
    TextareaInitializer.initialize('#js-new-comment')
    const markdownInitializer = new MarkdownInitializer()

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

    const saveButton = commentEditor.querySelector('.is-primary')
    const saveAndCheckButton = commentEditor.querySelector('.is-danger')

    const disableButtons = () => {
      saveButton.disabled = true
      if (saveAndCheckButton) saveAndCheckButton.disabled = true
    }

    const updatePreviewAndButtonState = () => {
      commentEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
      const isEmpty = editorTextarea.value.length === 0
      saveButton.disabled = isEmpty
      if (saveAndCheckButton) {
        saveAndCheckButton.disabled = isEmpty
      }
    }

    const resetEditor = () => {
      if (previewTab.classList.contains('is-active')) {
        toggleVisibility(tabElements, 'is-active')
      }
      editorTextarea.value = ''
      updatePreviewAndButtonState()
    }

    const hideSaveAndCheckButton = () => {
      if (saveAndCheckButton && saveAndCheckButton.parentNode) {
        saveAndCheckButton.parentNode.style.display = 'none'
      }
    }

    const validateBeforeSave = async (checkAfterSave) => {
      if (commentableType === 'Report' && isMentor && !checkAfterSave) {
        const alreadyChecked = await commentCheckable.isChecked(
          commentableType,
          commentableId
        )
        if (!alreadyChecked) {
          return window.confirm(
            '日報を確認済みにしていませんがよろしいですか？'
          )
        }
      }
      return true
    }

    const assignIfRequired = async () => {
      const shouldAssign =
        await commentCheckable.isUnassignedAndUncheckedProduct(
          commentableType,
          commentableId,
          isMentor
        )
      if (shouldAssign) {
        await commentCheckable.assignChecker(commentableId, currentUserId)
        return true
      }
      return false
    }

    const postComment = async () => {
      const params = {
        commentable_id: commentableId,
        commentable_type: commentableType,
        comment: {
          description: savedComment
        }
      }

      const response = await fetch('/api/comments', {
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

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.errors.join(', '))
      }

      return await response.text()
    }

    const addCommentToDOM = (html) => {
      const comments = document.querySelector('.thread-comments__items')
      const commentDiv = document.createElement('div')
      commentDiv.innerHTML = html.replace('style="display: none;', '')
      const newCommentElement = commentDiv.firstElementChild
      comments.appendChild(newCommentElement)
      initializeComment(newCommentElement)
      const reactionElement = newCommentElement.querySelector('.js-reactions')
      initializeReaction(reactionElement)

      const previousLatest = comments.querySelector('.is-latest')
      if (previousLatest) {
        previousLatest.classList.remove('is-latest')
      }

      newCommentElement.classList.add('is-latest')

      const event = new CustomEvent('comment-posted', {
        detail: {
          watchableId: commentableId,
          watchableType: commentableType
        }
      })
      document.dispatchEvent(event)
    }

    const createComment = async () => {
      if (savedComment.length < 1) {
        return null
      }

      try {
        const html = await postComment()
        addCommentToDOM(html)
      } catch (error) {
        console.warn(error)
      }
    }

    const getToastMessage = (checkAfterSave, assigned) => {
      if (checkAfterSave) {
        return commentableType === 'Product'
          ? '提出物を確認済みにしました。'
          : '日報を確認済みにしました。'
      } else if (assigned) {
        return '担当になりました。'
      }
      return 'コメントを投稿しました！'
    }

    const performCheck = async () => {
      await commentCheckable.check(
        commentableType,
        commentableId,
        '/api/checks',
        'POST'
      )
    }

    const handleSave = async (checkAfterSave = false) => {
      disableButtons()
      try {
        const shouldContinue = await validateBeforeSave(checkAfterSave)
        if (!shouldContinue) return

        const assigned = await assignIfRequired()

        savedComment = editorTextarea.value
        await createComment()

        if (checkAfterSave) {
          performCheck()
          hideSaveAndCheckButton()
        }

        resetEditor()
        toast(getToastMessage(checkAfterSave, assigned))
      } catch (error) {
        console.warn(error)
      }
    }

    editorTextarea.addEventListener('input', () => {
      updatePreviewAndButtonState()
    })

    saveButton.addEventListener('click', () => {
      handleSave()
    })

    if (saveAndCheckButton) {
      saveAndCheckButton.addEventListener('click', () => {
        if (
          commentableType === 'Product' &&
          !window.confirm('提出物を確認済にしてよろしいですか？')
        ) {
          return null
        } else {
          handleSave(true)
        }
      })
    }

    document.addEventListener('checked', () => {
      if (saveAndCheckButton && saveAndCheckButton.parentNode) {
        saveAndCheckButton.parentNode.style.display = 'none'
      }
    })

    document.addEventListener('unchecked', () => {
      if (saveAndCheckButton && saveAndCheckButton.parentNode) {
        saveAndCheckButton.parentNode.style.display = 'block'
      }
    })
  }
})
