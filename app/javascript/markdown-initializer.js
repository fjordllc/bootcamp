import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from './markdown-it-mention'
import MarkdownItUserIcon from './markdown-it-user-icon'
import MarkdownItLinkingImage from './markdown-it-linking-image'
import MarkdownOption from './markdown-it-option'
import UserIconRenderer from './user-icon-renderer'

export default class {
  replace(selector) {
    const elements = document.querySelectorAll(selector)
    if (elements.length === 0) {
      return null
    }

    Array.from(elements).forEach((element) => {
      element.style.display = 'block'
      element.innerHTML = this.render(element.textContent)
    })

    new UserIconRenderer().render(selector)
  }

  render(text) {
    const md = new MarkdownIt(MarkdownOption)
    md.use(MarkdownItEmoji)
    md.use(MarkdownItMention)
    md.use(MarkdownItUserIcon)
    md.use(MarkdownItLinkingImage)
    md.use(MarkdownItTaskLists)

    return md.render(text)
  }
}
