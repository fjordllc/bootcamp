import TextareaInitializer from 'textarea-initializer'

document.addEventListener('turbo:load', () => {
  const selector = '.js-markdown'
  if (!selector) {
    return null
  }

  TextareaInitializer.initialize(selector)
})
