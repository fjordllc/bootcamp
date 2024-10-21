export default (md, _options) => {
  md.inline.ruler.after('text', 'link-to-card', (state, silent) => {
    const start = state.pos
    const end = state.posMax
    const content = state.src.slice(start, end)
    const match = content.match(/.*?@\[card\]\((.+?)\)/)
    if (!match) return false

    if (!silent) {
      const linkCardUrl = md.utils.escapeHtml(match[1])

      const tokenOpen = state.push('link_open', 'a', 1)
      tokenOpen.attrs = [
        ['href', linkCardUrl],
        ['class', 'before-replacement-link-card']
      ]

      const tokenText = state.push('text', '', 0)
      tokenText.content = 'リンクカード適用前'

      state.push('link_close', 'a', -1)
    }
    state.pos += match[0].length
    return true
  })
}
