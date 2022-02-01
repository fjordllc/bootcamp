<template lang="pug">
.col-xxl-3.col-xl-4.col-lg-4.col-md-6.col-xs-12
  .users-item
    .users-item__inner.a-card
      .users-item__inactive-message.is-only-mentor(
        v-if='currentUser.mentor && user.student_or_trainee && !user.active'
      )
        | 1ヶ月以上ログインがありません
      header.users-item__header
        .users-item__header-inner
          .users-item__header-start
            .users-item__icon
              a(:href='user.url')
                img.users-item__user-icon-image.a-user-icon(
                  :title='user.icon_title',
                  :alt='user.icon_title',
                  :src='user.avatar_url',
                  :class='[roleClass, daimyoClass]'
                )
          .users-item__header-end
            .users-item__name
              a.users-item__name-link(:href='user.url')
                | {{ loginName }}
              a(
                v-if='user.company && user.company.logo_url',
                :href='user.company.url'
              )
                img.user-item__company-logo(:src='user.company.logo_url')
            ul.users-item-names
              li.users-item-names__item
                .users-item-names__ful-name
                  | {{ user.name }}
              li.users-item-names__item(v-if='user.discord_account')
                .users-item-names__chat
                  .users-item-names__chat-label
                    i.fab.fa-discord
                  a.users-item-names__chat-value(:href='user.times_url')(
                    v-if='user.times_url'
                  )
                    | {{ user.discord_account }}
                  span.users-item-names__chat-value(v-else)
                    | {{ user.discord_account }}
            user-sns(:user='user')
      .users-item__body
        .users-item__description.a-short-text
          p(v-for='paragraph in userDescParagraphs', :key='paragraph.id')
            | {{ paragraph.text }}
        .users-item__tags
          user-tags(:user='user')
      user-practice-progress(:user='user')
      footer.card-footer
        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item(v-if='currentUser.id != user.id')
              following(
                :isFollowing='user.isFollowing',
                :userId='user.id',
                :isWatching='user.isWatching'
              )
</template>
<script>
import Following from './following.vue'
import UserSns from './user-sns.vue'
import UserTags from './user-tags.vue'
import UserPracticeProgress from './user-practice-progress.vue'

export default {
  components: {
    following: Following,
    'user-sns': UserSns,
    'user-tags': UserTags,
    'user-practice-progress': UserPracticeProgress
  },
  props: {
    user: { type: Object, required: true },
    currentUser: { type: Object, required: true }
  },
  computed: {
    loginName() {
      return this.user.daimyo
        ? '★' + this.user.login_name
        : this.user.login_name
    },
    userDescParagraphs() {
      let description = this.user.description
      description =
        description.length <= 200
          ? description
          : description.substring(0, 200) + '...'
      const paragraphs = description.split(/\n|\r\n/).map((text, i) => {
        return {
          id: i,
          text: text
        }
      })
      return paragraphs
    },
    roleClass() {
      return `is-${this.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.user.daimyo }
    }
  }
}
</script>
