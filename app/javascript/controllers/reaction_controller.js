import { Controller } from '@hotwired/stimulus'
import { FetchRequest } from '@rails/request.js'
import { renderAllReactions } from 'reaction_render'

export default class extends Controller {
  static targets = [
    'reactionDropdown',
    'reactionCount',
    'reactionLoginNames',
    'reactionsUsersToggle',
    'reactionsUsersList'
  ]

  static values = {
    loginName: String,
    reactionableGid: String
  }

  connect() {
    this.updateUsersToggleState()
  }

  updateUsersToggleState() {
    const totalReactionCount = this.reactionCountTargets.reduce(
      (total, element) => total + (parseInt(element.textContent, 10) || 0),
      0
    )
    this.reactionsUsersToggleTarget.classList.toggle(
      'is-disabled',
      totalReactionCount === 0
    )
  }

  toggleDropdown(e) {
    const reactionEmoji = e.currentTarget.querySelector('.js-reaction')
    reactionEmoji.hidden = !reactionEmoji.hidden
  }

  toggle(e) {
    const kind = e.currentTarget.dataset.reactionKind
    const reactionId = e.currentTarget.dataset.reactionId

    if (reactionId) {
      this.destroyReaction(this.element, kind, this.loginNameValue, reactionId)
    } else {
      this.createReaction(
        this.element,
        kind,
        this.loginNameValue,
        this.reactionableGidValue
      )
    }
  }

  toggleUsersList(e) {
    if (this.reactionsUsersToggleTarget.classList.contains('is-disabled')) {
      return
    }
    e.stopPropagation()
    const isHidden = this.reactionsUsersListTarget.classList.contains('hidden')
    if (isHidden) {
      this.fetchAllReactions(this.reactionableGidValue, (data) => {
        if (!data || Object.keys(data).length === 0) {
          return
        }
        renderAllReactions(data, this.reactionsUsersListTarget)
        this.open(this.reactionsUsersListTarget)
      })
    } else {
      this.close(this.reactionsUsersListTarget)
    }
  }

  closeUsersListIfOutside(e) {
    const isOpen = !this.reactionsUsersListTarget.classList.contains('hidden')
    const clickedOutside =
      !this.reactionsUsersListTarget.contains(e.target) &&
      !this.reactionsUsersToggleTarget?.contains(e.target)
    if (isOpen && clickedOutside) {
      this.close(this.reactionsUsersListTarget)
    }
  }

  destroyReaction(reaction, kind, loginName, reactionId) {
    const url = `/api/reactions/${reactionId}`

    this.requestReaction(url, 'DELETE', () => {
      reaction
        .querySelectorAll(`[data-reaction-kind="${kind}"]`)
        .forEach((element) => {
          element.classList.remove('is-reacted')
          delete element.dataset.reactionId
          this.updateReactionCount(element, -1)
          this.updateReactionLoginNames(element, loginName)
        })
      this.updateUsersToggleState()
    })
  }

  requestReaction(url, method, callback) {
    const request = new FetchRequest(method, url, {
      responseKind: 'json'
    })

    request
      .perform()
      .then((response) => {
        if (response.ok) {
          return response.json
        } else {
          throw new Error(`API error: ${url} (status: ${response.statusCode})`)
        }
      })
      .then((json) => callback(json))
      .catch((error) => console.warn(error))
  }

  createReaction(reaction, kind, loginName, reactionableGid) {
    const url = `/api/reactions?reactionable_gid=${reactionableGid}&kind=${kind}`

    this.requestReaction(url, 'POST', (json) => {
      if (!json || !json.id) {
        return
      }
      reaction
        .querySelectorAll(`[data-reaction-kind="${kind}"]`)
        .forEach((element) => {
          element.classList.add('is-reacted')
          element.dataset.reactionId = json.id
          this.updateReactionCount(element, 1)
          this.updateReactionLoginNames(element, loginName)
        })
      this.updateUsersToggleState()
    })
  }

  fetchAllReactions(reactionableGid, callback) {
    const url = `/api/reactions?reactionable_gid=${encodeURIComponent(
      reactionableGid
    )}`
    this.requestReaction(url, 'GET', callback)
  }

  updateReactionCount(element, count) {
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

  updateReactionLoginNames(element, loginName) {
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

  open(usersList) {
    document.querySelectorAll('.js-reactions-users-list').forEach((element) => {
      if (!element.classList.contains('hidden')) {
        element.classList.add('hidden')
      }
    })
    usersList.classList.remove('hidden')
  }

  close(usersList) {
    usersList.classList.add('hidden')
  }
}
