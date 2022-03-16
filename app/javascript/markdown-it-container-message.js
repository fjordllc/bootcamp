import MarkdownItContainer from 'markdown-it-container'

export default function (md) {
  return MarkdownItContainer(md, 'message')
}
