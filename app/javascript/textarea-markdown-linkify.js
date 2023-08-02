import MarkdownIt from 'markdown-it'

export default class {
  linkify(selector) {
    const textareas = document.querySelectorAll(selector)
    if (textareas.length === 0) {
      return null
    }

    Array.from(textareas).forEach((textarea) => {
      textarea.addEventListener('paste', (event) => {
        const params = (new URL(document.location)).searchParams;
        // headless_chromeはクリップボードにアクセスできないため、GETパラメータの値を擬似的にクリップボードの値として扱う
        const pasteText = params.get('dummy_clipboard') || event.clipboardData.getData('text')
        const selectionStart = textarea.selectionStart
        const selectionEnd = textarea.selectionEnd
        const selectedText = textarea.value.slice(selectionStart, selectionEnd)
        if (selectedText && this._isURL(pasteText)) {
          event.preventDefault()
          const markdownLink = `[${selectedText}](${pasteText})`
          document.execCommand('insertText', false, markdownLink)
        }
      })
    })
  }

  _isURL(str) {
    const md = new MarkdownIt()
    return md.linkify.match(str)?.[0].url === str
  }
}
