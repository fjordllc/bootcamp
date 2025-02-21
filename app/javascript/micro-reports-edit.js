import CSRF from 'csrf'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const threadComments = document.querySelectorAll(
    '.thread-comment[id^="micro_report_"]'
  )

  threadComments.forEach((threadComment) => {
    const microReportId = threadComment.dataset.micro_report_id
    const microReportContent = threadComment.dataset.micro_report_content
    TextareaInitializer.initialize(`#js-comment-${microReportId}`)
    let savedMicroReort = ''

    const microReportDisplay = threadComment.querySelector(
      '.micro-report-display'
    )
    const microReportEditor = threadComment.querySelector(
      '.micro-report-editor'
    )

    const microReporDisplayContent =
      microReportDisplay.querySelector('.a-long-text')
    const microReportEditorPreview = microReportEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = microReportEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    const markdownInitializer = new MarkdownInitializer()
    if (microReportContent) {
      microReporDisplayContent.innerHTML =
        markdownInitializer.render(microReportContent)
      microReportEditorPreview.innerHTML =
        markdownInitializer.render(microReportContent)
    }

    const modalElements = [microReportDisplay, microReportEditor]
    const editButton = microReportDisplay.querySelector(
      '.card-main-actions__action'
    )
    if (editButton) {
      editButton.addEventListener('click', () => {
        if (!savedMicroReort) {
          savedMicroReort = editorTextarea.value
        }
        toggleVisibility(modalElements, 'is-hidden')
      })
    }

    const saveButton = microReportEditor.querySelector('.is-primary')
    if (saveButton) {
      saveButton.addEventListener('click', () => {
        toggleVisibility(modalElements, 'is-hidden')
        savedMicroReort = editorTextarea.value
        updatemicroReport(microReportId, savedMicroReort)
        microReporDisplayContent.innerHTML =
          markdownInitializer.render(savedMicroReort)
      })
    }

    const cancelButton = microReportEditor.querySelector('.is-secondary')
    cancelButton.addEventListener('click', () => {
      toggleVisibility(modalElements, 'is-hidden')
      editorTextarea.value = savedMicroReort
      microReportEditorPreview.innerHTML =
        markdownInitializer.render(savedMicroReort)
    })

    editorTextarea.addEventListener('input', () => {
      microReportEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
    })

    const editTab = microReportEditor.querySelector('.edit-micro-reort-tab')
    const editorTabContent = microReportEditor.querySelector('.is-editor')
    const previewTab = microReportEditor.querySelector(
      '.micro-reort-preview-tab'
    )
    const previewTabContent = microReportEditor.querySelector('.is-preview')
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
  })

  function toggleVisibility(elements, className) {
    elements.forEach((element) => {
      element.classList.toggle(className)
    })
  }

  function updatemicroReport(microReportId, content) {
    if (content.length < 1) {
      return null
    }
    const params = {
      id: microReportId,
      micro_report: { content: content }
    }
    fetch(`/api/micro_reports/${microReportId}`, {
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
})
