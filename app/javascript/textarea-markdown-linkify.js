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
        const { selectionStart, selectionEnd } = textarea
        const selectedText = textarea.value.slice(selectionStart, selectionEnd)
        // headless chromeではevent.clipboardData.getData('text')は空文字を返すため、代わりにnavigator.clipboard.readText()を使用
        // https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325362833
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

  // URLの判定にlinkify-itを使用している理由
  // https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325332666
  _isURL(str) {
    const md = new MarkdownIt()
    return md.linkify.match(str)?.[0].url === str
  }
}
