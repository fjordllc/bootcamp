<template lang="pug">
.thread-list-item(:class='isWatchClassName')
  .thread-list-item__inner
    .thread-list-item__label
      | {{ watch.model_name_with_i18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link.a-text-link(:href='watch.url')
              | {{ watch.title }}
      .thread-list-item__row
        .thread-list-item__summary
          p {{ watch.summary }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='userUrl')
                | {{ watch.edit_user.login_name }}
            .thread-list-item-meta__item
              time.a-meta(:datetime='watch.updated_at')
                | {{ createdAt }}
    .thread-list-item__option(v-if='checked')
      watchToggle(
        :checked='checked',
        :watchableType='watch.watchable_type',
        :watchableId='watch.watchable_id',
        :watchIndexId='watch.id',
        @update-index='$listeners["updateIndex"]'
      )
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import watchToggle from './watch-toggle.vue'
dayjs.locale(ja)
export default {
  components: {
    watchToggle: watchToggle
  },
  props: {
    watch: { type: Object, required: true },
    checked: { type: Boolean }
  },
  computed: {
    isWatchClassName() {
      return `is-${this.watch.watch_class_name}`
    },
    userUrl() {
      return `/users/${this.watch.edit_user.id}`
    },
    createdAt() {
      return dayjs(this.watch.created_at).format('YYYY年MM月DD日(dd) HH:mm')
    }
  }
}
</script>
