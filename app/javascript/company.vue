<template lang="pug">
.user-group(v-if='company.users.length !== 0')
  header.user-group__header
    h2.group-company-name
      a.group-company-name__link(:href='company.users_url')
        span.group-company-name__icon
          img.group-company-name__icon-image(
            :title='company.name',
            :alt='company.name',
            :src='company.logo_url'
          )
        span.group-company-name__name
          span.group-company-name__label
            | {{ company.name }}
          span.group-company-name__label-option
            | {{ company.description }}
  .m-user-icons
    .m-user-icons__items
      .m-user-icons__item(v-for='user in company.users', :key='user.id')
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
