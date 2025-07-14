import MarkdownItContainer from 'markdown-it-container'
import escapeHTML from './escapeHtml.js'

export default (md) => {
  md.use(MarkdownItContainer, 'speak', {
    marker: ':',
    validate: function (params) {
      return params.trim().match(/^speak(\s|$|(\s*\([^)]+\)\s*$))/)
    },
    render: (tokens, idx) => {
      const info = tokens[idx].info.trim()

      const parenMatch = info.match(/^speak\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)$/)

      if (parenMatch) {
        const speakerName = escapeHTML(parenMatch[1].trim())
        const avatarUrl = parenMatch[2].trim()

        if (tokens[idx].nesting === 1) {
          return `<div class="speak">
                    <div class="speak__speaker">
                      <img src="${avatarUrl}" alt="${speakerName}" title="@${speakerName}" class="a-user-emoji speak__speaker-avatar">
                      <span class="speak__speaker-name">${speakerName}</span>
                    </div>
                    <div class="speak__body">`
        }
      } else {
        const speakerName = escapeHTML(info)
          .replace('speak @', '')
          .replace('speak', '')
          .trim()
          .replace(/^\*\*@?/, '')
          .replace(/\*\*$/, '')
          .trim()

        if (tokens[idx].nesting === 1) {
          if (info.includes('@')) {
            return `<div class="speak">
                      <div class="speak__speaker">
                        <a href="/users/${speakerName}" class="a-user-emoji-link">
                          <img title="@${speakerName}" class="js-user-icon a-user-emoji" data-user="${speakerName}">
                          <span class="speak__speaker-name">${speakerName}</span>
                        </a>
                      </div>
                      <div class="speak__body">`
          } else {
            return `<div class="speak">
                      <div class="speak__speaker">
                        <img src="/images/users/avatars/default.png" alt="${speakerName}" title="${speakerName}" class="a-user-emoji speak__speaker-avatar">
                        <span class="speak__speaker-name">${speakerName}</span>
                      </div>
                      <div class="speak__body">`
          }
        }
      }

      return '</div></div>\n'
    }
  })
}
