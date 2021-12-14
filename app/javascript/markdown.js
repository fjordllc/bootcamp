import MarkdownInitializer from './markdown-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '.js-markdown-view'
  if (!selector) {
    return null
  }

  new MarkdownInitializer().replace('.js-markdown-view')
})
