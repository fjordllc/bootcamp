import TextareaInitializer from './textarea-initializer'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '.js-markdown'
  if (!selector) {
    return null
  }

  TextareaInitializer.initialize(selector)
})
