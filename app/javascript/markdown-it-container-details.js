import MarkdownItContainer from 'markdown-it-container'

export default (md) => {
  md.use(MarkdownItContainer, 'details', {
    render: (tokens, idx) => {
      const detailsInfo = tokens[idx].info.trim().match(/^details\s+(.*)$/)
      const detailsTitle = detailsInfo ? `${detailsInfo[1]}` : ''
      if (tokens[idx].nesting === 1) {
        // opening tag
        return '<details><summary>' + escapeHTML(detailsTitle) + '</summary>\n'
      } else {
        // closing tag
        return '</details>\n'
      }
    }
  })
}

function escapeHTML(string) {
  return string
    .replace(/&/g, '&lt;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
}
