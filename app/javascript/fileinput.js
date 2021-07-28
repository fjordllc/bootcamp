function initializeFileInput(target) {
  const inputs = target.querySelectorAll('.js-file-input input')
  if (!inputs) {
    return null
  }

  for (let i = 0; i < inputs.length; i++) {
    const input = inputs[i]
    input.addEventListener('change', (e) => {
      const file = e.target.files[0]
      const fileReader = new FileReader()
      fileReader.addEventListener('load', (event) => {
        const dataUri = event.target.result
        const frame = input.parentElement.parentElement
        const preview = frame.querySelector('.js-file-input__preview')
        const p = frame.querySelector('.js-file-input__preview p')
        let img = frame.querySelector('.js-file-input__preview img')

        if (!img) {
          img = document.createElement('img')
          preview.appendChild(img)
        }

        img.src = dataUri
        p.innerHTML = '画像を変更'
      })
      fileReader.readAsDataURL(file)
    })
  }
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
  } else {
    initializeFileInput(document)
  }
})
