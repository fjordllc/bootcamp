export default function userSns(user) {
  const githubUrl = `https://github.com/${user.github_account}`
  const twitterUrl = `https://twitter.com/${user.twitter_account}`

  const fragment = document.createDocumentFragment()

  const ul = document.createElement('ul')
  ul.className = 'sns-links__items is-button-group'

  // GitHub
  const liGithub = document.createElement('li')
  liGithub.className = 'sns-links__item'

  if (user.github_account) {
    const a = document.createElement('a')
    a.className = 'sns-links__item-link a-button is-sm is-secondary is-icon'
    a.href = githubUrl
    a.innerHTML = '<i class="fa-brands fa-github-alt"></i>'
    liGithub.appendChild(a)
  } else {
    const div = document.createElement('div')
    div.className = 'sns-links__item-link a-button is-sm is-disabled is-icon'
    div.innerHTML = '<i class="fa-brands fa-github-alt"></i>'
    liGithub.appendChild(div)
  }
  ul.appendChild(liGithub)

  // Twitter
  const liTwitter = document.createElement('li')
  liTwitter.className = 'sns-links__item'

  if (user.twitter_account) {
    const a = document.createElement('a')
    a.className = 'sns-links__item-link a-button is-sm is-secondary is-icon'
    a.href = twitterUrl
    a.innerHTML = '<i class="fa-brands fa-x-twitter"></i>'
    liTwitter.appendChild(a)
  } else {
    const div = document.createElement('div')
    div.className = 'sns-links__item-link a-button is-sm is-disabled is-icon'
    div.innerHTML = '<i class="fa-brands fa-x-twitter"></i>'
    liTwitter.appendChild(div)
  }
  ul.appendChild(liTwitter)

  // facebook
  const liFacebook = document.createElement('li')
  liFacebook.className = 'sns-links__item'

  if (user.facebook_url) {
    const a = document.createElement('a')
    a.className = 'sns-links__item-link a-button is-sm is-secondary is-icon'
    a.href = user.facebook_url
    a.innerHTML = '<i class="fa-brands fa-facebook-square"></i>'
    liFacebook.appendChild(a)
  } else {
    const div = document.createElement('div')
    div.className = 'sns-links__item-link a-button is-sm is-disabled is-icon'
    div.innerHTML = '<i class="fa-brands fa-facebook-square"></i>'
    liFacebook.appendChild(div)
  }
  ul.appendChild(liFacebook)

  // Blog
  const liBlog = document.createElement('li')
  liBlog.className = 'sns-links__item'

  if (user.blog_url) {
    const a = document.createElement('a')
    a.className = 'sns-links__item-link a-button is-sm is-secondary is-icon'
    a.href = user.blog_url
    a.innerHTML = '<i class="fa-solid fa-blog"></i>'
    liBlog.appendChild(a)
  } else {
    const div = document.createElement('div')
    div.className = 'sns-links__item-link a-button is-sm is-disabled is-icon'
    div.innerHTML = '<i class="fa-solid fa-blog"></i>'
    liBlog.appendChild(div)
  }
  ul.appendChild(liBlog)

  // Discrod
  const liDiscord = document.createElement('li')
  liDiscord.className = 'sns-links__item'

  if (user.discord_profile.times_url) {
    const a = document.createElement('a')
    a.className = 'sns-links__item-link a-button is-sm is-secondary is-icon'
    a.href = user.discord_profile.times_url
    a.innerHTML = '<i class="fa-solid fa-clock"></i>'
    liDiscord.appendChild(a)
  } else {
    const div = document.createElement('div')
    div.className = 'sns-links__item-link a-button is-sm is-disabled is-icon'
    div.innerHTML = '<i class="fa-solid fa-clock"></i>'
    liDiscord.appendChild(div)
  }
  ul.appendChild(liDiscord)

  fragment.append(ul)

  // Company
  if (user.company && user.company.logo_url) {
    const a = document.createElement('a')
    a.href = user.company.url

    const img = document.createElement('img')
    img.className = 'user-item__company-logo-image'
    img.src = user.company.logo_url
    a.appendChild(img)
    fragment.append(a)
  }

  return fragment
}
