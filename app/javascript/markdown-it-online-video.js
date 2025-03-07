import MarkdownItVideo from 'markdown-it-video'

export default (md) => {
  md.use(MarkdownItVideo, {
    vimeo: { width: 800, height: 450 }
  })
}
