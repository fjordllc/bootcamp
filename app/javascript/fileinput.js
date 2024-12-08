import Heic2any from 'heic2any'

function isHEIC(file) {
  const type = file.type
    ? file.type.split('image/').pop()
    : file.name.split('.').pop().toLowerCase()
  return type === 'heic' || type === 'heif'
}

function convertHEIC(file) {
  return new Promise((resolve) => {
    Heic2any({
      blob: file,
      toType: 'image/jpeg',
      quality: 1
    }).then((convertedBlob) => {
      const convertedFile = new File(
        [convertedBlob],
        file.name.substring(0, file.name.lastIndexOf('.')) + '.jpg',
        { type: 'image/jpeg' }
      )
      resolve(convertedFile)
    })
  })
}

function initializeFileInput(target) {
  const inputs = target.querySelectorAll('.js-file-input input')
  if (!inputs) return null

  inputs.forEach((input) => {
    input.addEventListener('change', async (e) => {
      let file = e.target.files[0]

      if (file) {
        const fileReader = new FileReader()
        fileReader.addEventListener('load', (event) => {
          const dataUri = event.target.result
          const preview = input.parentElement.parentElement.querySelector(
            '.js-file-input__preview'
          )
          const p = preview.querySelector('p')
          let img = preview.querySelector('img')

          if (!img) {
            img = document.createElement('img')
            preview.appendChild(img)
          }

          img.src = dataUri
          p.innerHTML = '画像を変更'
        })

        if (isHEIC(file)) file = await convertHEIC(file)

        fileReader.readAsDataURL(file)
      }
    })
  })
}

function extractField(elements) {
  for (let i = 0; i < elements.length; i++) {
    const element = elements[i]
    if (element.classList && element.classList.contains('nested-fields')) {
      return element
    } else {
      if (typeof element.querySelector === 'function') {
        const field = element.querySelector('.nested-fields')
        if (field) {
          return field
        }
      }
    }
  }
}

function initializeDiplomaUploadField() {
  const uploadField = document.getElementById('js-pdf-upload-field')
  if (!uploadField) return

  const removeButton = document.getElementById('js-remove-pdf-button')
  const fileLink = document.getElementById('js-pdf-file-link')
  const removeFlag = document.getElementById('js-remove-pdf-flag')
  const fileName = document.getElementById('js-pdf-name')
  const fileInput = uploadField.querySelector('input[type="file"]')

  uploadField.style.display = fileLink ? 'none' : 'flex'
  removeButton.style.display = fileLink ? 'block' : 'none'

  const updateDisplayedFileName = (name = '') => {
    fileName.textContent = name
    const displayedStatus = name ? 'block' : 'none'
    fileName.style.display = displayedStatus
    removeButton.style.display = displayedStatus
  }

  removeButton.addEventListener('click', () => {
    if (fileLink) fileLink.style.display = 'none'
    uploadField.style.display = 'flex'
    fileInput.value = ''
    removeFlag.value = '1'
    updateDisplayedFileName()
  })

  fileInput.addEventListener('change', () => {
    const selectedFile = fileInput.files[0]
    updateDisplayedFileName(selectedFile.name)
    if (selectedFile) removeFlag.value = '0'
  })
}

document.addEventListener('DOMContentLoaded', () => {
  const ref = document.querySelector('#reference_books')
  if (ref) {
    $(ref).on('cocoon:after-insert', (_, target) => {
      const added = extractField(target)
      initializeFileInput(added)
    })
  }
  initializeFileInput(document)
  initializeDiplomaUploadField()
})
