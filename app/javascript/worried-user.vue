<template lang="pug">
.thread-list-item
  .thread-list-item__inner
    .thread-list-item__author
      user-icon(
        :user='worriedUser',
        link_class='a-user-name',
        threadClassSuffix='-list-item'
      )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-name
          a.a-user-name(:href='worriedUser.url')
            | {{ worriedUser.long_name }}
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
