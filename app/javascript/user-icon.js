export default function userIcon({
  user,
  linkClass,
  imgClasses,
  loginName = null
}) {
  const link = document.createElement('a')
  link.href = user.url
  link.classList.add(linkClass)

  const span = document.createElement('span')
  span.classList.add('a-user-role', `is-${user.primary_role}`)
  if (user.joining_status === 'new-user') {
    span.classList.add('is-new-user')
  }

  const img = document.createElement('img')
  img.src = user.avatar_url
  img.alt = user.icon_title
  img.title = user.icon_title
  img.classList.add(...imgClasses)
  if (loginName) {
    img.setAttribute('data-login-name', loginName)
  }

  span.appendChild(img)
  link.appendChild(span)
  return link
}
