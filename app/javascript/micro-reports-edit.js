document.addEventListener('DOMContentLoaded', () => {
  const threadComments = document.querySelectorAll(
    '.thread-comment[id^="micro_report_"]'
  )

  threadComments.forEach((threadComment) => {
    const microReportDisplay = threadComment.querySelector(
      '.micro-report-display'
    )
    const microReportEditor = threadComment.querySelector(
      '.micro-report-editor'
    )

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
  })

  function toggleVisibility(elements, className) {
    elements.forEach((element) => {
      element.classList.toggle(className)
    })
  }
})
