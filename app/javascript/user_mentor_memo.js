import CSRF from 'csrf'
import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import initializeMemo from './initializeMentorMemo'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.mentor-memos')
  if (mentorMemo) {
    TextareaInitializer.initialize('#js-new-memo')
    const markdownInitializer = new MarkdownInitializer()
    const userId = mentorMemo.dataset.user_id

    const memoDisplay = mentorMemo.querySelector('.memos-display')
    const memoEditor = mentorMemo.querySelector('.new-memo-editor')

    const memoEditorPreview = memoEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = memoEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    const memos = document.querySelectorAll('.mentor-memo')
    memos.forEach((memo) => {
      initializeMemo(memo, userId)
    })

    const addButton = memoDisplay.querySelector('.js-add-memo')
    const addContainer = memoDisplay.querySelector('.js-add-action')
    const modalElements = [addContainer, memoEditor]
    addButton.addEventListener('click', () => {
      toggleClass(modalElements, 'is-hidden')
      editorTextarea.focus()
    })

    const saveButton = memoEditor.querySelector('.js-save-memo')
    saveButton.disabled = true
    editorTextarea.addEventListener('input', () => {
      saveButton.disabled = editorTextarea.value.trim().length === 0
    })

    saveButton.addEventListener('click', async () => {
      const memoContent = editorTextarea.value
      const html = await createMemo(memoContent, userId)
      if (!html) return

      const newMemo = initializeNewMemo(html, userId)
      newMemo.scrollIntoView()
      toggleClass(modalElements, 'is-hidden')
      editorTextarea.value = ''
      memoEditorPreview.innerHTML = ''
      TextareaInitializer.initialize('#js-new-memo')

      const emptyMessage = mentorMemo.querySelector('.o-empty-message')
      if (emptyMessage) {
        emptyMessage.classList.add('is-hidden')
      }
    })

    const cancelButton = memoEditor.querySelector('.js-cancel-memo')
    cancelButton.addEventListener('click', () => {
      toggleClass(modalElements, 'is-hidden')
      editorTextarea.value = ''
      memoEditorPreview.innerHTML = ''
      TextareaInitializer.initialize('#js-new-memo')
    })

    editorTextarea.addEventListener('change', () => {
      memoEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
      TextareaInitializer.initialize('#js-new-memo')
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

async function createMemo(memo, userId) {
  const params = {
    mentor_memo: {
      body: memo
    }
  }
  try {
    const response = await fetch(`/api/users/${userId}/mentor_memos/`, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json; charset=utf-8',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })

    if (!response.ok) throw new Error('Failed to fetch')

    return response.text()
  } catch (error) {
    console.warn(error)
    return false
  }
}

function initializeNewMemo(html, userId) {
  const memoList = document.querySelector('.mentor-memo-list')
  const memoDiv = document.createElement('div')
  memoDiv.innerHTML = html
  const newMemoElement = memoDiv.firstElementChild
  memoList.prepend(newMemoElement)
  initializeMemo(newMemoElement, userId)

  return newMemoElement
}

function toggleClass(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}
