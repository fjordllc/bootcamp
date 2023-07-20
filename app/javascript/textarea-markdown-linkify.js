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
          const newText =
            textarea.value.slice(0, selectionStart) +
            markdownLink +
            textarea.value.slice(selectionEnd)
          textarea.value = newText
          textarea.setSelectionRange(
            selectionStart + markdownLink.length,
            selectionStart + markdownLink.length
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
