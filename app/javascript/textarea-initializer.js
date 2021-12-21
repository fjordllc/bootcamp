import Tribute from 'tributejs'
import TextareaAutocomplteEmoji from './textarea-autocomplte-emoji'
import TextareaAutocomplteMention from './textarea-autocomplte-mention'
import TextareaMarkdown from 'textarea-markdown'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from './markdown-it-mention'
import MarkdownItUserIcon from './markdown-it-user-icon'
import MarkdownOption from './markdown-it-option'
import UserIconRenderer from './user-icon-renderer'
import autosize from 'autosize'

export default class {
  static initialize(selector) {
    const meta = document.querySelector('meta[name="csrf-token"]')
    const token = meta ? meta.content : ''
    const textareas = document.querySelectorAll(selector)
    if (textareas.length === 0) {
      return null
    }

    // autosize
    autosize(textareas)
    textareas.forEach((textarea) => {
      new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (entry.target.scrollHeight !== 0) {
            autosize.update(entry.target)
          }
        })
      }).observe(textarea)
    })

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
      tribute.attach(textareas)
    })

    // markdown
    Array.from(textareas).forEach((textarea) => {
      /* eslint-disable no-new */
      new TextareaMarkdown(textarea, {
          endPoint: '/api/image.json',
          paramName: 'file',
          responseKey: 'url',
          csrfToken: token,
          placeholder: '%filenameをアップロード中...',
          afterPreview: () => {
            autosize.update(textarea)

            const event = new Event('input', {
              bubbles: true,
              cancelable: true
            })
            textarea.dispatchEvent(event)
          },
          plugins: [
            MarkdownItEmoji,
            MarkdownItMention,
            MarkdownItUserIcon,
            MarkdownItTaskLists
          ],
          markdownOptions: MarkdownOption
        })
        /* eslint-enable no-new */
    })

    // user-icon
    new UserIconRenderer().render(selector)
  }

  static uninitialize(selector) {
    const textareas = document.querySelectorAll(selector)
    textareas.forEach((textarea) => {
      const cloneTextarea = textarea.cloneNode(true)
      textarea.parentNode.replaceChild(cloneTextarea, textarea)
    })
  }
}