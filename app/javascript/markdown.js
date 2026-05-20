import { replaceMarkdown } from './lazy-markdown.js'

document.addEventListener('turbo:load', () => {
  const selector = '.js-markdown-view'
  if (!document.querySelector(selector)) {
    return null
  }

  replaceMarkdown(selector)
})
