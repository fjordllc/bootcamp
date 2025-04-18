import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { initializeComment, toggleVisibility } from './initializeComment.js'
import { initializeReaction } from './reaction.js'
import { toast } from './vanillaToast.js'
import jsCheckable from './jsCheckable.js'

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

    editorTextarea.addEventListener('input', () => {
      updatePreviewAndButtonState()
    })

    const handleSave = async (checkAfterSave = false) => {
      const isUnassignedAndUnchekedProduct =
        await jsCheckable.isUnassignedAndUnchekedProduct(
          commentableType,
          commentableId
        )
      if (isUnassignedAndUnchekedProduct) {
        toastMessage = '担当になりました。'
        jsCheckable.assignChecker(commentableId, currentUserId)
      }

      if (commentableType === 'Report' && isMentor && !checkAfterSave) {
        const isAlreadyChecked = await jsCheckable.isChecked(
          commentableType,
          commentableId
        )

        if (
          !isAlreadyChecked &&
          !window.confirm('日報を確認済みにしていませんがよろしいですか？')
        ) {
          return
        }
      }

      savedComment = editorTextarea.value

      try {
        await createComment(
          savedComment,
          commentableId,
          commentableType,
          toastMessage
        )

        if (checkAfterSave) {
          await jsCheckable.check(
            commentableType,
            commentableId,
            '/api/checks',
            'POST'
          )
          toastMessage =
            commentableType === 'Product'
              ? '提出物を確認済みにしました。'
              : '日報を確認済みにしました。'
          saveAndCheckButton.parentNode.style.display = 'none'
        }
        resetEditor()
        toast(toastMessage)
        toastMessage = 'コメントを投稿しました！'
      } catch (error) {
        console.warn(error)
      }
    }

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

    editTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )

    previewTab.addEventListener('click', () =>
      toggleVisibility(tabElements, 'is-active')
    )

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

async function postComment(description, commentableId, commentableType) {
  const params = {
    commentable_id: commentableId,
    commentable_type: commentableType,
    comment: {
      description: description
    }
  };

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
  });

  if (!response.ok) {
    const data = await response.json();
    throw new Error(data.errors.join(', '));
  }

  return await response.text();
}

function addCommentToDOM(html, commentableId, commentableType) {
  const comments = document.querySelector('.thread-comments__items');
  const commentDiv = document.createElement('div');
  commentDiv.innerHTML = html.replace('style="display: none;', '');
  const newCommentElement = commentDiv.firstElementChild;
  comments.appendChild(newCommentElement);
  initializeComment(newCommentElement);
  const reactionElement = newCommentElement.querySelector('.js-reactions');
  initializeReaction(reactionElement);

  const event = new CustomEvent('comment-posted', {
    detail: {
      watchableId: commentableId,
      watchableType: commentableType
    }
  });
  document.dispatchEvent(event);
}

async function createComment(description, commentableId, commentableType) {
  if (description.length < 1) {
    return null;
  }

  try {
    const html = await postComment(description, commentableId, commentableType);
    addCommentToDOM(html, commentableId, commentableType);
  } catch (error) {
    console.warn(error);
  }
}
