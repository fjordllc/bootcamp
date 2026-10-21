import Tribute from 'tributejs'
import TextareaAutocomplteEmoji from 'textarea-autocomplte-emoji'
import TextareaAutocomplteMention from 'textarea-autocomplte-mention'
import TextareaMarkdownModule from 'textarea-markdown'
import { full as MarkdownItEmoji } from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from 'markdown-it-mention'
import MarkdownItWikiLink from 'markdown-it-wiki-link'
import MarkdownItUserIcon from 'markdown-it-user-icon'
import MarkdownOption from 'markdown-it-option'
import autosize from 'autosize'
import MarkDownItContainerMessage from 'markdown-it-container-message'
import MarkDownItContainerDetails from 'markdown-it-container-details'
import MarkDownItLinkAttributes from 'markdown-it-link-attributes'
import MarkDownItContainerSpeak from 'markdown-it-container-speak'
import CSRF from 'csrf'
import TextareaMarkdownLinkify from 'textarea-markdown-linkify'
import ReplaceLinkToCard from 'replace-link-to-card'
import MarkDownItContainerFigure from 'markdown-it-container-figure'
import MarkdownItVimeo from 'markdown-it-vimeo'
import MarkdownItYoutube from 'markdown-it-youtube'

const TextareaMarkdown =
  TextareaMarkdownModule.default?.default ||
  TextareaMarkdownModule.default ||
  TextareaMarkdownModule

const initializedMarkdown = new WeakSet()

export default class {
  static initialize(selector) {
    const textareas = document.querySelectorAll(selector)
    if (!textareas.length) return

    const loginName = document.body.dataset.loginName ?? ''

    if (loginName) {
      textareas.forEach((textarea) => {
        textarea.dataset.loginName = loginName
      })
    }

    let disconnected = false
    let tribute
    const observers = []

    // autosize
    autosize(textareas)
    textareas.forEach((textarea) => {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (entry.target.scrollHeight !== 0) {
            autosize.update(entry.target)
          }
        })
      })
      observer.observe(textarea)
      observers.push(observer)
    })

    // auto-completion
    const emoji = new TextareaAutocomplteEmoji()
    const mention = new TextareaAutocomplteMention()

    mention.fetchValues((json) => {
      if (disconnected) return
      emoji.addUserData(json)
      mention.values = json
      mention.values.unshift({ login_name: 'mentor', name: 'メンター' })
      const collection = [emoji.params(), mention.params()]
      tribute = new Tribute({
        collection
      })

      textareas.forEach((textarea) => {
        if (!textarea.dataset.tribute) {
          tribute.attach(textarea)
          textarea.dataset.tribute = 'true'
        }
      })
    })

    // markdown
    Array.from(textareas).forEach((textarea) => {
      if (initializedMarkdown.has(textarea)) return
      initializedMarkdown.add(textarea)
      delete textarea.dataset.tribute
      textarea.dataset.textareaMarkdownInitialized = 'true'
      /* eslint-disable no-new */
      new TextareaMarkdown(textarea, {
        endPoint: '/api/image.json',
        paramName: 'file',
        responseKey: 'url',
        csrfToken: CSRF.getToken(),
        placeholder: '%filenameをアップロード中...',
        uploadImageTag:
          '<a href="%url" target="_blank" rel="noopener noreferrer"><img src="%url" width="%width" height="%height" alt="%filename"></a>\n',
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
          MarkdownItWikiLink,
          MarkdownItUserIcon,
          MarkdownItTaskLists,
          MarkDownItContainerMessage,
          MarkDownItContainerDetails,
          MarkDownItLinkAttributes,
          MarkDownItContainerSpeak,
          MarkDownItContainerFigure,
          MarkdownItVimeo,
          MarkdownItYoutube
        ],
        markdownOptions: MarkdownOption
      })
      /* eslint-enable no-new */
    })

    // Convert selected text to markdown link on URL paste
    new TextareaMarkdownLinkify().linkify(selector)

    const cleanupLinkCards = ReplaceLinkToCard(selector)

    return () => {
      disconnected = true
      observers.forEach((observer) => observer.disconnect())
      autosize.destroy(textareas)
      textareas.forEach((textarea) => {
        if (tribute && textarea.dataset.tribute) {
          tribute.detach(textarea)
          delete textarea.dataset.tribute
        }
      })
      cleanupLinkCards?.()
    }
  }

  static uninitialize(selector) {
    const textareas = document.querySelectorAll(selector)
    textareas.forEach((textarea) => {
      const cloneTextarea = textarea.cloneNode(true)
      delete cloneTextarea.dataset.textareaMarkdownInitialized
      textarea.parentNode.replaceChild(cloneTextarea, textarea)
    })
  }
}
