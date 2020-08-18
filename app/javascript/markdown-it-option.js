import MarkdownIt from 'markdown-it'
import Prism from 'prismjs'
import './prism-languages'

export default {
  html: true,
  breaks: true,
  langPrefix: 'language-',
  linkify: true,
  highlight: (str, lang) => {
    if (lang) {
      let langObject = Prism.languages[lang]
      try {
        return (
          `<pre class="language-${lang}"><code>` +
          Prism.highlight(str, langObject, lang) +
          '</code></pre>'
        )
      } catch (_) { }
    }
    const m = new MarkdownIt()
    return `<pre class="language-${lang}"><code>` + m.utils.escapeHtml(str) + '</code></pre>'
  }
}
