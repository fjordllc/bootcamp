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
import ReplaceLinkToCard from 'replace-link-to-card'
import MarkDownItContainerFigure from 'markdown-it-container-figure'
import MarkdownItPurifier from 'markdown-it-purifier'
import MarkdownInitializer from 'markdown-initializer'

export default class {
  static initialize(selector) {
    const textareas = document.querySelectorAll(selector)
    if (!textareas.length) return

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

      textareas.forEach((textarea) => {
        if (!textarea.dataset.tribute) {
          tribute.attach(textarea)
          textarea.dataset.tribute = 'true'
        }
      })
    })

    // markdown
    Array.from(textareas).forEach((textarea) => {
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
          
          // Process video embeds in preview - find preview element within local scope
          let previewElement = null
          
          // First, try to find preview element within the immediate parent structure
          const markdownParent = textarea.closest('.js-markdown-parent') || textarea.closest('.markdown-form')
          if (markdownParent) {
            previewElement = markdownParent.querySelector('.js-preview, .markdown-form__preview')
          }
          
          // If not found, try within form scope
          if (!previewElement) {
            const form = textarea.closest('form') || textarea.closest('.form')
            if (form) {
              const possibleSelectors = ['.js-preview', '.markdown-form__preview']
              for (const selector of possibleSelectors) {
                previewElement = form.querySelector(selector)
                if (previewElement) break
              }
            }
          }
          
          // Final fallback to nearest container
          if (!previewElement) {
            const container = textarea.parentElement
            if (container) {
              previewElement = container.querySelector('.js-preview, .markdown-form__preview')
            }
          }
          
          // Process video embeds if preview element found and content contains video URLs
          if (previewElement && (
            textarea.value.includes('player.vimeo.com') || 
            textarea.value.includes('vimeo.com/') ||
            textarea.value.includes('youtube.com/embed') ||
            textarea.value.includes('youtu.be/') ||
            textarea.value.includes('youtube-nocookie.com/embed')
          )) {
            const markdownInitializer = new MarkdownInitializer()
            markdownInitializer.processVideoEmbedsInElement(previewElement, textarea.value)
          }

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
          MarkdownItTaskLists,
          MarkDownItContainerMessage,
          MarkDownItContainerDetails,
          MarkDownItLinkAttributes,
          MarkDownItContainerSpeak,
          MarkDownItContainerFigure,
          MarkdownItPurifier
        ],
        markdownOptions: MarkdownOption
      })
      /* eslint-enable no-new */
    })

    // user-icon
    new UserIconRenderer().render(selector)

    // Convert selected text to markdown link on URL paste
    new TextareaMarkdownLinkify().linkify(selector)

    ReplaceLinkToCard(selector)
  }

  static uninitialize(selector) {
    const textareas = document.querySelectorAll(selector)
    textareas.forEach((textarea) => {
      const cloneTextarea = textarea.cloneNode(true)
      textarea.parentNode.replaceChild(cloneTextarea, textarea)
    })
  }
}
