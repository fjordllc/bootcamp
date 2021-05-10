<template lang="pug">
.thread-list-item(:class='modelName')
  .thread-list-item__inner
    .thread-list-item__label
        | {{ searchable.model_name_with_i18n }}
    header.thread-list-item__header
      .thread-list-item__title
        a.thread-list-item__title-link(:href='searchable.url')
          | {{ searchable.title }}
    .thread-list-item__body
      .thread-list-item__summury
        p {{ searchable.summury }}
      .thread-list-item-meta
        .thread-list-item-meta__user
          a.thread-header__author(v-if='searchable.model_name !== "practice" && searchable.model_name !== "page"' :href='userUrl')
            | {{ searchable.login_name }}
        time.thread-list-item-meta__updated-at(:datetime='searchable.updated_at_date_time' pubdate='pubdate')
          | {{ searchable.updated_at }}

</template>
<script>
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
    }
  }
}
</script>
