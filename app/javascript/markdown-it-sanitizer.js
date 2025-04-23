export default (md) => {
  const escapeTags = ['style']
  const escapeAttributes = ['onload']

  md.core.ruler.push('sanitize', function (state) {
    for (const token of state.tokens) {
      if (['html_block', 'html_inline'].includes(token.type)) {
        token.content = escapeHtmlContent(
          token.content,
          escapeTags,
          escapeAttributes
        )
      } else if (token.type === 'inline' && token.children) {
        for (const child of token.children) {
          child.content = escapeHtmlContent(
            child.content,
            escapeTags,
            escapeAttributes
          )
        }
      }
    }
  })
}

function escapeHtmlContent(html, escapeTags = [], escapeAttributes = []) {
  const parser = new DOMParser()
  const doc = parser.parseFromString(`<body>${html}</body>`, 'text/html')

  doc.querySelectorAll('*').forEach((el) => {
    if (shouldEscape(el, escapeTags, escapeAttributes)) {
      el.replaceWith(doc.createTextNode(el.outerHTML))
    }
  })

  return doc.body.innerHTML
}

function shouldEscape(el, escapeTags, escapeAttributes) {
  const tag = el.tagName.toLowerCase()
  const isDangerousTag = escapeTags.includes(tag)

  const hasDangerousAttribute = [...el.attributes].some((attr) => {
    const attrName = attr.name.toLowerCase()
    return escapeAttributes.includes(attrName)
  })

  return isDangerousTag || hasDangerousAttribute
}
