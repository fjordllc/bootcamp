export default (md) => {
  const escapeTags = ['style']
  const escapeAttributes = ['onload']

  md.core.ruler.push('escape', function (state) {
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

  doc.querySelectorAll('*').forEach((element) => {
    if (shouldEscape(element, escapeTags, escapeAttributes)) {
      element.replaceWith(doc.createTextNode(element.outerHTML))
    }
  })

  return doc.body.innerHTML
}

function shouldEscape(element, escapeTags, escapeAttributes) {
  const tag = element.tagName.toLowerCase()
  const isDangerousTag = escapeTags.includes(tag)

  const hasDangerousAttribute = [...element.attributes].some((attr) => {
    const attrName = attr.name.toLowerCase()
    return escapeAttributes.includes(attrName)
  })

  return isDangerousTag || hasDangerousAttribute
}
