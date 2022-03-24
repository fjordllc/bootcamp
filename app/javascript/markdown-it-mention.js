import MarkdownItRegexp from 'markdown-it-regexp'

const mentionRegexp = /@([a-zA-Z0-9_-]+)/

export default MarkdownItRegexp(mentionRegexp, (match) => {
  if (match.input.includes('(http')) {
    const output = ('[' + match.input).match(
      /^\[([\w\s\d+&@]+)\]\((https?:\/\/[\w\d./?=#]+)\)$/
    )
    return output
      ? output[1].match(mentionRegexp)[0]
      : ('[' + match.input).match(mentionRegexp)[0]
  } else {
    return `<a href="${
      match[0] === '@mentor' ? `/users?target=mentor` : `/users/${match[1]}`
    }">${match[0]}</a>`
  }
})
