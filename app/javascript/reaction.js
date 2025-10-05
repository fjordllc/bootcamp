import { renderAllReactions } from './reaction_render'

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
  const reactionableGid = reaction.dataset.reactionReactionableGid

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
        destroyReaction(reaction, kind, loginName, reactionId)
      } else {
        createReaction(reaction, kind, loginName, reactionableGid)
      }
    })
  })

  setupUsersList(reaction, reactionableGid)
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
    .then((response) => {
      if (response.status === 404) {
        console.warn(`Reactionable not found: ${url}`)
        return {}
      } else if (!response.ok) {
        throw new Error(`API error: ${response.status}`)
      } else {
        return response.json()
      }
    })
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

function createReaction(reaction, kind, loginName, reactionableGid) {
  const url = `/api/reactions?reactionable_gid=${reactionableGid}&kind=${kind}`

  requestReaction(url, 'POST', (json) => {
    if (!json || !json.id) {
      return
    }
    reaction
      .querySelectorAll(`[data-reaction-kind="${kind}"]`)
      .forEach((element) => {
        element.classList.add('is-reacted')
        element.dataset.reactionId = json.id
        updateReactionCount(element, 1)
        updateReactionLoginNames(element, loginName)
      })
    updateUsersToggleState(reaction)
  })
}

function destroyReaction(reaction, kind, loginName, reactionId) {
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
    updateUsersToggleState(reaction)
  })
}

function setupUsersList(reaction, reactionableGid) {
  const usersToggle = reaction.querySelector('.js-reactions-users-toggle')
  const usersList = reaction.querySelector('.js-reactions-users-list')

  if (!usersToggle || !usersList) {
    return
  }

  updateUsersToggleState(reaction)

  usersToggle.addEventListener('click', (e) => {
    if (usersToggle.classList.contains('is-disabled')) {
      return
    }
    e.stopPropagation()
    const isHidden = usersList.classList.contains('hidden')
    if (isHidden) {
      fetchAllReactions(reactionableGid, (data) => {
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

function fetchAllReactions(reactionableGid, callback) {
  const url = `/api/reactions?reactionable_gid=${reactionableGid}`
  requestReaction(url, 'GET', callback)
}

function updateUsersToggleState(reaction) {
  const usersToggle = reaction.querySelector('.js-reactions-users-toggle')

  const sum = Array.from(
    reaction.querySelectorAll('.js-reaction-count')
  ).reduce((total, element) => total + Number(element.textContent || 0), 0)
  if (sum === 0) {
    usersToggle.classList.add('is-disabled')
  } else {
    usersToggle.classList.remove('is-disabled')
  }
}
