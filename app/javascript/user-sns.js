export default function userSns(user) {
  const snsAccounts = [
    {
      baseUrl: 'https://github.com/',
      url: user.github_account,
      iconClass: 'fa-brands fa-github-alt'
    },
    {
      baseUrl: 'https://twitter.com/',
      url: user.twitter_account,
      iconClass: 'fa-brands fa-x-twitter'
    },
    {
      url: user.facebook_url,
      iconClass: 'fa-brands fa-facebook-square'
    },
    {
      url: user.blog_url,
      iconClass: 'fa-solid fa-blog'
    },
    {
      url: user.discord_profile?.times_url,
      iconClass: 'fa-solid fa-clock'
    }
  ]

  const fragment = document.createDocumentFragment()

  const ul = document.createElement('ul')
  ul.className = 'sns-links__items is-button-group'

  snsAccounts.forEach((account) => {
    const li = document.createElement('li')
    li.className = 'sns-links__item'

    const isAvailable = Boolean(account.url)
    const tag = isAvailable ? 'a' : 'div'
    const statusClass = isAvailable ? 'is-secondary' : 'is-disabled'
    const url = account.baseUrl ? account.baseUrl + account.url : account.url

    const snsLink = document.createElement(tag)
    snsLink.className = `sns-links__item-link a-button is-sm ${statusClass} is-icon`
    isAvailable && (snsLink.href = url)
    const icon = document.createElement('i')
    icon.className = account.iconClass

    snsLink.appendChild(icon)
    li.appendChild(snsLink)
    ul.appendChild(li)
  })
  fragment.append(ul)

  if (user.company && user.company.logo_url) {
    const a = document.createElement('a')
    a.href = user.company.url

    const img = document.createElement('img')
    img.className = 'user-item__company-logo-image'
    img.src = user.company.logo_url
    img.alt = '会社ロゴ'

    a.appendChild(img)
    fragment.append(a)
  }

  return fragment
}
