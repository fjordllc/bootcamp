<template lang="pug">
ul
  li
    button.card-main-actions__action.a-button.is-sm.is-block(
      :class='following&&watching ? "is-danger" : "is-secondary"',
      @click='followOrUnfollow(true)'
    )
      | {{ watching ? "✔︎" : "" }}
      | コメントあり
  li
    button.card-main-actions__action.a-button.is-sm.is-block(
      :class='following&&!watching ? "is-danger" : "is-secondary"',
      @click='followOrUnfollow(false)'
    )
      | {{ following&&!watching ? "✔︎" : "" }}
      | コメントなし
</template>
<script>
import 'whatwg-fetch'

export default {
  props: {
    isFollowing: { type: Boolean, required: true },
    userId: { type: Number, required: true },
    isWatching : { type: Boolean, required: true },
  },
  data() {
    return {
      following: this.isFollowing,
      watching: this.isWatching,
    }
  },
  computed: {
    buttonLabel() {
      return this.following ? 'フォローを解除' : '日報をフォロー'
    },
    url: () => {
      return function (isWatch) {
        return this.following
            ? `/api/followings/${this.userId}`
            : `/api/followings?watch=${isWatch}`
      }
    },
    verb() {
      return this.following ? 'DELETE' : 'POST'
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
    followOrUnfollow(isWatch) {
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
            this.following = !this.following
            this.watching = isWatch
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
