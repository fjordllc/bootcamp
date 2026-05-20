import CSRF from './csrf.js'
import { initializeTextarea, renderMarkdown } from './lazy-markdown.js'
import { toast } from './vanillaToast.js'

document.addEventListener('turbo:load', () => {
  const practiceMemo = document.querySelector('.practice-memo')
  if (practiceMemo) {
    const practiceId = practiceMemo.dataset.practice_id
    let savedMemo = ''

    const memoDisplay = practiceMemo.querySelector('.memo-display')
    const memoEditor = practiceMemo.querySelector('.memo-editor')
    const memoDisplayContent = memoDisplay.querySelector('.a-long-text')
    const memoEditorPreview = memoEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = memoEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    fetch(`/api/practices/${practiceId}.json`, {
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
      .then(async (json) => {
        if (json.memo) {
          savedMemo = json.memo
          editorTextarea.value = savedMemo
          switchMemoDisplay(memoDisplay, savedMemo)
          initializeTextarea('#js-practice-memo')
          const rendered = await renderMarkdown(savedMemo)
          memoDisplayContent.innerHTML = rendered
          memoEditorPreview.innerHTML = rendered
        }
      })
      .catch((error) => {
        console.warn(error)
      })

    const editButton = memoDisplay.querySelector('.card-main-actions__action')
    const modalElements = [memoDisplay, memoEditor]
    editButton.addEventListener('click', () =>
      toggleClass(modalElements, 'is-hidden')
    )

    const saveButton = memoEditor.querySelector('.is-primary')
    saveButton.addEventListener('click', async () => {
      toggleClass(modalElements, 'is-hidden')
      savedMemo = editorTextarea.value
      updateMemo(savedMemo, practiceId)
      memoDisplayContent.innerHTML = await renderMarkdown(savedMemo)
      initializeTextarea('#js-practice-memo')
      switchMemoDisplay(memoDisplay, savedMemo)
    })

    const cancelButton = memoEditor.querySelector('.is-secondary')
    cancelButton.addEventListener('click', async () => {
      toggleClass(modalElements, 'is-hidden')
      editorTextarea.value = savedMemo
      memoEditorPreview.innerHTML = await renderMarkdown(savedMemo)
      initializeTextarea('#js-practice-memo')
    })

    editorTextarea.addEventListener('change', async () => {
      memoEditorPreview.innerHTML = await renderMarkdown(editorTextarea.value)
      initializeTextarea('#js-practice-memo')
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

function updateMemo(memo, practiceId) {
  const params = {
    practice: {
      memo
    }
  }
  fetch(`/api/practices/${practiceId}`, {
    method: 'PUT',
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
      toast('保存しました！')
    })
    .catch((error) => {
      console.warn(error)
    })
}

function switchMemoDisplay(memoDisplay, memo) {
  const memoContent = memoDisplay.querySelector('.any-memo')
  const noMemoMessage = memoDisplay.querySelector('.no-memo')
  memoContent.classList.toggle('is-hidden', memo === '')
  noMemoMessage.classList.toggle('is-hidden', memo !== '')
}

function toggleClass(elements, className) {
  elements.forEach((element) => {
    element.classList.toggle(className)
  })
}
