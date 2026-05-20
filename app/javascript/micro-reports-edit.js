import Bootcamp from './bootcamp.js'
import { initializeTextarea, renderMarkdown } from './lazy-markdown.js'

document.addEventListener('turbo:load', () => {
  const microReports = document.querySelectorAll('.micro-report')
  if (microReports.length === 0) return

  microReports.forEach(async (microReport) => {
    const microReportId = microReport.dataset.micro_report_id
    const microReportContent = microReport.dataset.micro_report_content
    initializeTextarea(`#js-comment-${microReportId}`)
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

    if (microReportContent) {
      const rendered = await renderMarkdown(microReportContent)
      microReportDisplayContent.innerHTML = rendered
      microReportEditorPreview.innerHTML = rendered
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
        initializeTextarea(`#js-comment-${microReportId}`)
        microReportDisplayContent.innerHTML = await renderMarkdown(
          savedMicroReport
        )
      })
    }

    const cancelButton = microReportEditor.querySelector('.js-cancel-button')
    if (cancelButton) {
      cancelButton.addEventListener('click', async () => {
        toggleVisibility(modalElements, 'is-hidden')
        editorTextarea.value = savedMicroReport
        microReportEditorPreview.innerHTML = await renderMarkdown(
          savedMicroReport
        )
      })
    }

    editorTextarea.addEventListener('input', async () => {
      microReportEditorPreview.innerHTML = await renderMarkdown(
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
      micro_report: { content }
    }
    const url = `/api/micro_reports/${microReportId}`
    return Bootcamp.patch(url, params).catch((error) => {
      console.warn(error)
    })
  }
})
