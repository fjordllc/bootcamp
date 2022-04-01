import MarkdownItContainer from 'markdown-it-container'

export default (md) => {
  md.use(MarkdownItContainer, 'message', {
    render: (tokens, idx) => {
      const messageInfo = tokens[idx].info
        .trim()
        .match(/^message\s+(alert|danger|warning|info|primary|success)$/)
      const messageName = messageInfo ? ` ${messageInfo[1]}` : ''
      if (tokens[idx].nesting === 1) {
        return `<div class="message${messageName}">\n`
      } else {
        return '</div>\n'
      }
    }
  })
}
