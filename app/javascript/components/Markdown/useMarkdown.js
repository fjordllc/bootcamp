import { useState } from 'react'
import MarkdownInitializer from '../../markdown-initializer'

const md = new MarkdownInitializer()

/**
 * MarkdowItによってmarkdownをHTMLへと変換するreact hookです
 */
export const useMarkdown = () => {
  // 何も処理していないmarkdown側のテキスト
  const [markdownText, setMarkDownText] = useState("")
  // markdownをhtmlへと変換したテキスト
  const [renderedHTML, setRenderedHTML] = useState("")

  // textareなどでの入力に伴いmarkdown・htmlテキストを更新するハンドラー
  const handleTextInput = (e) => {
    setMarkDownText(e.target.value)
    const renderedHTML = md.render(e.target.value)
    setRenderedHTML(renderedHTML)
  }

  return { markdownText, renderedHTML, handleTextInput }
}
