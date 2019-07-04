import MarkdownItRegexp from 'markdown-it-regexp'

export default MarkdownItRegexp(
  /@([a-zA-Z0-9_-]+)/,

  (match, _utils) => {
    return `<a href="/users/${match[1]}">${match[0]}</a>`
  }
)
