import { initializeTextarea } from './lazy-markdown.js'

document.addEventListener('turbo:load', () => {
  const selector = '.js-markdown'
  if (!document.querySelector(selector)) {
    return null
  }

  initializeTextarea(selector)
})
