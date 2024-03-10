import TextareaMarkdown from 'textarea-markdown'
import { filesize } from 'filesize'
import FileType from 'file-type/browser'

export default class TextareaMarkdownToHtml extends TextareaMarkdown {
  constructor(textarea, options = {}) {
    super(textarea, options)
  }

  upload(file) {
    const reader = new FileReader()
    reader.readAsArrayBuffer(file)
    reader.onload = async () => {
      const bytes = new Uint8Array(reader.result)
      const fileType = await FileType.fromBuffer(bytes)
      const fileSize = filesize(file.size, { base: 10, standard: 'jedec' })
      const text =
        '![' + this.options.placeholder.replace(/%filename/, file.name) + ']()'

      const beforeRange = this.textarea.selectionStart
      const beforeText = this.textarea.value.substring(0, beforeRange)
      const afterText = this.textarea.value.substring(
        beforeRange,
        this.textarea.value.length
      )
      this.textarea.value = `${beforeText}\n${text}\n${afterText}`

      const params = new FormData()
      params.append(this.options.paramName, file)

      const headers = { 'X-Requested-With': 'XMLHttpRequest' }
      if (this.options.csrfToken) {
        headers['X-CSRF-Token'] = this.options.csrfToken
      }

      fetch(this.options.endPoint, {
        method: 'POST',
        headers: headers,
        credentials: 'same-origin',
        body: params
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          const responseKey = this.options.responseKey
          const url = json[responseKey]
          if (this.options.imageableExtensions.includes(fileType.ext)) {
            const uploadTag = this.options.uploadImageTag
              .replace(/%filename/, file.name)
              .replace(/%url/, url)
            this.textarea.value = this.textarea.value.replace(text, uploadTag)
          } else if (this.options.videoExtensions.includes(fileType.ext)) {
            const uploadTag = this.options.uploadVideoTag
              .replace(/%filename/, file.name)
              .replace(/%url/, url)
            this.textarea.value = this.textarea.value.replace(text, uploadTag)
          } else {
            const uploadTag = this.options.uploadOtherTag
              .replace(/%filename/, file.name)
              .replace(/%url/, url)
              .replace(/%fileSize/, fileSize)
            this.textarea.value = this.textarea.value.replace(text, uploadTag)
          }

          this.applyPreview()
        })
        .catch((error) => {
          this.textarea.value = this.textarea.value.replace(text, '')
          console.warn('parsing failed', error)
        })
    }
  }
}
