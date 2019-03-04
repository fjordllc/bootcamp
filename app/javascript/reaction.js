document.addEventListener('DOMContentLoaded', () => {
  const reactions = document.querySelectorAll('.js-reactions')

  if (reactions.length === 0) { return }

  const requestReaction = (url, method, callback) => {
    fetch(url, {
      method: method,
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': $.rails.csrfToken()
      }
    }).then(response => {
      return response.json()
    }).then(json => {
      callback(json)
    }).catch(error => {
      console.warn(error)
    })
  }

  const updateReaction = (element, count) => {
    let reactionCount = element.querySelector('.js-reaction-count')

    if (reactionCount) {
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
  }

  const createReaction = (reaction, kind, reactionableId) => {
    const url = `/api/reactions?reactionable_id=${reactionableId}&kind=${kind}`

    requestReaction(url, 'POST', (json) => {
      Array.from(reaction.querySelectorAll(`[data-reaction-kind="${kind}"]`), element => {
        element.classList.add('is-reacted')
        element.dataset.reactionId = json.id
        updateReaction(element, 1)
      })
    })
  }

  const destroyReaction = (reaction, kind, reactionId) => {
    const url = `/api/reactions/${reactionId}`

    requestReaction(url, 'DELETE', (json) => {
      Array.from(reaction.querySelectorAll(`[data-reaction-kind="${kind}"]`), element => {
        element.classList.remove('is-reacted')
        delete (element.dataset.reactionId)
        updateReaction(element, -1)
      })
    })
  }

  Array.from(reactions, reaction => {
    const reactionableId = reaction.dataset.reactionReactionableId

    Array.from(reaction.querySelectorAll('li'), element => {
      element.addEventListener('click', e => {
        const kind = e.currentTarget.dataset.reactionKind
        const reactionId = e.currentTarget.dataset.reactionId

        if (reactionId) { destroyReaction(reaction, kind, reactionId) } else { createReaction(reaction, kind, reactionableId) }
      })
    })
  })

  Array.from(document.querySelectorAll('.js-reaction-dropdown'), dropdown => {
    dropdown.addEventListener('click', e => {
      const reaction = e.currentTarget.querySelector('.js-reaction')
      reaction.hidden = !reaction.hidden
    })
  })
})
