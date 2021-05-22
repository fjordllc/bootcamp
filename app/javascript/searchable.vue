<template lang="pug">
.thread-list-item(:class='modelName')
  .thread-list-item__inner
    .thread-list-item__label
      | {{ searchable.model_name_with_i18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='searchable.url')
              | {{ searchable.title }}
      .thread-list-item__row
        .thread-list-item__summury
          p {{ searchable.summury }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item(
              v-if='!["practice", "page", "user"].includes(searchable.model_name)'
            )
              a.a-user-name(:href='userUrl')
                | {{ searchable.login_name }}
            .thread-list-item-meta__item
              time.a-date(:datetime='searchable.updated_at', pubdate='pubdate')
                | {{ updatedAt }}
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)
export default {
  props: {
    searchable: { type: Object, required: true }
  },
  computed: {
    modelName() {
      return `is-${this.searchable.model_name}`
    },
    userUrl() {
      return `/users/${this.searchable.user_id}`
    },
    updatedAt() {
      return dayjs(this.searchable.updated_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    }
  }
}
</script>
