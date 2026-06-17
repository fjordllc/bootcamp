import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import initializeMemo from './initializeMentorMemo'
import { post } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  const mentorMemo = document.querySelector('.mentor-memos')
  if (!mentorMemo) return

  TextareaInitializer.initialize('#js-new-memo')
  const markdownInitializer = new MarkdownInitializer()
  const userId = mentorMemo.dataset.user_id

  const memoDisplay = mentorMemo.querySelector('.memos-display')
  const memoEditor = mentorMemo.querySelector('.new-memo-editor')

  const memoEditorPreview = memoEditor.querySelector(
    '.a-markdown-input__preview'
  )
  const editorTextarea = memoEditor.querySelector('.a-markdown-input__textarea')

  const memos = mentorMemo.querySelectorAll('.mentor-memo')
  const emptyMessage = mentorMemo.querySelector('.o-empty-message')
  if (memos.length) {
    memos.forEach((memo) => {
      initializeMemo(memo, userId)
    })
  } else {
    emptyMessage.classList.remove('is-hidden')
  }

  const addButton = memoDisplay.querySelector('.js-add-memo')
  const addContainer = memoDisplay.querySelector('.js-add-action')
  const modalElements = [addContainer, memoEditor]
  addButton.addEventListener('click', () => {
    toggleClass(modalElements, 'is-hidden')
    resetEditorTabs()
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
    closeEditor()

    if (emptyMessage) {
      emptyMessage.classList.add('is-hidden')
    }
  })

  const cancelButton = memoEditor.querySelector('.js-cancel-memo')
  cancelButton.addEventListener('click', () => {
    closeEditor()
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
  previewTab.addEventListener('click', () => {
    memoEditorPreview.innerHTML = markdownInitializer.render(
      editorTextarea.value
    )
    toggleClass(tabElements, 'is-active')
  })

  function resetEditorTabs() {
    editorTab.classList.add('is-active')
    editorTabContent.classList.add('is-active')
    previewTab.classList.remove('is-active')
    previewTabContent.classList.remove('is-active')
  }

  function closeEditor() {
    toggleClass(modalElements, 'is-hidden')
    editorTextarea.value = ''
    memoEditorPreview.innerHTML = ''
    saveButton.disabled = true
  }
})

async function createMemo(memo, userId) {
  const params = {
    mentor_memo: {
      body: memo
    }
  }
  try {
    const response = await post(`/api/users/${userId}/mentor_memos/`, {
      body: params
    })

    if (!response.ok) throw new Error('Failed to fetch')

    return await response.text
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
