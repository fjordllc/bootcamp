import { Controller } from '@hotwired/stimulus'
import Heic2any from 'heic2any'

export default class extends Controller {
  static targets = ['input', 'preview']

  async change() {
    const file = this.inputTarget.files[0]

    if (!file) return

    let previewFile = file

    if (this.isHEIC(file)) {
      previewFile = await this.convertHEIC(file)
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(previewFile)
      this.inputTarget.files = dataTransfer.files
    }

    const fileReader = new FileReader()

    fileReader.addEventListener('load', (event) => {
      const dataUri = event.target.result

      let img = this.previewTarget.querySelector('img')

      if (!img) {
        img = document.createElement('img')
        this.previewTarget.appendChild(img)
      }

      img.src = dataUri

      const p = this.previewTarget.querySelector('p')
      p.innerHTML = '画像を変更'
    })

    fileReader.readAsDataURL(previewFile)
  }

  dragover(event) {
    event.preventDefault()
  }

  drop(event) {
    event.preventDefault()

    this.inputTarget.files = event.dataTransfer.files
    this.inputTarget.dispatchEvent(new Event('change'))
  }

  isHEIC(file) {
    const type = file.type
      ? file.type.split('image/').pop()
      : file.name.split('.').pop().toLowerCase()

    return type === 'heic' || type === 'heif'
  }

  convertHEIC(file) {
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
}
