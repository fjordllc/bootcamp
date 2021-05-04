<template lang="pug">
.col-xxl-3.col-xl-4.col-lg-4.col-md-6.col-xs-12
  .users-item
    .users-item__inner.a-card
      header.users-item__header
        .users-item__header-container
          .users-item__inactive-message(v-if='currentUser.mentor && user.student_or_trainee && !user.active')
            | 1ヶ月ログインがありません
          .users-item__name
            a.users-item__name-link(:href='user.url')
              | {{ loginName }}
          ul.users-item-names
            li.users-item-names__item
              .users-item-names__ful-name
                | {{ user.name }}
              a(v-if='user.company && user.company.logo_url' :href='user.company.url')
                img.user-item__company-logo(:src='user.company.logo_url')
            li.users-item-names__item(v-if='user.discord_account')
              .users-item-names__chat
                .users-item-names__chat-label
                  i.fab.fa-discord
                .users-item-names__chat-value
                  | {{ user.discord_account }}
          usersSecretAttributes()
          .users-item__icon
            userIcon()
        usersSns()
      .users-item__body
        .users-item__description.a-short-text(style='white-space:pre-wrap')
          p(v-for='paragraph in paragraphs')
          | {{ user.description | truncate(200) }}
        .users-item__tags
          usersTags()
      usersProgress()
      footer.card-footer
        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item(v-if='currentUser.id != user.id')
              .js-following
            li.card-main-actions__item(v-if='currentUser.admin')
              a.card-main-actions__action.a-button.is-sm.is-secondary.is-block(:href='user.edit_admin_user_path')
                | 管理者として変更
</template>
<script>
export default {
  filters: {
    truncate(value, length) {
      if(value.length <= length) return value
      return value.substring(0, length) + '...'
    }
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
    }
  }
}
</script>
