<template lang="pug">
.sns-links
  ul.sns-links__items.is-button-group
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.github_account',
        :href='githubUrl'
      )
        i.fab.fa-github-alt
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fab.fa-github-alt
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.twitter_account',
        :href='twitterUrl'
      )
        i.fab.fa-twitter
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fab.fa-twitter
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.facebook_url',
        :href='user.facebook_url'
      )
        i.fab.fa-facebook
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fab.fa-facebook
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.blog_url',
        :href='user.blog_url'
      )
        i.fas.fa-blog
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fas.fa-blog
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.times_url',
        :href='user.times_url'
      )
        i.far.fa-clock
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.far.fa-clock
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  },
  computed: {
    githubUrl() {
      return `https://github.com/${this.user.github_account}`
    },
    twitterUrl() {
      return `https://twitter.com/${this.user.twitter_account}`
    }
  }
}
</script>
