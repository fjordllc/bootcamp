import 'textarea-autosize/dist/jquery.textarea_autosize.min'

document.addEventListener('turbolinks:load', () => {
  $('textarea').textareaAutoSize()
})
