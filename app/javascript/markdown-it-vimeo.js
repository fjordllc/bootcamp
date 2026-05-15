import MarkdownItRegexp from 'markdown-it-regexp'

const vimeoRegexp = /\[vimeo:(\d+)\]/

export default MarkdownItRegexp(vimeoRegexp, (match) => {
  const videoId = match[1]

  // Basic validation - ensure it's a numeric video ID
  if (!/^\d+$/.test(videoId)) {
    return match[0] // Return original text if invalid
  }

  return `<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/${videoId}?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" style="position:absolute;top:0;left:0;width:100%;height:100%;" title="Vimeo video"></iframe></div>`
})
