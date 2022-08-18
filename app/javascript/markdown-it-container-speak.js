import MarkdownItContainer from 'markdown-it-container'

export default (md) => {
  md.use(MarkdownItContainer, 'speak', {
    render: (tokens, idx) => {
      const speakerName = escapeHTML(tokens[idx].info)
        .replace('speak @', '')
        .trim()

      if (tokens[idx].nesting === 1) {
        return `<div class="speak">
                  <div class="speak__speaker">
                    <a href="/users/${speakerName}" class="a-user-emoji-link">
                      <img class="js-user-icon a-user-emoji" data-user="${speakerName}">
                      <spanv class="speak__speaker-name">${speakerName}</span>
                    </a>
                  </div>
                  <div class="speak__body">`
      } else {
        return '</div></div>\n'
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
