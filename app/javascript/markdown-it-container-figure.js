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
  removeFigureParagraph(md)
}

// figureブロックの中身からキャプションを抽出しfigcaptionタグで囲み、figureコンテンツを整形する
const buildFigureContent = (md) => {
  md.core.ruler.after('block', 'extracting_caption_from_figure', (state) => {
    let isInContainerFigure = false
    const figureIndexes = []

    state.tokens.forEach((token, i) => {
      if (token.type === 'container_figure_open') {
        isInContainerFigure = true
        figureIndexes.push(i)
      }
      if (isInContainerFigure && token.type === 'inline') {
        const linkedImageMatch = token.content.match(
          /<a [^>]+>\s*<img [^>]+>\s*<\/a>/
        )
        const linkedImageTag = linkedImageMatch ? linkedImageMatch[0] : ''
        const caption = token.content.replace(linkedImageTag, '').trim()
        token.content = `${linkedImageTag}${`<figcaption>${caption}</figcaption>`}`
      }
      if (token.type === 'container_figure_close') {
        isInContainerFigure = false
      }
    })

    return true
  })
}

// markdown-itが自動出力してしまうfigureタグ内のpタグを削除する
const removeFigureParagraph = (md) => {
  let isInContainerFigure = false

  md.renderer.rules.container_figure_open = () => {
    isInContainerFigure = true
    return '<figure>'
  }

  md.renderer.rules.paragraph_open = (tokens, idx, options, env, self) =>
    isInContainerFigure ? '' : self.renderToken(tokens, idx, options, env)

  md.renderer.rules.paragraph_close = (tokens, idx, options, env, self) =>
    isInContainerFigure ? '' : self.renderToken(tokens, idx, options, env)

  md.renderer.rules.container_figure_close = () => {
    isInContainerFigure = false
    return '</figure>'
  }
}
