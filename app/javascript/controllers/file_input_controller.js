import { Controller } from '@hotwired/stimulus'
import Heic2any from 'heic2any'

export default class extends Controller {
  static targets = ['input', 'preview']

  async change() {
    const changeId = (this.changeId ?? 0) + 1
    this.changeId = changeId
    const file = this.inputTarget.files[0]

    if (!file) return

    let previewFile = file

    if (this.isHEIC(file)) {
      try {
        previewFile = await this.convertHEIC(file)
        if (changeId !== this.changeId) return
      } catch (error) {
        console.error('HEIC conversion failed:', error)
        return
      }
    }

    const fileReader = new FileReader()

    fileReader.addEventListener('load', (event) => {
      if (changeId !== this.changeId) return
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

  async convertHEIC(file) {
    const convertedBlob = await Heic2any({
      blob: file,
      toType: 'image/jpeg',
      quality: 1
    })

    return new File(
      [convertedBlob],
      file.name.substring(0, file.name.lastIndexOf('.')) + '.jpg',
      { type: 'image/jpeg' }
    )
  }
}
