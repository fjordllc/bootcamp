<template lang="pug">
.thread-list-item
  .thread-list-item__inner
    .thread-list-item__author
      user-icon(
        :user='user',
        link_class='a-user-name',
        blockClassSuffix='thread-list-item'
      )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          h2.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link(
              :href='`${user.url}/talk`',
              itemprop='url'
            )
              | {{ user.name }} さんの相談部屋
</template>
<script>
import UserIcon from './user-icon'
export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    user: { type: Object, required: true }
  }
}
</script>
