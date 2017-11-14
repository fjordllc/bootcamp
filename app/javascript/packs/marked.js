import marked from "marked"

document.addEventListener('DOMContentLoaded', () => {
  [].forEach.call(document.querySelectorAll('.js-marked'), (e) => {
    e.innerHTML = marked(e.innerHTML, { breaks: true });
  });
});
