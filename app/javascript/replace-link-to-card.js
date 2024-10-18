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
  })
}

const isTweet = (url) => {
  return /^https:\/\/(twitter|x)\.com\/[a-zA-Z0-9_-]+\/status\/[a-zA-Z0-9?=&\-_]+$/.test(
    url
  )
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

      // 埋め込みTweetのデザインを適用する
      const twitterScript = document.createElement('script')
      twitterScript.src = 'https://platform.twitter.com/widgets.js'
      document.body.appendChild(twitterScript)
      document.body.removeChild(twitterScript)
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
        <div class="link-card">
          <div class="link-card__title">
            <a href="${url}" target="_blank">${metaData.title || url}</a>
          </div>
          <div class="link-card__description">${
            metaData.description || ''
          }</div>
          <div class="link-card__favicon"><img src="${
            metaData.favicon || ''
          }" /></div>
          <div class="link-card__site-title">
            <a href="${metaData.site_url || ''}" target="_blank">${
          metaData.site_name || ''
        }</a>
          </div>
          <div class="link-card__image"><img src="${
            metaData.image || ''
          }" /></div>
        </div>
      `
      )
      targetLink.remove()
    })
}
