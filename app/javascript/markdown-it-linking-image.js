export default function (md) {
  md.renderer.rules.image = function (tokens, idx, options, env, self) {
    const imageToken = tokens[idx]
    const imageIndex = imageToken.attrIndex('src')
    const imageUrl = imageToken.attrs[imageIndex][1]
    const alt = md.utils.escapeHtml(imageToken.content)
    const linkToken = tokens.find(token => token.type === 'link_open')
    let linkUrl = imageUrl

    if (linkToken) {
      const linkSrcIndex = linkToken.attrIndex('href')
      linkUrl = linkToken.attrs[linkSrcIndex][1]
    }

    return `<a href='${linkUrl}' target='_blank' rel='noopener noreferrer'><img src='${imageUrl}' alt='${alt}'></a>`
  }
}
