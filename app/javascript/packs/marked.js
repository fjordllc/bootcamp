import marked from "marked"

document.addEventListener('DOMContentLoaded', () => {
  Array.from(document.querySelectorAll('.js-marked'), (e) => {
    e.innerHTML = marked(e.innerHTML, { breaks: true });
  });
});
