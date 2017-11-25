import marked from "marked"

document.addEventListener('DOMContentLoaded', () => {
  [].forEach.call(document.querySelectorAll('.js-marked'), (e) => {
    e.style.display = 'block';
    e.innerHTML = marked(e.innerHTML, {
      breaks: true
    });
  });
});
