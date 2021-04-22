document.addEventListener('DOMContentLoaded', () => {
  const inputs = document.querySelectorAll('.js-file-input input')
  if (inputs) {
    for (let i = 0; i < inputs.length; i++) {
      const input = inputs[i]
      input.addEventListener('change', (e) => {
        const file = e.target.files[0]
        const fileReader = new FileReader()
        fileReader.addEventListener('load', (event) => {
          const dataUri = event.target.result
          const preview = document.querySelector('.js-file-input__preview')
          const p = document.querySelector('.js-file-input__preview p')
          let img = document.querySelector('.js-file-input__preview img')

          if (!img) {
            img = document.createElement('img')
            preview.appendChild(img)
          }

          img.src = dataUri
          console.log('dataUri', dataUri)
          p.innerHTML = '画像を変更'
        })
        fileReader.readAsDataURL(file)
      })
    }
  }
})
