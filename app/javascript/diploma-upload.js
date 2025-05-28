function initializeDiplomaUploadField() {
  const uploadField = document.getElementById('js-pdf-upload-field')
  if (!uploadField) return

  const removeButton = document.getElementById('js-remove-pdf-button')
  const fileLink = document.getElementById('js-pdf-file-link')
  const removeFlag = document.getElementById('js-remove-pdf-flag')
  const fileName = document.getElementById('js-pdf-name')
  const fileInput = uploadField.querySelector('input[type="file"]')
  const isFileUploaded = !!fileLink

  uploadField.style.display = isFileUploaded ? 'none' : 'flex'
  removeButton.style.display = isFileUploaded ? 'block' : 'none'

  const updateDisplayState = (name = '') => {
    fileName.textContent = name
    const displayedStatus = name ? 'block' : 'none'
    fileName.style.display = displayedStatus
    removeButton.style.display = displayedStatus
  }

  removeButton.addEventListener('click', () => {
    if (isFileUploaded) fileLink.style.display = 'none'
    uploadField.style.display = 'flex'
    fileInput.value = ''
    removeFlag.value = '1'
    updateDisplayState()
  })

  fileInput.addEventListener('change', () => {
    const selectedFile = fileInput.files[0]
    updateDisplayState(selectedFile.name)
    if (selectedFile) removeFlag.value = '0'
  })
}

document.addEventListener('DOMContentLoaded', () => {
  initializeDiplomaUploadField()
})
