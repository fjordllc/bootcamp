<template lang="pug">
ul
  li
    button(v-if='following && watching')
      | ✔︎ コメントあり
    button(v-else, @click='followOrChangeFollow(true)')
      | コメントあり
  li
    button(v-if='following && !watching')
      | ✔︎ コメントなし
    button(v-else, @click='followOrChangeFollow(false)')
      | コメントなし
  li
    button(v-if='!following')
      | ✔︎ フォローしない
    button(v-else, @click='unfollow')
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
<style scoped></style>
