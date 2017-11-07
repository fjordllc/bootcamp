import marked from "marked"
import MarkdownEditor from '../markdown-editor'

document.addEventListener('DOMContentLoaded', () => {
  const textareas = document.querySelectorAll('.js-markdown');
  if (textareas) {
   for (let i = 0; i < textareas.length; i++) {
     new MarkdownEditor(textareas[i]);
   }
  }
  const preview = document.querySelector('.js-markdown-preview');
  if (preview) {
    textareas[0].addEventListener('keyup', () => {
      preview.innerHTML = marked(textareas[0].value, { breaks: true });
    })
  }
});
