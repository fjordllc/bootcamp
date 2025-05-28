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
