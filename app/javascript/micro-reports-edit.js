import Bootcamp from 'bootcamp'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const microReports = document.querySelectorAll('.micro-report')
  if (microReports.length === 0) return

  microReports.forEach((microReport) => {
    const microReportId = microReport.dataset.micro_report_id
    const microReportContent = microReport.dataset.micro_report_content
    TextareaInitializer.initialize(`#js-comment-${microReportId}`)
    let savedMicroReport = ''

    const microReportDisplay = microReport.querySelector(
      '.micro-report-display'
    )
    const microReportEditor = microReport.querySelector('.micro-report-editor')

    const microReportDisplayContent =
      microReportDisplay.querySelector('.a-short-text')
    const microReportEditorPreview = microReportEditor.querySelector(
      '.a-markdown-input__preview'
    )
    const editorTextarea = microReportEditor.querySelector(
      '.a-markdown-input__textarea'
    )

    const markdownInitializer = new MarkdownInitializer()
    if (microReportContent) {
      microReportDisplayContent.innerHTML =
        markdownInitializer.render(microReportContent)
      microReportEditorPreview.innerHTML =
        markdownInitializer.render(microReportContent)
    }

    const modalElements = [microReportDisplay, microReportEditor]
    const editButton = microReportDisplay.querySelector('.js-editor-button')
    if (editButton) {
      editButton.addEventListener('click', () => {
        if (!savedMicroReport) {
          savedMicroReport = editorTextarea.value
        }
        toggleVisibility(modalElements, 'is-hidden')
      })
    }
    const saveButton = microReportEditor.querySelector('.js-save-button')
    if (saveButton) {
      saveButton.addEventListener('click', async () => {
        toggleVisibility(modalElements, 'is-hidden')
        savedMicroReport = editorTextarea.value
        await updateMicroReport(microReportId, savedMicroReport)
        TextareaInitializer.initialize(`#js-comment-${microReportId}`)
        microReportDisplayContent.innerHTML =
          markdownInitializer.render(savedMicroReport)
      })
    }

    const cancelButton = microReportEditor.querySelector('.js-cancel-button')
    if (cancelButton) {
      cancelButton.addEventListener('click', () => {
        toggleVisibility(modalElements, 'is-hidden')
        editorTextarea.value = savedMicroReport
        microReportEditorPreview.innerHTML =
          markdownInitializer.render(savedMicroReport)
      })
    }

    editorTextarea.addEventListener('input', () => {
      microReportEditorPreview.innerHTML = markdownInitializer.render(
        editorTextarea.value
      )
    })

    const editTab = microReportEditor.querySelector('.js-edit-tab')
    const editorTabContent = microReportEditor.querySelector('.is-editor')
    const previewTab = microReportEditor.querySelector('.js-preview-tab')
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

  function updateMicroReport(microReportId, content) {
    if (content.length < 1) {
      return null
    }
    const params = {
      id: microReportId,
      micro_report: { content: content }
    }
    const url = `/api/micro_reports/${microReportId}`
    return Bootcamp.patch(url, params).catch((error) => {
      console.warn(error)
    })
  }
})
