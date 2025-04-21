<template lang="pug">
.col-xxxl-2.col-xxl-3.col-xl-4.col-lg-4.col-md-6.col-xs-12
  .users-item.is-vue
    .users-item__inner.a-card
      .users-item__inactive-message-container.is-only-mentor(
        v-if='(currentUser.mentor || currentUser.admin) && user.student_or_trainee')
        .users-item__inactive-message(v-if='user.roles.includes("retired")')
          | 退会しました
        .users-item__inactive-message(
          v-else-if='user.roles.includes("hibernationed")')
          | 休会中: {{ user.hibernated_at }}〜({{ user.hibernation_elapsed_days }}日経過)
        .users-item__inactive-message(v-else-if='!user.active')
          | 1ヶ月以上ログインがありません
      header.users-item__header
        .users-item__header-inner
          .users-item__header-start
            .users-item__icon
              a(:href='user.url')
                span(:class='["a-user-role", roleClass, joiningStatusClass]')
                  img.users-item__user-icon-image.a-user-icon(
                    :title='user.icon_title',
                    :alt='user.icon_title',
                    :src='user.avatar_url')
          .users-item__header-end
            .card-list-item__rows
              .card-list-item__row
                .card-list-item-title
                  .card-list-item-title__end
                    a.card-list-item-title__title.is-lg.a-text-link(
                      :href='user.url')
                      | {{ loginName }}
              .card-list-item__row
                .card-list-item-meta
                  .card-list-item-meta__items
                    .card-list-item-meta__item
                      .a-meta
                        | {{ user.name }}
              .card-list-item__row
                .card-list-item-meta
                  .card-list-item-meta__items
                    .card-list-item-meta__item
                      a.a-meta(
                        v-if='user.discord_profile.times_url',
                        :href='user.discord_profile.times_url')
                        .a-meta__icon
                          i.fa-brands.fa-discord
                        | {{ user.discord_profile.account_name }}
                      .a-meta(v-else)
                        .a-meta__icon
                          i.fa-brands.fa-discord
                        | {{ user.discord_profile.account_name }}
        user-sns(:user='user')
        user-activity-counts(:user='user')
      .users-item__body
        .users-item__description.a-short-text
          p(v-for='paragraph in userDescParagraphs', :key='paragraph.id')
            | {{ paragraph.text }}
        .users-item__tags
          user-tags(:user='user')
      user-practice-progress(:user='user')
      hr.a-border-tint
      footer.card-footer.users-item__footer
        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item(
              v-if='currentUser.id != user.id && currentUser.adviser && user.company && currentUser.company_id == user.company.id')
              .a-button.is-disabled.is-sm.is-block
                i.fa-solid.fa-check
                span
                  | 自社研修生
            li.card-main-actions__item(v-else-if='currentUser.id != user.id')
              following(
                :isFollowing='user.isFollowing',
                :userId='user.id',
                :isWatching='user.isWatching')
            li.card-main-actions__item.is-only-mentor(
              v-if='currentUser.admin && user.talkUrl')
              a.a-button.is-secondary.is-sm.is-block(:href='user.talkUrl')
                | 相談部屋
</template>
<script>
import Following from '../following.vue'
import UserActivityCounts from './user-activity-counts.vue'
import UserSns from './user-sns.vue'
import UserTags from './user-tags.vue'
import UserPracticeProgress from './user-practice-progress.vue'

export default {
  name: 'User',
  components: {
    following: Following,
    'user-activity-counts': UserActivityCounts,
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
      return this.user.login_name
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
    joiningStatusClass() {
      return `is-${this.user.joining_status}`
    }
  }
}
</script>
