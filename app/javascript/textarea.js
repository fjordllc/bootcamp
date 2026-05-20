import TextareaInitializer from './textarea-initializer.js'

document.addEventListener('turbo:load', () => {
  const selector = '.js-markdown'
  if (!selector) {
    return null
  }

  TextareaInitializer.initialize(selector)
})
