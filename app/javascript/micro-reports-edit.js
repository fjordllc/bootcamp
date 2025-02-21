import MarkdownInitializer from 'markdown-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const threadComments = document.querySelectorAll(
    '.thread-comment[id^="micro_report_"]'
  )

  threadComments.forEach((threadComment) => {
    const microReportContent = threadComment.dataset.micro_report_content
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
    editButton.addEventListener('click', () => {
      toggleVisibility(modalElements, 'is-hidden')
    })
    const cancelButton = microReportEditor.querySelector('.is-secondary')
    cancelButton.addEventListener('click', () => {
      toggleVisibility(modalElements, 'is-hidden')
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
})
