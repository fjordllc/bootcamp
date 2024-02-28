import Tribute from 'tributejs'
import TextareaAutocomplteEmoji from 'textarea-autocomplte-emoji'
import TextareaAutocomplteMention from 'textarea-autocomplte-mention'
import TextareaMarkdown from 'textarea-markdown'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from 'markdown-it-mention'
import MarkdownItUserIcon from 'markdown-it-user-icon'
import MarkdownOption from 'markdown-it-option'
import UserIconRenderer from 'user-icon-renderer'
import autosize from 'autosize'
import MarkDownItContainerMessage from 'markdown-it-container-message'
import MarkDownItContainerDetails from 'markdown-it-container-details'
import MarkDownItLinkAttributes from 'markdown-it-link-attributes'
import MarkDownItContainerSpeak from 'markdown-it-container-speak'
import CSRF from 'csrf'
import TextareaMarkdownLinkify from 'textarea-markdown-linkify'

export default class {
  static initialize(element) {
    if (!element) return
    // autosize
    autosize(element)
    new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.target.scrollHeight !== 0) {
          autosize.update(entry.target)
        }
      })
    }).observe(element)

    // auto-completion
    const emoji = new TextareaAutocomplteEmoji()
    const mention = new TextareaAutocomplteMention()

    mention.fetchValues((json) => {
      emoji.addUserData(json)
      mention.values = json
      mention.values.unshift({ login_name: 'mentor', name: 'メンター' })
      const collection = [emoji.params(), mention.params()]
      const tribute = new Tribute({
        collection: collection
      })
      tribute.attach(element)
    })

    // markdown
    /* eslint-disable no-new */
    new TextareaMarkdown(element, {
      endPoint: '/api/image.json',
      paramName: 'file',
      responseKey: 'url',
      csrfToken: CSRF.getToken(),
      placeholder: '%filenameをアップロード中...',
      afterPreview: () => {
        autosize.update(element)

        const event = new Event('input', {
          bubbles: true,
          cancelable: true
        })
        element.dispatchEvent(event)
      },
      plugins: [
        MarkdownItEmoji,
        MarkdownItMention,
        MarkdownItUserIcon,
        MarkdownItTaskLists,
        MarkDownItContainerMessage,
        MarkDownItContainerDetails,
        MarkDownItLinkAttributes,
        MarkDownItContainerSpeak
      ],
      markdownOptions: MarkdownOption
    })
    /* eslint-enable no-new */

    // user-icon
    new UserIconRenderer(element).render()

    // Convert selected text to markdown link on URL paste
    new TextareaMarkdownLinkify(element).linkify()
  }

  uninitialize(element) {
    const cloneTextarea = element.cloneNode(true)
    element.parentNode.replaceChild(cloneTextarea, element)
  }
}
