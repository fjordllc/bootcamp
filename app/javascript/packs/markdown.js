import TextareaMarkdown from 'textarea-markdown'

document.addEventListener('DOMContentLoaded', () => {
  const meta = document.querySelector("meta[name=\"csrf-token\"]");
  const token = meta ? meta.content : '';

  Array.from(document.querySelectorAll('.js-markdown'), (textarea) => {
    new TextareaMarkdown(textarea, {
      endPoint: '/api/image.json',
      paramName: 'file',
      responseKey: 'url',
      csrfToken: token,
      placeholder: '%filenameをアップロード中...'
    })
  });
});
