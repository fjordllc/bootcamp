import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from './markdown-it-mention'

export default class {
  replace (selector) {
    const elements = document.querySelectorAll(selector)
    if (elements.length === 0) { return null }

    Array.from(elements).forEach((element) => {
      element.innerHTML = this.render(element.innerHTML)
      element.style.display = 'block'
    })
  }

  render (text) {
    const md = new MarkdownIt({
      html: true,
      breaks: true,
      langPrefix: 'language-',
      linkify: true
    })

    md.use(MarkdownItEmoji)
    md.use(MarkdownItMention)
    md.use(MarkdownItTaskLists)

    return md.render(text)
  }
}
