import MarkdownItContainer from 'markdown-it-container'

export default (md) => {
  md.use(MarkdownItContainer, 'speak', {
    render: (tokens, idx) => {
      const speakerName = tokens[idx].info.trim().match(/@([a-zA-Z0-9-]*)$/)
      if (tokens[idx].nesting === 1) {
        return `<div class="speak"><div class="speak__speaker"><a href="/users/${speakerName[1]}" class="a-user-emoji-link"><img class="js-user-icon a-user-emoji" data-user="${speakerName[1]}" width="40" height="40"></a><div class="speak__body"></div>`
      } else {
        return '</div>\n'
      }
    }
  })
}