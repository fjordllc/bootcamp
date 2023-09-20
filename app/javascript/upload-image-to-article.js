document.addEventListener('DOMContentLoaded', () => {
  const radioButton = document.getElementById(
    'article_thumbnail_type_prepared_image'
  )
  const fileField = document.getElementById('upload-thumbnail')
  fileField.style.display = 'none'
  console.log(radioButton)
  console.log(fileField)
  radioButton.addEventListener('change', () => {
    if (radioButton.checked) {
      console.log(radioButton.checked)
      fileField.style.display = 'block'
      console.log(fileField.style.display)
    }
    if (!radioButton.checked){
      console.log(radioButton.checked)
      fileField.style.display = 'none'
      console.log(fileField.style.display)
    }
    console.log(radioButton.checked)
  })
})
