document.addEventListener('turbolinks:load', () => {
  if (!document.querySelector('body.welcome')) {
    window.Prism.highlightAll()
  }
})
