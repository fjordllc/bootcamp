document.addEventListener('DOMContentLoaded', () => {
  const reactions = document.querySelectorAll('.js-reactions')

  if (reactions.length === 0) {
    return
  }

  reactions.forEach((reaction) => {
    initializeReaction(reaction)
  })
})

export function initializeReaction(reaction) {
  const loginName = reaction.dataset.reactionLoginName
  const reactionableId = reaction.dataset.reactionReactionableId

  const dropdown = reaction.querySelector('.js-reaction-dropdown')
  if (dropdown) {
    dropdown.addEventListener('click', (e) => {
      const reactionEmoji = e.currentTarget.querySelector('.js-reaction')
      reactionEmoji.hidden = !reactionEmoji.hidden
    })
  }

  reaction.querySelectorAll('li').forEach((element) => {
    element.addEventListener('click', (e) => {
      const kind = e.currentTarget.dataset.reactionKind
      const reactionId = e.currentTarget.dataset.reactionId

      if (reactionId) {
        destroyReaction(reaction, kind, loginName, reactionId, reactionableId)
      } else {
        createReaction(reaction, kind, loginName, reactionableId)
      }
    })
  })

  setupUsersList(reaction, reactionableId)
}

function requestReaction(url, method, callback) {
  fetch(url, {
    method: method,
    credentials: 'same-origin',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': $.rails.csrfToken()
    }
  })
    .then((response) => response.json())
    .then((json) => callback(json))
    .catch((error) => console.warn(error))
}

function updateReactionCount(element, count) {
  const reactionCount = element.querySelector('.js-reaction-count')

  if (!reactionCount) {
    return
  }

  reactionCount.textContent = Number(reactionCount.textContent) + count
  switch (reactionCount.textContent) {
    case '0':
      element.hidden = true
      break
    case '1':
      element.hidden = false
      break
  }
}

function updateReactionLoginNames(element, loginName) {
  const reactionLoginNames = element.querySelector('.js-reaction-login-names')

  if (!reactionLoginNames) {
    return
  }

  const reactionLoginName = Array.from(reactionLoginNames.children).find(
    (li) => li.textContent === loginName
  )

  if (reactionLoginName) {
    reactionLoginNames.removeChild(reactionLoginName)
  } else {
    const li = document.createElement('li')
    li.textContent = loginName
    reactionLoginNames.appendChild(li)
  }
}

function createReaction(reaction, kind, loginName, reactionableId) {
  const url = `/api/reactions?reactionable_id=${reactionableId}&kind=${kind}`

  requestReaction(url, 'POST', (json) => {
    reaction
      .querySelectorAll(`[data-reaction-kind="${kind}"]`)
      .forEach((element) => {
        element.classList.add('is-reacted')
        element.dataset.reactionId = json.id
        updateReactionCount(element, 1)
        updateReactionLoginNames(element, loginName)
      })
    updateUsersToggleState(reaction, reactionableId)
  })
}

function destroyReaction(
  reaction,
  kind,
  loginName,
  reactionId,
  reactionableId
) {
  const url = `/api/reactions/${reactionId}`

  requestReaction(url, 'DELETE', () => {
    reaction
      .querySelectorAll(`[data-reaction-kind="${kind}"]`)
      .forEach((element) => {
        element.classList.remove('is-reacted')
        delete element.dataset.reactionId
        updateReactionCount(element, -1)
        updateReactionLoginNames(element, loginName)
      })
    updateUsersToggleState(reaction, reactionableId)
  })
}

function setupUsersList(reaction, reactionableId) {
  const usersToggle = reaction.querySelector('.js-reactions-users-toggle')
  const usersList = reaction.querySelector('.js-reactions-users-list')

  if (!usersToggle || !usersList) {
    return
  }

  updateUsersToggleState(reaction, reactionableId)

  usersToggle.addEventListener('click', (e) => {
    if (usersToggle.classList.contains('is-disabled')) {
      return
    }
    e.stopPropagation()
    const isHidden = usersList.classList.contains('hidden')
    if (isHidden) {
      fetchAllReactions(reactionableId, (data) => {
        if (Object.keys(data).length === 0) {
          return
        }
        renderAllReactions(data, usersList)
        open()
      })
    } else {
      close()
    }
  })

  document.addEventListener('click', (e) => {
    const isHidden = usersList.classList.contains('hidden')
    if (
      !isHidden &&
      !usersList.contains(e.target) &&
      !usersToggle.contains(e.target)
    ) {
      close()
    }
  })

  function open() {
    document.querySelectorAll('.js-reactions-users-list').forEach((element) => {
      if (!element.classList.contains('hidden')) {
        element.classList.add('hidden')
      }
    })
    usersList.classList.remove('hidden')
  }

  function close() {
    usersList.classList.add('hidden')
  }
}

function fetchAllReactions(reactionableId, callback) {
  const url = `/api/reactions?reactionable_id=${reactionableId}`
  requestReaction(url, 'GET', callback)
}

function renderAllReactions(data, content) {
  content.innerHTML = ''

  if (Object.keys(data).length === 0) {
    return
  }

  Object.entries(data).forEach(([_kind, { emoji, users }]) => {
    const emojiLine = document.createElement('div')
    emojiLine.classList.add('reaction-users-line')

    const emojiSpan = document.createElement('span')
    emojiSpan.classList.add('reaction-emoji')
    emojiSpan.textContent = emoji
    emojiLine.appendChild(emojiSpan)

    const reactionList = document.createElement('ul')
    reactionList.classList.add('reaction-users', 'a-user-icons__items')
    users.forEach((user) => {
      const li = document.createElement('li')
      li.classList.add('reaction-user', 'a-user-icons__item')

      if (user.id && user.login_name && user.avatar_url) {
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
        li.appendChild(link)
      }

      reactionList.appendChild(li)
    })

    emojiLine.appendChild(reactionList)
    content.appendChild(emojiLine)
  })
}

function updateUsersToggleState(reaction, reactionableId) {
  const usersToggle = reaction.querySelector('.js-reactions-users-toggle')

  fetchAllReactions(reactionableId, (data) => {
    if (Object.keys(data).length === 0) {
      usersToggle.classList.add('is-disabled')
    } else {
      usersToggle.classList.remove('is-disabled')
    }
  })
}
