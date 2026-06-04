import TextareaInitializer from 'textarea-initializer'
import MarkdownInitializer from 'markdown-initializer'
import { put, destroy } from '@rails/request.js'

export default function initializeMemo(memo, userId) {
  const memoId = memo.dataset.memo_id
  const memoBody = memo.dataset.memo_body
  let savedMemo = memoBody || ''

  TextareaInitializer.initialize(`#js-memo-${memoId}`)
  const markdownInitializer = new MarkdownInitializer()

  const memoDisplay = memo.querySelector('.memo-display')
  const memoDisplayContent = memo.querySelector('.memo-text')

  const memoEditor = memo.querySelector('.memo-editor')
  const editorTextarea = memo.querySelector('.a-markdown-input__textarea')
  const editorPreview = memo.querySelector('.a-markdown-input__preview')

  if (memoBody) {
    memoDisplayContent.innerHTML = markdownInitializer.render(savedMemo)
    editorPreview.innerHTML = markdownInitializer.render(savedMemo)
  }

  const editButton = memo.querySelector('.js-edit-memo')
  if (editButton) {
    editButton.addEventListener('click', () => {
      toggleEditor()
      resetEditorTabs()
    })
  }

  const saveButton = memo.querySelector('.js-save-memo')
  editorTextarea.addEventListener('input', () => {
    saveButton.disabled = editorTextarea.value.length === 0
  })

  saveButton.addEventListener('click', async () => {
    try {
      const editedMemo = editorTextarea.value
      await updateMemo(memoId, editedMemo, userId)
      savedMemo = editedMemo
      toggleEditor()
      memoDisplayContent.innerHTML = markdownInitializer.render(savedMemo)
    } catch (error) {
      console.warn(error)
    }
  })

  const cancelButton = memo.querySelector('.js-cancel-memo')
  cancelButton.addEventListener('click', () => {
    toggleEditor()
    editorTextarea.value = savedMemo
    editorPreview.innerHTML = markdownInitializer.render(savedMemo)
  })

  const deleteButton = memo.querySelector('.js-delete-memo')
  if (deleteButton) {
    deleteButton.addEventListener('click', async () => {
      if (window.confirm('本当によろしいですか？')) {
        try {
          await deleteMemo(memoId, userId)
          memo.remove()

          const mentorMemos = document.querySelector('.mentor-memos')
          const emptyMessage = mentorMemos.querySelector('.o-empty-message')
          const memoList = mentorMemos.querySelectorAll('.mentor-memo')

          if (!memoList.length) emptyMessage.classList.remove('is-hidden')
        } catch (error) {
          console.warn(error)
        }
      }
    })
  }

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
    editorPreview.innerHTML = markdownInitializer.render(editorTextarea.value)
    toggleClass(tabElements, 'is-active')
  })

  async function updateMemo(memoId, memoContent, userId) {
    const params = {
      mentor_memo: {
        body: memoContent
      }
    }
    const response = await put(`/api/users/${userId}/mentor_memos/${memoId}`, {
      body: params
    })

    if (!response.ok) throw new Error('Failed to update')
  }

  async function deleteMemo(memoId, userId) {
    const response = await destroy(
      `/api/users/${userId}/mentor_memos/${memoId}`
    )

    if (!response.ok) throw new Error('Failed to delete')
  }

  function toggleEditor() {
    toggleClass([memoDisplay, memoEditor], 'is-hidden')
  }

  function toggleClass(elements, className) {
    elements.forEach((element) => {
      element.classList.toggle(className)
    })
  }

  function resetEditorTabs() {
    editorTab.classList.add('is-active')
    editorTabContent.classList.add('is-active')
    previewTab.classList.remove('is-active')
    previewTabContent.classList.remove('is-active')
  }
}
