import CSRF from 'csrf'
import { debounce } from './debounce.js'

export default (textareas) => {
  replaceLinkToCard()
  const debouncedReplace = debounce(replaceLinkToCard, 300)

  Array.from(textareas).forEach((textarea) => {
    textarea.addEventListener('input', debouncedReplace)
  })
}

const replaceLinkToCard = () => {
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

    const sibling = targetLink.previousElementSibling
    if (sibling.tagName === 'P') {
      sibling.insertAdjacentElement('afterend', targetLink)
      sibling.remove()
    }

    targetLink.classList.add('processed')
  })
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

    const imageSection = metaData.image
      ? `
    <div class="a-link-card__image"><a href="${
      metaData.site_url || ''
    }" target="_blank"  rel="noopener" class="a-link-card__image-link">
      <img src="${metaData.image}" alt="${
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
        ${isTwitter ? '<i class="fa-brands fa-x-twitter"></i>' : ''}
        <a href="${url}" target="_blank" rel="noopener">
          ${url}
        </a>
      </div>
    </div>
    `
  )
  targetLink.remove()
}
