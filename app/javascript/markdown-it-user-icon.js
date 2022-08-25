import MarkdownItRegexp from 'markdown-it-regexp'

export default MarkdownItRegexp(
  /:@(?!mentor:)([a-zA-Z0-9_-]+):/,

  (match) => {
    return `<a href="/users/${match[1]}" class="a-user-emoji-link"><img class="js-user-icon a-user-emoji" data-user="${match[1]}" width="40" height="40"></a>`
  }
)
