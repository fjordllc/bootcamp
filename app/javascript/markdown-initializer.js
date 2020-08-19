import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from './markdown-it-mention'
import MarkdownOption from './markdown-it-option'

export default class {
  replace (selector) {
    const elements = document.querySelectorAll(selector)
    if (elements.length === 0) { return null }

    Array.from(elements).forEach((element) => {
      element.style.display = 'block'
      element.innerHTML = this.render(element.textContent)
    })
  }

  render (text) {
    const md = new MarkdownIt(MarkdownOption)
    md.use(MarkdownItEmoji)
    md.use(MarkdownItMention)
    md.use(MarkdownItTaskLists)

    return md.render(text)
  }
}
