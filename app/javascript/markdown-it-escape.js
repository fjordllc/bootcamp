import DOMPurify from 'dompurify';

function dompurifyPlugin(md, options = {}) {
  md.core.ruler.push('sanitize_all', function(state) {
    state.tokens.forEach(token => {
      if (token.type === 'html_block' || token.type === 'html_inline') {
        console.log(token)
        token.content = DOMPurify.sanitize(token.content, options)
      }
      if (token.type === 'inline' && token.children) {
        console.log(token.children)
        token.children.forEach(child => {
          if (child.type === 'html_inline') {
            child.content = DOMPurify.sanitize(child.content, options)
          }
        })
      }
    })
  })
}

export default dompurifyPlugin;
