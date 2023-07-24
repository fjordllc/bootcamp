import MarkdownIt from 'markdown-it'

export default class {
  linkify(selector) {
    const textareas = document.querySelectorAll(selector)
    if (textareas.length === 0) {
      return null
    }

    Array.from(textareas).forEach((textarea) => {
      textarea.addEventListener('paste', (event) => {
        const pasteText = event.clipboardData.getData('text')
        const selectedText = window.getSelection().toString()
        if (selectedText && this._isURL(pasteText)) {
          event.preventDefault()
          const markdownLink = `[${selectedText}](${pasteText})`
          const selectionStart = textarea.selectionStart
          const selectionEnd = textarea.selectionEnd
          textarea.setRangeText(
            markdownLink,
            selectionStart,
            selectionEnd,
            'end'
          )
        }
      })
    })
  }

  _isURL(str) {
    const md = new MarkdownIt()
    return md.linkify.match(str)?.[0].url === str
  }
}
