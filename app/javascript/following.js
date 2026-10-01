import 'whatwg-fetch'
import CSRF from 'csrf'

const usersIndex = {
  getUrl(userId, isFollow, isWatch) {
    return isFollow
      ? `/api/followings/${userId}?watch=${isWatch}`
      : `/api/followings?watch=${isWatch}`
  },

  getVerb(isFollow) {
    return isFollow ? 'PATCH' : 'POST'
  },

  followOrChangeFollow(userId, isFollow, isWatch) {
    const details = document.getElementById(`follow_details${userId}`)
    const options = Array.from(
      details.querySelectorAll('.following__dropdown-item button')
    )
    if (options.some((button) => button.disabled)) return
    options.forEach((button) => (button.disabled = true))
    const params = {
      id: userId
    }
    fetch(usersIndex.getUrl(userId, isFollow, isWatch), {
      method: usersIndex.getVerb(isFollow),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
      .then((response) => {
        if (response.ok) {
          const summary = details.querySelector('.following__summary span')

          if (isWatch) {
            summary.className = 'a-button is-warning is-sm is-block'
            summary.innerHTML =
              '<i class="fa-solid fa-check"></i><span>コメントあり</span>'

            options[0].className =
              'following-option a-dropdown__item-inner is-active'
            options[0].onclick = null
            options[1].className = 'following-option a-dropdown__item-inner'
            options[1].onclick = function () {
              usersIndex.followOrChangeFollow(userId, true, false)
            }
            options[2].className = 'following-option a-dropdown__item-inner'
            options[2].onclick = function () {
              usersIndex.unfollow(userId, true)
            }
          } else {
            summary.className = 'a-button is-warning is-sm is-block'
            summary.innerHTML =
              '<i class="fa-solid fa-check"></i><span>コメントなし</span>'

            options[0].className = 'following-option a-dropdown__item-inner'
            options[0].onclick = function () {
              usersIndex.followOrChangeFollow(userId, true, true)
            }
            options[1].className =
              'following-option a-dropdown__item-inner is-active'
            options[1].onclick = null
            options[2].className = 'following-option a-dropdown__item-inner'
            options[2].onclick = function () {
              usersIndex.unfollow(userId, true)
            }
          }
          details.open = false
        } else {
          alert('フォロー処理に失敗しました')
        }
      })
      .catch(function (error) {
        console.warn(error)
        alert('フォロー処理に失敗しました')
      })
      .finally(() => {
        options.forEach((button) => (button.disabled = false))
      })
  },

  unfollow(userId, isWatch) {
    const details = document.getElementById(`follow_details${userId}`)
    const options = Array.from(
      details.querySelectorAll('.following__dropdown-item button')
    )
    if (options.some((button) => button.disabled)) return
    options.forEach((button) => (button.disabled = true))
    const params = {
      id: userId
    }
    fetch(usersIndex.getUrl(userId, true, isWatch), {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
      .then((response) => {
        if (response.ok) {
          const summary = details.querySelector('.following__summary span')
          summary.className = 'a-button is-secondary is-sm is-block'
          summary.innerHTML = 'フォローする'

          options[0].className = 'following-option a-dropdown__item-inner'
          options[0].onclick = function () {
            usersIndex.followOrChangeFollow(userId, false, true)
          }
          options[1].className = 'following-option a-dropdown__item-inner'
          options[1].onclick = function () {
            usersIndex.followOrChangeFollow(userId, false, false)
          }
          options[2].className =
            'following-option a-dropdown__item-inner is-active'
          options[2].onclick = null

          details.open = false
        } else {
          alert('フォロー処理に失敗しました')
        }
      })
      .catch(function (error) {
        console.warn(error)
        alert('フォロー処理に失敗しました')
      })
      .finally(() => {
        options.forEach((button) => (button.disabled = false))
      })
  }
}

window.usersIndex = usersIndex
