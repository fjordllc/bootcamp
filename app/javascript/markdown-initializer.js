import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from './markdown-it-mention.js'
import MarkdownItUserIcon from './markdown-it-user-icon.js'
import MarkdownItLinkingImage from './markdown-it-linking-image.js'
import MarkdownOption from './markdown-it-option.js'
import MarkdownItTaskListsInitializer from './markdown-it-task-lists-initializer.js'
import MarkdownItHeadings from './markdown-it-headings.js'
import MarkDownItContainerMessage from './markdown-it-container-message.js'
import MarkDownItContainerDetails from './markdown-it-container-details.js'
import MarkDownItLinkAttributes from 'markdown-it-link-attributes'
import MarkDownItContainerSpeak from './markdown-it-container-speak.js'
import ReplaceLinkToCard from './replace-link-to-card.js'
import MarkDownItContainerFigure from 'markdown-it-container-figure'
import MarkdownItVimeo from './markdown-it-vimeo.js'
import MarkdownItYoutube from './markdown-it-youtube.js'

export default class {
  replace(selector) {
    const elements = document.querySelectorAll(selector)
    if (elements.length === 0) {
      return null
    }

    Array.from(elements).forEach((element) => {
      if (element.dataset.markdownInitialized === 'true') return

      element.dataset.markdownInitialized = 'true'
      element.style.display = 'block'
      element.innerHTML = this.render(element.textContent)
    })

    MarkdownItTaskListsInitializer.initialize()
    ReplaceLinkToCard(selector)
  }

  render(text) {
    const md = new MarkdownIt(MarkdownOption)
    md.use(MarkdownItEmoji)
    md.use(MarkdownItMention)
    md.use(MarkdownItUserIcon)
    md.use(MarkdownItLinkingImage)
    md.use(MarkdownItTaskLists)
    md.use(MarkdownItHeadings)
    md.use(MarkDownItContainerMessage)
    md.use(MarkDownItContainerDetails)
    md.use(MarkDownItLinkAttributes, {
      matcher(href) {
        return !(
          href.startsWith(location.origin) ||
          href.startsWith('/') ||
          href.startsWith('#')
        )
      },
      attrs: {
        target: '_blank',
        rel: 'noopener'
      }
    })
    md.use(MarkDownItContainerSpeak)
    md.use(MarkDownItContainerFigure)
    md.use(MarkdownItVimeo)
    md.use(MarkdownItYoutube)
    return md.render(text)
  }
}
