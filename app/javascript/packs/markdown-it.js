import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItMention from './markdown-it-mention'
import MarkdownItTaskLists from 'markdown-it-task-lists'

document.addEventListener('turbolinks:load', () => {
  const md = new MarkdownIt({
    html: true,
    breaks: true,
    linkify: true,
    langPrefix: 'language-'
  })

  md.use(MarkdownItEmoji).use(MarkdownItMention).use(MarkdownItTaskLists)

  Array.from(document.querySelectorAll('.js-markdown-view'), e => {
    e.style.display = 'block'
    e.innerHTML = md.render(e.textContent)
  })
})
