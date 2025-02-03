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
        destroyReaction(reaction, kind, loginName, reactionId)
      } else {
        createReaction(reaction, kind, loginName, reactionableId)
      }
    })
  })
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
  })
}
