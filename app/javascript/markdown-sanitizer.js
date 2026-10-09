import DOMPurify from 'dompurify'

// Reject srcdoc-bearing frames before DOMPurify removes the attribute, so an
// otherwise approved src cannot turn the whole frame into an allowed embed.
DOMPurify.addHook('uponSanitizeElement', (node) => {
  if (node.nodeName === 'IFRAME' && node.hasAttribute('srcdoc')) node.remove()
})

const isAllowedVideo = (src) => {
  try {
    const url = new URL(src)
    if (url.protocol !== 'https:' || url.username || url.password || url.port) {
      return false
    }

    return (
      (['www.youtube.com', 'youtube.com'].includes(url.hostname) &&
        /^\/embed\/[a-zA-Z0-9_-]+$/.test(url.pathname)) ||
      (url.hostname === 'player.vimeo.com' &&
        /^\/video\/\d+$/.test(url.pathname))
    )
  } catch (_) {
    return false
  }
}

export default (html) => {
  const fragment = DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true },
    ADD_TAGS: ['iframe'],
    ADD_ATTR: ['target', 'allow', 'allowfullscreen', 'frameborder'],
    FORBID_TAGS: ['script', 'style', 'form'],
    FORBID_ATTR: ['srcdoc'],
    RETURN_DOM_FRAGMENT: true
  })

  // Only remove from the sanitized fragment; never add markup after sanitizing.
  fragment.querySelectorAll('iframe').forEach((frame) => {
    if (!isAllowedVideo(frame.getAttribute('src'))) frame.remove()
  })
  fragment.querySelectorAll('input').forEach((input) => {
    if (
      input.type !== 'checkbox' ||
      !input.classList.contains('task-list-item-checkbox')
    ) {
      input.remove()
    }
  })

  const container = document.createElement('div')
  container.appendChild(fragment)
  return container.innerHTML
}
