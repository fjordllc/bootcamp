export function renderAllReactions(data, content) {
  content.innerHTML = ''

  if (Object.keys(data).length === 0) {
    return
  }

  Object.entries(data).forEach(([_kind, { emoji, users }]) => {
    const emojiLine = createEmojiLine(emoji, users)
    content.appendChild(emojiLine)
  })
}

function createEmojiLine(emoji, users) {
  const emojiLine = document.createElement('div')
  emojiLine.classList.add('reaction-users-line')

  const emojiSpan = document.createElement('span')
  emojiSpan.classList.add('reaction-emoji')
  emojiSpan.textContent = emoji
  emojiLine.appendChild(emojiSpan)

  const reactionList = createUsersList(users)
  emojiLine.appendChild(reactionList)

  return emojiLine
}

function createUsersList(users) {
  const usersList = document.createElement('ul')
  usersList.classList.add('reaction-users', 'a-user-icons__items')

  users.forEach((user) => {
    const li = createUserItem(user)
    if (li) {
      usersList.appendChild(li)
    }
  })

  return usersList
}

function createUserItem(user) {
  if (!user.id || !user.login_name || !user.avatar_url) {
    return null
  }
  const li = document.createElement('li')
  li.classList.add('reaction-user', 'a-user-icons__item')

  const link = createUserLink(user)
  li.appendChild(link)

  return li
}

function createUserLink(user) {
  const link = document.createElement('a')
  link.classList.add('reaction-user-link', 'a-user-icons__item-link')
  link.href = `/users/${user.id}`

  const frame = document.createElement('span')
  frame.className = user.user_icon_frame_class

  const img = document.createElement('img')
  img.classList.add(
    'reaction-user-avatar',
    'a-user-icon',
    'a-user-icons__item-icon'
  )
  img.src = user.avatar_url
  img.alt = user.login_name

  frame.appendChild(img)
  link.appendChild(frame)

  return link
}
