<template lang="pug">
details.following(ref='followingDetailsRef')
  summary.following__summary
    span.a-button.is-warning.is-md.is-block(v-if='following && watching')
      i.fas.fa-check
      span
        | コメントあり
    span.a-button.is-warning.is-md.is-block(
      v-else-if='following && !watching'
    )
      i.fas.fa-check
      span
        | コメントなし
    span.a-button.is-secondary.is-md.is-block(v-else)
      | {{ buttonLabel }}
  .following__dropdown.a-dropdown
    ul.a-dropdown__items
      li.following__dropdown-item.a-dropdown__item
        button.following-option.a-dropdown__item-inner.is-active(
          v-if='following && watching'
        )
          .following-option__inner
            .following-option__label
              | コメントあり
            .following-option__desciption
              | フォローしたユーザーの日報を自動でWatch状態にします。日報投稿時の通知と日報にコメントが来た際に通知を受け取ります。
        button.following-option.a-dropdown__item-inner(
          v-else,
          @click='followOrChangeFollow(true)'
        )
          .following-option__inner
            .following-option__label
              | コメントあり
            .following-option__desciption
              | フォローしたユーザーの日報を自動でWatch状態にします。日報投稿時の通知と日報にコメントが来た際に通知を受け取ります。
      li.following__dropdown-item.a-dropdown__item
        button.following-option.a-dropdown__item-inner.is-active(
          v-if='following && !watching'
        )
          .following-option__inner
            .following-option__label
              | コメントなし
            .following-option__desciption
              | フォローしたユーザーの日報はWatch状態にしません。日報投稿時の通知だけ通知を受けとります。
        button.following-option.a-dropdown__item-inner(
          v-else,
          @click='followOrChangeFollow(false)'
        )
          .following-option__inner
            .following-option__label
              | コメントなし
            .following-option__desciption
              | フォローしたユーザーの日報はWatch状態にしません。日報投稿時の通知だけ通知を受けとります。
      li.following__dropdown-item.a-dropdown__item
        button.following-option.a-dropdown__item-inner.is-active(
          v-if='!following'
        )
          .following-option__inner
            .following-option__label
              | フォローしない
        button.following-option.a-dropdown__item-inner(
          v-else,
          @click='unfollow'
        )
          .following-option__inner
            .following-option__label
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
      if (this.following) {
        return this.watching ? 'コメントあり' : 'コメントなし'
      } else {
        return 'フォローする'
      }
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
      return 'フォロー処理に失敗しました'
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
        .finally(() => {
          this.$refs.followingDetailsRef.open = false
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
        .finally(() => {
          this.$refs.followingDetailsRef.open = false
        })
    }
  }
}
</script>
