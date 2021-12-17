import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from './markdown-it-mention'
import MarkdownItUserIcon from './markdown-it-user-icon'
import MarkdownItLinkingImage from './markdown-it-linking-image'
import MarkdownOption from './markdown-it-option'
import UserIconRenderer from './user-icon-renderer'
import MarkdownItTaskListsInitializer from './markdown-it-task-lists-initializer'
import MarkdownItHeadings, {
  initMarkdownItHeadings
} from './markdown-it-headings'

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

<<<<<<< HEAD
    MarkdownItTaskListsInitializer.initialize()
=======
    initMarkdownItHeadings()
>>>>>>> d3c3d4bae (マックダウンの見出しにanchorを入れる)
  }

  render(text) {
    const md = new MarkdownIt(MarkdownOption)
    md.use(MarkdownItEmoji)
    md.use(MarkdownItMention)
    md.use(MarkdownItUserIcon)
    md.use(MarkdownItLinkingImage)
    md.use(MarkdownItTaskLists)
    md.use(MarkdownItHeadings)

    return md.render(text)
  }
}
