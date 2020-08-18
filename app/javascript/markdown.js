import MarkdownInitializer from './markdown-initializer'

document.addEventListener('DOMContentLoaded', () => {
  new MarkdownInitializer().replace('.js-markdown-view')
})
