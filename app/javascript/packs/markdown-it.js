import MarkdownIt from 'markdown-it'

document.addEventListener('DOMContentLoaded', () => {
  let md = new MarkdownIt({
    html: true,
    breaks: true,
    langPrefix: true,
    linkify: true,
    langPrefix: 'language-'
  });

  [].forEach.call(document.querySelectorAll('.js-markdown'), (e) => {
    e.style.display = 'block';
    e.innerHTML =  md.render(e.innerHTML);
  });
});
