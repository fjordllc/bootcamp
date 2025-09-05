import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItMention from 'markdown-it-mention'
import MarkdownItUserIcon from 'markdown-it-user-icon'
import MarkdownItLinkingImage from 'markdown-it-linking-image'
import MarkdownOption from 'markdown-it-option'
import UserIconRenderer from 'user-icon-renderer'
import MarkdownItTaskListsInitializer from 'markdown-it-task-lists-initializer'
import MarkdownItHeadings from 'markdown-it-headings'
import MarkDownItContainerMessage from 'markdown-it-container-message'
import MarkDownItContainerDetails from 'markdown-it-container-details'
import MarkDownItLinkAttributes from 'markdown-it-link-attributes'
import MarkDownItContainerSpeak from 'markdown-it-container-speak'
import MarkdownItPurifier from 'markdown-it-purifier'
import ReplaceLinkToCard from 'replace-link-to-card'
import MarkDownItContainerFigure from 'markdown-it-container-figure'

export default class {
  replace(selector) {
    const elements = document.querySelectorAll(selector)
    if (elements.length === 0) {
      return null
    }

    Array.from(elements).forEach((element) => {
      const originalText = element.textContent
      element.style.display = 'block'
      element.innerHTML = this.render(originalText)
      
      // Process video embeds for this specific element only
      this.processVideoEmbedsInElement(element, originalText)
    })

    new UserIconRenderer().render(selector)
    MarkdownItTaskListsInitializer.initialize()
    ReplaceLinkToCard(selector)
  }

  render(text) {
    const md = new MarkdownIt(MarkdownOption)
    md.use(MarkdownItEmoji)
    md.use(MarkdownItMention)
    md.use(MarkdownItUserIcon)
    md.use(MarkdownItLinkingImage)
    md.use(MarkdownItTaskLists)
    md.use(MarkdownItHeadings)
    md.use(MarkDownItContainerMessage)
    md.use(MarkDownItContainerDetails)
    md.use(MarkDownItLinkAttributes, {
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
    md.use(MarkDownItContainerSpeak)
    md.use(MarkDownItContainerFigure)
    md.use(MarkdownItPurifier)
    return md.render(text)
  }

  // Temporary method to support video embeds (Vimeo and YouTube)
  // TODO: Remove this when video upload system is implemented
  processVideoEmbedsInElement(element, originalText) {
    if (!originalText) return
    
    // Process Vimeo embeds
    this.processVimeoEmbeds(element, originalText)
    
    // Process YouTube embeds
    this.processYouTubeEmbeds(element, originalText)
  }
  
  processVimeoEmbeds(element, originalText) {
    // Early return if no Vimeo content
    if (!originalText.includes('player.vimeo.com') && !originalText.includes('vimeo.com/')) return
    
    // Idempotency check: if Vimeo iframes already exist, do nothing
    const existingVimeoIframes = element.querySelectorAll('iframe[src^="https://player.vimeo.com/"]')
    if (existingVimeoIframes.length > 0) return
    
    // Look for Vimeo video URLs in the original text to extract video ID
    const vimeoPlayerRegex = /https:\/\/player\.vimeo\.com\/video\/(\d+)/g
    const vimeoShortRegex = /https:\/\/vimeo\.com\/(\d+)/g
    
    const playerMatches = Array.from(originalText.matchAll(vimeoPlayerRegex), match => match[1])
    const shortMatches = Array.from(originalText.matchAll(vimeoShortRegex), match => match[1])
    
    const videoIds = [...new Set([...playerMatches, ...shortMatches])] // Remove duplicates
    
    if (videoIds.length === 0) return
    
    // First try to replace empty wrapper divs
    this.replaceEmptyDivsWithEmbeds(element, videoIds, 'vimeo')
    
    // If no wrapper divs found, create embeds directly for standalone iframes
    this.replaceVimeoTextWithEmbeds(element, originalText, videoIds)
  }
  
  processYouTubeEmbeds(element, originalText) {
    // Early return if no YouTube content
    if (!originalText.includes('youtube.com/embed') && 
        !originalText.includes('youtu.be/') && 
        !originalText.includes('youtube-nocookie.com/embed')) return
    
    // Idempotency check: if YouTube iframes already exist, do nothing
    const existingYouTubeIframes = element.querySelectorAll('iframe[src*="youtube"]')
    if (existingYouTubeIframes.length > 0) return
    
    // Look for YouTube video URLs in the original text to extract video ID
    // Enhanced regex to capture more YouTube URL variations
    const youtubeEmbedRegex = /https:\/\/(?:www\.)?youtube(?:-nocookie)?\.com\/embed\/([a-zA-Z0-9_-]+)/g
    const youtubeShortRegex = /https:\/\/youtu\.be\/([a-zA-Z0-9_-]+)/g
    const youtubeWatchRegex = /https:\/\/(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/g
    
    const embedMatches = Array.from(originalText.matchAll(youtubeEmbedRegex), match => match[1])
    const shortMatches = Array.from(originalText.matchAll(youtubeShortRegex), match => match[1])
    const watchMatches = Array.from(originalText.matchAll(youtubeWatchRegex), match => match[1])
    
    const videoIds = [...new Set([...embedMatches, ...shortMatches, ...watchMatches])] // Remove duplicates
    
    if (videoIds.length === 0) return
    
    // First try to replace empty wrapper divs
    this.replaceEmptyDivsWithEmbeds(element, videoIds, 'youtube')
    
    // If no wrapper divs found, look for standalone YouTube iframes that were sanitized
    // and replace any remaining text/links containing YouTube embed URLs
    this.replaceYouTubeTextWithEmbeds(element, originalText, videoIds)
  }
  
  replaceVimeoTextWithEmbeds(element, originalText, videoIds) {
    if (videoIds.length === 0) return
    
    // If we still haven't processed any Vimeo embeds, 
    // create embeds directly for each video ID found
    const currentVimeoIframes = element.querySelectorAll('iframe[src^="https://player.vimeo.com/"]')
    if (currentVimeoIframes.length === 0) {
      // Create embeds and append them to the element
      videoIds.forEach(videoId => {
        const safeEmbed = this.createSafeVimeoEmbed(videoId)
        const tempDiv = document.createElement('div')
        tempDiv.innerHTML = safeEmbed
        element.appendChild(tempDiv.firstChild)
      })
    }
  }
  
  replaceYouTubeTextWithEmbeds(element, originalText, videoIds) {
    if (videoIds.length === 0) return
    
    // If we still haven't processed any YouTube embeds, 
    // create embeds directly for each video ID found
    const currentYouTubeIframes = element.querySelectorAll('iframe[src*="youtube"]')
    if (currentYouTubeIframes.length === 0) {
      // Look for text nodes or links that contain YouTube URLs and replace them
      const walker = document.createTreeWalker(
        element,
        NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
        {
          acceptNode: function(node) {
            if (node.nodeType === Node.TEXT_NODE) {
              return node.textContent.includes('youtube.com/embed') ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP
            }
            if (node.nodeType === Node.ELEMENT_NODE && node.tagName === 'A') {
              const href = node.getAttribute('href') || ''
              return href.includes('youtube.com/embed') ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP
            }
            return NodeFilter.FILTER_SKIP
          }
        }
      )
      
      const nodesToReplace = []
      let node
      while (node = walker.nextNode()) {
        nodesToReplace.push(node)
      }
      
      // Replace nodes that contain YouTube URLs
      if (nodesToReplace.length > 0) {
        videoIds.forEach((videoId, index) => {
          if (index < nodesToReplace.length) {
            const nodeToReplace = nodesToReplace[index]
            const safeEmbed = this.createSafeYouTubeEmbed(videoId)
            const tempDiv = document.createElement('div')
            tempDiv.innerHTML = safeEmbed
            
            if (nodeToReplace.nodeType === Node.TEXT_NODE) {
              nodeToReplace.parentNode.replaceChild(tempDiv.firstChild, nodeToReplace)
            } else {
              nodeToReplace.replaceWith(tempDiv.firstChild)
            }
          }
        })
      } else {
        // Fallback: just append embeds to the element
        videoIds.forEach(videoId => {
          const safeEmbed = this.createSafeYouTubeEmbed(videoId)
          const tempDiv = document.createElement('div')
          tempDiv.innerHTML = safeEmbed
          element.appendChild(tempDiv.firstChild)
        })
      }
    }
  }
  
  replaceEmptyDivsWithEmbeds(element, videoIds, platform) {
    // Look for potential wrapper divs (more robust detection)
    const potentialWrapperDivs = Array.from(element.querySelectorAll('div')).filter(div => {
      // Skip if already has video iframes
      if (div.querySelector('iframe[src*="player.vimeo.com"], iframe[src*="youtube"]')) {
        return false
      }
      
      const style = div.getAttribute('style') || ''
      let computedStyle
      try {
        computedStyle = getComputedStyle(div)
      } catch (e) {
        // Fallback if getComputedStyle fails
        computedStyle = { position: '', paddingTop: '', paddingBottom: '' }
      }
      
      // Check for responsive padding (56.25% = 16:9 aspect ratio) - more flexible matching
      const paddingRegex = /padding(?:-(?:top|bottom))?[^:]*:\s*56\.25%/i
      const hasResponsivePadding = paddingRegex.test(style) ||
                                  computedStyle.paddingTop === '56.25%' ||
                                  computedStyle.paddingBottom === '56.25%' ||
                                  // Also check for common variations
                                  /padding[^:]*:\s*56\.25%\s+0\s+0\s+0/i.test(style)
      
      // Check for relative positioning - more flexible matching
      const positionRegex = /position[^:]*:\s*relative/i
      const hasRelativePosition = positionRegex.test(style) ||
                                 computedStyle.position === 'relative'
      
      // Check if empty or only contains text/whitespace (no iframe children)
      const hasNoIframes = div.querySelectorAll('iframe').length === 0
      const isEmpty = div.children.length === 0 || 
                      (div.textContent.trim() === '' && hasNoIframes) ||
                      // Also consider divs with only whitespace nodes
                      Array.from(div.childNodes).every(node => 
                        node.nodeType === Node.TEXT_NODE && node.textContent.trim() === '')
      
      return hasResponsivePadding && hasRelativePosition && isEmpty
    })
    
    if (potentialWrapperDivs.length > 0 && videoIds.length > 0) {
      // Replace empty responsive divs with video embeds
      potentialWrapperDivs.forEach((wrapperDiv, index) => {
        if (index < videoIds.length) {
          const videoId = videoIds[index]
          const safeEmbed = platform === 'vimeo' ? 
            this.createSafeVimeoEmbed(videoId) : 
            this.createSafeYouTubeEmbed(videoId)
          const tempDiv = document.createElement('div')
          tempDiv.innerHTML = safeEmbed
          wrapperDiv.replaceWith(tempDiv.firstChild)
        }
      })
    }
  }
  
  // Create a safe, controlled Vimeo embed with minimal allowed attributes
  createSafeVimeoEmbed(videoId) {
    // Validate video ID is numeric
    if (!/^\d+$/.test(videoId)) return ''
    
    const iframe = `<iframe 
      src="https://player.vimeo.com/video/${videoId}?badge=0&autopause=0" 
      frameborder="0" 
      allow="autoplay; fullscreen; picture-in-picture" 
      referrerpolicy="strict-origin-when-cross-origin" 
      style="position:absolute;top:0;left:0;width:100%;height:100%;"
      title="Vimeo video ${videoId}">
    </iframe>`
    
    return `<div style="padding:56.25% 0 0 0;position:relative;width:100%;height:0;">${iframe}</div>`
  }
  
  // Create a safe, controlled YouTube embed with minimal allowed attributes
  createSafeYouTubeEmbed(videoId) {
    // Validate video ID format (YouTube video IDs are 11 characters: letters, numbers, hyphens, underscores)
    if (!/^[a-zA-Z0-9_-]{11}$/.test(videoId)) return ''
    
    const iframe = `<iframe 
      src="https://www.youtube-nocookie.com/embed/${videoId}?rel=0&modestbranding=1" 
      frameborder="0" 
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
      referrerpolicy="strict-origin-when-cross-origin" 
      allowfullscreen
      style="position:absolute;top:0;left:0;width:100%;height:100%;"
      title="YouTube video ${videoId}">
    </iframe>`
    
    return `<div style="padding:56.25% 0 0 0;position:relative;width:100%;height:0;">${iframe}</div>`
  }
}
