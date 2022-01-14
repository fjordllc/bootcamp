<template lang="pug">
.thread-list-item(:class='modelName')
  .thread-list-item__inner
    .thread-list-item__label(
      v-if='["comment", "answer"].includes(searchable.model_name_original)'
    )
      | {{ searchable.model_name_with_i18n }}
      .thread-list-item__label-option
        | コメント
    .thread-list-item__label(v-else)
      | {{ searchable.model_name_with_i18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='searchable.url')
              | {{ searchable.title }}
      .thread-list-item__row
        .thread-list-item__summary
          p(v-html='summary')
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item(
              v-if='!["practice", "page", "user"].includes(searchable.model_name)'
            )
              a.a-user-name(:href='userUrl')
                | {{ searchable.login_name }}
            .thread-list-item-meta__item
              time.a-meta(:datetime='searchable.updated_at', pubdate='pubdate')
                | {{ updatedAt }}
            .thread-list-item-meta__item(
              v-if='["comment", "answer"].includes(searchable.model_name_original)'
            )
              .a-meta
                | （
                a.a-user-name(:href='contributorUserUrl')
                  | {{ searchable.contributor_login_name }} {{ searchable.model_name_with_i18n }}
                | ）
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)
export default {
  props: {
    searchable: { type: Object, required: true },
    word: { type: String, required: true }
  },
  computed: {
    modelName() {
      return `is-${this.searchable.model_name}`
    },
    modelNameOriginal() {
      return `is-${this.searchable.model_name_original}`
    },
    userUrl() {
      return `/users/${this.searchable.user_id}`
    },
    contributorUserUrl() {
      return `/users/${this.searchable.contributor_user_id}`
    },
    updatedAt() {
      return dayjs(this.searchable.updated_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    createdAtOriginal() {
      return dayjs(this.searchable.created_at_original).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    summary() {
      const word = this.word
      const wordsPattern = word
        .trim()
        .replaceAll(/[.*+?^=!:${}()|[\]/\\]/g, '\\$&')
        .replaceAll(/\s+/g, '|')
      const pattern = new RegExp(wordsPattern, 'gi')
      if (word) {
        return this.searchable.summary.replaceAll(
          pattern,
          `<strong class='matched_word'>$&</strong>`
        )
      } else {
        return this.searchable.summary
      }
    }
  }
}
</script>
