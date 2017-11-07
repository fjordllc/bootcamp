import marked from "marked"

document.addEventListener('DOMContentLoaded', () => {
  const elements = document.querySelectorAll('.js-marked');
  if (elements) {
    for (let i = 0; i < elements.length; i++) {
      const element = elements[i];
      element.innerHTML = marked(element.innerHTML, { breaks: true });
    }
  }
});
