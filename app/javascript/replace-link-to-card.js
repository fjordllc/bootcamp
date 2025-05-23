import CSRF from 'csrf'
import { debounce } from './debounce.js'

export default (selector) => {
  const textareas = document.querySelectorAll(selector)
  if (!textareas.length) return

  replaceLinkToCard()
  const debouncedReplace = debounce(replaceLinkToCard, 300)
  textareas.forEach((textarea) => {
    textarea.addEventListener('input', debouncedReplace)
  })
}

const replaceLinkToCard = () => {
  const elements = document.querySelectorAll('.a-long-text')
  elements.forEach((element) => {
    render(element)
  })

  const targetLinkList = document.querySelectorAll(
    '.before-replacement-link-card:not(.processed)'
  )

  targetLinkList.forEach((targetLink) => {
    const url = targetLink.dataset.url
    if (!url) {
      console.error('URLが取得できませんでした:', targetLink)
      handleEmbedFailure(targetLink, url)
      return
    }

    if (isTweet(url)) {
      embedToTweet(targetLink, url).catch(() =>
        handleEmbedFailure(targetLink, url)
      )
    } else {
      embedToLinkCard(targetLink, url).catch(() =>
        handleEmbedFailure(targetLink, url)
      )
    }

    targetLink.classList.add('processed')
  })
}

const render = (element) => {
  const links = element.querySelectorAll('a')

  const matchedLinks = Array.from(links).filter((link) =>
    /^@card$/.test(link.parentElement.textContent)
  )

  matchedLinks.forEach((link) => {
    const parent = link.parentElement
    if (!(parent.tagName === 'P')) return

    const url = escapeHTML(link.href)
    if (!isValidHttpUrl(url)) return

    const div = document.createElement('div')
    div.dataset.url = url
    div.classList.add('a-link-card', 'before-replacement-link-card')

    const p = document.createElement('p')
    p.textContent = 'リンクカード適用中...'

    const i = document.createElement('i')
    i.classList.add('fa-regular', 'fa-loader', 'fa-spin')

    p.appendChild(i)
    div.appendChild(p)
    parent.replaceWith(div)
  })
}

const isValidHttpUrl = (str) => {
  try {
    const url = new URL(str)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch (_) {
    return false
  }
}
function escapeHTML(string) {
  return string
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
}

const isTweet = (url) => {
  return /^https:\/\/(twitter|x)\.com\/[a-zA-Z0-9_-]+\/status\/[a-zA-Z0-9?=&\-_]+$/.test(
    url
  )
}

const isTwitter = (url) => {
  return /^https:\/\/(twitter|x)\.com/.test(url)
}

const loadTwitterScript = () => {
  if (
    !document.querySelector(
      'script[src="https://platform.twitter.com/widgets.js"]'
    )
  ) {
    const twitterScript = document.createElement('script')
    twitterScript.src = 'https://platform.twitter.com/widgets.js'
    document.body.appendChild(twitterScript)
  }
}

const embedToTweet = async (targetLink, url) => {
  try {
    const response = await fetch(
      `/api/metadata?url=${encodeURIComponent(url)}&tweet=1`,
      {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      }
    )

    if (!response.ok) throw new Error(`Error: ${response.status}`)

    const embedTweet = await response.json()
    targetLink.insertAdjacentHTML('afterend', embedTweet.html)
    targetLink.remove()
    loadTwitterScript()
  } catch (error) {
    console.error('Tweetの埋め込みに失敗しました:', error)
    handleEmbedFailure(targetLink, url)
  }
}

const embedToLinkCard = async (targetLink, url) => {
  try {
    const response = await fetch(
      `/api/metadata?url=${encodeURIComponent(url)}`,
      {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      }
    )

    if (!response.ok) throw new Error(`Error: ${response.status}`)

    const metaData = await response.json()

    const imageSection = metaData.images
      ? `
    <div class="a-link-card__image"><a href="${
      metaData.site_url || ''
    }" target="_blank"  rel="noopener" class="a-link-card__image-link">
      <img src="${metaData.images}" alt="${
          metaData.title || 'Site Image'
        }" class="a-link-card__image-ogp" />
    </a></div>
    `
      : ''

    const descriptionSection = metaData.description
      ? `<p>${metaData.description}</p>`
      : `<p><a href="${url}" target="_blank" rel="noopener" class="a-link-card__body-url-link">${url}</a></p>`

    const faviconSection = metaData.favicon
      ? `
      <img src="${metaData.favicon}" alt="Favicon" class="a-link-card__favicon-image" />
      `
      : ''

    targetLink.insertAdjacentHTML(
      'afterend',
      `
      <div class="a-link-card">
        <div class="a-link-card__title">
          <a href="${url}" target="_blank" rel="noopener" class="a-link-card__title-link">
            <div class="a-link-card__title-text">${
              metaData.title || 'No Title'
            }</div>
          </a>
        </div>
        <div class="a-link-card__body">
          <div class="a-link-card__body-start">
            <div class="a-link-card__description">
              ${descriptionSection}
            </div>
            <div class="a-link-card__site-title">
              <a href="${
                metaData.site_url || ''
              }" target="_blank" rel="noopener" class="a-link-card__site-title-link">
                ${faviconSection}
                <div class="a-link-card__site-title-text">${
                  metaData.site_name || 'No Site Name'
                }</div>
              </a>
            </div>
          </div>
          <div class="a-link-card__body-end">
            ${imageSection}
          </div>
        </div>
      </div>
      `
    )
    targetLink.remove()
  } catch (error) {
    console.error('リンクカードの埋め込みに失敗しました:', error)
    handleEmbedFailure(targetLink, url)
  }
}

const handleEmbedFailure = (targetLink, url) => {
  targetLink.insertAdjacentHTML(
    'afterend',
    `
    <div class="a-link-card embed-error">
      <!-- リンクの変換に失敗しました。以下のリンクをご確認ください。 -->
      <div class="embed-error__inner">
        ${isTwitter(url) ? '<i class="fa-brands fa-x-twitter"></i>' : ''}
        <a href="${url}" target="_blank" rel="noopener">
          ${url}
        </a>
      </div>
    </div>
    `
  )
  targetLink.remove()
}
