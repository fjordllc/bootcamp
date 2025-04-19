import MarkdownItContainer from 'markdown-it-container'

export default (md) => {
  md.use(MarkdownItContainer, 'figure', {
    render: (tokens, idx) => {
      if (tokens[idx].nesting === 1) {
        return `<figure>`
      } else {
        return `</figure>`
      }
    }
  })

  buildFigureContent(md)
}

// figureブロックの中身からキャプションを抽出しfigcaptionタグで囲み、figureコンテンツを整形する
const buildFigureContent = (md) => {
  md.core.ruler.after('block', 'extracting_caption_from_figure', (state) => {
    let isInContainerFigure = false

    state.tokens.forEach((token, i) => {
      if (token.type === 'container_figure_open') {
        isInContainerFigure = true
      }
      if (isInContainerFigure && token.type === 'inline') {
        const matchedImageAndCaption = token.content.match(
          /^(<a [^>]+>\s*<img [^>]+>\s*<\/a>)([\s\S]*)$/
        )
        if (!matchedImageAndCaption) return

        const linkedImageTag = matchedImageAndCaption[1]
        const caption = matchedImageAndCaption[2].trim()
        token.content = `${linkedImageTag}<figcaption>${caption}</figcaption>`

        // markdown-itが自動出力してしまうfigureタグ内のpタグを出力しないようにする
        const pOpen = state.tokens[i - 1]
        const pClose = state.tokens[i + 1]
        pOpen.hidden = true
        pClose.hidden = true
      }
      if (token.type === 'container_figure_close') {
        isInContainerFigure = false
      }
    })

    return true
  })
}
