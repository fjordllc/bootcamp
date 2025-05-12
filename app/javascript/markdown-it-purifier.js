import DOMPurify from 'dompurify';

function dompurifyPlugin(md, options = {}) {
  md.core.ruler.push('sanitize_all', function (state) {
    state.tokens.forEach(token => {
      if (token.type === 'html_block') {
        token.content = DOMPurify.sanitize(token.content, options)
      }

      if (token.type === 'inline' && token.children) {
        const sanitizedChildren = []
        let buffer = ''
        let inHtmlBlock = false

        token.children.forEach(child => {
          const isStartTag = /^<[^/][^>]*>$/.test(child.content)
          const isEndTag   = /^<\/[^>]+>$/.test(child.content)

          if (inHtmlBlock) {
            buffer += child.content;

            if (isEndTag) {
              sanitizedChildren.push({
                type: 'html_inline',
                content: DOMPurify.sanitize(buffer, options),
                level: child.level
              })
              buffer = ''
              inHtmlBlock = false
            }

          } else {
            if (isStartTag) {
              inHtmlBlock = true
              buffer += child.content

            } else if (child.type === 'html_inline') {
              sanitizedChildren.push({
                type: 'html_inline',
                content: DOMPurify.sanitize(child.content, options),
                level: child.level
              })

            } else {
              sanitizedChildren.push(child)
            }
          }
        })

        if (buffer.length > 0) {
          sanitizedChildren.push({
            type: 'html_inline',
            content: DOMPurify.sanitize(buffer, options),
            level: 0
          });
        }

        token.children = sanitizedChildren;
      }
    })
  })
}

export default dompurifyPlugin;
