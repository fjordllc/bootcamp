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

document.addEventListener('DOMContentLoaded', () => {
  const ref = document.querySelector('#reference_books')
  if (ref) {
    $(ref).on('cocoon:after-insert', (_, target) => {
      const added = extractField(target)
      initializeFileInput(added)
    })
  }
  initializeFileInput(document)
})

document.addEventListener('DOMContentLoaded', () => {
  const removePdfButton = document.getElementById('js-remove-pdf-button')
  const pdfUploadField = document.getElementById('js-pdf-upload-field')
  const pdfFileLink = document.getElementById('js-pdf-file-link')
  const removePdfFlag = document.getElementById('js-remove-pdf-flag')
  const pdfFileNameDisplay = document.getElementById('js-pdf-name')

  removePdfButton.addEventListener('click', () => {
    if (pdfFileLink) pdfFileLink.style.display = 'none'
    pdfUploadField.style.display = 'flex'
    pdfUploadField.querySelector('input[type="file"]').value = ''
    removePdfFlag.value = '1'

    if (pdfFileNameDisplay) {
      pdfFileNameDisplay.textContent = ''
      pdfFileNameDisplay.style.display = 'none'
    }
  })

  const fileInput = pdfUploadField.querySelector('input[type="file"]')
  fileInput.addEventListener('change', () => {
    if (fileInput.files && fileInput.files[0]) {
      const fileName = fileInput.files[0].name

      if (pdfFileNameDisplay) {
        pdfFileNameDisplay.textContent = fileName
        pdfFileNameDisplay.style.display = 'block'
      }

      removePdfFlag.value = '0'
    } else {
      if (pdfFileNameDisplay) {
        pdfFileNameDisplay.textContent = ''
        pdfFileNameDisplay.style.display = 'none'
      }
    }
  })
})
