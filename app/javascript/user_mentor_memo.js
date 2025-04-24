import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.user-mentor-memo')
  if (mentorMemo) {
    const markdownInitializer = new MarkdownInitializer()
    const userId = mentorMemo.dataset.user_id
    let savedMemo = ''

    const memoDisplay = mentorMemo.querySelector('.memo-display')
    const memoEditor = mentorMemo.querySelector('.memo-editor')

    const placeholder = memoDisplay.querySelector('.a-placeholder')
    const emptyMessage = memoDisplay.querySelector('.o-empty-message')
    const memoDisplayContent = memoDisplay.querySelector(
      '.user-mentor-memo-content'
    )
    const memoEditorPreview = memoEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = memoEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    fetch(`/api/users/${userId}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        if (json.mentor_memo) {
          savedMemo = json.mentor_memo
        }
        placeholder.classList.add('is-hidden')
        if (savedMemo.length === 0) {
          emptyMessage.classList.remove('is-hidden')
        } else {
          memoDisplayContent.classList.remove('is-hidden')
          editorTextarea.value = savedMemo
          switchMemoDisplay(memoDisplay, savedMemo)
          memoDisplayContent.innerHTML = markdownInitializer.render(savedMemo)
          memoEditorPreview.innerHTML = markdownInitializer.render(savedMemo)
        }
      })
      .then(() => {
        TextareaInitializer.initialize('#js-user-mentor-memo')
      })
      .catch((error) => {
        console.warn(error)
      })

    const editButton = memoDisplay.querySelector('.card-footer-actions__action')
    const modalElements = [memoDisplay, memoEditor]
    editButton.addEventListener('click', () =>
      toggleClass(modalElements, 'is-hidden')
    )

    const saveButton = memoEditor.querySelector('.is-primary')
    saveButton.addEventListener('click', () => {
      toggleClass(modalElements, 'is-hidden')
      savedMemo = editorTextarea.value
      updateMemo(savedMemo, userId)
      memoDisplayContent.innerHTML = markdownInitializer.render(savedMemo)
      TextareaInitializer.initialize('#js-user-mentor-memo')
      switchMemoDisplay(memoDisplay, savedMemo)
    })

    const cancelButton = memoEditor.querySelector('.is-secondary')
    cancelButton.addEventListener('click', () => {
      toggleClass(modalElements, 'is-hidden')
      editorTextarea.value = savedMemo
      memoEditorPreview.innerHTML = markdownInitializer.render(savedMemo)
      // TextareaInitializer.initialize('#js-user-mentor-memo')
    })

    editorTextarea.addEventListener('change', () => {
      memoEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
      TextareaInitializer.initialize('#js-user-mentor-memo')
    })

    const editorTab = memoEditor.querySelector('.editor-tab')
    const editorTabContent = memoEditor.querySelector('.is-editor')
    const previewTab = memoEditor.querySelector('.preview-tab')
    const previewTabContent = memoEditor.querySelector('.is-preview')

    const tabElements = [
      editorTab,
      editorTabContent,
      previewTab,
      previewTabContent
    ]
    editorTab.addEventListener('click', () =>
      toggleClass(tabElements, 'is-active')
    )
    previewTab.addEventListener('click', () =>
      toggleClass(tabElements, 'is-active')
    )
  }
})

function updateMemo(memo, userId) {
  const params = {
    user: {
      mentor_memo: memo
    }
  }
  fetch(`/api/mentor_memos/${userId}`, {
    method: 'PUT',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type': 'application/json; charset=utf-8',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual',
    body: JSON.stringify(params)
  })
    .then((response) => {
      return response
    })
    .catch((error) => {
      console.warn(error)
    })
}

function switchMemoDisplay(memoDisplay, memo) {
  const memoDisplayContent = memoDisplay.querySelector(
    '.user-mentor-memo-content'
  )
  const emptyMessage = memoDisplay.querySelector('.o-empty-message')
  memoDisplayContent.classList.toggle('is-hidden', memo.length === 0)
  emptyMessage.classList.toggle('is-hidden', memo.length !== 0)
}

function toggleClass(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}
