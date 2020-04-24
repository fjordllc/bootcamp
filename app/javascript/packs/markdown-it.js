import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItMention from './markdown-it-mention'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import hljs from 'highlight.js'

document.addEventListener('DOMContentLoaded', () => {
  const md = new MarkdownIt({
    html: true,
    breaks: true,
    linkify: true,
    langPrefix: 'lng-',
    highlight: (str, lang) => {
      if (lang && hljs.getLanguage(lang)) {
        try {
          return hljs.highlight(lang, str).value
        } catch (__) {}
      }

      return ''
    }
  })

  md.use(MarkdownItEmoji).use(MarkdownItMention).use(MarkdownItTaskLists)

  Array.from(document.querySelectorAll('.js-markdown-view'), e => {
    e.style.display = 'block'
    e.innerHTML = md.render(e.textContent)
  })
})
