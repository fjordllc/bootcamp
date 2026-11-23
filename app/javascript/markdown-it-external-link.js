import MarkdownItLinkAttributes from 'markdown-it-link-attributes'

export default (md) => {
  md.use(MarkdownItLinkAttributes, {
    matcher(href) {
      return !(
        href.startsWith(location.origin) ||
        href.startsWith('/') ||
        href.startsWith('#')
      )
    },
    attrs: {
      target: '_blank',
      rel: 'noopener'
    }
  })
}
