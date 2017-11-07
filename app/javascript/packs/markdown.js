import marked from "marked"
import MarkdownEditor from '../markdown-editor'

document.addEventListener('DOMContentLoaded', () => {
  const textareas = document.querySelectorAll('.js-markdown');
  if (textareas) {
    for (let i = 0; i < textareas.length; i++) {
      const textarea = textareas[i];
      const previewId = textarea.getAttribute('data-preview-id');
      new MarkdownEditor(textarea);
      if (previewId) {
        const preview = document.getElementById(previewId);
        if (preview) {
          preview.innerHTML = marked(textarea.value, { breaks: true });

          textarea.addEventListener('keyup', () => {
            preview.innerHTML = marked(textarea.value, { breaks: true });
          })
        }
      }
    }
  }
});
