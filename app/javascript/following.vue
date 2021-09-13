<template lang="pug">
details
  summary
    | {{ following ? "フォロー中" : "フォローする" }}
  div
    ul
      li
        button.select-menu-item(v-if='following && watching')
          | ✔︎ コメントあり
        button.select-menu-item(v-else, @click='followOrChangeFollow(true)')
          | コメントあり
        | フォローしたユーザーの日報を自動でWatch状態にします。日報投稿時の通知と日報にコメントが来た際に通知を受け取ります。
      li
        button.select-menu-item(v-if='following && !watching')
          | ✔︎ コメントなし
        button.select-menu-item(v-else, @click='followOrChangeFollow(false)')
          | コメントなし
        | フォローしたユーザーの日報はWatch状態にしません。日報投稿時の通知だけ通知を受けとります。
      li
        button.select-menu-item(v-if='!following')
          | ✔︎ フォローしない
        button.select-menu-item(v-else, @click='unfollow')
          | フォローしない
</template>
<script>
import 'whatwg-fetch'

export default {
  props: {
    isFollowing: { type: Boolean, required: true },
    userId: { type: Number, required: true },
    isWatching: { type: Boolean, required: true }
  },
  data() {
    return {
      following: this.isFollowing,
      watching: this.isWatching
    }
  },
  computed: {
    buttonLabel() {
      return this.following ? 'フォローを解除' : '日報をフォロー'
    },
    url: () => {
      return function (isWatch) {
        return this.following
          ? `/api/followings/${this.userId}?watch=${isWatch}`
          : `/api/followings?watch=${isWatch}`
      }
    },
    verb() {
      return this.following ? 'PATCH' : 'POST'
    },
    errorMessage() {
      return this.following
        ? 'フォロー解除に失敗しました'
        : 'フォローに失敗しました'
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    followOrChangeFollow(isWatch) {
      const params = {
        id: this.userId
      }
      fetch(this.url(isWatch), {
        method: this.verb,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          if (response.ok) {
            if (!this.following) {
              this.following = true
            }
            this.watching = isWatch
          } else {
            alert(this.errorMessage)
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    unfollow() {
      const params = {
        id: this.userId
      }
      fetch(this.url(''), {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          if (response.ok) {
            this.following = false
            this.watching = false
          } else {
            alert(this.errorMessage)
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
<style scoped>
details > div {
  position: absolute;
  display: block;
  width: 300px;
  border: 1px solid rgba(27, 31, 35, 0.15);
  border-radius: 3px;
  box-shadow: 0 3px 12px rgba(27, 31, 35, 0.15);
  z-index: 100;
  background-color: #ffffff;
}

details[open] > summary:before {
  content: ' ';
  display: block;
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 50;
  background: transparent;
}

.select-menu-item {
  display: flex;
}
</style>
