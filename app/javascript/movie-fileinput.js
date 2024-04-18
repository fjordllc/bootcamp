document.addEventListener('DOMContentLoaded', () => {
  const FileInput = (target) => {
    const input = target.querySelector('.js-movie-file-input input')
    if (!input) return null

    input.addEventListener('change', (e) => {
      const file = e.target.files[0]

      if (file) {
        const fileReader = new FileReader()
        fileReader.addEventListener('load', (event) => {
          const dataUri = event.target.result
          const preview = input.parentElement.parentElement.querySelector(
            '.js-movie-file-input__preview'
          )
          const p = preview.querySelector('p')
          let movieData = preview.querySelector('video')

          if (!movieData) {
            movieData = document.createElement('video')
            movieData.setAttribute('controls', '')
            preview.appendChild(movieData)
          }

          movieData.src = dataUri
          p.innerHTML = '動画を変更'

          if (file.name.toLowerCase().endsWith('.mov')) {
            movieData.src = dataUri.replace(
              'data:video/quicktime',
              'data:video/mp4'
            )
          }
        })

        fileReader.readAsDataURL(file)
      }
    })
  }

  FileInput(document)
})
