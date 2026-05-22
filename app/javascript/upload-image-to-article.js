function setupUploadImageToArticle() {
  const radioButtons = document.getElementsByName('article[thumbnail_type]')
  const fileField = document.getElementById('upload-thumbnail')
  if (!fileField) return

  for (const radioButton of radioButtons) {
    if (radioButton.dataset.uploadImageToArticleInitialized === 'true') continue

    radioButton.dataset.uploadImageToArticleInitialized = 'true'
    radioButton.addEventListener('change', () => {
      if (radioButton.value === 'prepared_thumbnail') {
        fileField.style.display = 'block'
      } else {
        fileField.style.display = 'none'
      }
    })
  }
}

document.addEventListener('turbo:load', setupUploadImageToArticle)
document.addEventListener('DOMContentLoaded', setupUploadImageToArticle)
setupUploadImageToArticle()
