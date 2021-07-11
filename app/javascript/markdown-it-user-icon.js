import MarkdownItRegexp from 'markdown-it-regexp'

export default MarkdownItRegexp(
  /:@(?!mentor)([a-zA-Z0-9_-]+):/,

  (match) => {
    return `<a href="/users/${match[1]}"><img class="js-user-icon" data-user="${match[1]}" width="40" height="40" style="margin: 5px; display: inline-block"></a>`
  }
)
 