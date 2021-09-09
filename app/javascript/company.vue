<template lang="pug">
.user-group
  .users-item
    .users-item__inner
      header.users-item__header
        .users-item__header-container
          .users-item__name
            a.users-item__name-link(:href='company.url')
              | {{ company.name }}
          ul.users-item-names
            li.users-item-names__item
              .users-item-names__ful-name
                | {{ company.description }}
          .users-item__icon
            a(:href='company.url')
              img.users-item__user-icon-image.a-user-icon(
                :title='company.name',
                :alt='company.name',
                :src='company.logo_url',
              )
      .users-item__body
        .users-item__description.a-short-text
          | ユーザーアイコン

</template>

<script>
export default {
  props: {
    company: { type: Object, required: true }
  }
}
</script>
