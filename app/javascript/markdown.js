import MarkdownInitializer from 'markdown-initializer'

document.addEventListener('turbo:load', () => {
  const selector = '.js-markdown-view'
  if (!selector) {
    return null
  }

  new MarkdownInitializer().replace('.js-markdown-view')
})
