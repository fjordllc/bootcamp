import MarkdownIt from 'markdown-it'

export default class {
  linkify(selector) {
    const textareas = document.querySelectorAll(selector)

    Array.from(textareas).forEach((textarea) => {
      if (textarea.dataset.listenerAttached) return
      textarea.dataset.listenerAttached = 'true'

      textarea.addEventListener('paste', async (event) => {
        event.preventDefault()
        const { selectionStart, selectionEnd } = textarea
        const selectedText = textarea.value.slice(selectionStart, selectionEnd)
        const escapedSelectedText = selectedText.replace(/[[\]]/g, '\\$&')
        // headless chromeではevent.clipboardData.getData('text')は空文字を返すため、代わりにnavigator.clipboard.readText()を使用
        // https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325362833
        const clipboardText =
          event.clipboardData.getData('text') ||
          (await navigator.clipboard.readText())
        const textToInsert =
          escapedSelectedText && this._isURL(clipboardText)
            ? `[${escapedSelectedText}](${clipboardText})`
            : clipboardText
        document.execCommand('insertText', false, textToInsert)
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
