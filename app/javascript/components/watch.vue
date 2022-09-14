<template lang="pug">
.card-list-item(:class='isWatchClassName')
  .card-list-item__inner
    .card-list-item__label
      | {{ watch.model_name_with_i18n }}
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .card-list-item-title__title
            a.card-list-item-title__link.a-text-link(:href='watch.url')
              | {{ watch.title }}
      .card-list-item__row
        .card-list-item__summary
          p {{ watch.summary }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item(v-if='watch.created_user')
              a.a-user-name(:href='userUrl')
                | {{ watch.created_user.login_name }}
            .card-list-item-meta__item
              time.a-meta(:datetime='watch.updated_at')
                | {{ createdAt }}
    .card-list-item__option(v-if='checked')
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
      if (this.watch.created_user) {
        return `/users/${this.watch.created_user.id}`
      } else {
        return null
      }
    },
    createdAt() {
      return dayjs(this.watch.created_at).format('YYYY年MM月DD日(dd) HH:mm')
    }
  }
}
</script>
