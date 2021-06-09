<template lang="pug">
.thread-list-item(:class='[isWatchClassName]')
  .thread-list-item__inner
    .thread-list-item__label
      | {{watch.model_name_with_i18n}}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='watch.url')
             | {{ watch.title }}
      .thread-list-item__row
        .thread-list-item__summury
          p {{ watch.summury }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='userUrl')
                | {{ watch.edit_user.login_name }}
            .thread-list-item-meta__item
              time.a-date(:datetime='watch.updated_at')
                | {{createdAt}}
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)
export default {
  props: {
    watch: { type: Object, required: true },
  },
  computed: {
    watchUser(){
     return this.watch.user
    },
    isWatchClassName(){
     return `is-${this.watch.watch_class_name}`
    },
    userUrl() {
      return `/users/${this.watch.edit_user.id}`
    },
    createdAt() {
      return dayjs(this.watch.created_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    }
  }
}
</script>
