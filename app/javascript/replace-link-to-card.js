import CSRF from 'csrf'

export default (textareas) => {
  replaceLinkToCard()
  Array.from(textareas).forEach((textarea) => {
    textarea.addEventListener('input', () => {
      replaceLinkToCard()
    })
  })
}

const replaceLinkToCard = () => {
  const targetLinkList = document.querySelectorAll(
    '.before-replacement-link-card'
  )

  targetLinkList.forEach((targetLink) => {
    const url = targetLink.getAttribute('href')

    if (isTweet(url)) {
      embedToTweet(targetLink, url)
    } else {
      embedToLinkCard(targetLink, url)
    }

    const parent = targetLink.parentElement
    if (parent.tagName === 'P') {
      parent.insertAdjacentElement('afterend', targetLink)
      parent.remove()
    }
  })
}

const isTweet = (url) => {
  return /^https:\/\/(twitter|x)\.com\/[a-zA-Z0-9_-]+\/status\/[a-zA-Z0-9?=&\-_]+$/.test(
    url
  )
}

const loadTwitterScript = () => {
  if (!document.querySelector('script[src="https://platform.twitter.com/widgets.js"]')) {
    const twitterScript = document.createElement('script')
    twitterScript.src = 'https://platform.twitter.com/widgets.js'
    document.body.appendChild(twitterScript)
  }
}

const embedToTweet = (targetLink, url) => {
  fetch(`/api/metadata?url=${encodeURIComponent(url)}&tweet=true`, {
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
    .then((response) => response.json())
    .then((embedTweet) => {
      targetLink.insertAdjacentHTML('afterend', embedTweet.html)
      targetLink.remove()

      loadTwitterScript()
    })
}

const embedToLinkCard = (targetLink, url) => {
  fetch(`/api/metadata?url=${encodeURIComponent(url)}`, {
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
    .then((response) => response.json())
    .then((metaData) => {
      targetLink.insertAdjacentHTML(
        'afterend',
        `
        <div class="a-link-card">
          <div class="a-link-card__title">
            <a href="${url}" target="_blank" class="a-link-card__title-link">
              <div class="a-link-card__title-text">${metaData.title || url}</div>
            </a>
          </div>
          <div class="a-link-card__description">
            <div class="a-link-card__image">
              <a href="${metaData.site_url || ''}" target="_blank" class="a-link-card__image-link">
                <img src="${metaData.image || ''}" />
              </a>
            </div>
            <p>${metaData.description || ''}</p>
          </div>
          <div class="a-link-card__site-title">
            <a href="${metaData.site_url || ''}" target="_blank" class="a-link-card__site-title-link">
              <img src="${metaData.favicon || ''}"
                alt="${metaData.title || url}ファビコン"
                class="a-link-card__favicon-image"
              />
              <div class="a-link-card__site-title-text">${metaData.site_name || ''}</div>
            </a>
          </div>
        </div>
      `
      )
      targetLink.remove()
    })
}
