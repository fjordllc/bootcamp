import Vue from 'vue'
import Following from 'following.vue'
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
      .then(function (response) {
        if (response.ok) {
          return response.json()
        } else {
          alert('フォロー処理に失敗しました')
        }
      })
      .then(function (data) {
        document.getElementById(`follow_${userId}`).innerHTML = data.html
      })
      .catch(function (error) {
        console.warn(error)
      })
  },

  unfollow(userId, isWatch) {
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
      .then(function (response) {
        if (response.ok) {
          return response.json()
        } else {
          alert('フォロー処理に失敗しました')
        }
      })
      .then(function (data) {
        document.getElementById(`follow_${userId}`).innerHTML = data.html
      })
      .catch(function (error) {
        console.warn(error)
      })
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const followings = document.querySelectorAll('.js-following')
  if (followings) {
    for (let i = 0; i < followings.length; i++) {
      const following = followings[i]
      const isFollowing = following.getAttribute('data-is-following')
      const userId = following.getAttribute('data-user-id')
      const isWatching = following.getAttribute('data-is-watching')

      new Vue({
        render: (h) =>
          h(Following, {
            props: {
              isFollowing: isFollowing === 'true',
              userId: Number(userId),
              isWatching: isWatching === 'true'
            }
          })
      }).$mount('.js-following')
    }
  }
})

window.usersIndex = usersIndex
