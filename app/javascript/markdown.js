import { replaceMarkdown } from './lazy-markdown.js'

document.addEventListener('turbo:load', () => {
  setupMarkdown()
})

function setupMarkdown() {
  const selector = '.js-markdown-view'
  if (!document.querySelector(selector)) {
    return null
  }

  replaceMarkdown(selector)
}

document.addEventListener('DOMContentLoaded', setupMarkdown)
setupMarkdown()
