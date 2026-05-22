import { initializeTextarea } from './lazy-markdown.js'

document.addEventListener('turbo:load', () => {
  setupTextarea()
})

function setupTextarea() {
  const selector = '.js-markdown'
  if (!document.querySelector(selector)) {
    return null
  }

  initializeTextarea(selector)
}

document.addEventListener('DOMContentLoaded', setupTextarea)
setupTextarea()
