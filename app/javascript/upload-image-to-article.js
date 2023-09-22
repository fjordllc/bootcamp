document.addEventListener('DOMContentLoaded', () => {
  const radioButtons = document.getElementsByName(
    'article[thumbnail_type]'
  )
  const fileField = document.getElementById('upload-thumbnail')
  for (const radioButton of radioButtons) {
    radioButton.addEventListener('change', () => {
      if (radioButton.value === 'prepared_thumbnail') {
        fileField.style.display = 'block'
      } else {
        fileField.style.display = 'none'
      }
    })
  }
})
