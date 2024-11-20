export default (md, _options) => {
  md.core.ruler.after('replacements', 'link-to-card', function (state) {
    const tokens = state.tokens
    let allowLevel = 0
    for (let i = 0; i < tokens.length; i++) {
      const token = tokens[i]
      if (token.type === 'container_details_open') {
        allowLevel++
        continue
      }
      if (token.type === 'container_details_close' && allowLevel > 0) {
        allowLevel--
        continue
      }
      // 親のp要素がマークダウンでネストしていない場合のみリンクカードを生成する(details以外)
      const sourceToken = tokens[i - 1]
      const isParentRootParagraph =
        sourceToken &&
        sourceToken.type === 'paragraph_open' &&
        sourceToken.level === allowLevel
      if (!isParentRootParagraph) continue

      // 対象となるlinkはinlineTokenのchildrenにのみ存在する
      if (token.type !== 'inline') continue

      const children = token.children
      if (!children) continue

      // childrenにlinkが存在する場合のみリンクカードを生成する
      const hasLink = children?.some((child) => child.type === 'link_open')
      if (!hasLink) continue

      // childrenにbrが存在しない場合のみリンクカードを生成する
      const hasBr = children?.some((child) => child.type === 'softbreak')
      if (hasBr) continue

      const match = token.content.match(/^@\[card\]\((.+)\)$/)
      if (!match) continue

      const linkCardUrl = match[1]
      if (!isValidHttpUrl(linkCardUrl)) continue

      const linkCardToken = new state.Token('html_block', '', 0)
      linkCardToken.content = `
      <div class="a-link-card before-replacement-link-card" data-url="${md.utils.escapeHtml(
        linkCardUrl
      )}">
        <p>リンクカード適用中... <i class="fa-regular fa-loader fa-spin"></i></p>
      </div>
        `
      // tokens[i]の位置にpushしてしまうと、Tokenの配列として正しい形でなくなり、正しくないHTMLが出力されてしまう。
      // 正しいTokenの配列を保つために、一連のtoken(pOpen inline pClose)の後にpushしている
      tokens.splice(i + 2, 0, linkCardToken)

      sourceToken.attrJoin('style', 'display: none')
    }
    return true
  })
}

const isValidHttpUrl = (str) => {
  try {
    const url = new URL(str)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch (_) {
    return false
  }
}
