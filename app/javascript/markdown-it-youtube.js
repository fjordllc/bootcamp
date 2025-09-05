import MarkdownItRegexp from 'markdown-it-regexp'

const youtubeRegexp = /\[youtube:([a-zA-Z0-9_-]+)\]/

export default MarkdownItRegexp(youtubeRegexp, (match) => {
  const videoId = match[1]

  // Basic validation - ensure it's a valid YouTube video ID format
  if (!/^[a-zA-Z0-9_-]+$/.test(videoId)) {
    return match[0] // Return original text if invalid
  }

  return `<iframe width="889" height="500" src="https://www.youtube.com/embed/${videoId}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`
})
