<template lang="pug">
tr.admin-table__item
  td.admin-table__item-value.is-text-align-center
    user-icon(
      :user='worriedUser',
      link_class='a-user-name',
      blockClassSuffix='admin-table'
    )
  td.admin-table__item-value.is-text-align-center
    a.a-user-name(:href='worriedUser.url')
      | {{ worriedUser.long_name }}
  td.admin-table__item-value.is-text-align-center
    img.admin-table__user-icon(src="/images/emotion/sad.svg")
</template>
<script>
import UserIcon from './user-icon'

export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    worriedUser: { type: Object, required: true }
  }
}
</script>
