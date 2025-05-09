<template lang="pug">
.sns-links
  ul.sns-links__items.is-button-group
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.github_account',
        :href='githubUrl')
        i.fa-brands.fa-github-alt
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fa-brands.fa-github-alt
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.twitter_account',
        :href='twitterUrl')
        i.fa-brands.fa-x-twitter
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fa-brands.fa-x-twitter
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.facebook_url',
        :href='user.facebook_url')
        i.fa-brands.fa-facebook-square
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fa-brands.fa-facebook-square
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.blog_url',
        :href='user.blog_url')
        i.fa-solid.fa-blog
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fa-solid.fa-blog
    li.sns-links__item
      a.sns-links__item-link.a-button.is-sm.is-secondary.is-icon(
        v-if='user.discord_profile.times_url',
        :href='user.discord_profile.times_url')
        i.fa-solid.fa-clock
      .sns-links__item-link.a-button.is-sm.is-disabled.is-icon(v-else)
        i.fa-solid.fa-clock

  a(v-if='user.company && user.company.logo_url', :href='user.company.url')
    img.user-item__company-logo-image(:src='user.company.logo_url')
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
