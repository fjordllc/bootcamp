export default (md, _options) => {
  md.core.ruler.after('replacements', 'link-to-card', function (state) {
    const tokens = state.tokens
    let allowLevel = 0
    tokens.forEach((token, i) => {
      if (token.type === 'container_details_open') {
        allowLevel++
        return
      }
      if (token.type === 'container_details_close' && allowLevel > 0) {
        allowLevel--
        return
      }
      // 親のp要素がマークダウンでネストしていない場合のみリンクカードを生成する(details以外)
      const parentToken = tokens[i - 1]
      const isParentRootParagraph =
        parentToken &&
        parentToken.type === 'paragraph_open' &&
        parentToken.level === allowLevel
      if (!isParentRootParagraph) return

      // 対象となるlinkはinlineTokenのchildrenにのみ存在する
      if (token.type !== 'inline') return

      const children = token.children
      if (!children) return

      // childrenにlinkが存在する場合のみリンクカードを生成する
      const hasLink = children?.some((child) => child.type === 'link_open')
      if (!hasLink) return

      // childrenにbrが存在しない場合のみリンクカードを生成する
      const hasBr = children?.some((child) => child.type === 'softbreak')
      if (hasBr) return

      const match = token.content.match(/^@\[card\]\((.+?)\)/)
      if (!match) return

      const linkCardUrl = md.utils.escapeHtml(match[1])
      const linkCardToken = new state.Token('html_inline', '', 0)
      linkCardToken.content = `
            <div class="a-link-card before-replacement-link-card" data-url="${linkCardUrl}">
              <p>リンクカード適用中... <i class="fa-regular fa-loader fa-spin"></i></p>
            </div>
          `
      tokens[i] = linkCardToken
    })
    return true
  })
}
