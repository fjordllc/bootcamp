export default function (md) {
  const defaultRender = md.renderer.rules.image

  md.renderer.rules.image = function (tokens, idx, options, env, self) {
    if (tokens.some(token => token.type === 'link_open')) {
      return defaultRender(tokens, idx, options, env, self)
    }

    const imageToken = tokens[idx]
    const imageIndex = imageToken.attrIndex('src')
    const imageUrl = imageToken.attrs[imageIndex][1]
    const alt = md.utils.escapeHtml(imageToken.content)
    return `<a href='${imageUrl}' target='_blank' rel='noopener noreferrer'><img src='${imageUrl}' alt='${alt}'></a>`
  }
}
