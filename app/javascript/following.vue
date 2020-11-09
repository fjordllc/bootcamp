<template lang="pug">
  button.card-footer-actions__action.a-button.is-sm.is-block(:class=" following ? 'is-danger' : 'is-secondary' " @click="followOrUnfollow")
    | {{ buttonLabel }}
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['isFollowing', 'userId'],
  data () {
    return {
      following: this.isFollowing
    }
  },
  computed: {
    buttonLabel() {
      return this.following ? 'フォローを解除' : '日報をフォロー'
    },
    url () {
      return this.following ? `/api/followings/${this.userId}` : '/api/followings'
    },
    verb () {
      return this.following ? 'DELETE' : 'POST'
    },
    errorMessage () {
      return this.following ? 'フォロー解除に失敗しました' : 'フォローに失敗しました'
    }
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    followOrUnfollow () {
       const params = {
         id: this.userId
       }
       fetch(this.url, {
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
         .then(response => {
            if (response.ok) {
              this.following = !this.following
            } else {
              alert(this.errorMessage)
            }
         })
         .catch(error => {
           console.warn('Failed to parsing', error)
         })
    }
  }
}
</script>
<style scoped>
</style>
