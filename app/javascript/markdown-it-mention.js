import MarkdownItRegexp from 'markdown-it-regexp'

export default MarkdownItRegexp(
  /@([a-zA-Z0-9_-]+)/,
  (match) =>
    `<a href="${
      match[0] === '@mentor' ? `/users?target=mentor` : `/users/${match[1]}`
    }">${match[0]}</a>`
)
