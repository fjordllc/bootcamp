<template lang="pug">
.user-group(v-if='company.users.length !== 0')
  .users-item
    .users-item__inner
      header.users-item__header
        .users-item__header-container
          .users-item__name
            a.users-item__name-link(:href='company.users_url')
              | {{ company.name }}
          ul.users-item-names
            li.users-item-names__item
              .users-item-names__ful-name
                | {{ company.description }}
          .users-item__icon
            a(:href='company.users_url')
              img.users-item__user-icon-image.a-user-icon(
                :title='company.name',
                :alt='company.name',
                :src='company.logo_url'
              )
      .users-item__body
        .users-item__description.a-short-text
          .m-user-icons
            .m-user-icons__items
              .m-user-icons__item(
                v-for='user in company.users',
                :key='user.id'
              )
                a.m-user-icons__item-link(:href='user.url')
                  img(
                    :src='user.avatar_url',
                    :title='user.icon_title',
                    :class='`m-user-icons__item-icon a-user-icon is-${user.role}`'
                  )
</template>
<script>
export default {
  props: {
    company: { type: Object, required: true }
  }
}
</script>
