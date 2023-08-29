import MarkdownIt from 'markdown-it'

export default class {
  linkify(selector) {
    const textareas = document.querySelectorAll(selector)
    if (textareas.length === 0) {
      return null
    }

    Array.from(textareas).forEach((textarea) => {
      textarea.addEventListener('paste', async (event) => {
        event.preventDefault()
        const selectionStart = textarea.selectionStart
        const selectionEnd = textarea.selectionEnd
        const selectedText = textarea.value.slice(selectionStart, selectionEnd)
        const pasteText =
          event.clipboardData.getData('text') ||
          (await navigator.clipboard.readText())
        if (selectedText && this._isURL(pasteText)) {
          const markdownLink = `[${selectedText}](${pasteText})`
          document.execCommand('insertText', false, markdownLink)
        } else {
          document.execCommand('insertText', false, pasteText)
        }
      })
    })
  }

  _isURL(str) {
    const md = new MarkdownIt()
    return md.linkify.match(str)?.[0].url === str
  }
}
