export default (md, _options) => {
  md.block.ruler.before(
    'paragraph',
    'link-to-card',
    (state, startLine, _endLine, silent) => {
      const content = state.src
        .slice(state.bMarks[startLine], state.eMarks[startLine])
        .trim()

      const match = content.match(/^@\[card\]\((.+?)\)/)
      if (!match) return false

      if (silent) return true

      const linkCardUrl = md.utils.escapeHtml(match[1])

      const token = state.push('html_block', '', 0)
      token.content = `
        <div class="a-link-card before-replacement-link-card" data-url="${linkCardUrl}">
          <p>リンクカード適用中... <i class="fa-regular fa-loader fa-spin"></i></p>
        </div>
      `

      const remainingText = content.slice(match[0].length).trim()

      if (remainingText) {
        const textToken = state.push('inline', '', 0)
        textToken.content = remainingText
      }

      state.line = startLine + 1
      return true
    }
  )
}
